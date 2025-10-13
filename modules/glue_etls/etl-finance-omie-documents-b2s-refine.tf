# JOB: Shopify -> Silver
module "glue_job_omie_documnets_to_silver" {
  source = "../glue_job"

  name          = "finance-omie-documents-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/finance-omie-documnets-b2s-refine.py"
  temp_bucket        = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  # Só o que muda por job. O submódulo já liga logs/metrics/bookmark.
  default_arguments = {
    "--SOURCE_PATH"           = "s3://${var.bronze_bucket}/domain=finance/source=omie/documents"
    "--TARGET_DOCUMENTS_PATH" = "s3://${var.silver_bucket}/domain=finance/source=omie/documents"
    "--MODE"                  = "overwrite"
    "--SINCE_DAYS"            = "7"
    # Se precisar, você pode incluir:
    # "--conf" = "spark.sql.sources.partitionOverwriteMode=dynamic"
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}

