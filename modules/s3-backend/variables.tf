variable "bucket_name" {
  description = "The globally unique name of the S3 bucket for storing Terraform state."
  type        = string
}

variable "environment" {
  description = "Deployment environment name (e.g., dev, staging, prod)."
  type        = string
}

variable "kms_key_description" {
  description = "Description for the KMS Customer Managed Key used to encrypt Terraform state."
  type        = string
  default     = "KMS Key for Terraform State Storage"
}

variable "force_destroy" {
  description = "Whether to allow destruction of the state bucket even if it contains objects. Never set to true in production."
  type        = bool
  default     = false
}

variable "noncurrent_version_retention_days" {
  description = "Number of days to retain noncurrent state file versions in S3 before expiration."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Resource tags to be applied to all resources in this module."
  type        = map(string)
  default     = {}
}
