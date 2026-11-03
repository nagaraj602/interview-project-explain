variable "environment" {
  description = "Deployment environment name (dev, staging, prod)."
  type        = string
}

variable "vpc_cidr" {
  description = "The primary CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "EKS cluster name used for tagging subnets for ingress/load balancer discovery."
  type        = string
}

variable "availability_zones" {
  description = "List of Availability Zones to deploy subnets into. Must be 3 AZs for high availability."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "List of 3 CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of 3 CIDR blocks for the private subnets (EKS nodes/workloads)."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "database_subnet_cidrs" {
  description = "List of 3 CIDR blocks for the isolated database subnets (RDS PostgreSQL)."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "single_nat_gateway" {
  description = "If true, provision only 1 NAT Gateway for cost savings (ideal for dev/staging). If false, provision 1 per AZ (production HA)."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch for network auditing and threat detection."
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "CloudWatch log retention period in days for VPC Flow Logs."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to all VPC resources."
  type        = map(string)
  default     = {}
}
