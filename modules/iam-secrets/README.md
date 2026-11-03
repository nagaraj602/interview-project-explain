# IAM & Secrets Manager Module

This module provisions an AWS Secrets Manager secret designed to store CI/CD pipeline credentials, deployment tokens, and third-party risk verification API keys, coupled with a strictly hardened IAM Instance Profile adhering to the Principle of Least Privilege.

## Security Highlights

- **Least-Privilege Policy**:
  - Grants exclusively `secretsmanager:GetSecretValue` and `secretsmanager:DescribeSecret` on the **exact secret ARN**.
  - Grants `kms:Decrypt` and `kms:DescribeKey` on the **exact KMS Customer Managed Key ARN**.
  - No wildcard `*` actions on Secrets Manager or KMS.
- **Dedicated KMS CMK**:
  - Key rotation enabled with automated 365-day rotation.
  - Dedicated KMS Key Policy isolating secrets access from other services.
- **IAM Instance Profile**:
  - Easily attached to self-hosted CI/CD runners (e.g., GitHub Actions Runner, GitLab Runner, or Jenkins agent) operating within private subnets.
- **Drift-Safe Secrets Handling**:
  - Uses `lifecycle { ignore_changes = [secret_string] }` on the secret version, allowing external CI/CD operators to inject real credentials via AWS CLI or Secrets Manager console without Terraform overwriting them on subsequent plans.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environment` | Deployment environment name | `string` | n/a | yes |
| `secret_name_prefix` | Subpath prefix for secret name | `string` | `"cicd/deployment-credentials"` | no |
| `secret_description` | Detailed secret description | `string` | `"Marketplace Risk Platform CI/CD deployment credentials..."` | no |
| `initial_secret_values` | Sensitive map of initial placeholder values | `map(string)` | `{ DEPLOY_TOKEN = "...", ... }` | no |
| `tags` | Tags applied to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `secret_arn` | ARN of the Secrets Manager secret |
| `secret_id` | Identifier of the Secrets Manager secret |
| `secret_name` | Full friendly name of the secret |
| `kms_key_arn` | ARN of the KMS CMK |
| `iam_role_arn` | IAM Role ARN |
| `iam_instance_profile_arn` | IAM Instance Profile ARN ready for EC2 attachment |
| `iam_policy_arn` | Scoped IAM policy ARN |
