terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }

  # -------------------------------------------------------------------------------------------------------------------
  # Terraform 1.10+ Native S3 State Backend with S3 Conditional Write State Locking (NO DynamoDB)
  # -------------------------------------------------------------------------------------------------------------------
  backend "s3" {
    bucket       = "marketplace-risk-tfstate-dev"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Marketplace-Risk-Detection"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
