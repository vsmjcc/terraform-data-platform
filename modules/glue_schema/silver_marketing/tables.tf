locals {
  tables = {
    cdp_profiles = {
      description = "Perfis de clientes oriundos de CDP (flattened), particionados por created_at_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=cdp/dataset=cdp_profiles/"

      columns = [
        # Principais
        { name = "type",             type = "string",    comment = "Tipo do objeto (ex: profile)" },
        { name = "id",               type = "string",    comment = "ID único do perfil" },

        # Atributos diretos
        { name = "email",            type = "string",    comment = "Email do cliente" },
        { name = "phone_number",     type = "string",    comment = "Telefone" },
        { name = "external_id",      type = "string",    comment = "ID externo" },
        { name = "anonymous_id",     type = "string",    comment = "ID anônimo" },
        { name = "first_name",       type = "string",    comment = "Primeiro nome" },
        { name = "last_name",        type = "string",    comment = "Sobrenome" },
        { name = "organization",     type = "string",    comment = "Organização" },
        { name = "locale",           type = "string",    comment = "Localidade (pt-BR, en-US, etc.)" },
        { name = "title",            type = "string",    comment = "Título/cargo" },
        { name = "image",            type = "string",    comment = "URL da imagem do perfil" },
        { name = "created_at",       type = "timestamp", comment = "Data de criação do perfil" },
        { name = "updated_at",       type = "timestamp", comment = "Data da última atualização" },
        { name = "last_event_date",  type = "timestamp", comment = "Data do último evento" },
        { name = "joined_group_at",  type = "timestamp", comment = "Entrada no grupo" },

        # Localização (achatado)
        { name = "location_country",   type = "string",  comment = "País" },
        { name = "location_region",    type = "string",  comment = "Região/estado" },
        { name = "location_city",      type = "string",  comment = "Cidade" },
        { name = "location_zip",       type = "string",  comment = "CEP" },
        { name = "location_latitude",  type = "double",  comment = "Latitude" },
        { name = "location_longitude", type = "double",  comment = "Longitude" },
        { name = "location_timezone",  type = "string",  comment = "Fuso horário" },

        # Propriedades personalizadas
        { name = "accepts_marketing", type = "boolean",         comment = "Aceita marketing" },
        { name = "shopify_tags",      type = "array<string>",   comment = "Tags do Shopify" },

        # Metadado de origem
        { name = "source_system",     type = "string",          comment = "Sistema de origem (ex: Klaviyo, HubSpot)" }
      ]

      # Partição por created_at_date (projection no módulo)
      partition_keys = [
        {
          name    = "created_at_date"
          type    = "date"
          comment = "Data de criação do perfil (YYYY-MM-DD)"
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
  database_name  = var.database_name
  table_name     = each.key
  description    = each.value.description
  location       = each.value.location
  columns        = each.value.columns
  partition_keys = each.value.partition_keys

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
  }
}
