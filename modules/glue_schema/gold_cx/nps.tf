# locals {
#   tables = {
#     nps_by_order_date = {
#       description = "Agregação semanal do NPS por data do pedido (ordem de compra)."
#       location    = "s3://${var.bucket}/domain=${var.domain}/source=typeform/dataset=nps_by_order_date/"
#       columns = [
#         { name = "hidden_store", type = "string", comment = "Loja associada" },
#         { name = "week", type = "timestamp", comment = "Semana de referência (data inicial da semana)" },
#         { name = "total_respostas", type = "bigint", comment = "Total de respostas coletadas" },
#         { name = "promotores", type = "bigint", comment = "Quantidade de promotores" },
#         { name = "detratores", type = "bigint", comment = "Quantidade de detratores" },
#         { name = "pct_promotores", type = "double", comment = "Percentual de promotores" },
#         { name = "pct_detratores", type = "double", comment = "Percentual de detratores" },
#         { name = "nps", type = "double", comment = "Score NPS (promotores - detratores)" }
#       ]
#       partition_keys = []
#     }

#     nps_by_response_date = {
#       description = "Agregação semanal do NPS por data da resposta (data de envio do formulário)."
#       location    = "s3://${var.bucket}/domain=${var.domain}/source=typeform/dataset=nps_by_response_date/"
#       columns = [
#         { name = "hidden_store", type = "string", comment = "Loja associada" },
#         { name = "week", type = "timestamp", comment = "Semana de referência (data inicial da semana)" },
#         { name = "total_respostas", type = "bigint", comment = "Total de respostas coletadas" },
#         { name = "promotores", type = "bigint", comment = "Quantidade de promotores" },
#         { name = "detratores", type = "bigint", comment = "Quantidade de detratores" },
#         { name = "pct_promotores", type = "double", comment = "Percentual de promotores" },
#         { name = "pct_detratores", type = "double", comment = "Percentual de detratores" },
#         { name = "nps", type = "double", comment = "Score NPS (promotores - detratores)" }
#       ]
#       partition_keys = []
#     }
#   }
# }

# module "tables" {
#   source = "../../../modules/glue_table"

#   for_each       = local.tables
#   environment    = var.environment
#   database_name  = var.database_name
#   table_name     = each.key
#   description    = each.value.description
#   location       = each.value.location
#   columns        = each.value.columns
#   partition_keys = each.value.partition_keys
#   parameters     = { classification = "parquet", compressionType = "snappy" }
# }

