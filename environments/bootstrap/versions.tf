terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Local state is initially used for the bootstrap root to break the chicken-and-egg dependency.
  # Once the S3 bucket is created, state can optionally be migrated if desired.
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "Marketplace-Risk-Detection"
      ManagedBy = "Terraform-Bootstrap"
    }
  }
}
