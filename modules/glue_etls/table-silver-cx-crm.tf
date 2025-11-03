
resource "aws_glue_catalog_table" "crm_user" {
  name          = "crm_user"
  database_name = aws_glue_catalog_database.silver_cx.name
  description   = "Dimensão simplificada de usuários da Kustomer (CRM) - Silver"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
  }

  storage_descriptor {
    location      = "s3://${var.silver_bucket}/domain=customer_experience/source=kustomer/dataset=crm_user/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "crm_user_serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    columns {
      name    = "user_id"
      type    = "string"
      comment = "ID original do usuário"
    }
    columns {
      name    = "display_name"
      type    = "string"
      comment = "Nome de exibição do usuário"
    }
    columns {
      name    = "email"
      type    = "string"
      comment = "E-mail corporativo"
    }
    columns {
      name    = "created_at"
      type    = "timestamp"
      comment = "Data de criação do usuário"
    }
    columns {
      name    = "updated_at"
      type    = "timestamp"
      comment = "Última atualização no sistema"
    }
    columns {
      name    = "deleted_at"
      type    = "timestamp"
      comment = "Data de exclusão"
    }
    columns {
      name    = "source_system"
      type    = "string"
      comment = "Origem dos dados (ex.: kustomer)"
    }
    columns {
      name    = "ingested_at"
      type    = "timestamp"
      comment = "Data de ingestão no Data Lake"
    }
  }
}