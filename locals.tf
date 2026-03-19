locals {
  # Derive a safe table name: fall back to a sensible default if name is not provided
  table_name = var.name != null ? var.name : "dynamodb-table"

  # Autoscaling requires PROVISIONED billing mode — guard against misconfiguration
  effective_billing_mode = var.autoscaling_enabled ? "PROVISIONED" : var.billing_mode

  # Streams must be enabled when stream_view_type is set
  effective_stream_enabled = var.stream_view_type != null ? true : var.stream_enabled
}
