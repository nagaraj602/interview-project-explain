# =====================================================================================================================
# DUMMY SEED DATA FOR MARKETPLACE RISK DETECTION PLATFORM
# Provisions pre-upgrade sample datasets to verify data persistence across cluster and database upgrades
# =====================================================================================================================

# ---------------------------------------------------------------------------------------------------------------------
# Secrets Manager: Seed Dummy Risk Transactions & AML Screening Records
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_secretsmanager_secret" "dummy_risk_data" {
  name                    = "${var.environment}/risk-platform/seed-transactions-dataset"
  description             = "Pre-upgrade seed risk transaction records for verification testing"
  kms_key_id              = module.iam_secrets.kms_key_id
  recovery_window_in_days = 0

  tags = {
    Environment = var.environment
    Tier        = "data-seed"
    Purpose     = "Pre-Upgrade Data Verification"
  }
}

resource "aws_secretsmanager_secret_version" "dummy_risk_data" {
  secret_id = aws_secretsmanager_secret.dummy_risk_data.id
  secret_string = jsonencode({
    schema_version = "v1.0"
    created_at     = "2026-11-04T05:35:00Z"
    records_count  = 5
    transactions = [
      {
        transaction_id = "TX-89214-X"
        buyer_id       = "USR-40192"
        seller_id      = "MERCHANT-8821"
        amount_usd     = 2450.00
        currency       = "USD"
        payment_method = "credit_card"
        device_hash    = "d41d8cd98f00b204e9800998ecf8427e"
        ip_risk_score  = 0.12
        aml_flagged    = false
        fraud_verdict  = "ALLOW"
      },
      {
        transaction_id = "TX-89215-Y"
        buyer_id       = "USR-91024"
        seller_id      = "MERCHANT-1092"
        amount_usd     = 9999.99
        currency       = "USD"
        payment_method = "crypto_transfer"
        device_hash    = "79054025255fb1a26e4bc422aef54eb4"
        ip_risk_score  = 0.94
        aml_flagged    = true
        fraud_verdict  = "BLOCK_SANCTION_MATCH"
      },
      {
        transaction_id = "TX-89216-Z"
        buyer_id       = "USR-12847"
        seller_id      = "MERCHANT-4401"
        amount_usd     = 340.50
        currency       = "USD"
        payment_method = "apple_pay"
        device_hash    = "8b1a9953c4611296a827abf8c47804d7"
        ip_risk_score  = 0.45
        aml_flagged    = false
        fraud_verdict  = "STEP_UP_CHALLENGE"
      },
      {
        transaction_id = "TX-89217-A"
        buyer_id       = "USR-55821"
        seller_id      = "MERCHANT-8821"
        amount_usd     = 45.00
        currency       = "USD"
        payment_method = "debit_card"
        device_hash    = "c4ca4238a0b923820dcc509a6f75849b"
        ip_risk_score  = 0.02
        aml_flagged    = false
        fraud_verdict  = "ALLOW"
      },
      {
        transaction_id = "TX-89218-B"
        buyer_id       = "USR-77319"
        seller_id      = "MERCHANT-3390"
        amount_usd     = 4999.00
        currency       = "EUR"
        payment_method = "wire_transfer"
        device_hash    = "eccbc87e4b5ce2fe28308fd9f2a7baf3"
        ip_risk_score  = 0.81
        aml_flagged    = true
        fraud_verdict  = "MANUAL_REVIEW_REQUIRED"
      }
    ]
  })
}
