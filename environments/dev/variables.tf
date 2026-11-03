variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Target deployment environment."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR range for the Dev VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for Dev public subnets."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR ranges for Dev private subnets."
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24", "10.20.13.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR ranges for Dev database subnets."
  type        = list(string)
  default     = ["10.20.21.0/24", "10.20.22.0/24", "10.20.23.0/24"]
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway in dev to optimize cloud costs."
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster for the dev environment."
  type        = string
  default     = "dev-risk-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for dev EKS cluster."
  type        = string
  default     = "1.35"
}

variable "eks_instance_types" {
  description = "EC2 instance types for the dev EKS node group."
  type        = list(string)
  default     = ["m6i.large"]
}

variable "eks_desired_size" {
  description = "Desired worker node count in dev."
  type        = number
  default     = 2
}

variable "eks_min_size" {
  description = "Minimum worker node count in dev."
  type        = number
  default     = 1
}

variable "eks_max_size" {
  description = "Maximum worker node count in dev."
  type        = number
  default     = 4
}

variable "rds_instance_class" {
  description = "Instance class for Dev RDS PostgreSQL."
  type        = string
  default     = "db.t4g.medium"
}

variable "rds_multi_az" {
  description = "Whether dev RDS runs Multi-AZ."
  type        = bool
  default     = false
}

variable "rds_allocated_storage" {
  description = "Initial storage in GiB for Dev RDS."
  type        = number
  default     = 50
}

variable "rds_max_allocated_storage" {
  description = "Max storage ceiling in GiB for Dev RDS autoscaling."
  type        = number
  default     = 200
}

variable "backup_retention_period" {
  description = "Backup retention period in days (14 days required)."
  type        = number
  default     = 14
}
