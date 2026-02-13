locals {
  tables = {

    ga4_dim_date = {
      description = "Dimensão de datas para análises de GA4."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=ga4_dim_date/"
      columns = [
        { name = "date",     type = "date",   comment = "Data do evento" },
        { name = "day",      type = "int",    comment = "Dia do mês" },
        { name = "month",    type = "int",    comment = "Mês" },
        { name = "quarter",  type = "int",    comment = "Trimestre" },
        { name = "semester", type = "int",    comment = "Semestre" },
        { name = "year",     type = "int",    comment = "Ano" }
      ]
      partition_keys = []
    }

    ga4_dim_source_medium = {
      description = "Dimensão de canal (source e medium)."
      location    = "s3://${var.bucket}/domain=analytics/dataset=ga4_dim_source_medium/"
      columns = [
        { name = "id",     type = "bigint", comment = "Chave da dimensão source/medium" },
        { name = "source", type = "string", comment = "Fonte do tráfego" },
        { name = "medium", type = "string", comment = "Meio do tráfego" }
      ]
      partition_keys = []
    }

    ga4_dim_campaign = {
      description = "Dimensão de campanhas GA4."
      location    = "s3://${var.bucket}/domain=analytics/dataset=ga4_dim_campaign/"
      columns = [
        { name = "id",       type = "bigint", comment = "Chave da dimensão campanha" },
        { name = "campaign", type = "string", comment = "Nome da campanha" }
      ]
      partition_keys = []
    }

    ga4_fact_sessions_daily = {
        description = "Fato de sessões GA4 no grão diário por canal e campanha."
        location    = "s3://${var.bucket}/domain=${var.domain}/dataset=ga4_fact_sessions_daily/"
        columns = [
            { name = "date",             type = "date",   comment = "Data da sessão" },
            { name = "source_medium_id", type = "bigint", comment = "FK para dim_source_medium" },
            { name = "campaign_id",      type = "bigint", comment = "FK para dim_campaign" },
            { name = "sessions",         type = "bigint", comment = "Quantidade de sessões" }
        ]
        partition_keys = [
            { name = "date", type = "date" }
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
  parameters     = {
    classification  = "parquet"
    compressionType = "snappy"
  }
}
