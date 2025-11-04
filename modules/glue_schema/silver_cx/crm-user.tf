locals {
  crm_tables = {
    crm_users = {
      description = "Usuários do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_users/"
      columns = [
        { name = "user_id",       type = "string",    comment = "ID original do usuário" },
        { name = "display_name",  type = "string",    comment = "Nome de exibição do usuário" },
        { name = "email",         type = "string",    comment = "E-mail corporativo" },
        { name = "created_at",    type = "timestamp", comment = "Data de criação do usuário" },
        { name = "updated_at",    type = "timestamp", comment = "Última atualização no sistema" },
        { name = "deleted_at",    type = "timestamp", comment = "Data de exclusão" },
        { name = "source_system", type = "string",    comment = "Origem (ex.: kustomer)" },
        { name = "ingested_at",   type = "timestamp", comment = "Data de ingestão no DL" },
      ]
      partition_keys = [] # vazio por ora
    }

    crm_customers = {
      description = "Clientes do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_customers/"
      columns = [
        { name = "customer_id",   type = "string",    comment = "ID original do usuário" },
        { name = "display_name",  type = "string",    comment = "Nome de exibição do usuário" },
        { name = "email",         type = "string",    comment = "E-mail corporativo" },
        { name = "created_at",    type = "timestamp", comment = "Data de criação do usuário" },
        { name = "updated_at",    type = "timestamp", comment = "Última atualização no sistema" },
        { name = "deleted_at",    type = "timestamp", comment = "Data de exclusão" },
        { name = "source_system", type = "string",    comment = "Origem (ex.: kustomer)" },
        { name = "ingested_at",   type = "timestamp", comment = "Data de ingestão no DL" },
      ]
      partition_keys = [] # vazio por ora
    }

    crm_tags = {
      description = "Tags do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_tags/"
      columns = [
        { name = "tag_id",        type = "string",    comment = "ID da tag no sistema de origem (Kustomer)" },
        { name = "name",          type = "string",    comment = "Nome da tag" },
        { name = "org_id",        type = "string",    comment = "ID da organização associada" },
        { name = "created_at",    type = "timestamp", comment = "Data de criação da tag" },
        { name = "updated_at",    type = "timestamp", comment = "Data da última atualização" },
        { name = "modified_at",   type = "timestamp", comment = "Data da última modificação (se diferente do updated)" },
        { name = "deleted",       type = "boolean",   comment = "Indica se a tag foi excluída no sistema de origem" },
        { name = "deleted_at",    type = "timestamp", comment = "Data da exclusão, se aplicável" },
        { name = "created_by_id", type = "string",    comment = "ID do usuário que criou a tag (se disponível)" },
        { name = "modified_by_id",type = "string",    comment = "ID do usuário que modificou a tag" },
        { name = "deleted_by_id", type = "string",    comment = "ID do usuário que excluiu a tag" },
        { name = "source_system", type = "string",    comment = "Origem dos dados (ex.: kustomer)" },
        { name = "ingested_at",   type = "timestamp", comment = "Data de ingestão no Data Lake" }
      ]
      partition_keys = []
    }

    crm_queues = {
      description = "Filas (Queues) do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_queues/"
      columns = [
        { name = "queue_id",                   type = "string",    comment = "ID da fila (origem Kustomer)" },
        { name = "name",                       type = "string",    comment = "Nome interno da fila" },
        { name = "display_name",               type = "string",    comment = "Nome de exibição" },
        { name = "priority",                   type = "int",       comment = "Prioridade" },
        { name = "item_size",                  type = "int",       comment = "Tamanho do item (geralmente 1)" },
        { name = "restrict_transfers_by_users",type = "boolean",   comment = "Restringe transferências por usuário" },
        { name = "accepts_voice_channel",      type = "boolean",   comment = "Aceita canal de voz (quando disponível)" },
        { name = "system",                     type = "boolean",   comment = "Fila de sistema" },
        { name = "description",                type = "string",    comment = "Descrição" },
        { name = "org_id",                     type = "string",    comment = "ID da organização" },
        { name = "created_by_id",              type = "string",    comment = "Usuário que criou" },
        { name = "modified_by_id",             type = "string",    comment = "Usuário que modificou" },
        { name = "created_at",                 type = "timestamp", comment = "Criação" },
        { name = "updated_at",                 type = "timestamp", comment = "Última atualização" },
        { name = "modified_at",                type = "timestamp", comment = "Última modificação" },
        { name = "deleted",                    type = "boolean",   comment = "Excluída na origem" },
        { name = "source_system",              type = "string",    comment = "Origem (ex.: kustomer)" },
        { name = "ingested_at",                type = "timestamp", comment = "Ingestão no DL" }
      ]
      partition_keys = []
    }

    crm_customers = {
      description = "Clientes (Customers) do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_customers/"
      columns = [
        # Identidade
        { name = "customer_id",                 type = "string",    comment = "ID do cliente (origem Kustomer)" },
        { name = "display_name",                type = "string",    comment = "Nome exibido pelo CRM" },
        { name = "name",                        type = "string",    comment = "Nome completo (quando disponível)" },

        # Contatos (arrays + derivação do principal)
        { name = "emails",                      type = "array<string>", comment = "Lista de e-mails do cliente" },
        { name = "phones",                      type = "array<string>", comment = "Lista de telefones E.164" },
        { name = "whatsapps",                   type = "array<string>", comment = "Lista de contas WhatsApp" },
        { name = "primary_email",               type = "string",    comment = "E-mail principal derivado" },
        { name = "primary_phone",               type = "string",    comment = "Telefone principal derivado" },
        { name = "primary_whatsapp",            type = "string",    comment = "WhatsApp principal derivado" },

        # Estado / meta
        { name = "verified",                    type = "boolean",   comment = "Cliente verificado" },
        { name = "deleted",                     type = "boolean",   comment = "Marcado como excluído na origem" },
        { name = "progressive_status",          type = "string",    comment = "Status de progressão (ex.: done)" },

        # Últimos eventos (úteis para recência)
        { name = "last_message_at",             type = "timestamp", comment = "Timestamp do último envio/recebimento" },
        { name = "last_message_in_channel",     type = "string",    comment = "Canal do último inbound (ex.: whatsapp)" },
        { name = "last_message_in_sent_at",     type = "timestamp", comment = "Quando chegou a última msg inbound" },
        { name = "last_message_out_sent_at",    type = "timestamp", comment = "Quando saiu a última msg outbound" },

        # Conversas agregadas
        { name = "conversation_count_open",     type = "int",       comment = "Conversas abertas" },
        { name = "conversation_count_done",     type = "int",       comment = "Conversas concluídas" },
        { name = "conversation_count_snoozed",  type = "int",       comment = "Conversas em snooze" },
        { name = "conversation_count_all",      type = "int",       comment = "Total de conversas" },

        # Relacionamentos úteis
        { name = "last_conversation_id",        type = "string",    comment = "ID da última conversa" },
        { name = "last_conversation_channels",  type = "array<string>", comment = "Canais da última conversa" },
        { name = "org_id",                      type = "string",    comment = "Organização do tenant" },
        { name = "modified_by_id",              type = "string",    comment = "Último usuário que alterou" },

        # Timestamps do registro
        { name = "created_at",                  type = "timestamp", comment = "Criação do customer" },
        { name = "updated_at",                  type = "timestamp", comment = "Última atualização" },
        { name = "modified_at",                 type = "timestamp", comment = "Última modificação (quando existir)" },
        { name = "last_activity_at",            type = "timestamp", comment = "Última atividade (qualquer)" },
        { name = "last_customer_activity_at",   type = "timestamp", comment = "Última atividade do cliente" },

        # Governança
        { name = "source_system",               type = "string",    comment = "Origem (ex.: kustomer)" },
        { name = "ingested_at",                 type = "timestamp", comment = "Ingestão no Data Lake" }
      ]
      partition_keys = []
    },

    nps = {
      description = "Respostas NPS (Typeform) em nível de submissão."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=typeform/dataset=nps/"
      columns = [
        { name = "source",                       type = "string", comment = "Fonte (ex.: typeform)" },
        { name = "dataset",                      type = "string", comment = "Nome do dataset (ex.: nps)" },
        { name = "hash",                         type = "string", comment = "Hash do evento" },
        { name = "request_id",                   type = "string", comment = "Request ID" },
        { name = "event_id",                     type = "string", comment = "Event ID" },
        { name = "event_type",                   type = "string", comment = "Tipo do evento" },
        { name = "form_id",                      type = "string", comment = "ID do formulário" },
        { name = "token",                        type = "string", comment = "Token de submissão" },
        { name = "landed_at",                    type = "string", comment = "Data/hora de entrada (string)" },
        { name = "submitted_at",                 type = "string", comment = "Data/hora de envio (string)" },
        { name = "hidden_closedat",              type = "string", comment = "Hidden: closedAt" },
        { name = "hidden_createdat",             type = "string", comment = "Hidden: createdAt" },
        { name = "hidden_customerid",            type = "string", comment = "Hidden: customerId" },
        { name = "hidden_email",                 type = "string", comment = "Hidden: email" },
        { name = "hidden_name",                  type = "string", comment = "Hidden: name" },
        { name = "hidden_ordernumber",           type = "string", comment = "Hidden: orderNumber" },
        { name = "hidden_paymentauthorizedat",   type = "string", comment = "Hidden: paymentAuthorizedAt" },
        { name = "hidden_phonenumber",           type = "string", comment = "Hidden: phoneNumber" },
        { name = "hidden_seller",                type = "string", comment = "Hidden: seller" },
        { name = "hidden_sellerid",              type = "string", comment = "Hidden: sellerId" },
        { name = "hidden_shopifycustomerid",     type = "string", comment = "Hidden: shopifyCustomerId" },
        { name = "hidden_store",                 type = "string", comment = "Hidden: store" },
        { name = "hidden_storeid",               type = "string", comment = "Hidden: storeId" },
        { name = "ending_id",                    type = "string", comment = "Ending ID do Typeform" },
        { name = "ending_ref",                   type = "string", comment = "Ending ref do Typeform" }
      ]
      partition_keys = [
        { name = "ingestion_ts", type = "string", comment = "Partição por timestamp de ingestão (string)" }
      ]
    }

    nps_answers = {
      description = "Respostas detalhadas por pergunta (Typeform NPS)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=typeform/dataset=nps_answers/"
      columns = [
        { name = "definition_form_id",   type = "string", comment = "ID do formulário" },
        { name = "definition_form_title",type = "string", comment = "Título do formulário" },
        { name = "field_id",             type = "string", comment = "ID do campo" },
        { name = "field_ref",            type = "string", comment = "Ref do campo" },
        { name = "field_type",           type = "string", comment = "Tipo do campo" },
        { name = "field_title",          type = "string", comment = "Título do campo" },
        { name = "choice_id",            type = "string", comment = "ID da opção" },
        { name = "choice_ref",           type = "string", comment = "Ref da opção" },
        { name = "choice_label",         type = "string", comment = "Rótulo da opção" },
        { name = "answer_type",          type = "string", comment = "Tipo de resposta" },
        { name = "answer_number",        type = "bigint", comment = "Valor numérico (NPS etc.)" },
        { name = "answer_text",          type = "string", comment = "Texto da resposta" },
        { name = "answer_choice_id",     type = "string", comment = "ID da opção respondida" },
        { name = "answer_choice_label",  type = "string", comment = "Rótulo da opção respondida" },
        { name = "answer_choice_ref",    type = "string", comment = "Ref da opção respondida" },
        { name = "answer_field_id",      type = "string", comment = "ID do campo respondido" },
        { name = "answer_field_type",    type = "string", comment = "Tipo do campo respondido" },
        { name = "answer_field_ref",     type = "string", comment = "Ref do campo respondido" },
        { name = "nps_classificacao",    type = "string", comment = "Classificação (detrator/neutral/promotor)" }
      ]
      partition_keys = []
    }


  }
}

module "crm_tables" {
  source = "../../../modules/glue_table" # ajuste o caminho

  for_each       = local.crm_tables
  database_name  = var.database_name
  table_name     = each.key
  description    = each.value.description
  location       = each.value.location
  columns        = each.value.columns
  partition_keys = each.value.partition_keys
  parameters     = { classification = "parquet", compressionType = "snappy" }
}

