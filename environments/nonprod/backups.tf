# =====================================================================================================================
# PRE-UPGRADE DATABASE BACKUPS (NATIVE TERRAFORM SNAPSHOTS)
# Creates durable, point-in-time RDS snapshots before initiating database engine and EKS upgrades.
# =====================================================================================================================

# ---------------------------------------------------------------------------------------------------------------------
# Dev PostgreSQL Pre-Upgrade Snapshot
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_snapshot" "dev_pre_upgrade" {
  db_instance_identifier = module.rds_dev.db_instance_identifier
  db_snapshot_identifier = "dev-risk-db-pre-upgrade-snapshot"

  tags = {
    Environment = "dev"
    Purpose     = "Pre-Upgrade Full Backup"
    ManagedBy   = "Terraform"
    CreatedFor  = "Engine Upgrade"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Staging PostgreSQL Pre-Upgrade Snapshot
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_db_snapshot" "staging_pre_upgrade" {
  db_instance_identifier = module.rds_staging.db_instance_identifier
  db_snapshot_identifier = "staging-risk-db-pre-upgrade-snapshot"

  tags = {
    Environment = "staging"
    Purpose     = "Pre-Upgrade Full Backup"
    ManagedBy   = "Terraform"
    CreatedFor  = "Engine Upgrade"
  }
}

output "dev_backup_snapshot_arn" {
  description = "ARN of the Dev PostgreSQL pre-upgrade manual snapshot."
  value       = aws_db_snapshot.dev_pre_upgrade.db_snapshot_arn
}

output "staging_backup_snapshot_arn" {
  description = "ARN of the Staging PostgreSQL pre-upgrade manual snapshot."
  value       = aws_db_snapshot.staging_pre_upgrade.db_snapshot_arn
}
