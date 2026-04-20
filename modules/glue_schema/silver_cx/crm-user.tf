locals {
  crm_tables = {
    crm_users = {
      description = "Usuários do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_users/"
      columns = [
        { name = "user_id", type = "string", comment = "ID original do usuário" },
        { name = "display_name", type = "string", comment = "Nome de exibição do usuário" },
        { name = "email", type = "string", comment = "E-mail corporativo" },
        { name = "created_at", type = "timestamp", comment = "Data de criação do usuário" },
        { name = "updated_at", type = "timestamp", comment = "Última atualização no sistema" },
        { name = "deleted_at", type = "timestamp", comment = "Data de exclusão" },
        { name = "source_system", type = "string", comment = "Origem (ex.: kustomer)" },
        { name = "ingested_at", type = "timestamp", comment = "Data de ingestão no DL" },
      ]
      partition_keys = [] # vazio por ora
    }

    crm_customers = {
      description = "Clientes do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_customers/"
      columns = [
        { name = "customer_id", type = "string", comment = "ID original do usuário" },
        { name = "display_name", type = "string", comment = "Nome de exibição do usuário" },
        { name = "email", type = "string", comment = "E-mail corporativo" },
        { name = "created_at", type = "timestamp", comment = "Data de criação do usuário" },
        { name = "updated_at", type = "timestamp", comment = "Última atualização no sistema" },
        { name = "deleted_at", type = "timestamp", comment = "Data de exclusão" },
        { name = "source_system", type = "string", comment = "Origem (ex.: kustomer)" },
        { name = "ingested_at", type = "timestamp", comment = "Data de ingestão no DL" },
      ]
      partition_keys = [] # vazio por ora
    }

    crm_tags = {
      description = "Tags do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_tags/"
      columns = [
        { name = "tag_id", type = "string", comment = "ID da tag no sistema de origem (Kustomer)" },
        { name = "name", type = "string", comment = "Nome da tag" },
        { name = "org_id", type = "string", comment = "ID da organização associada" },
        { name = "created_at", type = "timestamp", comment = "Data de criação da tag" },
        { name = "updated_at", type = "timestamp", comment = "Data da última atualização" },
        { name = "modified_at", type = "timestamp", comment = "Data da última modificação (se diferente do updated)" },
        { name = "deleted", type = "boolean", comment = "Indica se a tag foi excluída no sistema de origem" },
        { name = "deleted_at", type = "timestamp", comment = "Data da exclusão, se aplicável" },
        { name = "created_by_id", type = "string", comment = "ID do usuário que criou a tag (se disponível)" },
        { name = "modified_by_id", type = "string", comment = "ID do usuário que modificou a tag" },
        { name = "deleted_by_id", type = "string", comment = "ID do usuário que excluiu a tag" },
        { name = "source_system", type = "string", comment = "Origem dos dados (ex.: kustomer)" },
        { name = "ingested_at", type = "timestamp", comment = "Data de ingestão no Data Lake" }
      ]
      partition_keys = []
    }

    crm_queues = {
      description = "Filas (Queues) do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_queues/"
      columns = [
        { name = "queue_id", type = "string", comment = "ID da fila (origem Kustomer)" },
        { name = "name", type = "string", comment = "Nome interno da fila" },
        { name = "display_name", type = "string", comment = "Nome de exibição" },
        { name = "priority", type = "int", comment = "Prioridade" },
        { name = "item_size", type = "int", comment = "Tamanho do item (geralmente 1)" },
        { name = "restrict_transfers_by_users", type = "boolean", comment = "Restringe transferências por usuário" },
        { name = "accepts_voice_channel", type = "boolean", comment = "Aceita canal de voz (quando disponível)" },
        { name = "system", type = "boolean", comment = "Fila de sistema" },
        { name = "description", type = "string", comment = "Descrição" },
        { name = "org_id", type = "string", comment = "ID da organização" },
        { name = "created_by_id", type = "string", comment = "Usuário que criou" },
        { name = "modified_by_id", type = "string", comment = "Usuário que modificou" },
        { name = "created_at", type = "timestamp", comment = "Criação" },
        { name = "updated_at", type = "timestamp", comment = "Última atualização" },
        { name = "modified_at", type = "timestamp", comment = "Última modificação" },
        { name = "deleted", type = "boolean", comment = "Excluída na origem" },
        { name = "source_system", type = "string", comment = "Origem (ex.: kustomer)" },
        { name = "ingested_at", type = "timestamp", comment = "Ingestão no DL" }
      ]
      partition_keys = []
    }

    crm_customers = {
      description = "Clientes (Customers) do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_customers/"
      columns = [
        # Identidade
        { name = "customer_id", type = "string", comment = "ID do cliente (origem Kustomer)" },
        { name = "display_name", type = "string", comment = "Nome exibido pelo CRM" },
        { name = "name", type = "string", comment = "Nome completo (quando disponível)" },

        # Contatos (arrays + derivação do principal)
        { name = "emails", type = "array<string>", comment = "Lista de e-mails do cliente" },
        { name = "phones", type = "array<string>", comment = "Lista de telefones E.164" },
        { name = "whatsapps", type = "array<string>", comment = "Lista de contas WhatsApp" },
        { name = "primary_email", type = "string", comment = "E-mail principal derivado" },
        { name = "primary_phone", type = "string", comment = "Telefone principal derivado" },
        { name = "primary_whatsapp", type = "string", comment = "WhatsApp principal derivado" },

        # Estado / meta
        { name = "verified", type = "boolean", comment = "Cliente verificado" },
        { name = "deleted", type = "boolean", comment = "Marcado como excluído na origem" },
        { name = "progressive_status", type = "string", comment = "Status de progressão (ex.: done)" },

        # Últimos eventos (úteis para recência)
        { name = "last_message_at", type = "timestamp", comment = "Timestamp do último envio/recebimento" },
        { name = "last_message_in_channel", type = "string", comment = "Canal do último inbound (ex.: whatsapp)" },
        { name = "last_message_in_sent_at", type = "timestamp", comment = "Quando chegou a última msg inbound" },
        { name = "last_message_out_sent_at", type = "timestamp", comment = "Quando saiu a última msg outbound" },

        # Conversas agregadas
        { name = "conversation_count_open", type = "int", comment = "Conversas abertas" },
        { name = "conversation_count_done", type = "int", comment = "Conversas concluídas" },
        { name = "conversation_count_snoozed", type = "int", comment = "Conversas em snooze" },
        { name = "conversation_count_all", type = "int", comment = "Total de conversas" },

        # Relacionamentos úteis
        { name = "last_conversation_id", type = "string", comment = "ID da última conversa" },
        { name = "last_conversation_channels", type = "array<string>", comment = "Canais da última conversa" },
        { name = "org_id", type = "string", comment = "Organização do tenant" },
        { name = "modified_by_id", type = "string", comment = "Último usuário que alterou" },

        # Timestamps do registro
        { name = "created_at", type = "timestamp", comment = "Criação do customer" },
        { name = "updated_at", type = "timestamp", comment = "Última atualização" },
        { name = "modified_at", type = "timestamp", comment = "Última modificação (quando existir)" },
        { name = "last_activity_at", type = "timestamp", comment = "Última atividade (qualquer)" },
        { name = "last_customer_activity_at", type = "timestamp", comment = "Última atividade do cliente" },

        # Governança
        { name = "source_system", type = "string", comment = "Origem (ex.: kustomer)" },
        { name = "ingested_at", type = "timestamp", comment = "Ingestão no Data Lake" }
      ]
      partition_keys = []
    }

    crm_conversations = {
      description = "Conversas do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_conversations/"
      columns = [
        # Identidade & chaves
        { name = "conversation_id", type = "string", comment = "ID da conversa (origem Kustomer)" },
        { name = "customer_id", type = "string", comment = "ID do cliente associado" },
        { name = "org_id", type = "string", comment = "ID da organização (tenant)" },
        { name = "brand_id", type = "string", comment = "ID da marca" },
        { name = "queue_id", type = "string", comment = "ID da fila (routing)" },
        { name = "modified_by_id", type = "string", comment = "Usuário que modificou por último" },
        { name = "ended_by_id", type = "string", comment = "Usuário que encerrou a conversa" },

        # Metadados básicos
        { name = "name", type = "string", comment = "Nome/título da conversa" },
        { name = "preview", type = "string", comment = "Prévia da conversa" },
        { name = "channels", type = "array<string>", comment = "Canais da conversa (ex.: instagram-comment, whatsapp)" },
        { name = "status", type = "string", comment = "Status atual (ex.: open, done, snoozed)" },
        { name = "ended", type = "boolean", comment = "Indicador de conversa encerrada" },
        { name = "ended_reason", type = "string", comment = "Motivo do encerramento" },
        { name = "priority", type = "int", comment = "Prioridade atribuída" },
        { name = "spam", type = "boolean", comment = "Marcada como spam na origem" },

        # Contagens
        { name = "message_count", type = "int", comment = "Total de mensagens" },
        { name = "note_count", type = "int", comment = "Total de notas" },
        { name = "outbound_message_count", type = "int", comment = "Total de mensagens enviadas (outbound)" },
        { name = "inbound_message_count", type = "int", comment = "Total de mensagens recebidas (inbound)" },

        # Atribuições
        { name = "assigned_users", type = "array<string>", comment = "Usuários atribuídos" },
        { name = "assigned_teams", type = "array<string>", comment = "Times atribuídos" },

        # Timestamps principais
        { name = "created_at", type = "timestamp", comment = "Criação da conversa" },
        { name = "updated_at", type = "timestamp", comment = "Última atualização" },
        { name = "modified_at", type = "timestamp", comment = "Última modificação (se diferente de updated_at)" },
        { name = "last_activity_at", type = "timestamp", comment = "Última atividade" },
        { name = "ended_at", type = "timestamp", comment = "Data/hora do encerramento" },
        { name = "last_message_at", type = "timestamp", comment = "Data/hora da última mensagem (qualquer direção)" },
        { name = "last_received_at", type = "timestamp", comment = "Data/hora da última mensagem recebida (inbound)" },

        # Abertura/SLAs agregados
        { name = "open_status_at", type = "timestamp", comment = "Timestamp de abertura (statusAt)" },
        { name = "total_open_time_ms", type = "bigint", comment = "Tempo total aberta (ms)" },
        { name = "total_open_business_time_ms", type = "bigint", comment = "Tempo aberto em horário de negócio (ms)" },

        # SLA (resumo)
        { name = "sla_name", type = "string", comment = "Nome da política de SLA aplicada" },
        { name = "sla_version", type = "string", comment = "Versão da política de SLA" },
        { name = "sla_status", type = "string", comment = "Status do SLA (ex.: done, breached)" },
        { name = "sla_breached", type = "boolean", comment = "Indica se houve violação de SLA" },
        { name = "sla_first_breach_at", type = "timestamp", comment = "Primeiro momento de violação de SLA" },
        { name = "sla_first_response_breach_at", type = "timestamp", comment = "Breach previsto/real do first response" },

        # Primeiro inbound (recorte útil)
        { name = "first_message_in_id", type = "string", comment = "ID da primeira mensagem inbound" },
        { name = "first_message_in_sent_at", type = "timestamp", comment = "Envio da primeira mensagem inbound" },
        { name = "first_message_in_channel", type = "string", comment = "Canal da primeira mensagem inbound" },
        { name = "first_message_in_media_type", type = "string", comment = "Tipo de mídia do primeiro inbound (quando houver)" },
        { name = "first_message_in_media_url", type = "string", comment = "URL da mídia do primeiro inbound" },
        { name = "first_message_in_media_permalink", type = "string", comment = "Permalink da mídia do primeiro inbound" },
        { name = "first_message_in_media_caption", type = "string", comment = "Legenda/caption do primeiro inbound" },

        # Último inbound (recorte útil)
        { name = "last_message_in_id", type = "string", comment = "ID da última mensagem inbound" },
        { name = "last_message_in_sent_at", type = "timestamp", comment = "Envio da última mensagem inbound" },
        { name = "last_message_in_channel", type = "string", comment = "Canal da última mensagem inbound" },

        # Governança
        { name = "source_system", type = "string", comment = "Origem (ex.: kustomer)" },
        { name = "ingested_at", type = "timestamp", comment = "Data/hora de ingestão no Data Lake" }
      ]
      partition_keys = [] # manter sem partição por ora
    }

    crm_messages = {
      description = "Mensagens do CRM (Kustomer) - Silver"
      location    = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_messages/"

      columns = [
        # Identidade
        { name = "message_id", type = "string", comment = "ID da mensagem (origem Kustomer)" },
        { name = "external_id", type = "string", comment = "ID externo da mensagem (quando houver)" },

        # Relacionamentos
        { name = "org_id", type = "string", comment = "ID da organização (tenant)" },
        { name = "customer_id", type = "string", comment = "ID do cliente associado" },
        { name = "conversation_id", type = "string", comment = "ID da conversa associada" },
        { name = "created_by_id", type = "string", comment = "Usuário que criou (quando aplicável)" },
        { name = "modified_by_id", type = "string", comment = "Usuário que modificou (quando aplicável)" },

        # Canal / app / direção
        { name = "channel", type = "string", comment = "Canal (ex.: instagram, instagram-comment, whatsapp, email)" },
        { name = "app", type = "string", comment = "Aplicação de origem (ex.: instagram, twilio_whatsapp, postmark)" },
        { name = "direction", type = "string", comment = "in | out" },
        { name = "direction_type", type = "string", comment = "Tipo de direção (ex.: initial-in, response-out, followup-in)" },

        # Conteúdo
        { name = "subject", type = "string", comment = "Assunto (para e-mail)" },
        { name = "preview", type = "string", comment = "Prévia/trecho da mensagem" },
        { name = "size", type = "int", comment = "Tamanho aproximado (quando fornecido)" },

        # Meta (normalizado para campos simples)
        { name = "meta_from", type = "string", comment = "Remetente/Origem (user/telefone/email, quando disponível)" },
        { name = "meta_to", type = "string", comment = "Destinatário (user/telefone/email, quando disponível)" },
        { name = "meta_reply_to", type = "string", comment = "ReplyTo / referência (quando aplicável)" },
        { name = "meta_message_type", type = "string", comment = "Tipo de mensagem (ex.: storyMention, image)" },
        { name = "meta_media_type", type = "string", comment = "Tipo de mídia (ex.: CAROUSEL_ALBUM, image)" },
        { name = "meta_media_url", type = "string", comment = "URL da mídia (quando houver)" },
        { name = "meta_media_permalink", type = "string", comment = "Permalink da mídia (quando houver)" },
        { name = "meta_media_caption", type = "string", comment = "Legenda/caption da mídia (quando houver)" },
        { name = "meta_permalink", type = "string", comment = "Permalink (casos IG/FB story/message)" },

        # E-mail (listas já achatadas para praticidade)
        { name = "meta_to_emails", type = "array<string>", comment = "Lista de e-mails em 'to' (e-mail)" },
        { name = "meta_cc_emails", type = "array<string>", comment = "Lista de e-mails em 'cc' (e-mail)" },
        { name = "meta_bcc_emails", type = "array<string>", comment = "Lista de e-mails em 'bcc' (e-mail)" },

        # Status + tempos
        { name = "status", type = "string", comment = "Status na origem (ex.: received, sent)" },
        { name = "response_time_ms", type = "bigint", comment = "responseTime em milissegundos (quando fornecido)" },
        { name = "response_business_time_ms", type = "bigint", comment = "responseBusinessTime em milissegundos (quando fornecido)" },

        # Atribuições
        { name = "assigned_teams", type = "array<string>", comment = "Times atribuídos" },
        { name = "assigned_users", type = "array<string>", comment = "Usuários atribuídos" },

        # Flags
        { name = "auto", type = "boolean", comment = "Mensagem automática (bot/macros)" },
        { name = "redacted", type = "boolean", comment = "Indica se foi redigida/mascarada na origem" },

        # Timestamps
        { name = "sent_at", type = "timestamp", comment = "Envio/chegada (origem)" },
        { name = "created_at", type = "timestamp", comment = "Criação do registro na origem" },
        { name = "updated_at", type = "timestamp", comment = "Última atualização na origem" },
        { name = "modified_at", type = "timestamp", comment = "Última modificação (quando aplicável)" },
        { name = "first_read_at", type = "timestamp", comment = "Primeira leitura (quando disponível)" },

        # Diversos
        { name = "rev", type = "int", comment = "Versão do registro (rev)" },
        { name = "reactions", type = "array<string>", comment = "Reações (quando houver)" },
        { name = "custom_fields_json", type = "string", comment = "Campos custom (JSON serializado)" },
        { name = "intent_detections_json", type = "string", comment = "Intent detections (JSON serializado)" },
        { name = "attachments", type = "array<string>", comment = "IDs dos anexos associados à mensagem" },


        # Governança
        { name = "source_system", type = "string", comment = "Origem (ex.: kustomer)" },
        { name = "ingested_at", type = "timestamp", comment = "Ingestão no Data Lake" }
      ]

      # Mensagens tendem a ter grande volume: particionar por data de envio ajuda muito no custo do Athena
      partition_keys = [
        { name = "sent_at_date", type = "string", comment = "Partição YYYY-MM-DD derivada de sent_at (UTC)" }
      ]
    }

    nps = {
      description = "Respostas NPS (Typeform) em nível de submissão."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=typeform/dataset=nps/"
      columns = [
        { name = "source", type = "string", comment = "Fonte (ex.: typeform)" },
        { name = "dataset", type = "string", comment = "Nome do dataset (ex.: nps)" },
        { name = "hash", type = "string", comment = "Hash do evento" },
        { name = "request_id", type = "string", comment = "Request ID" },
        { name = "event_id", type = "string", comment = "Event ID" },
        { name = "event_type", type = "string", comment = "Tipo do evento" },
        { name = "form_id", type = "string", comment = "ID do formulário" },
        { name = "token", type = "string", comment = "Token de submissão" },
        { name = "landed_at", type = "string", comment = "Data/hora de entrada (string)" },
        { name = "submitted_at", type = "string", comment = "Data/hora de envio (string)" },
        { name = "hidden_closedat", type = "string", comment = "Hidden: closedAt" },
        { name = "hidden_createdat", type = "string", comment = "Hidden: createdAt" },
        { name = "hidden_customerid", type = "string", comment = "Hidden: customerId" },
        { name = "hidden_email", type = "string", comment = "Hidden: email" },
        { name = "hidden_name", type = "string", comment = "Hidden: name" },
        { name = "hidden_ordernumber", type = "string", comment = "Hidden: orderNumber" },
        { name = "hidden_paymentauthorizedat", type = "string", comment = "Hidden: paymentAuthorizedAt" },
        { name = "hidden_phonenumber", type = "string", comment = "Hidden: phoneNumber" },
        { name = "hidden_seller", type = "string", comment = "Hidden: seller" },
        { name = "hidden_sellerid", type = "string", comment = "Hidden: sellerId" },
        { name = "hidden_shopifycustomerid", type = "string", comment = "Hidden: shopifyCustomerId" },
        { name = "hidden_store", type = "string", comment = "Hidden: store" },
        { name = "hidden_storeid", type = "string", comment = "Hidden: storeId" },
        { name = "ending_id", type = "string", comment = "Ending ID do Typeform" },
        { name = "ending_ref", type = "string", comment = "Ending ref do Typeform" }
      ]
      partition_keys = [
        { name = "ingestion_ts", type = "string", comment = "Partição por timestamp de ingestão (string)" }
      ]
    }

    nps_answers = {
      description = "Respostas detalhadas por pergunta (Typeform NPS)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=typeform/dataset=nps_answers/"
      columns = [
        { name = "definition_form_id", type = "string", comment = "ID do formulário" },
        { name = "definition_form_title", type = "string", comment = "Título do formulário" },
        { name = "field_id", type = "string", comment = "ID do campo" },
        { name = "field_ref", type = "string", comment = "Ref do campo" },
        { name = "field_type", type = "string", comment = "Tipo do campo" },
        { name = "field_title", type = "string", comment = "Título do campo" },
        { name = "choice_id", type = "string", comment = "ID da opção" },
        { name = "choice_ref", type = "string", comment = "Ref da opção" },
        { name = "choice_label", type = "string", comment = "Rótulo da opção" },
        { name = "answer_type", type = "string", comment = "Tipo de resposta" },
        { name = "answer_number", type = "bigint", comment = "Valor numérico (NPS etc.)" },
        { name = "answer_text", type = "string", comment = "Texto da resposta" },
        { name = "answer_choice_id", type = "string", comment = "ID da opção respondida" },
        { name = "answer_choice_label", type = "string", comment = "Rótulo da opção respondida" },
        { name = "answer_choice_ref", type = "string", comment = "Ref da opção respondida" },
        { name = "answer_field_id", type = "string", comment = "ID do campo respondido" },
        { name = "answer_field_type", type = "string", comment = "Tipo do campo respondido" },
        { name = "answer_field_ref", type = "string", comment = "Ref do campo respondido" },
        { name = "nps_classificacao", type = "string", comment = "Classificação (detrator/neutral/promotor)" }
      ]
      partition_keys = []
    }

    nps_form = {
      description = "Respostas NPS normalizadas por submissão (Silver CX)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=typeform/dataset=nps_form/"

      columns = [
        { name = "source",              type = "string",    comment = "Fonte (ex.: typeform)" },
        { name = "dataset",             type = "string",    comment = "Nome do dataset" },
        { name = "event_id",            type = "string",    comment = "Event ID da resposta" },
        { name = "form_id",             type = "string",    comment = "ID do formulário" },
        { name = "form_title",          type = "string",    comment = "Título do formulário" },
        { name = "submitted_at",        type = "timestamp", comment = "Data/hora de envio" },
        { name = "landed_at",           type = "timestamp", comment = "Data/hora de entrada na página" },
        { name = "customer_id",         type = "string",    comment = "ID do cliente no Typeform" },
        { name = "email",               type = "string",    comment = "Email do cliente" },
        { name = "customer_name",       type = "string",    comment = "Nome do cliente" },
        { name = "order_created_at",    type = "timestamp", comment = "Data/hora de criação do pedido" }, # ADICIONADO
        { name = "order_number",        type = "string",    comment = "Order name / número do pedido vindo do form" },
        { name = "store_name",          type = "string",    comment = "Nome da loja" },
        { name = "store_id",            type = "string",    comment = "ID da loja" },
        { name = "seller_name",         type = "string",    comment = "Nome do vendedor" },
        { name = "seller_id",           type = "string",    comment = "ID do vendedor" },
        { name = "phonenumber",         type = "string",    comment = "Telefone" },
        { name = "shopify_customer_id", type = "string",    comment = "ID do cliente no Shopify" },
        { name = "shopify_order_id",    type = "string",    comment = "ID do pedido no Shopify" },
        { name = "question_ref",        type = "string",    comment = "Ref da pergunta no Typeform" },
        { name = "question_label",      type = "string",    comment = "Texto da pergunta" },
        { name = "answer_value",        type = "string",    comment = "Resposta normalizada" },
        { name = "request_id",          type = "string",    comment = "Request ID" },
        { name = "ingestion_ts",        type = "timestamp", comment = "Timestamp de ingestão" },
        { name = "ingestion_date",      type = "date",      comment = "Data de ingestão original" }
      ]

      partition_keys = [
        { name = "submitted_date", type = "date", comment = "Data de submissão usada para particionamento" }
      ]
    }

    form_nps_response = {
      description = "Resposta NPS refinada com canal de venda."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=typeform/dataset=form_nps_response/"

      columns = [
        { name = "response_id",          type = "string", comment = "ID da resposta no Typeform" },
        { name = "date",                 type = "date",   comment = "Data da submissão" },
        { name = "typeform_customer_id", type = "string", comment = "ID do cliente no Typeform" },
        { name = "shopify_customer_id",  type = "string", comment = "ID do cliente no Shopify" },
        { name = "shopify_order_id",     type = "string", comment = "ID do pedido no Shopify" },
        { name = "id_form",              type = "string", comment = "ID do formulário Typeform" },
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

  }
}

module "crm_tables" {
  source = "../../../modules/glue_table" # ajuste o caminho

  for_each       = local.crm_tables
  environment    = var.environment
  database_name  = var.database_name
  table_name     = each.key
  description    = each.value.description
  location       = each.value.location
  columns        = each.value.columns
  partition_keys = each.value.partition_keys
  parameters     = { classification = "parquet", compressionType = "snappy" }
}

