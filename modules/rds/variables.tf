variable "environment" {
  description = "Deployment environment name (dev, staging, prod)."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS is deployed."
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group created in the private database subnets."
  type        = string
}

variable "eks_node_security_group_id" {
  description = "Security Group ID of the EKS worker nodes allowed to connect to RDS."
  type        = string
}

variable "db_name" {
  description = "Initial database name for the Marketplace Risk Platform."
  type        = string
  default     = "marketplacerisk"
}

variable "db_username" {
  description = "Master administrator username for the PostgreSQL database."
  type        = string
  default     = "risk_master_admin"
}

variable "instance_class" {
  description = "Compute instance class for the RDS instance."
  type        = string
  default     = "db.r6g.xlarge"
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16.4"
}

variable "allocated_storage" {
  description = "Initial storage allocation in GiB (gp3)."
  type        = number
  default     = 50
}

variable "max_allocated_storage" {
  description = "Maximum storage threshold in GiB for automated storage autoscaling."
  type        = number
  default     = 500
}

variable "multi_az" {
  description = "Specifies if the RDS instance is Multi-AZ with synchronous standby replication."
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days (14 days required for compliance)."
  type        = number
  default     = 14
}

variable "deletion_protection" {
  description = "Enable deletion protection against accidental database termination."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip a final snapshot before deletion (must be false in prod)."
  type        = bool
  default     = false
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed."
  type        = bool
  default     = true
}

variable "enable_blue_green_update" {
  description = "Enables native Terraform/AWS RDS Blue/Green Deployment (must be false when Secrets Manager manages master credentials)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all RDS resources."
  type        = map(string)
  default     = {}
}
