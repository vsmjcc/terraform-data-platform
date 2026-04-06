locals {
  tables = {
    orders = {
      description = "Orders Shopify refinadas (S2S Enriched) - Silver Enriched"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=orders/"
      columns = [
        { name = "order_id", type = "string", comment = "ID do pedido" },
        { name = "created_at", type = "timestamp", comment = "Data/hora de criação" },
        { name = "updated_at", type = "timestamp", comment = "Data/hora da última atualização" },
        { name = "processed_at", type = "timestamp", comment = "Data/hora de processamento" },
        { name = "cancelled_at", type = "timestamp", comment = "Data/hora de cancelamento" },
        { name = "closed_at", type = "timestamp", comment = "Data/hora de fechamento" },

        { name = "order_name", type = "string", comment = "Nome/identificador do pedido" },
        { name = "order_number", type = "bigint", comment = "Número do pedido" },
        { name = "number_internal", type = "bigint", comment = "Número interno" },

        { name = "financial_status", type = "string", comment = "Status financeiro" },
        { name = "fulfillment_status", type = "string", comment = "Status de fulfillment" },
        { name = "confirmed", type = "boolean", comment = "Pedido confirmado" },

        { name = "currency", type = "string", comment = "Moeda" },
        { name = "subtotal_price", type = "decimal(18,2)", comment = "Subtotal" },
        { name = "total_price", type = "decimal(18,2)", comment = "Total" },
        { name = "total_discounts", type = "decimal(18,2)", comment = "Total de descontos" },
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

    # Nome alinhado com o DAG Airflow:
    # `modules/glue_schema/silver_enriched/orders-s2s-enriched-dag.py` passa `--GLUE_TABLE orders_enriched`.
    # Sem este catálogo, o script faz fallback para `source=conformed/dataset=orders_enriched`
    # e o Athena pode ficar consultando uma partição antiga em outro location.
    orders_enriched = {
      description = "Orders Shopify refinadas (S2S Enriched) - Silver Enriched (orders_enriched)"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=conformed/dataset=orders_enriched/"
      columns = [
        { name = "source_order_id",     type = "string",        comment = "ID do pedido concatenado" },
        { name = "shopify_order_id",    type = "string",        comment = "ID do pedido shopify" },
        { name = "omie_order_id",       type = "string",        comment = "ID do pedido omie" },
        { name = "created_at",          type = "timestamp",     comment = "Data/hora de criação" },
        { name = "updated_at",          type = "timestamp",     comment = "Data/hora da última atualização" },
        { name = "processed_at",        type = "timestamp",     comment = "Data/hora de processamento" },
        { name = "cancelled_at",        type = "timestamp",     comment = "Data/hora de cancelamento" },
        { name = "closed_at",           type = "timestamp",     comment = "Data/hora de fechamento" },

        { name = "order_name",         type = "string",        comment = "Nome/identificador do pedido" },
        { name = "order_number",       type = "bigint",        comment = "Número do pedido" },
        { name = "number_internal",    type = "bigint",        comment = "Número interno" },

        { name = "financial_status",   type = "string",        comment = "Status financeiro" },
        { name = "fulfillment_status", type = "string",        comment = "Status de fulfillment" },
        { name = "confirmed",          type = "boolean",       comment = "Pedido confirmado" },

        { name = "shopify_customer_id",  type = "string",        comment = "Identificador do customer no shopify" },
        { name = "customer_id",  type = "string",        comment = "Identificador do customer" },
        { name = "document_id",  type = "string",        comment = "Identificador da nota fiscal" },
        { name = "customer_document",  type = "string",        comment = "CPF" },
        { name = "customer_document_raw",  type = "string",        comment = "CPF original" },
        { name = "email",  type = "string",        comment = "email" },
        
        { name = "currency",             type = "string",        comment = "Moeda" },
        { name = "subtotal_price",       type = "decimal(18,2)", comment = "Subtotal" },
        { name = "total_price",          type = "decimal(18,2)", comment = "Total" },
        { name = "total_discounts",     type = "decimal(18,2)", comment = "Total de descontos" },
        { name = "current_total_discounts", type = "decimal(18,2)", comment = "Descontos atuais" },
        { name = "current_total_price", type = "decimal(18,2)", comment = "Total atual" },
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

        orders_items_enriched = {
      description = "Order items unificados de Shopify, Omie e Protheus (S2S Enriched) - Silver Enriched"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=conformed/dataset=orders_items_enriched/"
      columns = [
        { name = "source_system",      type = "string",        comment = "Sistema de origem do item" },
        { name = "source_type",        type = "string",        comment = "Tipo de origem do item" },
        { name = "source_order_id",    type = "string",        comment = "Identificador do pedido/documento na origem" },
        { name = "source_document_id", type = "string",        comment = "Identificador do documento fiscal na origem" },
        { name = "source_item_id",     type = "string",        comment = "Identificador único do item na origem" },

        { name = "sale_date",          type = "date",          comment = "Data de venda do item" },
        { name = "document_date",      type = "date",          comment = "Data do documento fiscal do item" },
        { name = "created_date",       type = "date",          comment = "Data de criação/ingestão de referência" },

        { name = "product_id",         type = "string",        comment = "Identificador do produto" },
        { name = "product_code",       type = "string",        comment = "Código/SKU do produto" },
        { name = "variant_id",         type = "string",        comment = "Identificador da variante do produto" },
        { name = "sku",                type = "string",        comment = "SKU do item" },
        { name = "product_name",       type = "string",        comment = "Nome do produto" },

        { name = "quantity",           type = "double",        comment = "Quantidade vendida/faturada" },
        { name = "unit_price",         type = "decimal(18,2)", comment = "Preço unitário" },
        { name = "gross_amount",       type = "decimal(18,2)", comment = "Valor bruto do item" },
        { name = "discount_amount",    type = "decimal(18,2)", comment = "Valor de desconto do item" },
        { name = "net_amount",         type = "decimal(18,2)", comment = "Valor líquido do item" },

        { name = "currency",           type = "string",        comment = "Moeda do item" }
      ]

      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido/documento (YYYY-MM-DD)" }
      ]
    }

    # S2S: produtos refinados (subset de colunas para análise)
    products = {
      description = "Produtos refinados (S2S): subset de colunas (identificação, estoque, datas); particionado por ingestion_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_products_refined/"

      columns = [
        { name = "product_id", type = "bigint", comment = "ID interno do produto no Omie" },
        { name = "product_code", type = "string", comment = "Código do produto" },
        { name = "description", type = "string", comment = "Descrição do produto" },
        { name = "stock_quantity", type = "double", comment = "Quantidade em estoque" },
        { name = "stock_minimum", type = "double", comment = "Estoque mínimo" },
        { name = "created_at", type = "timestamp", comment = "Data/hora de inclusão no Omie" },
        { name = "launch_end_date", type = "date", comment = "Data de fim do período no Omie" },
        { name = "updated_by", type = "string", comment = "Usuário da última alteração" }
      ]

      partition_keys = [
        { name = "ingestion_date", type = "date", comment = "Data de ingestão (YYYY-MM-DD)" }
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