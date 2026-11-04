variable "aws_region" {
  description = "AWS region for provisioning backend state storage."
  type        = string
  default     = "us-east-1"
}

variable "environments" {
  description = "List of environments to provision S3 backend state buckets for (nonprod, prod)."
  type        = list(string)
  default     = ["nonprod", "prod"]
}

variable "bucket_prefix" {
  description = "Prefix for the S3 state backend buckets."
  type        = string
  default     = "marketplace-risk-tfstate"
}

variable "noncurrent_version_retention_days" {
  description = "Number of days to retain noncurrent state file versions in S3 before expiration."
  type        = number
  default     = 90
}
