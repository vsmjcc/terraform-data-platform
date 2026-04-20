locals {
  tables = {

    customers = {
      description = "Cadastro de clientes do e-commerce."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=customers/"
      columns = [
        { name = "customer_id", type = "bigint", comment = "ID do cliente" },
        { name = "email", type = "string", comment = "Email do cliente" },
        { name = "first_name", type = "string", comment = "Primeiro nome" },
        { name = "last_name", type = "string", comment = "Sobrenome" },
        { name = "state", type = "string", comment = "Estado do cliente" },
        { name = "verified_email", type = "boolean", comment = "Indica se o email foi verificado" },
        { name = "created_at_ts", type = "timestamp", comment = "Data/hora de criação no Shopify" },
        { name = "updated_at_ts", type = "timestamp", comment = "Data/hora da última atualização" },
        { name = "phone", type = "string", comment = "Telefone do cliente" },
        { name = "currency", type = "string", comment = "Moeda associada à conta" },
        { name = "_ingestion_ts", type = "timestamp", comment = "Timestamp de ingestão no data lake" },
        { name = "ingestion_date", type = "date", comment = "Data de ingestão (YYYY-MM-DD)" }
      ]
      partition_keys = [
        { name = "created_date", type = "date", comment = "Partição por data de criação (YYYY-MM-DD)" }
      ]
    }

    customer_addresses = {
      description = "Endereços dos clientes, conforme cadastro de e-commerce."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=customer_addresses/"
      columns = [
        { name = "address_id", type = "bigint", comment = "ID do endereço" },
        { name = "customer_id", type = "bigint", comment = "ID do cliente associado" },
        { name = "first_name", type = "string", comment = "Primeiro nome" },
        { name = "last_name", type = "string", comment = "Sobrenome" },
        { name = "company", type = "string", comment = "Nome da empresa (se houver)" },
        { name = "address1", type = "string", comment = "Endereço principal" },
        { name = "address2", type = "string", comment = "Complemento" },
        { name = "city", type = "string", comment = "Cidade" },
        { name = "province", type = "string", comment = "Estado / província" },
        { name = "country", type = "string", comment = "Nome do país" },
        { name = "zip", type = "string", comment = "CEP" },
        { name = "phone", type = "string", comment = "Telefone" },
        { name = "name", type = "string", comment = "Nome completo" },
        { name = "province_code", type = "string", comment = "Código da província (ex: SP)" },
        { name = "country_code", type = "string", comment = "Código do país (ex: BR)" },
        { name = "country_name", type = "string", comment = "Nome do país" },
        { name = "is_default", type = "boolean", comment = "Se é o endereço padrão do cliente" },
        { name = "parent_updated_at_ts", type = "timestamp", comment = "Data/hora da última atualização no cliente" },
        { name = "_ingestion_ts", type = "timestamp", comment = "Timestamp de ingestão no data lake" }
      ]
      partition_keys = []
    }


    orders = {
      description = "Pedidos de e-commerce (Shopify), normalizados."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=orders/"
      columns = [
        { name = "order_id", type = "string", comment = "ID do pedido (Shopify, como string)" },
        { name = "created_at", type = "timestamp", comment = "Data/hora de criação" },
        { name = "updated_at", type = "timestamp", comment = "Data/hora da última atualização" },
        { name = "processed_at", type = "timestamp", comment = "Data/hora de processamento" },
        { name = "cancelled_at", type = "timestamp", comment = "Data/hora de cancelamento" },
        { name = "closed_at", type = "timestamp", comment = "Data/hora de fechamento" },

        { name = "order_name", type = "string", comment = "Nome/identificador do pedido" },
        { name = "order_number", type = "bigint", comment = "Número do pedido" },
        { name = "order_channel", type = "string", comment = "Canal operacional do pedido: ECOMMERCE, STORE, OMNI ou MANUAL" },
        { name = "iglu_order_id", type = "string", comment = "ID do pedido no Iglu" },

        { name = "customer_id", type = "string", comment = "Identificador do cliente Shopify" },
        { name = "email", type = "string", comment = "Email do cliente Shopify" },
        { name = "customer_document", type = "string", comment = "Documento do cliente (CPF/CNPJ normalizado)" },
        { name = "consumer_identity_status", type = "string", comment = "Status da identificação do consumidor: IDENTIFIED, IDENTIFIED_WITHOUT_DOCUMENT ou ANONYMOUS" },

        { name = "financial_status", type = "string", comment = "Status financeiro" },
        { name = "fulfillment_status", type = "string", comment = "Status de fulfillment" },
        { name = "confirmed", type = "boolean", comment = "Pedido confirmado" },

        { name = "currency", type = "string", comment = "Moeda da loja" },
        { name = "presentment_currency", type = "string", comment = "Moeda de apresentação" },
        { name = "subtotal_price", type = "decimal(18,2)", comment = "Subtotal" },
        { name = "total_price", type = "decimal(18,2)", comment = "Total" },
        { name = "total_tax", type = "decimal(18,2)", comment = "Total de impostos" },
        { name = "total_discounts", type = "decimal(18,2)", comment = "Total de descontos" },
        { name = "total_line_items_price", type = "decimal(18,2)", comment = "Total dos itens" },
        { name = "current_subtotal_price", type = "decimal(18,2)", comment = "Subtotal atual" },
        { name = "current_total_discounts", type = "decimal(18,2)", comment = "Descontos atuais" },
        { name = "current_total_price", type = "decimal(18,2)", comment = "Total atual" },

        { name = "source_name", type = "string", comment = "Nome da origem" },
        { name = "source_identifier", type = "string", comment = "Identificador da origem" },
        { name = "gateway", type = "array<string>", comment = "Gateways de pagamento do pedido" },

        { name = "tags", type = "array<string>", comment = "Tags do pedido em uppercase" },
        { name = "custom_attributes", type = "map<string,string>", comment = "Atributos personalizados do pedido" },
        { name = "shipping_delivery_time", type = "int", comment = "Prazo de entrega em dias, extraído do checkout/Iglu" },
        { name = "seller_id", type = "string", comment = "ID do vendedor responsável pelo pedido" },
        { name = "seller_name", type = "string", comment = "Nome do vendedor responsável pelo pedido" },
        { name = "location_id", type = "string", comment = "ID da loja/localização do pedido" },
        { name = "location_name", type = "string", comment = "Nome da loja/localização do pedido" },
        { name = "note", type = "string", comment = "Nota do pedido" },
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_items = {
      description = "Itens dos pedidos do e-commerce (Shopify)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=order_items/"
      columns = [
        { name = "order_id", type = "string", comment = "ID do pedido" },
        { name = "currency", type = "string", comment = "Moeda" },
        { name = "item_pos", type = "int", comment = "Posição do item na lista" },
        { name = "item_id", type = "string", comment = "ID do item" },
        { name = "product_id", type = "string", comment = "ID do produto" },
        { name = "variant_id", type = "string", comment = "ID da variante" },
        { name = "sku", type = "string", comment = "SKU" },
        { name = "title", type = "string", comment = "Título do item" },
        { name = "variant_title", type = "string", comment = "Título da variante" },
        { name = "name", type = "string", comment = "Nome completo do item" },
        { name = "vendor", type = "string", comment = "Fornecedor" },
        { name = "quantity", type = "int", comment = "Quantidade" },
        { name = "price", type = "decimal(18,2)", comment = "Preço unitário" },
        { name = "total_discount", type = "decimal(18,2)", comment = "Desconto total alocado no item" },
        { name = "taxable", type = "boolean", comment = "Se é tributável" },
        { name = "gift_card", type = "boolean", comment = "Se é gift card" },
        { name = "requires_shipping", type = "boolean", comment = "Se requer envio" },
        { name = "fulfillable_quantity", type = "int", comment = "Quantidade atendível" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }


    order_customers = {
      description = "Clientes associados aos pedidos (Shopify)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=order_customers/"
      columns = [
        { name = "order_id", type = "string", comment = "ID do pedido" },
        { name = "customer_id", type = "string", comment = "ID do cliente" },
        { name = "email", type = "string", comment = "Email" },
        { name = "first_name", type = "string", comment = "Primeiro nome" },
        { name = "last_name", type = "string", comment = "Sobrenome" },
        { name = "phone", type = "string", comment = "Telefone" },
        { name = "state", type = "string", comment = "Estado" },
        { name = "verified_email", type = "boolean", comment = "Email verificado" },
        { name = "customer_tags", type = "array<string>", comment = "Tags do cliente" },
        { name = "orders_count", type = "int", comment = "Quantidade de pedidos do cliente" },
        { name = "total_spent", type = "decimal(18,2)", comment = "Total gasto pelo cliente" },
        { name = "customer_note", type = "string", comment = "Nota do cliente" },
        { name = "customer_document", type = "string", comment = "Documento do cliente (CPF/CNPJ normalizado)" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_addresses = {
      description = "Endereços de billing/shipping dos pedidos (Shopify)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=order_addresses/"
      columns = [
        { name = "order_id", type = "string", comment = "ID do pedido" },
        { name = "address_type", type = "string", comment = "Tipo de endereço (shipping/billing)" },
        { name = "name", type = "string", comment = "Nome completo" },
        { name = "first_name", type = "string", comment = "Primeiro nome" },
        { name = "last_name", type = "string", comment = "Sobrenome" },
        { name = "company", type = "string", comment = "Empresa" },
        { name = "phone", type = "string", comment = "Telefone" },
        { name = "address1", type = "string", comment = "Endereço 1" },
        { name = "address2", type = "string", comment = "Endereço 2" },
        { name = "city", type = "string", comment = "Cidade" },
        { name = "province", type = "string", comment = "Estado/Província" },
        { name = "province_code", type = "string", comment = "Código da província" },
        { name = "country", type = "string", comment = "País" },
        { name = "country_code", type = "string", comment = "Código do país" },
        { name = "zip", type = "string", comment = "CEP" },
        { name = "latitude", type = "double", comment = "Latitude" },
        { name = "longitude", type = "double", comment = "Longitude" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_discount_applications = {
      description = "Aplicações de desconto por pedido."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=order_discount_applications/"
      columns = [
        { name = "order_id", type = "string", comment = "ID do pedido" },
        { name = "app_pos", type = "int", comment = "Posição da aplicação" },
        { name = "type", type = "string", comment = "Tipo da aplicação de desconto" },
        { name = "allocation_method", type = "string", comment = "Método de alocação" },
        { name = "target_selection", type = "string", comment = "Seleção de alvo" },
        { name = "target_type", type = "string", comment = "Tipo de alvo" },
        { name = "code", type = "string", comment = "Código do desconto, quando aplicável" },
        { name = "title", type = "string", comment = "Título do desconto" },
        { name = "description", type = "string", comment = "Descrição do desconto" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_payments = {
      description = "Pagamentos associados aos pedidos, derivados de transactions do Shopify e enriquecidos com pagamentos do Iglu/POS."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=order_payments/"
      columns = [
        { name = "order_id", type = "string", comment = "ID do pedido" },
        { name = "currency", type = "string", comment = "Moeda da transação" },
        { name = "payment_pos", type = "int", comment = "Posição da transação no pedido" },
        { name = "transaction_id", type = "string", comment = "ID da transação" },
        { name = "kind", type = "string", comment = "Tipo da transação" },
        { name = "status", type = "string", comment = "Status da transação" },
        { name = "gateway", type = "string", comment = "Gateway da transação" },
        { name = "formatted_gateway", type = "string", comment = "Nome formatado do gateway" },
        { name = "payment_id", type = "string", comment = "Identificador do pagamento no provedor" },
        { name = "payment_method", type = "string", comment = "Método de pagamento informado pelo Iglu/POS" },
        { name = "nsu", type = "string", comment = "NSU da transação informado pelo Iglu/POS" },
        { name = "installments", type = "int", comment = "Quantidade de parcelas do pagamento" },
        { name = "authorization_code", type = "string", comment = "Código de autorização da transação" },
        { name = "card_brand", type = "string", comment = "Bandeira do cartão informada pelo Iglu/POS" },
        { name = "conciliation", type = "boolean", comment = "Indicador de conciliação informado pelo Iglu/POS" },
        { name = "manually_capturable", type = "boolean", comment = "Indica se a captura é manual" },
        { name = "processed_at", type = "timestamp", comment = "Data/hora de processamento da transação" },
        { name = "amount", type = "decimal(18,2)", comment = "Valor da transação" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_fulfillments = {
      description = "Fulfillments (envios) por pedido."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=order_fulfillments/"
      columns = [
        { name = "order_id", type = "string", comment = "ID do pedido" },
        { name = "fulfillment_pos", type = "int", comment = "Posição do fulfillment" },
        { name = "fulfillment_id", type = "string", comment = "ID do fulfillment" },
        { name = "created_at", type = "timestamp", comment = "Criação do fulfillment" },
        { name = "updated_at", type = "timestamp", comment = "Atualização do fulfillment" },
        { name = "status", type = "string", comment = "Status do fulfillment" },
        { name = "shipment_status", type = "string", comment = "Status de envio exibido" },
        { name = "tracking_company", type = "string", comment = "Transportadora" },
        { name = "tracking_number", type = "string", comment = "Número principal de rastreio" },
        { name = "tracking_numbers", type = "array<string>", comment = "Números de rastreio" },
        { name = "tracking_url", type = "string", comment = "URL principal de rastreio" },
        { name = "tracking_urls", type = "array<string>", comment = "URLs de rastreio" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_fulfillment_items = {
      description = "Itens dos fulfillments de pedidos."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=order_fulfillment_items/"
      columns = [
        { name = "order_id", type = "string", comment = "ID do pedido" },
        { name = "fulfillment_id", type = "string", comment = "ID do fulfillment" },
        { name = "fulfillment_pos", type = "int", comment = "Posição do fulfillment" },
        { name = "line_pos", type = "int", comment = "Posição da linha" },
        { name = "item_id", type = "string", comment = "ID do item do pedido" },
        { name = "sku", type = "string", comment = "SKU" },
        { name = "title", type = "string", comment = "Título" },
        { name = "vendor", type = "string", comment = "Fornecedor" },
        { name = "quantity", type = "int", comment = "Quantidade" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    iglu_returns = {
      description = "Iglu returns, normalized from the public returns report."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=iglu/dataset=returns/"
      columns = [
        { name = "return_document_key", type = "string", comment = "Return fiscal document key" },
        { name = "sale_document_key", type = "string", comment = "Original sale fiscal document key" },
        { name = "return_store", type = "string", comment = "Store where the return was registered" },
        { name = "sale_store", type = "string", comment = "Store where the original sale was registered" },
        { name = "shopify_order_name", type = "string", comment = "Associated Shopify order name" },
        { name = "returned_at", type = "timestamp", comment = "Return date and time" },
        { name = "return_amount", type = "decimal(18,2)", comment = "Returned amount" },
        { name = "_ingestion_ts", type = "timestamp", comment = "Data lake ingestion timestamp" }
      ]
      partition_keys = [
        { name = "return_date", type = "date", comment = "Partition by return date" }
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
