locals {
  tables = {
    orders = {
      description = "Pedidos enriquecidos em nível de pedido. Grão: 1 linha por pedido do e-commerce."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=orders/"
      columns = [
        { name = "order_id", type = "string", comment = "ID canônico do pedido na camada enriched. Atualmente igual ao ID legado do Shopify" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido no Shopify, preservado para rastreabilidade da plataforma de origem" },
        { name = "order_number", type = "bigint", comment = "Número do pedido usado como referência comercial para conciliação" },

        { name = "created_at", type = "timestamp", comment = "Data/hora de criação" },
        { name = "updated_at", type = "timestamp", comment = "Data/hora da última atualização" },
        { name = "processed_at", type = "timestamp", comment = "Data/hora de processamento" },
        { name = "cancelled_at", type = "timestamp", comment = "Data/hora de cancelamento" },
        { name = "closed_at", type = "timestamp", comment = "Data/hora de fechamento" },

        { name = "order_channel", type = "string", comment = "Canal operacional do pedido: ECOMMERCE, STORE, OMNI ou MANUAL" },
        { name = "iglu_order_id", type = "string", comment = "ID do pedido no Iglu" },
        { name = "source_name", type = "string", comment = "Nome da origem no Shopify" },
        { name = "source_identifier", type = "string", comment = "Identificador da origem no Shopify" },
        { name = "tags", type = "array<string>", comment = "Tags do pedido normalizadas em uppercase" },

        { name = "seller_id", type = "string", comment = "ID do vendedor responsável pelo pedido" },
        { name = "seller_name", type = "string", comment = "Nome do vendedor responsável pelo pedido" },
        { name = "location_id", type = "string", comment = "ID da loja/localização do pedido" },
        { name = "location_name", type = "string", comment = "Nome da loja/localização do pedido" },
        { name = "shipping_delivery_time", type = "int", comment = "Prazo de entrega em dias, extraído do checkout/Iglu" },

        { name = "financial_status", type = "string", comment = "Status financeiro" },
        { name = "fulfillment_status", type = "string", comment = "Status de fulfillment" },
        { name = "confirmed", type = "boolean", comment = "Pedido confirmado" },

        { name = "customer_id", type = "string", comment = "ID consolidado do cliente na camada enriched" },
        { name = "shopify_customer_id", type = "string", comment = "ID do cliente no Shopify" },
        { name = "customer_id_resolution_status", type = "string", comment = "Status da resolução do customer_id consolidado: RESOLVED, UNRESOLVED_SHOPIFY_FALLBACK ou MISSING_SOURCE_CUSTOMER_ID" },
        { name = "customer_document", type = "string", comment = "Documento do cliente normalizado/hash conforme regra de identidade" },
        { name = "consumer_identity_status", type = "string", comment = "Status da identificação do consumidor: IDENTIFIED, IDENTIFIED_WITHOUT_DOCUMENT ou ANONYMOUS" },
        { name = "email", type = "string", comment = "Email do cliente no pedido" },

        { name = "currency", type = "string", comment = "Moeda" },
        { name = "subtotal_price", type = "decimal(18,2)", comment = "Subtotal" },
        { name = "total_price", type = "decimal(18,2)", comment = "Total" },
        { name = "total_tax", type = "decimal(18,2)", comment = "Total de impostos" },
        { name = "total_discounts", type = "decimal(18,2)", comment = "Total de descontos" },
        { name = "total_line_items_price", type = "decimal(18,2)", comment = "Total dos itens" },
        { name = "current_subtotal_price", type = "decimal(18,2)", comment = "Subtotal atual" },
        { name = "current_total_discounts", type = "decimal(18,2)", comment = "Descontos atuais" },
        { name = "current_total_price", type = "decimal(18,2)", comment = "Total atual" },

        { name = "payment_total_amount", type = "decimal(18,2)", comment = "Soma dos pagamentos/transações vinculados ao pedido" },
        { name = "payment_methods", type = "array<string>", comment = "Métodos de pagamento identificados no pedido" },
        { name = "payment_transactions_count", type = "int", comment = "Quantidade de transações/pagamentos vinculados" },
        { name = "paid_at", type = "timestamp", comment = "Primeira data/hora de pagamento aprovado/capturado" },
        { name = "payment_status_summary", type = "string", comment = "Resumo de pagamento: PAID, PARTIALLY_PAID, UNPAID, REFUNDED ou UNKNOWN" },

        { name = "has_fiscal_document", type = "boolean", comment = "Indica se o pedido possui ao menos um documento fiscal vinculado" },
        { name = "fiscal_document_count", type = "int", comment = "Quantidade de documentos fiscais vinculados ao pedido" },
        { name = "first_fiscal_document_id", type = "string", comment = "Primeiro documento fiscal vinculado ao pedido, para atalho analítico" },
        { name = "first_fiscal_document_issue_date", type = "date", comment = "Data de emissão do primeiro documento fiscal vinculado" },
        { name = "invoicing_status", type = "string", comment = "Status de faturamento do pedido: NOT_INVOICED, PARTIALLY_INVOICED, INVOICED, OVER_INVOICED ou UNKNOWN" },

        { name = "shipping_city", type = "string", comment = "Cidade de entrega resumida do pedido" },
        { name = "shipping_state", type = "string", comment = "UF/estado de entrega resumido do pedido" },
        { name = "shipping_zip", type = "string", comment = "CEP de entrega resumido do pedido" },
        { name = "billing_city", type = "string", comment = "Cidade de cobrança resumida do pedido" },
        { name = "billing_state", type = "string", comment = "UF/estado de cobrança resumido do pedido" },
        { name = "billing_zip", type = "string", comment = "CEP de cobrança resumido do pedido" },
      ]

      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido (YYYY-MM-DD)" }
      ]
    }

    customers = {
      description = "Customers consolidados de Shopify, Protheus e Omie (S2S Enriched) - Silver Enriched"
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=customers/"
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

    order_items = {
      description = "Itens de pedidos enriquecidos. Grão: 1 linha por item do pedido do e-commerce."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=order_items/"

      columns = [
        { name = "order_id", type = "string", comment = "ID canônico do pedido na camada enriched. Atualmente igual ao ID legado do Shopify" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido no Shopify" },
        { name = "order_number", type = "bigint", comment = "Número do pedido usado como referência comercial para conciliação" },
        { name = "item_pos", type = "int", comment = "Posição do item no pedido" },
        { name = "item_id", type = "string", comment = "ID do item no Shopify" },

        { name = "product_id", type = "string", comment = "ID do produto na plataforma de origem" },
        { name = "variant_id", type = "string", comment = "ID da variante na plataforma de origem" },
        { name = "sku", type = "string", comment = "SKU informado no pedido" },
        { name = "product_code", type = "string", comment = "Código canônico do produto, quando enriquecido por produtos" },
        { name = "title", type = "string", comment = "Título do item" },
        { name = "variant_title", type = "string", comment = "Título da variante" },
        { name = "name", type = "string", comment = "Nome completo do item" },
        { name = "vendor", type = "string", comment = "Fornecedor/marca" },

        { name = "quantity", type = "int", comment = "Quantidade pedida" },
        { name = "price", type = "decimal(18,2)", comment = "Preço unitário do item" },
        { name = "total_discount", type = "decimal(18,2)", comment = "Desconto total alocado ao item" },
        { name = "gross_amount", type = "decimal(18,2)", comment = "Valor bruto calculado do item" },
        { name = "net_amount", type = "decimal(18,2)", comment = "Valor líquido calculado do item" },
        { name = "currency", type = "string", comment = "Moeda" },

        { name = "taxable", type = "boolean", comment = "Indica se o item é tributável" },
        { name = "gift_card", type = "boolean", comment = "Indica se o item é gift card" },
        { name = "requires_shipping", type = "boolean", comment = "Indica se o item requer envio" },
        { name = "fulfillable_quantity", type = "int", comment = "Quantidade ainda atendível" },

        { name = "order_channel", type = "string", comment = "Canal operacional do pedido" },
        { name = "customer_id", type = "string", comment = "ID consolidado do cliente na camada enriched" },
        { name = "shopify_customer_id", type = "string", comment = "ID original do cliente no Shopify" },
        { name = "customer_id_resolution_status", type = "string", comment = "Status da resolução do customer_id consolidado: RESOLVED, UNRESOLVED_SHOPIFY_FALLBACK ou MISSING_SOURCE_CUSTOMER_ID" },
        { name = "location_id", type = "string", comment = "ID da loja/localização do pedido" },
        { name = "location_name", type = "string", comment = "Nome da loja/localização do pedido" },
        { name = "seller_id", type = "string", comment = "ID do vendedor responsável pelo pedido" },
        { name = "seller_name", type = "string", comment = "Nome do vendedor responsável pelo pedido" },

        { name = "is_invoiced", type = "boolean", comment = "Indica se o item possui faturamento fiscal vinculado" },
        { name = "invoicing_status", type = "string", comment = "Status de faturamento do item: NOT_INVOICED, PARTIALLY_INVOICED, INVOICED, OVER_INVOICED ou UNKNOWN" },
        { name = "invoiced_quantity", type = "double", comment = "Quantidade faturada vinculada ao item" },
        { name = "invoiced_amount", type = "decimal(18,2)", comment = "Valor faturado vinculado ao item" },
        { name = "fiscal_document_ids", type = "array<string>", comment = "Documentos fiscais vinculados ao item" },
        { name = "invoicing_match_rule", type = "string", comment = "Regra usada para vincular o item ao documento fiscal" },
        { name = "invoicing_difference_quantity", type = "double", comment = "Diferença entre quantidade pedida e faturada" },
        { name = "invoicing_difference_amount", type = "decimal(18,2)", comment = "Diferença entre valor líquido pedido e valor faturado" }
      ]

      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido (YYYY-MM-DD)" }
      ]
    }

    order_payments = {
      description = "Pagamentos enriquecidos dos pedidos. Grão: 1 linha por transação/pagamento do pedido."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=order_payments/"

      columns = [
        { name = "order_id", type = "string", comment = "ID canônico do pedido na camada enriched" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido no Shopify" },
        { name = "order_number", type = "bigint", comment = "Número do pedido" },
        { name = "customer_id", type = "string", comment = "ID consolidado do cliente" },
        { name = "shopify_customer_id", type = "string", comment = "ID original do cliente no Shopify" },
        { name = "customer_id_resolution_status", type = "string", comment = "Status da resolução do customer_id consolidado: RESOLVED, UNRESOLVED_SHOPIFY_FALLBACK ou MISSING_SOURCE_CUSTOMER_ID" },
        { name = "order_channel", type = "string", comment = "Canal operacional do pedido" },
        { name = "location_id", type = "string", comment = "ID da loja/localização do pedido" },
        { name = "location_name", type = "string", comment = "Nome da loja/localização do pedido" },
        { name = "seller_id", type = "string", comment = "ID do vendedor responsável pelo pedido" },
        { name = "seller_name", type = "string", comment = "Nome do vendedor responsável pelo pedido" },

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
        { name = "order_date", type = "date", comment = "Partição por data do pedido (YYYY-MM-DD)" }
      ]
    }

    order_addresses = {
      description = "Endereços enriquecidos dos pedidos. Grão: 1 linha por pedido e tipo de endereço."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=order_addresses/"

      columns = [
        { name = "order_id", type = "string", comment = "ID canônico do pedido na camada enriched" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido no Shopify" },
        { name = "order_number", type = "bigint", comment = "Número do pedido" },
        { name = "customer_id", type = "string", comment = "ID consolidado do cliente" },
        { name = "shopify_customer_id", type = "string", comment = "ID original do cliente no Shopify" },
        { name = "customer_id_resolution_status", type = "string", comment = "Status da resolução do customer_id consolidado: RESOLVED, UNRESOLVED_SHOPIFY_FALLBACK ou MISSING_SOURCE_CUSTOMER_ID" },
        { name = "order_channel", type = "string", comment = "Canal operacional do pedido" },

        { name = "address_type", type = "string", comment = "Tipo de endereço: shipping ou billing" },
        { name = "address_source", type = "string", comment = "Fonte usada para o endereço: SHOPIFY, ZSHIP_CUSTOM_ATTRIBUTE, ZBILL_CUSTOM_ATTRIBUTE ou POS_CUSTOM_ATTRIBUTE" },
        { name = "name", type = "string", comment = "Nome completo associado ao endereço" },
        { name = "first_name", type = "string", comment = "Primeiro nome" },
        { name = "last_name", type = "string", comment = "Sobrenome" },
        { name = "company", type = "string", comment = "Empresa" },
        { name = "phone", type = "string", comment = "Telefone" },

        { name = "address1", type = "string", comment = "Endereço 1 original/selecionado" },
        { name = "address2", type = "string", comment = "Endereço 2 original/selecionado" },
        { name = "street", type = "string", comment = "Logradouro normalizado" },
        { name = "number", type = "string", comment = "Número normalizado" },
        { name = "complement", type = "string", comment = "Complemento normalizado" },
        { name = "neighborhood", type = "string", comment = "Bairro normalizado" },
        { name = "city", type = "string", comment = "Cidade" },
        { name = "state", type = "string", comment = "UF/estado" },
        { name = "province", type = "string", comment = "Estado/província original" },
        { name = "province_code", type = "string", comment = "Código da província original" },
        { name = "country", type = "string", comment = "País" },
        { name = "country_code", type = "string", comment = "Código do país" },
        { name = "zip", type = "string", comment = "CEP" },
        { name = "latitude", type = "double", comment = "Latitude" },
        { name = "longitude", type = "double", comment = "Longitude" }
      ]

      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido (YYYY-MM-DD)" }
      ]
    }

    order_documents = {
      description = "Amarrações entre pedidos e documentos fiscais. Grão: 1 linha por vínculo pedido x documento."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=order_documents/"

      columns = [
        { name = "order_id", type = "string", comment = "ID canônico do pedido na camada enriched" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido no Shopify" },
        { name = "order_number", type = "bigint", comment = "Número do pedido usado como referência comercial" },
        { name = "document_id", type = "string", comment = "ID canônico do documento fiscal" },
        { name = "document_key", type = "string", comment = "Chave fiscal do documento" },
        { name = "document_number", type = "string", comment = "Número do documento fiscal" },
        { name = "document_series", type = "string", comment = "Série do documento fiscal" },
        { name = "document_type", type = "string", comment = "Tipo/modelo do documento fiscal" },
        { name = "purchase_order", type = "string", comment = "Pedido de compra/venda informado no documento fiscal" },
        { name = "issue_date", type = "date", comment = "Data de emissão do documento fiscal" },
        { name = "issuer_cnpj", type = "string", comment = "CNPJ do emitente do documento fiscal" },
        { name = "issuer_name", type = "string", comment = "Nome do emitente do documento fiscal" },
        { name = "total_products", type = "decimal(18,2)", comment = "Valor total dos produtos no documento" },
        { name = "total_discounts", type = "decimal(18,2)", comment = "Valor total de descontos no documento" },
        { name = "total_invoice", type = "decimal(18,2)", comment = "Valor total do documento fiscal" },
        { name = "match_rule", type = "string", comment = "Regra usada para amarrar pedido e documento" },
        { name = "match_confidence", type = "string", comment = "Confiança do vínculo: HIGH, MEDIUM, LOW ou MANUAL" },
        { name = "is_matched", type = "boolean", comment = "Indica se o documento foi amarrado ao pedido" }
      ]

      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido (YYYY-MM-DD)" }
      ]
    }

    order_item_documents = {
      description = "Amarrações entre itens de pedido e itens fiscais. Grão: 1 linha por vínculo item do pedido x item fiscal."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=order_item_documents/"

      columns = [
        { name = "order_id", type = "string", comment = "ID canônico do pedido na camada enriched" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido no Shopify" },
        { name = "order_number", type = "bigint", comment = "Número do pedido usado como referência comercial" },
        { name = "item_id", type = "string", comment = "ID do item no Shopify" },
        { name = "sku", type = "string", comment = "SKU do item do pedido" },
        { name = "document_id", type = "string", comment = "ID canônico do documento fiscal" },
        { name = "document_key", type = "string", comment = "Chave fiscal do documento" },
        { name = "document_item_seq", type = "string", comment = "Sequência/identificador do item no documento fiscal" },
        { name = "document_product_code", type = "string", comment = "Código do produto no item fiscal" },
        { name = "document_product_name", type = "string", comment = "Nome do produto no item fiscal" },
        { name = "ordered_quantity", type = "double", comment = "Quantidade pedida" },
        { name = "invoiced_quantity", type = "double", comment = "Quantidade faturada vinculada" },
        { name = "ordered_amount", type = "decimal(18,2)", comment = "Valor líquido pedido" },
        { name = "invoiced_amount", type = "decimal(18,2)", comment = "Valor faturado vinculado" },
        { name = "match_rule", type = "string", comment = "Regra usada para amarrar item do pedido e item fiscal" },
        { name = "invoicing_status", type = "string", comment = "Status de faturamento do item" },
        { name = "quantity_difference", type = "double", comment = "Diferença entre quantidade pedida e faturada" },
        { name = "amount_difference", type = "decimal(18,2)", comment = "Diferença entre valor pedido e faturado" }
      ]

      partition_keys = [
        { name = "order_date", type = "date", comment = "Partição por data do pedido (YYYY-MM-DD)" }
      ]
    }

    # S2S: produtos refinados (subset de colunas para análise)
    products = {
      description = "Produtos refinados (S2S): subset de colunas (identificação, estoque, datas); particionado por ingestion_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/dataset=products/"

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
        { name = "shopify_customer_id",  type = "string", comment = "ID do cliente no Shopify" },
        { name = "shopify_order_id",     type = "string", comment = "ID do pedido no Shopify" },
        { name = "id_form",              type = "string", comment = "ID do formulário Typeform" },
        { name = "order_name",           type = "string", comment = "Nome do pedido resolvido no Shopify" },
        { name = "customer_name",        type = "string", comment = "Nome do cliente do formulário" }, 
        { name = "order_created_at",     type = "timestamp", comment = "Data/hora de criação do pedido" }, 
        { name = "store_id",             type = "string", comment = "ID da loja" },
        { name = "store_name",           type = "string", comment = "Nome da loja" },
        { name = "seller_id",            type = "string", comment = "ID do vendedor" },
        { name = "seller_name",          type = "string", comment = "Nome do vendedor" },
        { name = "nps",                  type = "int",    comment = "Nota NPS" },
        { name = "nps_type",             type = "string", comment = "Classificação do NPS" },
        { name = "sales_channel",        type = "string", comment = "Canal de venda" },
        { name = "ingestion_date",       type = "date",   comment = "Data de ingestão original" }
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
        { name = "shopify_customer_id",  type = "string", comment = "ID do cliente no Shopify" },
        { name = "shopify_order_id",     type = "string", comment = "ID do pedido no Shopify" },
        { name = "id_form",              type = "string", comment = "ID do formulário Typeform" },
        { name = "order_name",           type = "string", comment = "Nome do pedido resolvido no Shopify" },
        { name = "customer_name",        type = "string", comment = "Nome do cliente do formulário" }, 
        { name = "order_created_at",     type = "timestamp", comment = "Data/hora de criação do pedido" },
        { name = "store_id",             type = "string", comment = "ID da loja" },
        { name = "store_name",           type = "string", comment = "Nome da loja" },
        { name = "seller_id",            type = "string", comment = "ID do vendedor" },
        { name = "seller_name",          type = "string", comment = "Nome do vendedor" },
        { name = "sales_channel",        type = "string", comment = "Canal de venda" },
        { name = "ingestion_date",       type = "date",   comment = "Data de ingestão original" }
      ]

      partition_keys = [
        { name = "submitted_date", type = "date", comment = "Data de submissão usada para particionamento" }
      ]
    }

    ga4_sessions_daily = {
      description = "Sessões GA4 enriquecidas com classificação de canais (class1/2/3)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=google_analytics/dataset=ga4_sessions/"

      columns = [
        # Dimensões GA4
        { name = "session_source_medium", type = "string", comment = "Fonte / Mídia da sessão (ex.: google / cpc)" },
        { name = "session_campaign_name", type = "string", comment = "Nome da campanha (ex.: [ED] Zerezes Institucional)" },

        # Taxonomia de canais (enriquecimento)
        { name = "class1", type = "string", comment = "Class1 da classificação de canais" },
        { name = "class2", type = "string", comment = "Class2 da classificação de canais" },
        { name = "class3", type = "string", comment = "Class3 da classificação de canais" },

        # Métricas
        { name = "sessions", type = "bigint", comment = "Quantidade de sessões" },

        # Metadados do pipeline
        { name = "source_system", type = "string", comment = "Sistema de origem (ga4)" },
        { name = "ingestion_date", type = "date", comment = "Dia que o dado entrou na bronze" },
        { name = "run_id", type = "string", comment = "ID de execução/ingestão" }
      ]

      partition_keys = [
        {
          name    = "report_date"
          type    = "date"
          comment = "Dia do relatório (YYYY-MM-DD, derivado do GA4 date)"
          projection = {
            type          = "date"
            format        = "yyyy-MM-dd"
            range         = "2020-01-01,NOW"
            interval      = "1"
            interval_unit = "DAYS"
          }
        }
      ]
    }

    ga4_transactions_daily = {
      description = "Transações GA4 enriquecidas com classificação de canais (class1/2/3)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=google_analytics/dataset=ga4_transactions/"

      columns = [
        # Dimensões GA4
        { name = "transaction_id", type = "string", comment = "ID da transação (pode vir vazio em linhas agregadas)" },
        { name = "source_medium", type = "string", comment = "Fonte / Mídia atribuídas" },
        { name = "campaign_name", type = "string", comment = "Nome da campanha atribuída" },

        # Taxonomia de canais (enriquecimento)
        { name = "class1", type = "string", comment = "Class1 da classificação de canais" },
        { name = "class2", type = "string", comment = "Class2 da classificação de canais" },
        { name = "class3", type = "string", comment = "Class3 da classificação de canais" },

        # Métricas
        { name = "conversions", type = "bigint", comment = "Número de conversões atribuídas" },
        { name = "total_revenue", type = "double", comment = "Receita total atribuída (moeda da propriedade/relatório)" },

        # Metadados do pipeline
        { name = "source_system", type = "string", comment = "Sistema de origem (ga4)" },
        { name = "ingestion_date", type = "date", comment = "Dia que o dado entrou na bronze" },
        { name = "run_id", type = "string", comment = "ID de execução/ingestão" }
      ]

      partition_keys = [
        {
          name    = "report_date"
          type    = "date"
          comment = "Dia do relatório (YYYY-MM-DD, derivado do GA4 date)"
          projection = {
            type          = "date"
            format        = "yyyy-MM-dd"
            range         = "2020-01-01,NOW"
            interval      = "1"
            interval_unit = "DAYS"
          }
        }
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
