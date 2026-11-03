# ---------------------------------------------------------------------------------------------------------------------
# VPC Networking Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "vpc_id" {
  description = "The Dev VPC ID."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private Subnet IDs where EKS and workloads run."
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database Subnet IDs where RDS PostgreSQL runs."
  value       = module.vpc.database_subnet_ids
}

# ---------------------------------------------------------------------------------------------------------------------
# EKS Cluster Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "eks_cluster_name" {
  description = "Dev EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "Dev EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Dev EKS cluster private API Server endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes control plane version."
  value       = module.eks.cluster_version
}

output "eks_oidc_provider_arn" {
  description = "OIDC IAM provider ARN for IRSA."
  value       = module.eks.oidc_provider_arn
}

output "eks_risk_engine_irsa_role_arn" {
  description = "Dev IRSA Role ARN for Risk Detection Service."
  value       = module.eks.risk_engine_irsa_role_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS PostgreSQL Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "rds_endpoint" {
  description = "Dev RDS PostgreSQL connection endpoint."
  value       = module.rds.db_instance_endpoint
}

output "rds_address" {
  description = "Dev RDS PostgreSQL host address."
  value       = module.rds.db_instance_address
}

output "rds_master_user_secret_arn" {
  description = "Secrets Manager secret ARN containing RDS master credentials."
  value       = module.rds.master_user_secret_arn
}

output "rds_app_db_config_secret_arn" {
  description = "Secrets Manager secret ARN containing application database config."
  value       = module.rds.app_db_config_secret_arn
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM & CI/CD Security Outputs
# ---------------------------------------------------------------------------------------------------------------------
output "cicd_secret_arn" {
  description = "Secrets Manager ARN for CI/CD deployment credentials."
  value       = module.iam_secrets.secret_arn
}

output "cicd_runner_instance_profile_arn" {
  description = "IAM Instance Profile ARN for CI/CD runners."
  value       = module.iam_secrets.iam_instance_profile_arn
}
