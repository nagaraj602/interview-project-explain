# S3 Native Backend Module (Terraform 1.10+)

This module provisions an enterprise-grade AWS S3 bucket designed specifically for **Terraform 1.10+ native S3 state locking**, completely eliminating the need for an external Amazon DynamoDB table.

## Key Features

- **Native S3 Locking**: Leverages Amazon S3 conditional writes (`PutObject` with conditional checks) introduced in Terraform 1.10 (`use_lockfile = true`).
- **KMS Customer Managed Key (CMK)**: Automated 30-day key rotation, restrictive key policy, and S3 Bucket Key enabled to minimize KMS request costs by up to 99%.
- **Versioning Enabled**: Preserves the complete audit history of all state changes with rollback capabilities.
- **CIS Benchmark Hardened**: All four `PublicAccessBlock` controls enforced, legacy ACLs disabled via `BucketOwnerEnforced`, and TLS 1.2+ strictly enforced.
- **Cost-Optimized Lifecycle**: Automatically purges noncurrent state versions older than 90 days (configurable) and cancels stale multipart uploads after 7 days.

## Terraform 1.10+ Backend Usage

```hcl
terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "marketplace-risk-tfstate-prod"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:us-east-1:123456789012:key/your-key-id"
    use_lockfile = true # Eliminates DynamoDB dependency
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `bucket_name` | Globally unique S3 bucket name | `string` | n/a | yes |
| `environment` | Deployment environment (dev, staging, prod) | `string` | n/a | yes |
| `kms_key_description` | KMS key description | `string` | `"KMS Key for Terraform State Storage"` | no |
| `force_destroy` | Allow deletion of non-empty bucket | `bool` | `false` | no |
| `noncurrent_version_retention_days` | Days to retain noncurrent versions | `number` | `90` | no |
| `tags` | Map of tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_id` | S3 state bucket identifier |
| `bucket_arn` | S3 state bucket ARN |
| `bucket_region` | AWS region of the bucket |
| `kms_key_arn` | KMS CMK ARN used for state encryption |
| `kms_key_id` | KMS CMK ID |
| `backend_config_example` | Pre-rendered HCL backend block |
