locals {
  tables = {

    # ======================================
    # products_collection (indicações)
    # ======================================
    products_collection = {
      description = "Tabela de relação da coleção com o produto."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=gsheets/dataset=talent_employee_referrals/"

      columns = [
        { name = "product_code", type = "timestamp", comment = "Codigo do produto" },
        { name = "product_description", type = "string", comment = "Descrição do produto" },
        { name = "collection", type = "string", comment = "Coleção" },
        { name = "release_year", type = "string", comment = "Ano de lançamento da  coleção" }
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
}
