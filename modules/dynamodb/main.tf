locals {
  is_provisioned = var.billing_mode == "PROVISIONED"

  required_attributes = distinct(concat(
    [
      { name = var.hash_key, type = "S" }
    ],
    var.range_key == null ? [] : [{ name = var.range_key, type = "S" }],
    var.attributes
  ))

  autoscaling_enabled = local.is_provisioned && var.autoscaling.enabled
}

resource "aws_dynamodb_table" "this" {
  name         = var.name
  billing_mode = var.billing_mode
  table_class  = var.table_class

  hash_key  = var.hash_key
  range_key = var.range_key

  dynamic "attribute" {
    for_each = local.required_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  read_capacity  = local.is_provisioned ? var.read_capacity : null
  write_capacity = local.is_provisioned ? var.write_capacity : null

  dynamic "global_secondary_index" {
    for_each = var.gsi
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = try(global_secondary_index.value.range_key, null)
      projection_type = global_secondary_index.value.projection_type

      non_key_attributes = (
        global_secondary_index.value.projection_type == "INCLUDE"
        ? try(global_secondary_index.value.non_key_attributes, [])
        : null
      )

      read_capacity  = local.is_provisioned ? try(global_secondary_index.value.read_capacity, var.read_capacity) : null
      write_capacity = local.is_provisioned ? try(global_secondary_index.value.write_capacity, var.write_capacity) : null
    }
  }

  # TTL (compatível com versões mais antigas do provider)
  dynamic "ttl" {
    for_each = var.ttl_attribute == null ? [] : [var.ttl_attribute]
    content {
      enabled        = true
      attribute_name = ttl.value
    }
  }

  point_in_time_recovery {
    enabled = var.enable_pitr
  }

  server_side_encryption {
    enabled = true
  }

  deletion_protection_enabled = var.enable_deletion_protection

  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null

  tags = merge(var.tags, { Name = var.name })
}

# Autoscaling (somente PROVISIONED)
resource "aws_appautoscaling_target" "read" {
  count              = local.autoscaling_enabled ? 1 : 0
  max_capacity       = var.autoscaling.max_read
  min_capacity       = var.autoscaling.min_read
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_target" "write" {
  count              = local.autoscaling_enabled ? 1 : 0
  max_capacity       = var.autoscaling.max_write
  min_capacity       = var.autoscaling.min_write
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read" {
  count              = local.autoscaling_enabled ? 1 : 0
  name               = "${var.name}-read-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling.target_read_pct
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
  }
}

resource "aws_appautoscaling_policy" "write" {
  count              = local.autoscaling_enabled ? 1 : 0
  name               = "${var.name}-write-target"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling.target_write_pct
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
  }
}
