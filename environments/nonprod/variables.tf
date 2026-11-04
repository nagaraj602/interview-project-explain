# =====================================================================================================================
# NON-PRODUCTION ENVIRONMENT (DEV + STAGING CONSOLIDATED): VARIABLE DEFINITIONS
# Cost-optimized 2-Cluster architecture: Shared VPC & EKS cluster, isolated namespaces & databases
# =====================================================================================================================

variable "aws_region" {
  description = "AWS deployment region."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Target deployment environment."
  type        = string
  default     = "nonprod"
}

variable "vpc_cidr" {
  description = "CIDR range for the shared Non-Production VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for Non-Production public subnets across 3 AZs."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR ranges for Non-Production private subnets across 3 AZs."
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR ranges for Non-Production database subnets across 3 AZs."
  type        = list(string)
  default     = ["10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24"]
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway in nonprod to optimize cloud costs (saves ~$65/mo per eliminated NAT GW)."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the consolidated non-production EKS cluster."
  type        = string
  default     = "nonprod-risk-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for non-production EKS cluster."
  type        = string
  default     = "1.35"
}

variable "eks_instance_types" {
  description = "EC2 instance types for the consolidated non-production EKS node group."
  type        = list(string)
  default     = ["m6i.large"]
}

variable "eks_capacity_type" {
  description = "Capacity type for worker nodes (SPOT for maximum cost efficiency, or ON_DEMAND)."
  type        = string
  default     = "SPOT"
}

variable "eks_desired_size" {
  description = "Desired worker node count in nonprod (shared between dev and staging workloads)."
  type        = number
  default     = 2
}

variable "eks_min_size" {
  description = "Minimum worker node count in nonprod."
  type        = number
  default     = 1
}

variable "eks_max_size" {
  description = "Maximum worker node count in nonprod for combined dev + staging autoscaling."
  type        = number
  default     = 8
}

# RDS Dev Settings
variable "rds_dev_instance_class" {
  description = "Instance class for Dev PostgreSQL database."
  type        = string
  default     = "db.t4g.medium"
}

# RDS Staging Settings
variable "rds_staging_instance_class" {
  description = "Instance class for Staging PostgreSQL database."
  type        = string
  default     = "db.t4g.large"
}

variable "rds_staging_multi_az" {
  description = "Whether staging RDS runs Multi-AZ (false for cost savings, true for failover testing)."
  type        = bool
  default     = false
}

variable "rds_allocated_storage" {
  description = "Initial storage in GiB for nonprod RDS instances."
  type        = number
  default     = 50
}

variable "rds_max_allocated_storage" {
  description = "Max storage ceiling in GiB for nonprod RDS autoscaling."
  type        = number
  default     = 200
}

variable "backup_retention_period" {
  description = "Backup retention period in days (7 days for nonprod cost efficiency, up to 14 days)."
  type        = number
  default     = 7
}

variable "rds_engine_version" {
  description = "PostgreSQL engine version for nonprod databases."
  type        = string
  default     = "16.4"
}

variable "rds_deletion_protection" {
  description = "Enable deletion protection on RDS PostgreSQL (set to false for test teardown)."
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot on deletion (set to true for automated test teardown)."
  type        = bool
  default     = true
}
