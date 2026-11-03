output "secret_arn" {
  description = "The ARN of the CI/CD deployment credentials secret."
  value       = aws_secretsmanager_secret.cicd.arn
}

output "secret_id" {
  description = "The ID of the CI/CD deployment credentials secret."
  value       = aws_secretsmanager_secret.cicd.id
}

output "secret_name" {
  description = "The friendly name of the CI/CD credentials secret."
  value       = aws_secretsmanager_secret.cicd.name
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt the secret."
  value       = aws_kms_key.secrets.arn
}

output "kms_key_id" {
  description = "The ID of the KMS key used to encrypt the secret."
  value       = aws_kms_key.secrets.key_id
}

output "iam_role_arn" {
  description = "The ARN of the IAM role with restricted secret access."
  value       = aws_iam_role.cicd_runner.arn
}

output "iam_role_name" {
  description = "The name of the IAM role with restricted secret access."
  value       = aws_iam_role.cicd_runner.name
}

output "iam_instance_profile_arn" {
  description = "The ARN of the restricted IAM Instance Profile for CI/CD runner EC2 instances."
  value       = aws_iam_instance_profile.cicd_runner.arn
}

output "iam_instance_profile_name" {
  description = "The name of the restricted IAM Instance Profile."
  value       = aws_iam_instance_profile.cicd_runner.name
}

output "iam_policy_arn" {
  description = "The ARN of the scoped IAM policy permitting only secretsmanager:GetSecretValue."
  value       = aws_iam_policy.cicd_secret_access.arn
}
