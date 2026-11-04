output "db_instance_id" {
  description = "The RDS PostgreSQL instance identifier."
  value       = aws_db_instance.main.id
}

output "db_instance_identifier" {
  description = "The friendly RDS instance identifier used by DB snapshots."
  value       = aws_db_instance.main.identifier
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance."
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "The connection endpoint in address:port format."
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "The hostname of the RDS database instance."
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "The database connection port."
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "The database name."
  value       = aws_db_instance.main.db_name
}

output "master_user_secret_arn" {
  description = "The ARN of the AWS Secrets Manager secret automatically created by RDS containing the master password."
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}

output "app_db_config_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing database connection coordinates."
  value       = aws_secretsmanager_secret.app_db_config.arn
}

output "rds_security_group_id" {
  description = "The security group ID assigned to the RDS database."
  value       = aws_security_group.rds.id
}

output "kms_key_arn" {
  description = "The KMS Key ARN used for RDS storage and Secrets Manager encryption."
  value       = aws_kms_key.rds.arn
}
