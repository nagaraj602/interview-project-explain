variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Target deployment environment."
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR range for the Production VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for Production public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR ranges for Production private subnets."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR ranges for Production database subnets."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "single_nat_gateway" {
  description = "Must be false in prod to guarantee 3-AZ NAT Gateway redundancy."
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name of the EKS cluster for the production environment."
  type        = string
  default     = "prod-risk-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for production EKS cluster."
  type        = string
  default     = "1.35"
}

variable "eks_instance_types" {
  description = "EC2 instance types for the production EKS node group."
  type        = list(string)
  default     = ["m6i.xlarge"]
}

variable "eks_desired_size" {
  description = "Desired worker node count in production."
  type        = number
  default     = 3
}

variable "eks_min_size" {
  description = "Minimum worker node count in production across 3 AZs."
  type        = number
  default     = 3
}

variable "eks_max_size" {
  description = "Maximum worker node count in production for peak traffic autoscaling."
  type        = number
  default     = 15
}

variable "rds_instance_class" {
  description = "Instance class for Production RDS PostgreSQL."
  type        = string
  default     = "db.r6g.xlarge"
}

variable "rds_multi_az" {
  description = "Must be true in production for synchronous standby high availability."
  type        = bool
  default     = true
}

variable "rds_allocated_storage" {
  description = "Initial storage in GiB for Production RDS."
  type        = number
  default     = 50
}

variable "rds_max_allocated_storage" {
  description = "Max storage ceiling in GiB for Production RDS autoscaling."
  type        = number
  default     = 500
}

variable "backup_retention_period" {
  description = "Backup retention period in days (14 days required for compliance)."
  type        = number
  default     = 14
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
