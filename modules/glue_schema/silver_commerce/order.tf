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

