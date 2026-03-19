################################################################################
# DynamoDB Module Wrapper
# Wraps terraform-aws-modules/dynamodb-table/aws
################################################################################

module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = ">= 4.2"

  ################################################################################
  # Table
  ################################################################################

  create_table = var.create_table
  name         = local.table_name
  region       = var.region

  hash_key  = var.hash_key
  range_key = var.range_key

  attributes = var.attributes

  billing_mode         = var.billing_mode
  read_capacity        = var.read_capacity
  write_capacity       = var.write_capacity
  on_demand_throughput = var.on_demand_throughput
  warm_throughput      = var.warm_throughput

  table_class                 = var.table_class
  deletion_protection_enabled = var.deletion_protection_enabled

  ################################################################################
  # Indexes
  ################################################################################

  global_secondary_indexes              = var.global_secondary_indexes
  local_secondary_indexes               = var.local_secondary_indexes
  ignore_changes_global_secondary_index = var.ignore_changes_global_secondary_index

  ################################################################################
  # TTL
  ################################################################################

  ttl_enabled        = var.ttl_enabled
  ttl_attribute_name = var.ttl_attribute_name

  ################################################################################
  # Point-in-Time Recovery
  ################################################################################

  point_in_time_recovery_enabled        = var.point_in_time_recovery_enabled
  point_in_time_recovery_period_in_days = var.point_in_time_recovery_period_in_days

  ################################################################################
  # Encryption
  ################################################################################

  server_side_encryption_enabled     = var.server_side_encryption_enabled
  server_side_encryption_kms_key_arn = var.server_side_encryption_kms_key_arn

  ################################################################################
  # Streams
  ################################################################################

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

  ################################################################################
  # Global Tables / Replicas
  ################################################################################

  replica_regions      = var.replica_regions
  global_table_witness = var.global_table_witness

  ################################################################################
  # Autoscaling
  ################################################################################

  autoscaling_enabled  = var.autoscaling_enabled
  autoscaling_defaults = var.autoscaling_defaults
  autoscaling_read     = var.autoscaling_read
  autoscaling_write    = var.autoscaling_write
  autoscaling_indexes  = var.autoscaling_indexes

  ################################################################################
  # Restore
  ################################################################################

  restore_source_name      = var.restore_source_name
  restore_source_table_arn = var.restore_source_table_arn
  restore_to_latest_time   = var.restore_to_latest_time
  restore_date_time        = var.restore_date_time

  ################################################################################
  # Import
  ################################################################################

  import_table = var.import_table

  ################################################################################
  # Resource Policy
  ################################################################################

  resource_policy = var.resource_policy

  ################################################################################
  # Timeouts & Tags
  ################################################################################

  timeouts = var.timeouts
  tags     = var.tags
}
