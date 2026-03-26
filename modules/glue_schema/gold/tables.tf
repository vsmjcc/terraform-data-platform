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
        enabled         = true
        data_source_key = "gold"
        import_mode     = "SPICE"
      }
      
    }

    # Fato de vendas por produto (Omie). Populada pelo job fact-product-sales-s2g.
    fact_product_sales = {
      description = "Fato de vendas por produto, documento e dia (Omie). Suporta análise de share entre lançamentos e não-lançamentos."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=fact_product_sales/"

      columns = [
        { name = "product_id", type = "bigint", comment = "FK para dim_product (-99 se não encontrado)" },
        { name = "document_id", type = "string", comment = "ID do documento de venda" },
        { name = "quantity", type = "double", comment = "Quantidade vendida" },
        { name = "gross_sale_amount", type = "double", comment = "Valor bruto de venda (total_price)" },
        { name = "discount_amount", type = "double", comment = "Valor de desconto" },
        { name = "realized_sale_amount", type = "double", comment = "Valor líquido realizado (bruto - desconto)" },
        { name = "is_launch_product", type = "boolean", comment = "Flag indicando se é produto em período de lançamento" },
        { name = "launch_type", type = "string", comment = "Tipo de lançamento: LANCAMENTO ou NAO_LANCAMENTO" }
      ]
      partition_keys = [
        { name = "date", type = "date", comment = "Data da venda (YYYY-MM-DD)" }
      ]

      quicksight = {
        enabled         = true
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

