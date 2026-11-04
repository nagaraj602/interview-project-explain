# State Backend Bootstrap

This directory provides the Terraform execution root to provision remote S3 backend state buckets and dedicated KMS Customer Managed Keys (CMKs) across all environments (`dev`, `staging`, `prod`) using the [`modules/s3-backend`](../../modules/s3-backend) module.

## Why This Exists (Chicken-and-Egg Resolution)

Terraform S3 backends require the S3 bucket to exist before running `terraform init` in downstream environments (`dev`, `staging`, `prod`). 

This bootstrap root executes with **local state** to provision:
1. Hardened S3 state buckets (`marketplace-risk-tfstate-{dev,staging,prod}`).
2. Dedicated KMS Customer Managed Keys with automated 30-day rotation.
3. TLS 1.2+ mandatory bucket policies, object versioning, and public access blocks.
4. Support for **Terraform 1.10+ native S3 state locking** (`use_lockfile = true`) without requiring DynamoDB.

## Deployment Workflow

```bash
cd environments/bootstrap

# 1. Initialize bootstrap (runs with local state)
terraform init

# 2. Plan state backend resources
terraform plan -out=tfplan

# 3. Apply to provision the S3 buckets and KMS keys in AWS us-east-1
terraform apply tfplan
```

Once provisioned, downstream environments (`dev`, `staging`, `prod`) can immediately initialize their remote S3 backend via `terraform init`.
