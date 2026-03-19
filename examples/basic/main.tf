provider "aws" {
  region = "us-east-1"
}

################################################################################
# Basic DynamoDB Table (on-demand billing, SSE, PITR, TTL)
################################################################################

module "dynamodb" {
  source = "../../"

  name     = "basic-table"
  hash_key = "id"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  # Billing
  billing_mode = "PAY_PER_REQUEST"

  # Encryption
  server_side_encryption_enabled = true

  # Point-in-time recovery
  point_in_time_recovery_enabled = true

  # TTL
  ttl_enabled        = true
  ttl_attribute_name = "expires_at"

  # Protection
  deletion_protection_enabled = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Example     = "basic"
  }
}
