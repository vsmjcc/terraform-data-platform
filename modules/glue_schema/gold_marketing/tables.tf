locals {
  tables = {

    # Dimensão device (GSC): DESKTOP, MOBILE, etc. Populada pelo job dim-device-gsc-s2g.
    dim_device_gsc = {
      description = "Dimensão de dispositivo para Google Search Console (GSC)."
      location     = "s3://${var.bucket}/domain=${var.domain}/dataset=dim_device_gsc/"

      columns = [
        { name = "id",     type = "bigint", comment = "Chave da dimensão (hash do device; -99 para NA)" },
        { name = "device", type = "string", comment = "Dispositivo normalizado (ex.: DESKTOP, MOBILE)" }
      ]
      partition_keys = []
    }

    # Dimensão query (GSC): termos de busca. Populada pelo job dim-query-gsc-s2g.
    dim_query_gsc = {
      description = "Dimensão de query de busca para Google Search Console (GSC)."
      location     = "s3://${var.bucket}/domain=${var.domain}/dataset=dim_query_gsc/"

      columns = [
        { name = "id",    type = "bigint", comment = "Chave da dimensão (hash da query; -99 para NA)" },
        { name = "query", type = "string", comment = "Termo de busca normalizado" }
      ]
      partition_keys = []
    }

    # Fato GSC: clicks/impressions por (date, device_id, query_id). Populada pelo job fact-gsc-metrics-s2g.
    fact_gsc_metrics = {
      description = "Fato de métricas GSC (clicks, impressions) por data, dispositivo e query."
      location     = "s3://${var.bucket}/domain=${var.domain}/dataset=fact_gsc_metrics/"

      columns = [
        { name = "device_id",  type = "bigint", comment = "FK para dim_device_gsc" },
        { name = "query_id",   type = "bigint", comment = "FK para dim_query_gsc" },
        { name = "clicks",     type = "bigint", comment = "Total de cliques" },
        { name = "impressions", type = "bigint", comment = "Total de impressões" }
      ]
      partition_keys = [
        { name = "date", type = "date", comment = "Data do relatório (YYYY-MM-DD)" }
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
  }
}
