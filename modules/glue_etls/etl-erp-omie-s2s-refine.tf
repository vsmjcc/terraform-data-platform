# JOB: Omie products Silver (B2S) -> Silver (Enriquecimento/Refinado)

module "glue_job_omie_products_s2s_refine" {
  source = "../glue_job"

  name = "erp-omie-products-s2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/erp-omie-products-s2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}

# JOB: Omie document_items Silver (B2S) -> Silver (Enriquecimento/Refinado)

module "glue_job_omie_document_items_s2s_refine" {
  source = "../glue_job"

  name = "erp-omie-documents-item-s2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/erp-omie-documents-item-s2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}
