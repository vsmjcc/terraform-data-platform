locals {
  tables = {
    test = {
      description = "teste"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=test/dataset=test/"
      columns = [
        { name = "id",       type = "string",    comment = "ID de test" },
      ]
      partition_keys = [] 
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
  parameters     = { classification = "parquet", compressionType = "snappy" }
}

