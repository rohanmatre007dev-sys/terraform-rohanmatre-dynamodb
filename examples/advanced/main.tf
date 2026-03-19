provider "aws" {
  region = "us-east-1"
}

################################################################################
# Advanced DynamoDB Table
# Demonstrates: provisioned capacity, autoscaling, GSIs, LSIs,
#               streams, PITR, SSE with custom KMS key, TTL, global tables
################################################################################

module "dynamodb_provisioned" {
  source = "../../"

  name      = "advanced-provisioned-table"
  hash_key  = "user_id"
  range_key = "created_at"

  attributes = [
    { name = "user_id", type = "S" },
    { name = "created_at", type = "S" },
    { name = "status", type = "S" },
    { name = "email", type = "S" },
  ]

  # PROVISIONED billing required for autoscaling
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  # Global Secondary Index
  global_secondary_indexes = [
    {
      name            = "StatusIndex"
      hash_key        = "status"
      range_key       = "created_at"
      projection_type = "ALL"
      read_capacity   = 5
      write_capacity  = 5
    },
    {
      name            = "EmailIndex"
      hash_key        = "email"
      projection_type = "KEYS_ONLY"
      read_capacity   = 5
      write_capacity  = 5
    },
  ]

  # Local Secondary Index (can only be set at table creation)
  local_secondary_indexes = [
    {
      name            = "StatusLSI"
      range_key       = "status"
      projection_type = "ALL"
    },
  ]

  # Autoscaling — NOTE: toggling this recreates the table
  autoscaling_enabled = true

  autoscaling_defaults = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 70
  }

  autoscaling_read = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 70
    max_capacity       = 100
  }

  autoscaling_write = {
    scale_in_cooldown  = 50
    scale_out_cooldown = 40
    target_value       = 70
    max_capacity       = 100
  }

  autoscaling_indexes = {
    StatusIndex = {
      read_max_capacity  = 50
      read_min_capacity  = 5
      write_max_capacity = 50
      write_min_capacity = 5
    }
    EmailIndex = {
      read_max_capacity  = 30
      read_min_capacity  = 5
      write_max_capacity = 30
      write_min_capacity = 5
    }
  }

  # Encryption with custom KMS key
  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = "arn:aws:kms:us-east-1:012345678901:key/mrk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

  # Streams
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # TTL
  ttl_enabled        = true
  ttl_attribute_name = "expires_at"

  # PITR
  point_in_time_recovery_enabled        = true
  point_in_time_recovery_period_in_days = 35

  # Protection
  deletion_protection_enabled = true

  table_class = "STANDARD"

  tags = {
    Terraform   = "true"
    Environment = "prod"
    Example     = "advanced-provisioned"
  }
}

################################################################################
# Global DynamoDB Table (Multi-Region)
################################################################################

module "dynamodb_global" {
  source = "../../"

  name     = "advanced-global-table"
  hash_key = "id"

  attributes = [
    { name = "id", type = "S" }
  ]

  billing_mode = "PAY_PER_REQUEST"

  # Streams are required for global tables
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # Replicas in additional regions
  replica_regions = [
    {
      region_name            = "eu-west-1"
      point_in_time_recovery = true
      propagate_tags         = true
    },
    {
      region_name            = "ap-southeast-1"
      point_in_time_recovery = true
      propagate_tags         = true
    },
  ]

  server_side_encryption_enabled = true
  point_in_time_recovery_enabled = true
  deletion_protection_enabled    = true

  tags = {
    Terraform   = "true"
    Environment = "prod"
    Example     = "advanced-global"
  }
}
