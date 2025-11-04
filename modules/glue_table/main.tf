locals {
  # Partições com projection habilitada
  proj_pks = [
    for pk in var.partition_keys : pk
    if try(pk.projection.enabled, false)
  ]

  # Chaves projection.* para TODAS as PKs projetadas
  projection_keys_map = length(local.proj_pks) == 0 ? {} : merge(
    { "projection.enabled" = "true" },
    merge([
      for pk in local.proj_pks : {
        "projection.${pk.name}.type"          = pk.projection.type
        "projection.${pk.name}.format"        = try(pk.projection.format, null)
        "projection.${pk.name}.range"         = try(pk.projection.range,  null)
        "projection.${pk.name}.interval"      = try(pk.projection.interval, null)
        "projection.${pk.name}.interval.unit" = try(pk.projection.interval_unit, null)
        "projection.${pk.name}.values"        = try(pk.projection.values, null)
      }
    ]...)
  )

  # Remove chaves com null
  projection_keys = {
    for k, v in local.projection_keys_map : k => v
    if v != null
  }

  # Segmentos do template: ex.: ["dt_date=${dt_date}/","hh=${hh}/"]
  proj_segments = [
    for pk in local.proj_pks :
    "${pk.name}=${format("$${%s}", pk.name)}/"
  ]

  # storage.location.template final (ternário em UMA linha)
  storage_location_template = length(local.proj_pks) == 0 ? null : format(
    "%s/%s",
    trimsuffix(var.location, "/"),
    join("", local.proj_segments)
  )

  # Params de projection completos
  projection_params_full = length(local.proj_pks) == 0 ? {} : merge(
    local.projection_keys,
    { "storage.location.template" = local.storage_location_template }
  )

  # Parâmetros finais do Glue
  parameters_final = merge(
    var.parameters,
    { EXTERNAL = "TRUE" },
    local.projection_params_full
  )
}


resource "aws_glue_catalog_table" "this" {
  database_name = var.database_name
  name          = var.table_name
  table_type    = "EXTERNAL_TABLE"
  description   = var.description

  parameters = local.parameters_final

  storage_descriptor {
    location      = var.location
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = { "serialization.format" = "1" }
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

  dynamic "partition_keys" {
    for_each = var.partition_keys
    content {
      name    = partition_keys.value.name
      type    = partition_keys.value.type
      comment = try(partition_keys.value.comment, null)
    }
  }
}
