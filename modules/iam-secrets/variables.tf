variable "environment" {
  description = "Deployment environment name (dev, staging, prod)."
  type        = string
}

variable "secret_name_prefix" {
  description = "Prefix for the Secrets Manager secret holding CI/CD deployment credentials."
  type        = string
  default     = "cicd/deployment-credentials"
}

variable "secret_description" {
  description = "Description of the CI/CD credentials secret."
  type        = string
  default     = "Marketplace Risk Platform CI/CD deployment credentials, signing keys, and external API tokens"
}

variable "initial_secret_values" {
  description = "Initial key-value map stored inside the secret version."
  type        = map(string)
  sensitive   = true
  default = {
    DEPLOY_TOKEN     = "placeholder-replace-in-console"
    RISK_API_KEY     = "placeholder-replace-in-console"
    WEBHOOK_SIGN_KEY = "placeholder-replace-in-console"
  }
}

variable "tags" {
  description = "Tags to apply to all resources in this module."
  type        = map(string)
  default     = {}
}
