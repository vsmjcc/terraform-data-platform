# JOB: Omie documents -> Silver
module "glue_job_omie_documents_to_silver" {
  source = "../glue_job"

  name          = "finance-omie-documents-b2s-refine"
  script_bucket = var.etls_bucket
  script_key    = "glue/finance-omie-documents-b2s-refine.py"

  temp_bucket   = var.etls_bucket
  data_buckets  = [var.bronze_bucket, var.silver_bucket]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
    # (bronze) mantenha como está — ajuste só se quiser padronizar bronze também
    "--SOURCE_PATH"          = "s3://${var.bronze_bucket}/domain=finance/source=omie/documents"

    # (silver) novo padrão: domain=finance_documents / source=omie
    "--TARGET_HEADER_PATH"   = "s3://${var.silver_bucket}/domain=finance_documents/source=omie/documents_header"
    "--TARGET_ITEMS_PATH"    = "s3://${var.silver_bucket}/domain=finance_documents/source=omie/documents_items"
    "--TARGET_PAYMENTS_PATH" = "s3://${var.silver_bucket}/domain=finance_documents/source=omie/documents_payments"

    "--MODE"       = "overwrite"
    "--SINCE_DAYS" = "7"

    # (opcional) catálogo
    # "--GLUE_DATABASE"       = "silver_finance"
    # "--GLUE_HEADER_TABLE"   = "documents_header"
    # "--GLUE_ITEMS_TABLE"    = "documents_items"
    # "--GLUE_PAYMENTS_TABLE" = "documents_payments"
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}
