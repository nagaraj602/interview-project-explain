# ---------------------------------------------------------------------------------------------------------------------
# Terraform 1.10+ Native S3 State Backend with S3 Conditional Write State Locking (NO DynamoDB)
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket       = "marketplace-risk-tfstate-prod"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
