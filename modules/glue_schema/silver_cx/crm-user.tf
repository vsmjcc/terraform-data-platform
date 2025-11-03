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




# resource "aws_glue_catalog_table" "crm_user2" {
#   name          = "crm_user"
#   database_name = var.database_name
#   description   = "Usuários do CRM (Kustomer) - Silver"
#   table_type    = "EXTERNAL_TABLE"

#   parameters = {
#     classification  = "parquet"
#     compressionType = "snappy"
#   }

#   storage_descriptor {
#     location      = "s3://${var.bucket}/domain=${var.domain}/source=crm/dataset=crm_user/"
#     input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
#     output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

#     ser_de_info {
#       name                  = "crm_user_serde"
#       serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
#     }

#     columns {
#       name    = "user_id"
#       type    = "string"
#       comment = "ID original do usuário"
#     }
#     columns {
#       name    = "display_name"
#       type    = "string"
#       comment = "Nome de exibição do usuário"
#     }
#     columns {
#       name    = "email"
#       type    = "string"
#       comment = "E-mail corporativo"
#     }
#     columns {
#       name    = "created_at"
#       type    = "timestamp"
#       comment = "Data de criação do usuário"
#     }
#     columns {
#       name    = "updated_at"
#       type    = "timestamp"
#       comment = "Última atualização no sistema"
#     }
#     columns {
#       name    = "deleted_at"
#       type    = "timestamp"
#       comment = "Data de exclusão"
#     }
#     columns {
#       name    = "source_system"
#       type    = "string"
#       comment = "Origem dos dados (ex.: kustomer)"
#     }
#     columns {
#       name    = "ingested_at"
#       type    = "timestamp"
#       comment = "Data de ingestão no Data Lake"
#     }
#   }
# }