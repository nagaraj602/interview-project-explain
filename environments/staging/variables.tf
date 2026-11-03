variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Target deployment environment."
  type        = string
  default     = "staging"
}

variable "vpc_cidr" {
  description = "CIDR range for the Staging VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for Staging public subnets."
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR ranges for Staging private subnets."
  type        = list(string)
  default     = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR ranges for Staging database subnets."
  type        = list(string)
  default     = ["10.10.21.0/24", "10.10.22.0/24", "10.10.23.0/24"]
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway vs Multi-AZ NAT Gateways."
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name of the EKS cluster for the staging environment."
  type        = string
  default     = "staging-risk-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for staging EKS cluster."
  type        = string
  default     = "1.35"
}

variable "eks_instance_types" {
  description = "EC2 instance types for the staging EKS node group."
  type        = list(string)
  default     = ["m6i.xlarge"]
}

variable "eks_desired_size" {
  description = "Desired worker node count in staging."
  type        = number
  default     = 3
}

variable "eks_min_size" {
  description = "Minimum worker node count in staging."
  type        = number
  default     = 2
}

variable "eks_max_size" {
  description = "Maximum worker node count in staging."
  type        = number
  default     = 6
}

variable "rds_instance_class" {
  description = "Instance class for Staging RDS PostgreSQL."
  type        = string
  default     = "db.r6g.large"
}

variable "rds_multi_az" {
  description = "Whether staging RDS runs Multi-AZ."
  type        = bool
  default     = true
}

variable "rds_allocated_storage" {
  description = "Initial storage in GiB for Staging RDS."
  type        = number
  default     = 50
}

variable "rds_max_allocated_storage" {
  description = "Max storage ceiling in GiB for Staging RDS autoscaling."
  type        = number
  default     = 500
}

variable "backup_retention_period" {
  description = "Backup retention period in days (14 days required)."
  type        = number
  default     = 14
}
