output "state_buckets" {
  description = "Summary of provisioned S3 backend buckets and KMS CMKs across all environments."
  value = {
    for env, mod in module.s3_backend : env => {
      bucket_id              = mod.bucket_id
      bucket_arn             = mod.bucket_arn
      bucket_region          = mod.bucket_region
      kms_key_arn            = mod.kms_key_arn
      kms_key_id             = mod.kms_key_id
      backend_config_example = mod.backend_config_example
    }
  }
}
