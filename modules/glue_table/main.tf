resource "aws_glue_catalog_table" "this" {
  name          = var.table_name
  database_name = var.database_name
  description   = var.description
  table_type    = "EXTERNAL_TABLE"
  parameters    = var.parameters

  dynamic "partition_keys" {
    for_each = var.partition_keys
    content {
      name    = partition_keys.value.name
      type    = partition_keys.value.type
      comment = try(partition_keys.value.comment, null)
    }
  }

  storage_descriptor {
    location      = var.location
    input_format  = var.input_format
    output_format = var.output_format

    ser_de_info {
      name                  = "${var.table_name}_serde"
      serialization_library = var.serde_lib
    }

    dynamic "columns" {
      for_each = var.columns
      content {
        name    = columns.value.name
        type    = columns.value.type
        comment = try(columns.value.comment, null)
      }
    }
  }
}