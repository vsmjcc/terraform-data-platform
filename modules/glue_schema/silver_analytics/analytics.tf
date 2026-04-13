locals {
  tables = {

    ga4_sessions_daily = {
      description = "Sessões por fonte/mídia e campanha (GA4), particionado por report_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=google_analytics/dataset=ga4_sessions/"

      columns = [
        # Dimensões GA4
        { name = "session_source_medium", type = "string", comment = "Fonte / Mídia da sessão (ex.: google / cpc)" },
        { name = "session_campaign_name", type = "string", comment = "Nome da campanha (ex.: [ED] Zerezes Institucional)" },

        # Métricas
        { name = "sessions", type = "bigint", comment = "Quantidade de sessões" },

        # Metadados do pipeline
        { name = "source_system", type = "string", comment = "Sistema de origem (ga4)" },
        { name = "ingestion_date", type = "date", comment = "Dia que o dado entrou na bronze" },
        { name = "run_id", type = "string", comment = "ID de execução/ingestão" }
      ]

      partition_keys = [
        {
          name    = "report_date"
          type    = "date"
          comment = "Dia do relatório (YYYY-MM-DD, derivado do GA4 date)"
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

    ga4_transactions_daily = {
      description = "Conversões e receita por transação (GA4), com fonte/mídia/campanha; particionado por report_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=google_analytics/dataset=ga4_transactions/"

      columns = [
        # Dimensões GA4
        { name = "transaction_id", type = "string", comment = "ID da transação (pode vir vazio em linhas agregadas)" },
        { name = "source_medium", type = "string", comment = "Fonte / Mídia atribuídas" },
        { name = "campaign_name", type = "string", comment = "Nome da campanha atribuída" },

        #taxonomia
        { name = "class1", type = "string", comment = "Class1" },
        { name = "class2", type = "string", comment = "Class2" },
        { name = "class3", type = "string", comment = "Class3" },

        # Métricas
        { name = "conversions", type = "bigint", comment = "Número de conversões atribuídas" },
        { name = "total_revenue", type = "double", comment = "Receita total atribuída (moeda da propriedade/relatório)" },

        # Metadados do pipeline
        { name = "source_system", type = "string", comment = "Sistema de origem (ga4)" },
        { name = "ingestion_date", type = "date", comment = "Dia que o dado entrou na bronze" },
        { name = "run_id", type = "string", comment = "ID de execução/ingestão" }
      ]

      partition_keys = [
        {
          name    = "report_date"
          type    = "date"
          comment = "Dia do relatório (YYYY-MM-DD, derivado do GA4 date)"
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

    ga4_ads_cost_daily = {
      description = "Custo de mídia por campanha (GA4 Ads / linked), particionado por report_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=google_analytics/dataset=ga4_cost/"

      columns = [
        # Dimensões
        { name = "campaign_name", type = "string", comment = "Nome da campanha" },

        # Métricas de custo
        { name = "advertiser_ad_cost", type = "double", comment = "Custo do anunciante" },
        { name = "advertiser_ad_cost_per_click", type = "double", comment = "CPC (custo por clique)" },
        { name = "advertiser_ad_cost_per_conv", type = "double", comment = "Custo por conversão" },

        # Metadados do pipeline
        { name = "source_system", type = "string", comment = "Sistema de origem (ga4)" },
        { name = "ingestion_date", type = "date", comment = "Dia que o dado entrou na bronze" },
        { name = "run_id", type = "string", comment = "ID de execução/ingestão" }
      ]

      partition_keys = [
        {
          name    = "report_date"
          type    = "date"
          comment = "Dia do relatório (YYYY-MM-DD, derivado do GA4 date)"
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
  environment    = var.environment
  database_name  = var.database_name
  table_name     = each.key
  description    = each.value.description
  location       = each.value.location
  columns        = each.value.columns
  partition_keys = each.value.partition_keys
  parameters     = { classification = "parquet", compressionType = "snappy" }
}

