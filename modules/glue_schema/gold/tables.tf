locals {
  tables = {

    # Dimensão de produto (Omie). Populada pelo job dim-product-s2g.
    dim_product = {
      description = "Dimensão de produto Omie para análises de vendas e lançamentos."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=dim_product/"

      columns = [
        { name = "id", type = "bigint", comment = "Chave da dimensão (product_id ou hash do product_code; -99 para NA)" },
        { name = "product_id", type = "bigint", comment = "ID interno do produto no Omie" },
        { name = "product_code", type = "string", comment = "Código do produto" },
        { name = "description", type = "string", comment = "Descrição do produto" },
        { name = "created_at", type = "timestamp", comment = "Data/hora de inclusão no Omie" },
        { name = "launch_end_date", type = "date", comment = "Data de fim do período de lançamento" },
        { name = "updated_by", type = "string", comment = "Usuário da última alteração" }
      ]
      partition_keys = []

      quicksight = {
        enabled         = false
        data_source_key = "gold"
        import_mode     = "SPICE"
      }
      
    }

    # Fato detalhada de vendas por produto. Populada pelo job fact-product-sales-s2g.
    fact_product_sales = {
      description = "Fato detalhada de vendas por produto em granularidade de item vendido. Suporta conferência manual e validação do indicador de faturamento de lançamentos."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=fact_product_sales/"

      columns = [
        { name = "product_id", type = "bigint", comment = "FK para dim_product (-99 se não encontrado)" },
        { name = "source_system", type = "string", comment = "Sistema de origem da venda (shopify, omie, protheus)" },
        { name = "source_item_id", type = "string", comment = "Identificador único do item vendido na origem" },
        { name = "source_document_id", type = "string", comment = "Identificador do documento fiscal/pedido associado à venda" },
        { name = "is_launch_sale", type = "boolean", comment = "Flag indicando se a venda ocorreu dentro do período de lançamento do produto" },
        { name = "quantity", type = "double", comment = "Quantidade vendida" },
        { name = "gross_sale_amount", type = "double", comment = "Valor bruto de venda" },
        { name = "discount_amount", type = "double", comment = "Valor de desconto" },
        { name = "realized_sale_amount", type = "double", comment = "Valor líquido realizado (bruto - desconto)" }
      ]
      partition_keys = [
        { name = "date", type = "date", comment = "Data da venda (YYYY-MM-DD)" }
      ]

      quicksight = {
        enabled         = false
        data_source_key = "gold"
        import_mode     = "SPICE"
      }
    }

    # Dimensão de clientes. Populada pelo job dim-customers-s2g.
    dim_customers = {
      description = "Dimensão de clientes consolidada na Gold com dados cadastrais e datas da primeira e última compra."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=dim_customers/"

      columns = [
        { name = "customer_id",           type = "string",        comment = "Chave do cliente consolidado" },
        { name = "shopify_customer_ids",  type = "array<string>", comment = "IDs de cliente associados na Shopify" },
        { name = "protheus_customer_ids", type = "array<string>", comment = "IDs de cliente associados no Protheus" },
        { name = "omie_customer_ids",     type = "array<string>", comment = "IDs de cliente associados no Omie" },
        { name = "latest_base_source",    type = "string",        comment = "Fonte mais recente usada na consolidação cadastral" },
        { name = "reference_date",        type = "timestamp",     comment = "Data/hora de referência do cadastro consolidado" },
        { name = "customer_document",     type = "string",        comment = "Documento anonimizado / hash do cliente" },
        { name = "email",                 type = "string",        comment = "E-mail consolidado do cliente" },
        { name = "legal_name",            type = "string",        comment = "Nome legal / razão social consolidada" },
        { name = "trade_name",            type = "string",        comment = "Nome fantasia / nome social consolidado" },
        { name = "phone",                 type = "string",        comment = "Telefone consolidado do cliente" },
        { name = "address_street",        type = "string",        comment = "Logradouro do cliente" },
        { name = "address_number",        type = "string",        comment = "Número do endereço" },
        { name = "address_complement",    type = "string",        comment = "Complemento do endereço" },
        { name = "address_neighborhood",  type = "string",        comment = "Bairro do endereço" },
        { name = "address_city",          type = "string",        comment = "Cidade do endereço" },
        { name = "address_state",         type = "string",        comment = "Estado / UF do endereço" },
        { name = "address_zipcode",       type = "string",        comment = "CEP do endereço" },
        { name = "address_country",       type = "string",        comment = "País do endereço" },
        { name = "address_country_code",  type = "string",        comment = "Código do país do endereço" },
        { name = "address_latitude",      type = "double",        comment = "Latitude do endereço" },
        { name = "address_longitude",     type = "double",        comment = "Longitude do endereço" },
        { name = "first_purchase_date",   type = "date",          comment = "Data da primeira compra válida do cliente" },
        { name = "last_purchase_date",    type = "date",          comment = "Data da última compra válida do cliente" }
      ]
      partition_keys = []
    }

    # Fato diária de novos clientes. Populada pelo job fact-new-customers-daily-s2g.
    fact_new_customers_daily = {
      description = "Fato diária de novos clientes com base na data da primeira compra registrada na dim_customers."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=fact_new_customers_daily/"

      columns = [
        { name = "date",                type = "date",   comment = "Data de referência do indicador" },
        { name = "new_customers_count", type = "bigint", comment = "Quantidade de novos clientes no dia" }
      ]
      partition_keys = []
    }

    ga4_dim_date = {
      description = "Dimensão de datas para análises de GA4."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=ga4_dim_date/"
      columns = [
        { name = "date", type = "date", comment = "Data do evento" },
        { name = "day", type = "int", comment = "Dia do mês" },
        { name = "month", type = "int", comment = "Mês" },
        { name = "quarter", type = "int", comment = "Trimestre" },
        { name = "semester", type = "int", comment = "Semestre" },
        { name = "year", type = "int", comment = "Ano" }
      ]
      partition_keys = []

      quicksight = {
        enabled         = false
        data_source_key = "gold"
        import_mode     = "SPICE"
      }
    }

    ga4_dim_source_medium = {
      description = "Dimensão de canal (source e medium)."
      location    = "s3://${var.bucket}/domain=analytics/dataset=ga4_dim_source_medium/"
      columns = [
        { name = "id", type = "bigint", comment = "Chave da dimensão source/medium" },
        { name = "source", type = "string", comment = "Fonte do tráfego" },
        { name = "medium", type = "string", comment = "Meio do tráfego" }
      ]
      partition_keys = []

      quicksight = {
        enabled         = false
        data_source_key = "gold"
        import_mode     = "SPICE"
      }
    }

    ga4_dim_campaign = {
      description = "Dimensão de campanhas GA4."
      location    = "s3://${var.bucket}/domain=analytics/dataset=ga4_dim_campaign/"
      columns = [
        { name = "id", type = "bigint", comment = "Chave da dimensão campanha" },
        { name = "campaign", type = "string", comment = "Nome da campanha" }
      ]
      partition_keys = []

      quicksight = {
        enabled         = false
        data_source_key = "gold"
        import_mode     = "SPICE"
      }
    }

    ga4_fact_sessions_daily = {
      description = "Fato de sessões GA4 no grão diário por canal e campanha."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=ga4_fact_sessions_daily/"

      columns = [
        { name = "date", type = "date", comment = "Data da sessão" },
        { name = "source_medium_id", type = "bigint", comment = "FK para dim_source_medium" },
        { name = "campaign_id", type = "bigint", comment = "FK para dim_campaign" },
        { name = "sessions", type = "bigint", comment = "Quantidade de sessões" }
      ]

      partition_keys = [
        { name = "report_date", type = "date" }
      ]

      quicksight = {
        enabled         = false
        data_source_key = "gold"
        import_mode     = "SPICE"
      }
    }

    # Dimensão device (GSC): DESKTOP, MOBILE, etc. Populada pelo job dim-device-gsc-s2g.
    dim_device_gsc = {
      description = "Dimensão de dispositivo para Google Search Console (GSC)."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=dim_device_gsc/"

      columns = [
        { name = "id", type = "bigint", comment = "Chave da dimensão (hash do device; -99 para NA)" },
        { name = "device", type = "string", comment = "Dispositivo normalizado (ex.: DESKTOP, MOBILE)" }
      ]
      partition_keys = []

      quicksight = {
        enabled         = false
        data_source_key = "gold"
        import_mode     = "SPICE"
      }
    }

    # Dimensão query (GSC): termos de busca. Populada pelo job dim-query-gsc-s2g.
    dim_query_gsc = {
      description = "Dimensão de query de busca para Google Search Console (GSC)."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=dim_query_gsc/"

      columns = [
        { name = "id", type = "bigint", comment = "Chave da dimensão (hash da query; -99 para NA)" },
        { name = "query", type = "string", comment = "Termo de busca normalizado" }
      ]
      partition_keys = []

      quicksight = {
        enabled         = false
        data_source_key = "gold"
        import_mode     = "SPICE"
      }
    }

    # Fato GSC: clicks/impressions por (date, device_id, query_id). Populada pelo job fact-gsc-metrics-s2g.
    fact_gsc_metrics = {
      description = "Fato de métricas GSC (clicks, impressions) por data, dispositivo e query."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=fact_gsc_metrics/"

      columns = [
        { name = "device_id", type = "bigint", comment = "FK para dim_device_gsc" },
        { name = "query_id", type = "bigint", comment = "FK para dim_query_gsc" },
        { name = "clicks", type = "bigint", comment = "Total de cliques" },
        { name = "impressions", type = "bigint", comment = "Total de impressões" }
      ]
      partition_keys = [
        { name = "date", type = "date", comment = "Data do relatório (YYYY-MM-DD)" }
      ]

      quicksight = {
        enabled         = false
        data_source_key = "gold"
        import_mode     = "SPICE"
      }
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

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
  }

  quicksight             = try(each.value.quicksight, null)
  quicksight_data_sources = var.quicksight_data_sources

}

