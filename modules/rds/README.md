# Multi-AZ RDS PostgreSQL Module

This module provisions an enterprise-grade, Multi-AZ PostgreSQL instance deployed strictly in private database subnets with automated storage autoscaling, CloudWatch Enhanced Monitoring, and native AWS Secrets Manager credential management.

## Key Features

- **Multi-AZ High Availability**: Synchronous physical replication across Availability Zones with automatic failover (typically completes within 60–120 seconds).
- **Zero Public Exposure**: `publicly_accessible = false` ensures zero internet-facing attack surface.
- **Strict Security Group Ingress**: Ingress port 5432 is restricted exclusively to the EKS worker node security group.
- **Storage Autoscaling**: Starts at 50 GiB (`gp3`) and dynamically scales up to 500 GiB based on free storage thresholds, preventing transaction stalls during traffic surges.
- **14-Day Automated Backup Retention**: Meets strict regulatory and forensic requirements with point-in-time recovery (PITR) enabled.
- **Native Secrets Manager Integration**: RDS natively manages master database credentials via AWS Secrets Manager with KMS Customer Managed Key encryption, eliminating hardcoded passwords and state-file exposure.
- **Parameter Hardening**: Enforces SSL connections (`rds.force_ssl = 1`) and logs long-running queries (>1000ms), lock waits, and connection events.
- **Observability**: CloudWatch Enhanced Monitoring (60s granularity) and Performance Insights (7-day retention) enabled out-of-the-box.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `environment` | Deployment environment name | `string` | n/a | yes |
| `vpc_id` | ID of the VPC | `string` | n/a | yes |
| `db_subnet_group_name` | Name of DB subnet group | `string` | n/a | yes |
| `eks_node_security_group_id`| Security group of EKS nodes | `string` | n/a | yes |
| `db_name` | Database name | `string` | `"marketplacerisk"` | no |
| `db_username` | Master username | `string` | `"risk_master_admin"` | no |
| `instance_class` | RDS compute class | `string` | `"db.r6g.xlarge"` | no |
| `engine_version` | PostgreSQL version | `string` | `"16.4"` | no |
| `allocated_storage` | Baseline storage in GiB | `number` | `50` | no |
| `max_allocated_storage` | Autoscaling ceiling in GiB | `number` | `500` | no |
| `multi_az` | Deploy synchronous standby | `bool` | `true` | no |
| `backup_retention_period` | Backup retention days | `number` | `14` | no |
| `deletion_protection` | Prevent accidental deletion | `bool` | `true` | no |
| `skip_final_snapshot` | Skip snapshot before destroy | `bool` | `false` | no |
| `tags` | Tags applied to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `db_instance_id` | RDS database instance ID |
| `db_instance_arn` | RDS database ARN |
| `db_instance_endpoint` | PostgreSQL connection endpoint (`host:port`) |
| `db_instance_address` | Hostname of the primary database |
| `db_instance_port` | Database listener port (5432) |
| `master_user_secret_arn` | Secrets Manager secret ARN for master credentials |
| `app_db_config_secret_arn`| Secrets Manager secret ARN for application coordinates |
| `rds_security_group_id` | Security group ID attached to the RDS instance |
