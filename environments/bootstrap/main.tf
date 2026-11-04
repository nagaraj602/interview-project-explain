# =====================================================================================================================
# BOOTSTRAP TIER: TERRAFORM REMOTE STATE BACKENDS (S3 + KMS NATIVE LOCKING)
# =====================================================================================================================

module "s3_backend" {
  for_each = toset(var.environments)
  source   = "../../modules/s3-backend"

  bucket_name                       = "${var.bucket_prefix}-${each.key}"
  environment                       = each.key
  kms_key_description               = "KMS Key for Terraform State Storage (${each.key})"
  force_destroy                     = true
  noncurrent_version_retention_days = var.noncurrent_version_retention_days

  tags = {
    Project     = "Marketplace-Risk-Detection"
    Environment = each.key
    ManagedBy   = "Terraform-Bootstrap"
    Tier        = "backend-state"
  }
}
