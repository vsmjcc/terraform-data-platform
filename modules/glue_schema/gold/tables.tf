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

