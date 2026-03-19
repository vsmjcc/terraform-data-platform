locals {
  tables = {
    orders = {
      description = "Orders Shopify refinadas (S2S Enriched) - Silver Enriched"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=orders/"
      columns = [
        { name = "order_id",          type = "string",        comment = "ID do pedido" },
        { name = "created_at",        type = "timestamp",     comment = "Data/hora de criação" },
        { name = "updated_at",        type = "timestamp",     comment = "Data/hora da última atualização" },
        { name = "processed_at",      type = "timestamp",     comment = "Data/hora de processamento" },
        { name = "cancelled_at",      type = "timestamp",     comment = "Data/hora de cancelamento" },
        { name = "closed_at",         type = "timestamp",     comment = "Data/hora de fechamento" },

        { name = "order_name",       type = "string",        comment = "Nome/identificador do pedido" },
        { name = "order_number",     type = "bigint",        comment = "Número do pedido" },
        { name = "number_internal",  type = "bigint",        comment = "Número interno" },

        { name = "financial_status", type = "string",        comment = "Status financeiro" },
        { name = "fulfillment_status", type = "string",      comment = "Status de fulfillment" },
        { name = "confirmed",         type = "boolean",       comment = "Pedido confirmado" },

        { name = "currency",           type = "string",       comment = "Moeda" },
        { name = "subtotal_price",     type = "decimal(18,2)", comment = "Subtotal" },
        { name = "total_price",        type = "decimal(18,2)", comment = "Total" },
        { name = "total_discounts",    type = "decimal(18,2)", comment = "Total de descontos" },
        { name = "current_total_discounts", type = "decimal(18,2)", comment = "Descontos atuais" },
        { name = "current_total_price", type = "decimal(18,2)", comment = "Total atual" },

        # arrays/structs (removidos do Glue Catalog como workaround)
        # Campos que estavam causando erro ao abrir o split no Athena/Trino
        # quando as partições antigas ainda estão com estrutura “nested”.
      ]

      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido (YYYY-MM-DD)" }
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
  parameters     = { classification = "parquet", compressionType = "snappy" }
}