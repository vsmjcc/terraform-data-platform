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


    customers = {
      description = "Customers consolidados de Shopify, Protheus e Omie (S2S Enriched) - Silver Enriched"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=conformed/dataset=customers/"
      columns = [
        { name = "customer_id",            type = "string",         comment = "Identificador único consolidado do cliente" },
        { name = "shopify_customer_ids",   type = "array<string>",  comment = "Lista de IDs do cliente na fonte Shopify" },
        { name = "protheus_customer_ids",  type = "array<string>",  comment = "Lista de IDs do cliente na fonte Protheus" },
        { name = "omie_customer_ids",      type = "array<string>",  comment = "Lista de IDs do cliente na fonte Omie" },
        { name = "latest_base_source",     type = "string",         comment = "Fonte da linha base mais atualizada usada na consolidação" },
        { name = "reference_date",         type = "timestamp",      comment = "Data/hora de referência da linha base utilizada" },
        { name = "customer_document",      type = "string",         comment = "CPF ou CNPJ normalizado do cliente" },
        { name = "email",                  type = "string",         comment = "Email do cliente" },
        { name = "legal_name",             type = "string",         comment = "Nome principal ou razão social do cliente" },
        { name = "trade_name",             type = "string",         comment = "Nome fantasia ou nome reduzido do cliente" },
        { name = "phone",                  type = "string",         comment = "Telefone normalizado do cliente" },
        { name = "address_street",         type = "string",         comment = "Logradouro consolidado do cliente" },
        { name = "address_number",         type = "string",         comment = "Número do endereço consolidado do cliente" },
        { name = "address_complement",     type = "string",         comment = "Complemento do endereço consolidado do cliente" },
        { name = "address_neighborhood",   type = "string",         comment = "Bairro consolidado do cliente" },
        { name = "address_city",           type = "string",         comment = "Cidade consolidada do cliente" },
        { name = "address_state",          type = "string",         comment = "Estado/UF consolidado do cliente" },
        { name = "address_zipcode",        type = "string",         comment = "CEP normalizado consolidado do cliente" },
        { name = "address_country",        type = "string",         comment = "País consolidado do cliente" },
        { name = "address_country_code",   type = "string",         comment = "Código do país consolidado do cliente" },
        { name = "address_latitude",       type = "double",         comment = "Latitude do endereço consolidado do cliente" },
        { name = "address_longitude",      type = "double",         comment = "Longitude do endereço consolidado do cliente" },
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