locals {
  tables = {
    
    store_foot_traffic_hourly = {
      description = "Contagem horária de pessoas por loja (foot traffic)."
      # ajuste 'source=' se preferir outro nome; usei 'vemco' por ser comum para footfall
      location    = "s3://${var.bucket}/domain=${var.domain}/source=foot_traffic/dataset=store_foot_traffic_hourly/"
      columns = [
        { name = "location_id", type = "bigint",   comment = "ID da loja/local" },
        { name = "cnpj",        type = "string",   comment = "CNPJ da loja" },
        { name = "event_timestamp",        type = "timestamp",comment = "Timestamp (hora exata da janela)" },
        { name = "count",       type = "int",      comment = "Pessoas contadas na hora" }
      ]
      partition_keys = [
        {
          name    = "event_date"
          type    = "date"
          comment = "Partição por dia (YYYY-MM-DD)"

          projection = {
            type          = "date"
            format        = "yyyy-MM-dd"
            range         = "2020-01-01,NOW"
            interval      = "1"
            interval_unit = "DAYS"
          }
        }
      ]
    }
  }
}


module "tables" {
  source = "../../../modules/glue_table"

  for_each       = local.tables
  database_name  = var.database_name
  table_name     = each.key
  description    = each.value.description
  location       = each.value.location
  columns        = each.value.columns
  partition_keys = each.value.partition_keys

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
    # NÃO precisa passar projection.* aqui — o módulo já monta
  }
}
