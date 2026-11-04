# =====================================================================================================================
# NON-PRODUCTION ENVIRONMENT (DEV + STAGING CONSOLIDATED): OUTPUTS
# =====================================================================================================================

# ---------------------------------------------------------------------------------------------------------------------
# VPC & Networking Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the shared Non-Production VPC."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs across 3 AZs."
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_public_ips" {
  description = "Public Elastic IP assigned to the shared Nonprod NAT Gateway."
  value       = module.vpc.nat_gateway_public_ips
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS Cluster Outputs (Consolidated Cluster)
# ---------------------------------------------------------------------------------------------------------------------
output "eks_cluster_name" {
  description = "Name of the consolidated non-production EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "ARN of the non-production EKS cluster."
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Private API server endpoint of the non-production EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version running on the non-production EKS cluster."
  value       = module.eks.cluster_version
}

output "eks_oidc_provider_arn" {
  description = "IAM OIDC Provider ARN for IRSA on the non-production cluster."
  value       = module.eks.oidc_provider_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# Database Outputs: Dev & Staging PostgreSQL
# ---------------------------------------------------------------------------------------------------------------------
output "rds_dev_address" {
  description = "Private DNS address of the Dev RDS instance."
  value       = module.rds_dev.db_instance_address
}

output "rds_dev_endpoint" {
  description = "Connection endpoint of the Dev RDS instance."
  value       = module.rds_dev.db_instance_endpoint
}

output "rds_dev_config_secret_arn" {
  description = "Secrets Manager secret ARN containing Dev database connection details."
  value       = module.rds_dev.app_db_config_secret_arn
}

output "rds_staging_address" {
  description = "Private DNS address of the Staging RDS instance."
  value       = module.rds_staging.db_instance_address
}

output "rds_staging_endpoint" {
  description = "Connection endpoint of the Staging RDS instance."
  value       = module.rds_staging.db_instance_endpoint
}

output "rds_staging_config_secret_arn" {
  description = "Secrets Manager secret ARN containing Staging database connection details."
  value       = module.rds_staging.app_db_config_secret_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# CI/CD Security Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "cicd_secret_arn" {
  description = "Secrets Manager secret ARN holding nonprod deployment credentials."
  value       = module.iam_secrets.secret_arn
}

output "cicd_runner_instance_profile_arn" {
  description = "IAM instance profile ARN for CI/CD runners."
  value       = module.iam_secrets.iam_instance_profile_arn
}
