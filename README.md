# terraform-rohanmatre-dynamodb

Terraform wrapper module for [terraform-aws-modules/dynamodb-table/aws](https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest).

This module exposes the full variable surface of the upstream DynamoDB module with sensible defaults, a `locals.tf` layer for derived configuration, and guard-rails for common misconfiguration (e.g. autoscaling without PROVISIONED billing, stream_view_type without stream_enabled).

---

## Usage

### Basic (on-demand)

```hcl
module "dynamodb" {
  source = "../../"

  name     = "my-table"
  hash_key = "id"

  attributes = [
    { name = "id", type = "S" }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
```

### Provisioned with Autoscaling

> **Warning:** enabling or disabling `autoscaling_enabled` causes the table to be **recreated**. See the upstream module README for the required `terraform state mv` commands.

```hcl
module "dynamodb" {
  source = "../../"

  name     = "autoscaled-table"
  hash_key = "id"

  attributes = [
    { name = "id", type = "S" }
  ]

  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  autoscaling_enabled = true

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

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}
```

### Global Table (Multi-Region)

```hcl
module "dynamodb" {
  source = "../../"

  name     = "global-table"
  hash_key = "id"

  attributes = [
    { name = "id", type = "S" }
  ]

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  replica_regions = [
    { region_name = "eu-west-1" },
    { region_name = "ap-southeast-1" },
  ]

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}
```

---

## Important Notes

- **Autoscaling toggle recreates the table.** Use `terraform state mv` to migrate state — see the upstream module README.
- **`ignore_changes_global_secondary_index` also recreates the table** if enabled after creation.
- **Autoscaling requires `billing_mode = "PROVISIONED"`** — `locals.tf` enforces this automatically when `autoscaling_enabled = true`.
- **`stream_view_type` auto-enables streams** — `locals.tf` sets `stream_enabled = true` when `stream_view_type` is provided.
- **PostgreSQL / MySQL**: this module is DynamoDB-only; for relational databases see `terraform-rohanmatre-rds`.

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.7 |
| aws | >= 6.28 |

## Inputs

See [variables.tf](./variables.tf) for the full list of inputs and their descriptions. All variables are optional.

| Variable | Default | Description |
|---|---|---|
| `name` | `null` | Table name |
| `hash_key` | `null` | Partition key attribute name |
| `billing_mode` | `PAY_PER_REQUEST` | `PAY_PER_REQUEST` or `PROVISIONED` |
| `autoscaling_enabled` | `false` | Enable App Autoscaling (recreates table on toggle) |
| `stream_enabled` | `false` | Enable DynamoDB Streams |
| `point_in_time_recovery_enabled` | `false` | Enable PITR |
| `server_side_encryption_enabled` | `false` | Enable SSE with KMS |
| `deletion_protection_enabled` | `null` | Enable table deletion protection |

## Outputs

| Output | Description |
|--------|-------------|
| `dynamodb_table_arn` | ARN of the DynamoDB table |
| `dynamodb_table_id` | ID of the DynamoDB table |
| `dynamodb_table_stream_arn` | ARN of the Table Stream |
| `dynamodb_table_stream_label` | ISO 8601 timestamp of the Table Stream |
| `dynamodb_table_replicas` | Map of Table replicas by region |
| `dynamodb_table_replica_arns` | Map of replica ARNs |
| `dynamodb_table_replica_stream_arns` | Map of replica stream ARNs |
| `dynamodb_table_replica_stream_labels` | Map of replica stream timestamps |

## License

Apache-2.0 Licensed.
