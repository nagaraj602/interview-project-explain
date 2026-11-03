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
# Dedicated KMS Customer Managed Key (CMK) for Secrets Encryption
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_kms_key" "secrets" {
  description             = "KMS Key for ${var.environment} CI/CD Secrets Manager Secret"
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
        Sid    = "AllowSecretsManagerService"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
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
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-cicd-secrets-kms"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.environment}-cicd-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# ---------------------------------------------------------------------------------------------------------------------
# Secrets Manager Secret: CI/CD Deployment Credentials
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "cicd" {
  name                    = "${var.environment}/${var.secret_name_prefix}"
  description             = var.secret_description
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 0 # In production, set to 7 or 30 for safety

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-cicd-secret"
      Environment = var.environment
      Purpose     = "CICD-Credentials"
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_secretsmanager_secret_version" "cicd" {
  secret_id     = aws_secretsmanager_secret.cicd.id
  secret_string = jsonencode(var.initial_secret_values)

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Role & Restricted Instance Profile (Least-Privilege secretsmanager:GetSecretValue)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role" "cicd_runner" {
  name = "${var.environment}-cicd-runner-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EC2AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-cicd-runner-role"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# Highly scoped IAM policy strictly restricted to GetSecretValue on the specific secret ARN and KMS Decrypt on the KMS CMK
resource "aws_iam_policy" "cicd_secret_access" {
  name        = "${var.environment}-cicd-secret-get-only"
  description = "Allows exclusively secretsmanager:GetSecretValue on the CI/CD deployment secret and KMS Decrypt"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "StrictGetSecretValueOnly"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.cicd.arn
      },
      {
        Sid    = "KmsDecryptOnly"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.secrets.arn
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-cicd-secret-policy"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

resource "aws_iam_role_policy_attachment" "cicd_secret_access" {
  role       = aws_iam_role.cicd_runner.name
  policy_arn = aws_iam_policy.cicd_secret_access.arn
}

# IAM Instance Profile exported for attachment to CI/CD EC2 runners / build agents
resource "aws_iam_instance_profile" "cicd_runner" {
  name = "${var.environment}-cicd-runner-profile"
  role = aws_iam_role.cicd_runner.name

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-cicd-runner-profile"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
