terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# KMS Customer Managed Key for RDS Storage & Secrets Manager Master Password
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_kms_key" "rds" {
  description             = "KMS Key for RDS PostgreSQL & Master Credentials (${var.environment})"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowRDSServiceEncryption"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowSecretsManagerEncryption"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-rds-kms"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_kms_alias" "rds" {
  name          = "alias/${var.environment}-rds-postgres"
  target_key_id = aws_kms_key.rds.key_id
}

# ---------------------------------------------------------------------------------------------------------------------
# Security Group: PostgreSQL Database Tier
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.environment}-rds-sg"
  description = "Controls ingress access to RDS PostgreSQL strictly from EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-rds-sg"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_security_group_rule" "rds_ingress_from_eks" {
  description              = "Allow PostgreSQL port 5432 ingress solely from EKS worker nodes"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = var.eks_node_security_group_id
}

# ---------------------------------------------------------------------------------------------------------------------
# DB Parameter Group (Enforce SSL / TLS & PostgreSQL Logging)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_parameter_group" "rds" {
  name        = "${var.environment}-rds-pg16-params"
  family      = "postgres16"
  description = "Hardened parameter group for Marketplace Risk Detection PostgreSQL 16"

  parameter {
    name  = "rds.force_ssl"
    value = "1" # CIS Benchmark: Enforces in-transit TLS encryption
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_checkpoints"
    value = "1"
  }

  parameter {
    name  = "log_lock_waits"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # Log queries exceeding 1000ms
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-rds-parameter-group"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Role for RDS Enhanced Monitoring
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "RDSMonitoringAssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-rds-monitoring-role"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_attach" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS PostgreSQL Instance (Multi-AZ, Private-Only, Autoscaling Storage, Secrets Manager Managed)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_instance" "main" {
  identifier = "${var.environment}-risk-detection-db"

  engine                = "postgres"
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage # Storage autoscaling
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds.arn

  multi_az               = var.multi_az
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false # Explicitly disabling public endpoint per security architecture

  db_name  = var.db_name
  username = var.db_username

  # AWS Secrets Manager Native Integration: Automatically creates and rotates master credentials
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.rds.arn

  parameter_group_name = aws_db_parameter_group.rds.name

  # Backup & Maintenance Configuration
  backup_retention_period    = var.backup_retention_period # 14-day backup retention period
  backup_window              = "03:00-04:00"
  maintenance_window         = "Sun:04:30-Sun:05:30"
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true

  # Protection & Lifecycle
  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = "${var.environment}-risk-db-final-snapshot"
  allow_major_version_upgrade = var.allow_major_version_upgrade

  # Native Terraform RDS Blue/Green Deployment (Zero-Downtime Major Upgrades)
  blue_green_update {
    enabled = var.enable_blue_green_update
  }

  # Performance Insights & CloudWatch Enhanced Monitoring
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id       = aws_kms_key.rds.arn
  monitoring_interval                   = 60
  monitoring_role_arn                   = aws_iam_role.rds_monitoring.arn

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-risk-detection-db"
      Environment = var.environment
      Engine      = "PostgreSQL"
      ManagedBy   = "Terraform"
    }
  )

  depends_on = [aws_iam_role_policy_attachment.rds_monitoring_attach]
}

# ---------------------------------------------------------------------------------------------------------------------
# Application Secrets Manager Metadata Secret (Connection Info for Microservices)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "app_db_config" {
  name                    = "${var.environment}/risk-platform/db-config"
  description             = "PostgreSQL database host, port, database name, and master secret reference"
  kms_key_id              = aws_kms_key.rds.arn
  recovery_window_in_days = 0

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-risk-db-config"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_secretsmanager_secret_version" "app_db_config" {
  secret_id = aws_secretsmanager_secret.app_db_config.id
  secret_string = jsonencode({
    engine               = "postgres"
    host                 = aws_db_instance.main.address
    port                 = aws_db_instance.main.port
    dbname               = var.db_name
    master_secret_arn    = aws_db_instance.main.master_user_secret[0].secret_arn
    sslmode              = "require"
    connection_string_ro = "postgresql://${var.db_username}@${aws_db_instance.main.address}:${aws_db_instance.main.port}/${var.db_name}?sslmode=require"
  })
}
