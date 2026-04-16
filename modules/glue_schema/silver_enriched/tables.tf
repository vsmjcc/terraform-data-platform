locals {
  tables = {
    orders = {
      description = "Orders Shopify refinadas (S2S Enriched) - Silver Enriched"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=conformed/dataset=orders/"
      columns = [
        { name = "source_order_id", type = "string", comment = "ID do pedido concatenado" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido shopify" },
        { name = "omie_order_id", type = "string", comment = "ID do pedido omie" },
        { name = "created_at", type = "timestamp", comment = "Data/hora de criação" },
        { name = "updated_at", type = "timestamp", comment = "Data/hora da última atualização" },
        { name = "processed_at", type = "timestamp", comment = "Data/hora de processamento" },
        { name = "cancelled_at", type = "timestamp", comment = "Data/hora de cancelamento" },
        { name = "closed_at", type = "timestamp", comment = "Data/hora de fechamento" },

        { name = "order_name", type = "string", comment = "Nome/identificador do pedido" },
        { name = "order_number", type = "bigint", comment = "Número do pedido" },
        { name = "order_channel", type = "string", comment = "Canal operacional do pedido: ECOMMERCE, STORE, OMNI ou MANUAL" },
        { name = "iglu_order_id", type = "string", comment = "ID do pedido no Iglu" },
        { name = "consumer_identity_status", type = "string", comment = "Status da identificação do consumidor" },
        { name = "shipping_delivery_time", type = "int", comment = "Prazo de entrega em dias, extraído do checkout/Iglu" },
        { name = "seller_id", type = "string", comment = "ID do vendedor responsável pelo pedido" },
        { name = "seller_name", type = "string", comment = "Nome do vendedor responsável pelo pedido" },
        { name = "location_id", type = "string", comment = "ID da loja/localização do pedido" },
        { name = "location_name", type = "string", comment = "Nome da loja/localização do pedido" },

        { name = "financial_status", type = "string", comment = "Status financeiro" },
        { name = "fulfillment_status", type = "string", comment = "Status de fulfillment" },
        { name = "confirmed", type = "boolean", comment = "Pedido confirmado" },

        { name = "shopify_customer_id", type = "string", comment = "Identificador do customer no shopify" },
        { name = "customer_id", type = "string", comment = "Identificador do customer" },
        { name = "document_id", type = "string", comment = "Identificador da nota fiscal" },
        { name = "customer_document", type = "string", comment = "CPF" },
        { name = "customer_document_raw", type = "string", comment = "CPF original" },
        { name = "email", type = "string", comment = "email" },

        { name = "currency", type = "string", comment = "Moeda" },
        { name = "subtotal_price", type = "decimal(18,2)", comment = "Subtotal" },
        { name = "total_price", type = "decimal(18,2)", comment = "Total" },
        { name = "total_discounts", type = "decimal(18,2)", comment = "Total de descontos" },
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
        { name = "customer_id", type = "string", comment = "Identificador único consolidado do cliente" },
        { name = "shopify_customer_ids", type = "array<string>", comment = "Lista de IDs do cliente na fonte Shopify" },
        { name = "protheus_customer_ids", type = "array<string>", comment = "Lista de IDs do cliente na fonte Protheus" },
        { name = "omie_customer_ids", type = "array<string>", comment = "Lista de IDs do cliente na fonte Omie" },
        { name = "latest_base_source", type = "string", comment = "Fonte da linha base mais atualizada usada na consolidação" },
        { name = "reference_date", type = "timestamp", comment = "Data/hora de referência da linha base utilizada" },
        { name = "customer_document", type = "string", comment = "CPF ou CNPJ normalizado do cliente" },
        { name = "email", type = "string", comment = "Email do cliente" },
        { name = "legal_name", type = "string", comment = "Nome principal ou razão social do cliente" },
        { name = "trade_name", type = "string", comment = "Nome fantasia ou nome reduzido do cliente" },
        { name = "phone", type = "string", comment = "Telefone normalizado do cliente" },
        { name = "address_street", type = "string", comment = "Logradouro consolidado do cliente" },
        { name = "address_number", type = "string", comment = "Número do endereço consolidado do cliente" },
        { name = "address_complement", type = "string", comment = "Complemento do endereço consolidado do cliente" },
        { name = "address_neighborhood", type = "string", comment = "Bairro consolidado do cliente" },
        { name = "address_city", type = "string", comment = "Cidade consolidada do cliente" },
        { name = "address_state", type = "string", comment = "Estado/UF consolidado do cliente" },
        { name = "address_zipcode", type = "string", comment = "CEP normalizado consolidado do cliente" },
        { name = "address_country", type = "string", comment = "País consolidado do cliente" },
        { name = "address_country_code", type = "string", comment = "Código do país consolidado do cliente" },
        { name = "address_latitude", type = "double", comment = "Latitude do endereço consolidado do cliente" },
        { name = "address_longitude", type = "double", comment = "Longitude do endereço consolidado do cliente" },
      ]

      partition_keys = []
    }

    orders_items_enriched = {
      description = "Order items consolidados e reconciliados de Shopify, Omie e Protheus (S2S Enriched) - Silver Enriched"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=conformed/dataset=orders_items_enriched/"

      columns = [
        { name = "order_id", type = "string", comment = "Identificador canônico do pedido na S2S" },
        { name = "source_system", type = "string", comment = "Sistema da linha que prevaleceu após a reconciliação" },
        { name = "source_type", type = "string", comment = "Tipo de origem da linha vencedora" },
        { name = "matched_sources", type = "array<string>", comment = "Lista das fontes onde o item/pedido foi encontrado" },
        { name = "source_priority", type = "int", comment = "Prioridade usada na retenção: Protheus=1, Omie=2, Shopify=3" },
        { name = "reconciliation_status", type = "string", comment = "Status final da conciliação: reconciled ou unmatched" },
        { name = "matched_by", type = "string", comment = "Regra usada no match: document_id, order_bridge ou none" },
        { name = "reconciliation_scope", type = "string", comment = "Escopo base usado na conciliação do item" },
        { name = "item_reconciliation_key", type = "string", comment = "Chave final da linha reconciliada" },

        { name = "shopify_order_id", type = "string", comment = "ID do pedido no Shopify quando houver" },
        { name = "omie_order_id", type = "string", comment = "ID do pedido/documento no Omie quando houver" },
        { name = "protheus_order_id", type = "string", comment = "ID do pedido/documento no Protheus quando houver" },

        { name = "source_item_id", type = "string", comment = "ID do item da linha vencedora, mantido apenas para rastreabilidade" },
        { name = "document_id", type = "string", comment = "Documento fiscal canônico. Se existir e for diferente entre plataformas, não há match" },
        { name = "source_document_id", type = "string", comment = "Alias do document_id para compatibilidade com consumidores downstream" },
        { name = "document_key", type = "string", comment = "Chave do documento fiscal quando existir" },
        { name = "document_number", type = "string", comment = "Número do documento fiscal quando existir" },
        { name = "document_series", type = "string", comment = "Série do documento fiscal quando existir" },
        { name = "purchase_order", type = "string", comment = "Código comercial do pedido usado na ponte Shopify x Omie" },

        { name = "sale_date", type = "date", comment = "Data de venda do item" },
        { name = "document_date", type = "date", comment = "Data do documento fiscal" },
        { name = "created_date", type = "date", comment = "Data de criação/ingestão de referência" },

        { name = "product_id", type = "string", comment = "Identificador do produto quando existir" },
        { name = "product_code", type = "string", comment = "Código principal do produto" },
        { name = "variant_id", type = "string", comment = "Identificador da variante quando existir" },
        { name = "sku", type = "string", comment = "SKU informado na origem" },
        { name = "product_name", type = "string", comment = "Nome do produto" },

        { name = "quantity", type = "double", comment = "Quantidade vendida/faturada" },
        { name = "unit_price", type = "decimal(18,2)", comment = "Preço unitário" },
        { name = "gross_amount", type = "decimal(18,2)", comment = "Valor bruto do item" },
        { name = "discount_amount", type = "decimal(18,2)", comment = "Valor de desconto do item" },
        { name = "net_amount", type = "decimal(18,2)", comment = "Valor líquido do item" },
        { name = "currency", type = "string", comment = "Moeda" }
      ]

      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido/documento (YYYY-MM-DD)" }
      ]
    }

    # S2S: produtos refinados (subset de colunas para análise)
    products = {
      description = "Produtos refinados (S2S): subset de colunas (identificação, estoque, datas); particionado por ingestion_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=conformed/dataset=products/"

      columns = [
        { name = "product_id", type = "string", comment = "ID interno do produto" },
        { name = "source", type = "string", comment = "Sistema de origem" },
        { name = "product_code", type = "string", comment = "Código do produto" },
        { name = "description", type = "string", comment = "Descrição do produto" },
        { name = "stock_quantity", type = "double", comment = "Quantidade em estoque" },
        { name = "stock_minimum", type = "double", comment = "Estoque mínimo" },
        { name = "launch_end_date", type = "date", comment = "Data de fim do período no Omie" },
        { name = "updated_at", type = "date", comment = "Usuário da última alteração" },
        { name = "ingestion_date", type = "date", comment = "Data de ingestão (YYYY-MM-DD)" }
      ]

      partition_keys = [
        { name = "created_date", type = "date", comment = "Data de criação do produto" }
      ]
    }

    form_nps_response = {
      description = "Resposta NPS refinada com canal de venda."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=typeform/dataset=form_nps_response/"

      columns = [
        { name = "response_id", type = "string", comment = "ID da resposta no Typeform" },
        { name = "date", type = "date", comment = "Data da submissão" },
        { name = "typeform_customer_id", type = "string", comment = "ID do cliente no Typeform" },
        { name = "shopify_customer_id", type = "string", comment = "ID do cliente no Shopify" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido no Shopify" },
        { name = "id_form", type = "string", comment = "ID do formulário Typeform" },
        { name = "store_id", type = "string", comment = "ID da loja" },
        { name = "store_name", type = "string", comment = "Nome da loja" },
        { name = "seller_id", type = "string", comment = "ID do vendedor" },
        { name = "seller_name", type = "string", comment = "Nome do vendedor" },
        { name = "nps", type = "int", comment = "Nota NPS" },
        { name = "nps_type", type = "string", comment = "Classificação do NPS" },
        { name = "sales_channel", type = "string", comment = "Canal de venda" },
        { name = "ingestion_date", type = "date", comment = "Data de ingestão original" }
      ]

      partition_keys = [
        { name = "submitted_date", type = "date", comment = "Data de submissão usada para particionamento" }
      ]
    }

    form_nps_additional_responses = {
      description = "Respostas adicionais do NPS refinadas com canal de venda."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=typeform/dataset=form_nps_additional_responses/"

      columns = [
        { name = "response_id", type = "string", comment = "ID da resposta no Typeform" },
        { name = "question_id", type = "string", comment = "Ref da pergunta" },
        { name = "question_desc", type = "string", comment = "Texto da pergunta" },
        { name = "answer_desc", type = "string", comment = "Texto da resposta" },
        { name = "type", type = "string", comment = "Tipo da resposta" },
        { name = "date", type = "date", comment = "Data da submissão" },
        { name = "typeform_customer_id", type = "string", comment = "ID do cliente no Typeform" },
        { name = "shopify_customer_id", type = "string", comment = "ID do cliente no Shopify" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido no Shopify" },
        { name = "id_form", type = "string", comment = "ID do formulário Typeform" },
        { name = "store_id", type = "string", comment = "ID da loja" },
        { name = "store_name", type = "string", comment = "Nome da loja" },
        { name = "seller_id", type = "string", comment = "ID do vendedor" },
        { name = "seller_name", type = "string", comment = "Nome do vendedor" },
        { name = "sales_channel", type = "string", comment = "Canal de venda" },
        { name = "ingestion_date", type = "date", comment = "Data de ingestão original" }
      ]

      partition_keys = [
        { name = "submitted_date", type = "date", comment = "Data de submissão usada para particionamento" }
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
