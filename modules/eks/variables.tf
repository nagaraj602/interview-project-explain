variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (dev, staging, prod)."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy for the EKS control plane and nodes."
  type        = string
  default     = "1.35"
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster and nodes reside."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where EKS cluster ENIs and worker nodes are deployed."
  type        = list(string)
}

variable "instance_types" {
  description = "EC2 instance types for the EKS managed node group."
  type        = list(string)
  default     = ["m6i.xlarge"]
}

variable "capacity_type" {
  description = "Capacity type for the managed node group (ON_DEMAND or SPOT)."
  type        = string
  default     = "ON_DEMAND"
}

variable "desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes in the node group."
  type        = number
  default     = 3
}

variable "max_size" {
  description = "Maximum number of worker nodes in the node group."
  type        = number
  default     = 10
}

variable "max_unavailable" {
  description = "Maximum number of nodes unavailable during rolling update for zero-downtime rollouts."
  type        = number
  default     = 1
}

variable "disk_size_gb" {
  description = "Root disk size in GiB for worker node EC2 instances."
  type        = number
  default     = 100
}

variable "cluster_log_retention_days" {
  description = "Retention period in days for CloudWatch EKS control plane logs."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to all EKS resources."
  type        = map(string)
  default     = {}
}
