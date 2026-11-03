output "bucket_id" {
  description = "The ID and name of the S3 state bucket."
  value       = aws_s3_bucket.state.id
}

output "bucket_arn" {
  description = "The ARN of the S3 state bucket."
  value       = aws_s3_bucket.state.arn
}

output "bucket_region" {
  description = "The AWS region where the state bucket is located."
  value       = aws_s3_bucket.state.region
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for state envelope encryption."
  value       = aws_kms_key.state_key.arn
}

output "kms_key_id" {
  description = "The ID of the KMS key used for state envelope encryption."
  value       = aws_kms_key.state_key.key_id
}

output "backend_config_example" {
  description = "Example backend configuration snippet using Terraform 1.10+ native S3 state locking."
  value       = <<-EOT
    terraform {
      required_version = ">= 1.10.0"
      backend "s3" {
        bucket       = "${aws_s3_bucket.state.id}"
        key          = "${var.environment}/terraform.tfstate"
        region       = "${data.aws_region.current.region}"
        encrypt      = true
        kms_key_id   = "${aws_kms_key.state_key.arn}"
        use_lockfile = true # Terraform 1.10+ native S3 conditional write locking
      }
    }
  EOT
}
