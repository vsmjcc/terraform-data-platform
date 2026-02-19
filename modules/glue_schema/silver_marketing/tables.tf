locals {
  tables = {
    cdp_profiles = {
      description = "Perfis de clientes oriundos de CDP (flattened), particionados por created_at_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=cdp/dataset=cdp_profiles/"

      columns = [
        # Principais
        { name = "type",             type = "string",    comment = "Tipo do objeto (ex: profile)" },
        { name = "id",               type = "string",    comment = "ID único do perfil" },

        # Atributos diretos
        { name = "email",            type = "string",    comment = "Email do cliente" },
        { name = "phone_number",     type = "string",    comment = "Telefone" },
        { name = "external_id",      type = "string",    comment = "ID externo" },
        { name = "anonymous_id",     type = "string",    comment = "ID anônimo" },
        { name = "first_name",       type = "string",    comment = "Primeiro nome" },
        { name = "last_name",        type = "string",    comment = "Sobrenome" },
        { name = "organization",     type = "string",    comment = "Organização" },
        { name = "locale",           type = "string",    comment = "Localidade (pt-BR, en-US, etc.)" },
        { name = "title",            type = "string",    comment = "Título/cargo" },
        { name = "image",            type = "string",    comment = "URL da imagem do perfil" },
        { name = "created_at",       type = "timestamp", comment = "Data de criação do perfil" },
        { name = "updated_at",       type = "timestamp", comment = "Data da última atualização" },
        { name = "last_event_date",  type = "timestamp", comment = "Data do último evento" },
        { name = "joined_group_at",  type = "timestamp", comment = "Entrada no grupo" },

        # Localização (achatado)
        { name = "location_country",   type = "string",  comment = "País" },
        { name = "location_region",    type = "string",  comment = "Região/estado" },
        { name = "location_city",      type = "string",  comment = "Cidade" },
        { name = "location_zip",       type = "string",  comment = "CEP" },
        { name = "location_latitude",  type = "double",  comment = "Latitude" },
        { name = "location_longitude", type = "double",  comment = "Longitude" },
        { name = "location_timezone",  type = "string",  comment = "Fuso horário" },

        # Propriedades personalizadas
        { name = "accepts_marketing", type = "boolean",         comment = "Aceita marketing" },
        { name = "shopify_tags",      type = "array<string>",   comment = "Tags do Shopify" },

        # Metadado de origem
        { name = "source_system",     type = "string",          comment = "Sistema de origem (ex: Klaviyo, HubSpot)" }
      ]

      # Partição por created_at_date (projection no módulo)
      partition_keys = [
        {
          name    = "created_at_date"
          type    = "date"
          comment = "Data de criação do perfil (YYYY-MM-DD)"
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

    ads_facebook_campaign_insights_daily = {
      description = "Métricas diárias de campanhas do Facebook Ads (Insights) por campanha, particionadas por report_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=facebook_ads/dataset=insights_campaign_daily/"

      columns = [
        # Identificação e datas
        { name = "date_start",      type = "timestamp", comment = "Início do período (geralmente à 00:00 do dia)" },
        { name = "date_stop",       type = "timestamp", comment = "Fim do período (geralmente à 23:59 do dia)" },

        # Conta / campanha
        { name = "account_id",      type = "string",    comment = "ID da conta de anúncios" },
        { name = "account_name",    type = "string",    comment = "Nome da conta de anúncios" },
        { name = "campaign_id",     type = "string",    comment = "ID da campanha" },
        { name = "campaign_name",   type = "string",    comment = "Nome da campanha" },
        { name = "buying_type",     type = "string",    comment = "Tipo de compra (ex.: AUCTION)" },
        { name = "objective",       type = "string",    comment = "Objetivo da campanha" },

        # Métricas principais
        { name = "impressions",             type = "bigint",   comment = "Impressões" },
        { name = "reach",                   type = "bigint",   comment = "Alcance" },
        { name = "clicks",                  type = "bigint",   comment = "Cliques totais" },
        { name = "inline_link_clicks",      type = "bigint",   comment = "Cliques no link" },
        { name = "unique_clicks",           type = "bigint",   comment = "Cliques únicos" },
        { name = "spend",                   type = "double",   comment = "Gasto (moeda da conta)" },
        { name = "cpc",                     type = "double",   comment = "Custo por clique" },
        { name = "cpm",                     type = "double",   comment = "Custo por mil impressões" },
        { name = "ctr",                     type = "double",   comment = "Taxa de cliques (%)" },
        { name = "frequency",               type = "double",   comment = "Frequência" },

        # Quebras/ações (listas do Graph API)
        { name = "actions",                 type = "array<struct<action_type:string,value:double>>",         comment = "Ações agregadas (ex.: offsite_conversion, link_click)" },
        { name = "action_values",           type = "array<struct<action_type:string,value:double>>",         comment = "Valores associados às ações (ex.: value de compras)" },
        { name = "conversions",             type = "array<struct<action_type:string,value:double>>",         comment = "Conversões por tipo" },

        # Rankings de qualidade (quando disponíveis)
        { name = "quality_ranking",         type = "string",   comment = "Ranking de qualidade" },
        { name = "engagement_rate_ranking", type = "string",   comment = "Ranking de taxa de engajamento" },
        { name = "conversion_rate_ranking", type = "string",   comment = "Ranking de taxa de conversão" },

        # Moeda e país (se vierem do endpoint/conta)
        { name = "account_currency",        type = "string",   comment = "Moeda da conta (ex.: BRL)" },
        { name = "account_country",         type = "string",   comment = "País da conta" },

        # Metadados do pipeline
        { name = "source_system",           type = "string",   comment = "Sistema de origem (facebook_ads)" },
        { name = "ingestion_date",          type = "date",     comment = "Dia em que o dado entrou na bronze" },
        { name = "run_id",                  type = "string",   comment = "ID de execução/ingestão" }
      ]

      # Partição por report_date (projeção no módulo)
      partition_keys = [
        {
          name    = "report_date"
          type    = "date"
          comment = "Dia do relatório (YYYY-MM-DD)"
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

    # Google Search Console – métricas por query/device/site (B2S refine)
    gsc_metrics = {
      description = "Métricas do Google Search Console por query, device e site (clicks, impressions), particionadas por report_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=google_search_console/dataset=gsc_metrics/"

      columns = [
        { name = "query",          type = "string", comment = "Termo de busca (normalizado: maiúsculo, sem acentos)" },
        { name = "device",         type = "string", comment = "Dispositivo (normalizado: DESKTOP, MOBILE, etc.)" },
        { name = "clicks",         type = "bigint", comment = "Número de cliques" },
        { name = "impressions",    type = "bigint", comment = "Número de impressões" },
        { name = "site_url",       type = "string", comment = "URL do site no GSC" },
        { name = "search_type",    type = "string", comment = "Tipo de busca (ex.: WEB, IMAGE)" },
        { name = "ingestion_date", type = "date",   comment = "Dia em que o dado entrou na bronze" },
        { name = "run_id",         type = "string", comment = "ID de execução/ingestão" },
        { name = "generated_at",   type = "string", comment = "Timestamp de geração do relatório na origem" },
        { name = "dataset",        type = "string", comment = "Dataset de origem (ex.: nome do property)" },
        { name = "source",         type = "string", comment = "Fonte (ex.: google_search_console)" }
      ]

      partition_keys = [
        {
          name    = "report_date"
          type    = "date"
          comment = "Dia do relatório no GSC (YYYY-MM-DD)"
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
  }
}
