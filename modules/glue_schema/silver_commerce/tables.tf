locals {
  tables = {

    customers = {
      description = "Cadastro de clientes do e-commerce."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=customers/"
      columns = [
        { name = "customer_id",     type = "bigint",    comment = "ID do cliente" },
        { name = "email",           type = "string",    comment = "Email do cliente" },
        { name = "first_name",      type = "string",    comment = "Primeiro nome" },
        { name = "last_name",       type = "string",    comment = "Sobrenome" },
        { name = "state",           type = "string",    comment = "Estado do cliente" },
        { name = "verified_email",  type = "boolean",   comment = "Indica se o email foi verificado" },
        { name = "created_at_ts",   type = "timestamp", comment = "Data/hora de criação no Shopify" },
        { name = "updated_at_ts",   type = "timestamp", comment = "Data/hora da última atualização" },
        { name = "phone",           type = "string",    comment = "Telefone do cliente" },
        { name = "currency",        type = "string",    comment = "Moeda associada à conta" },
        { name = "_ingestion_ts",   type = "timestamp", comment = "Timestamp de ingestão no data lake" },
        { name = "ingestion_date",  type = "date",      comment = "Data de ingestão (YYYY-MM-DD)" }
      ]
      partition_keys = [
        { name = "created_date", type = "date", comment = "Partição por data de criação (YYYY-MM-DD)" }
      ]
    }

    customer_addresses = {
      description = "Endereços dos clientes, conforme cadastro de e-commerce."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/dataset=customer_addresses/"
      columns = [
        { name = "address_id",          type = "bigint",    comment = "ID do endereço" },
        { name = "customer_id",         type = "bigint",    comment = "ID do cliente associado" },
        { name = "first_name",          type = "string",    comment = "Primeiro nome" },
        { name = "last_name",           type = "string",    comment = "Sobrenome" },
        { name = "company",             type = "string",    comment = "Nome da empresa (se houver)" },
        { name = "address1",            type = "string",    comment = "Endereço principal" },
        { name = "address2",            type = "string",    comment = "Complemento" },
        { name = "city",                type = "string",    comment = "Cidade" },
        { name = "province",            type = "string",    comment = "Estado / província" },
        { name = "country",             type = "string",    comment = "Nome do país" },
        { name = "zip",                 type = "string",    comment = "CEP" },
        { name = "phone",               type = "string",    comment = "Telefone" },
        { name = "name",                type = "string",    comment = "Nome completo" },
        { name = "province_code",       type = "string",    comment = "Código da província (ex: SP)" },
        { name = "country_code",        type = "string",    comment = "Código do país (ex: BR)" },
        { name = "country_name",        type = "string",    comment = "Nome do país" },
        { name = "is_default",          type = "boolean",   comment = "Se é o endereço padrão do cliente" },
        { name = "parent_updated_at_ts",type = "timestamp", comment = "Data/hora da última atualização no cliente" },
        { name = "_ingestion_ts",       type = "timestamp", comment = "Timestamp de ingestão no data lake" }
      ]
      partition_keys = []
    }

    orders = {
      description = "Pedidos de e-commerce (Shopify), normalizados."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/orders/"
      columns = [
        # chaves e datas
        { name = "order_id",        type = "string",    comment = "ID do pedido (Shopify, como string)" },
        { name = "created_at",      type = "timestamp", comment = "Data/hora de criação" },
        { name = "updated_at",      type = "timestamp", comment = "Data/hora da última atualização" },
        { name = "processed_at",    type = "timestamp", comment = "Data/hora de processamento" },
        { name = "cancelled_at",    type = "timestamp", comment = "Data/hora de cancelamento" },
        { name = "closed_at",       type = "timestamp", comment = "Data/hora de fechamento" },

        # identificação/nomes
        { name = "order_name",      type = "string",    comment = "Nome/identificador do pedido" },
        { name = "order_number",    type = "bigint",    comment = "Número do pedido" },
        { name = "number_internal", type = "bigint",    comment = "Número interno" },

        # status
        { name = "financial_status",   type = "string",  comment = "Status financeiro" },
        { name = "fulfillment_status", type = "string",  comment = "Status de fulfillment" },
        { name = "confirmed",          type = "boolean", comment = "Pedido confirmado" },

        # moeda/valores
        { name = "currency",                  type = "string",         comment = "Moeda" },
        { name = "presentment_currency",      type = "string",         comment = "Moeda de apresentação" },
        { name = "subtotal_price",            type = "decimal(18,2)",  comment = "Subtotal" },
        { name = "total_price",               type = "decimal(18,2)",  comment = "Total" },
        { name = "total_tax",                 type = "decimal(18,2)",  comment = "Total de impostos" },
        { name = "total_discounts",           type = "decimal(18,2)",  comment = "Total de descontos" },
        { name = "total_line_items_price",    type = "decimal(18,2)",  comment = "Total dos itens de linha" },
        { name = "current_subtotal_price",    type = "decimal(18,2)",  comment = "Subtotal atual" },
        { name = "current_total_discounts",   type = "decimal(18,2)",  comment = "Descontos atuais" },
        { name = "current_total_price",       type = "decimal(18,2)",  comment = "Total atual" },
        { name = "current_total_tax",         type = "decimal(18,2)",  comment = "Impostos atuais" },
        { name = "total_outstanding",         type = "decimal(18,2)",  comment = "Saldo em aberto" },
        { name = "total_tip_received",        type = "decimal(18,2)",  comment = "Total de gorjetas recebidas" },
        { name = "total_weight",              type = "bigint",         comment = "Peso total" },

        # origem/fonte
        { name = "source_name",               type = "string", comment = "Nome da origem" },
        { name = "source_identifier",         type = "string", comment = "Identificador da origem" },
        { name = "source_url",                type = "string", comment = "URL da origem" },
        { name = "gateway",                   type = "string", comment = "Gateway de pagamento" },
        { name = "referring_site",            type = "string", comment = "Site de referência" },
        { name = "landing_site",              type = "string", comment = "Landing site" },
        { name = "landing_site_ref",          type = "string", comment = "Referência do landing site" },
        { name = "browser_ip",                type = "string", comment = "IP do navegador" },

        # checkout/cart
        { name = "checkout_id",               type = "string", comment = "ID do checkout" },
        { name = "checkout_token",            type = "string", comment = "Token do checkout" },
        { name = "cart_token",                type = "string", comment = "Token do carrinho" },

        # metadados diversos
        { name = "tags",                      type = "string", comment = "Tags do pedido" },
        { name = "note",                      type = "string", comment = "Nota do pedido" },
        { name = "po_number",                 type = "string", comment = "Número de pedido de compra" },
        { name = "payment_terms",             type = "string", comment = "Termos de pagamento" },
        { name = "confirmation_number",       type = "string", comment = "Número de confirmação" },
        { name = "admin_graphql_api_id",      type = "string", comment = "Admin GraphQL API ID" },
        { name = "app_id",                    type = "string", comment = "ID do app" },
        { name = "company",                   type = "string", comment = "Empresa" },
        { name = "device_id",                 type = "string", comment = "ID do dispositivo" },
        { name = "location_id",               type = "string", comment = "ID da localização" },
        { name = "merchant_of_record_app_id", type = "string", comment = "App merchant of record" },
        { name = "merchant_business_entity_id", type = "string", comment = "Entidade de negócio" },
        { name = "order_status_url",          type = "string", comment = "URL de status do pedido" },

        # arrays/structs (removidos do Glue Catalog como workaround)
        # Esses campos aparecem como nested/complex no Parquet de partições já existentes,
        # e o Athena/Trino está falhando ao abrir o split.
        # Quando reprocessar as partições com o script atualizado, podemos reintroduzir.
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_items = {
      description = "Itens dos pedidos do e-commerce (Shopify)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/order_items/"
      columns = [
        { name = "order_id",      type = "string",        comment = "ID do pedido" },
        { name = "currency",      type = "string",        comment = "Moeda" },
        { name = "item_pos",      type = "int",           comment = "Posição do item na lista" },
        { name = "item_id",       type = "string",        comment = "ID do item" },
        { name = "product_id",    type = "string",        comment = "ID do produto" },
        { name = "variant_id",    type = "string",        comment = "ID da variante" },
        { name = "sku",           type = "string",        comment = "SKU" },
        { name = "title",         type = "string",        comment = "Título do item" },
        { name = "variant_title", type = "string",        comment = "Título da variante" },
        { name = "name",          type = "string",        comment = "Nome completo do item" },
        { name = "vendor",        type = "string",        comment = "Fornecedor" },
        { name = "quantity",      type = "int",           comment = "Quantidade" },
        { name = "price",         type = "decimal(18,2)", comment = "Preço" },
        { name = "total_discount",type = "decimal(18,2)", comment = "Desconto total" },
        { name = "taxable",       type = "boolean",       comment = "Se é tributável" },
        { name = "gift_card",     type = "boolean",       comment = "Se é gift card" },
        { name = "requires_shipping", type = "boolean",   comment = "Se requer envio" },
        { name = "fulfillable_quantity", type = "int",    comment = "Quantidade atendível" },
        { name = "fulfillment_status",   type = "string", comment = "Status de fulfillment" },
        { name = "grams",         type = "int",           comment = "Peso em gramas" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_customers = {
      description = "Clientes associados aos pedidos (Shopify)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/order_customers/"
      columns = [
        { name = "order_id",          type = "string",        comment = "ID do pedido" },
        { name = "customer_id",       type = "string",        comment = "ID do cliente" },
        { name = "email",             type = "string",        comment = "Email" },
        { name = "first_name",        type = "string",        comment = "Primeiro nome" },
        { name = "last_name",         type = "string",        comment = "Sobrenome" },
        { name = "phone",             type = "string",        comment = "Telefone" },
        { name = "state",             type = "string",        comment = "Estado" },
        { name = "verified_email",    type = "boolean",       comment = "Email verificado" },
        { name = "customer_tags",     type = "string",        comment = "Tags do cliente" },
        { name = "orders_count",      type = "int",           comment = "Quantidade de pedidos do cliente" },
        { name = "total_spent",       type = "decimal(18,2)", comment = "Total gasto pelo cliente" },
        { name = "customer_note",     type = "string",        comment = "Nota do cliente" },
        { name = "customer_document", type = "string",        comment = "Documento do cliente (CPF/CNPJ normalizado)" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_addresses = {
      description = "Endereços de billing/shipping dos pedidos (Shopify)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/order_addresses/"
      columns = [
        { name = "order_id",      type = "string", comment = "ID do pedido" },
        { name = "address_type",  type = "string", comment = "Tipo de endereço (shipping/billing)" },
        { name = "name",          type = "string", comment = "Nome completo" },
        { name = "first_name",    type = "string", comment = "Primeiro nome" },
        { name = "last_name",     type = "string", comment = "Sobrenome" },
        { name = "company",       type = "string", comment = "Empresa" },
        { name = "phone",         type = "string", comment = "Telefone" },
        { name = "address1",      type = "string", comment = "Endereço 1" },
        { name = "address2",      type = "string", comment = "Endereço 2" },
        { name = "city",          type = "string", comment = "Cidade" },
        { name = "province",      type = "string", comment = "Estado/Província" },
        { name = "province_code", type = "string", comment = "Código da província" },
        { name = "country",       type = "string", comment = "País" },
        { name = "country_code",  type = "string", comment = "Código do país" },
        { name = "zip",           type = "string", comment = "CEP" },
        { name = "latitude",      type = "double", comment = "Latitude" },
        { name = "longitude",     type = "double", comment = "Longitude" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_discount_codes = {
      description = "Códigos de desconto aplicados nos pedidos."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/order_discount_codes/"
      columns = [
        { name = "order_id",   type = "string",        comment = "ID do pedido" },
        { name = "code_pos",   type = "int",           comment = "Posição do código" },
        { name = "code",       type = "string",        comment = "Código de desconto" },
        { name = "type",       type = "string",        comment = "Tipo de desconto" },
        { name = "amount",     type = "decimal(18,2)", comment = "Valor do desconto" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_discount_applications = {
      description = "Aplicações de desconto (discount_applications) por pedido."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/order_discount_applications/"
      columns = [
        { name = "order_id",   type = "string",        comment = "ID do pedido" },
        { name = "app_pos",    type = "int",           comment = "Posição da aplicação" },
        { name = "type",       type = "string",        comment = "Tipo" },
        { name = "value",      type = "decimal(18,2)", comment = "Valor" },
        { name = "value_type", type = "string",        comment = "Tipo de valor" },
        { name = "allocation_method", type = "string", comment = "Método de alocação" },
        { name = "target_selection",  type = "string", comment = "Seleção de alvo" },
        { name = "target_type",       type = "string", comment = "Tipo de alvo" },
        { name = "title",      type = "string",        comment = "Título" },
        { name = "description",type = "string",        comment = "Descrição" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_payments = {
      description = "Pagamentos associados aos pedidos (gateway names)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/order_payments/"
      columns = [
        { name = "order_id",   type = "string", comment = "ID do pedido" },
        { name = "currency",   type = "string", comment = "Moeda" },
        { name = "payment_pos",type = "int",    comment = "Posição do gateway" },
        { name = "gateway",    type = "string", comment = "Nome do gateway" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_fulfillments = {
      description = "Fulfillments (envios) por pedido."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/order_fulfillments/"
      columns = [
        { name = "order_id",         type = "string",    comment = "ID do pedido" },
        { name = "fulfillment_pos",  type = "int",       comment = "Posição do fulfillment" },
        { name = "fulfillment_id",   type = "string",    comment = "ID do fulfillment" },
        { name = "created_at",       type = "timestamp", comment = "Criação do fulfillment" },
        { name = "updated_at",       type = "timestamp", comment = "Atualização do fulfillment" },
        { name = "status",           type = "string",    comment = "Status" },
        { name = "shipment_status",  type = "string",    comment = "Status de envio" },
        { name = "service",          type = "string",    comment = "Serviço" },
        { name = "tracking_company", type = "string",    comment = "Transportadora" },
        { name = "location_id",      type = "string",    comment = "ID da localização" },
        { name = "tracking_number",  type = "string",    comment = "Número de rastreio (single)" },
        { name = "tracking_numbers", type = "array<string>", comment = "Números de rastreio (lista)" },
        { name = "tracking_url",     type = "string",    comment = "URL de rastreio (single)" },
        { name = "tracking_urls",    type = "array<string>", comment = "URLs de rastreio (lista)" },
        { name = "admin_graphql_api_id", type = "string", comment = "Admin GraphQL API ID" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
      ]
    }

    order_fulfillment_items = {
      description = "Itens dos fulfillments de pedidos."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=shopify/order_fulfillment_items/"
      columns = [
        { name = "order_id",        type = "string",        comment = "ID do pedido" },
        { name = "fulfillment_id",  type = "string",        comment = "ID do fulfillment" },
        { name = "fulfillment_pos", type = "int",           comment = "Posição do fulfillment" },
        { name = "line_pos",        type = "int",           comment = "Posição da linha" },
        { name = "item_id",         type = "string",        comment = "ID do item" },
        { name = "product_id",      type = "string",        comment = "ID do produto" },
        { name = "variant_id",      type = "string",        comment = "ID da variante" },
        { name = "sku",             type = "string",        comment = "SKU" },
        { name = "title",           type = "string",        comment = "Título" },
        { name = "vendor",          type = "string",        comment = "Fornecedor" },
        { name = "quantity",        type = "int",           comment = "Quantidade" },
        { name = "fulfillment_service", type = "string",    comment = "Serviço de fulfillment" },
        { name = "grams",           type = "int",           comment = "Peso em gramas" },
        { name = "price",           type = "decimal(18,2)", comment = "Preço" },
        { name = "total_discount",  type = "decimal(18,2)", comment = "Desconto total" },
        { name = "taxable",         type = "boolean",       comment = "Se é tributável" },
        { name = "gift_card",       type = "boolean",       comment = "Se é gift card" },
        { name = "requires_shipping", type = "boolean",     comment = "Se requer envio" }
      ]
      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido" }
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

