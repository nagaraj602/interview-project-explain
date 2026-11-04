# =====================================================================================================================
# DEV ENVIRONMENT: MARKETPLACE RISK DETECTION PLATFORM
# =====================================================================================================================

# ---------------------------------------------------------------------------------------------------------------------
# Module: VPC Networking Tier
# ---------------------------------------------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  cluster_name          = var.cluster_name
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  single_nat_gateway    = var.single_nat_gateway
  enable_flow_logs      = true

  tags = {
    Environment = var.environment
    Tier        = "networking"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Module: EKS Kubernetes Cluster (v1.35) - Private Endpoint Only
# ---------------------------------------------------------------------------------------------------------------------
module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  environment        = var.environment
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  instance_types  = var.eks_instance_types
  capacity_type   = "ON_DEMAND"
  desired_size    = var.eks_desired_size
  min_size        = var.eks_min_size
  max_size        = var.eks_max_size
  max_unavailable = 1

  tags = {
    Environment = var.environment
    Tier        = "compute"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Module: RDS PostgreSQL Database - Private Multi-AZ Ready, 14-Day Retention, Secrets Manager
# ---------------------------------------------------------------------------------------------------------------------
module "rds" {
  source = "../../modules/rds"

  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  db_subnet_group_name       = module.vpc.db_subnet_group_name
  eks_node_security_group_id = module.eks.node_security_group_id

  db_name                 = "marketplaceriskdev"
  db_username             = "risk_dev_admin"
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  max_allocated_storage   = var.rds_max_allocated_storage
  multi_az                = var.rds_multi_az
  backup_retention_period = var.backup_retention_period

  deletion_protection = var.rds_deletion_protection
  skip_final_snapshot = var.rds_skip_final_snapshot

  tags = {
    Environment = var.environment
    Tier        = "database"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Module: IAM Instance Profile & CI/CD Credentials Secret
# ---------------------------------------------------------------------------------------------------------------------
module "iam_secrets" {
  source = "../../modules/iam-secrets"

  environment        = var.environment
  secret_name_prefix = "cicd/deployment-credentials"

  tags = {
    Environment = var.environment
    Tier        = "security"
  }
}
