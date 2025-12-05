module "glue_job_omie_products_to_silver" {
  source = "../glue_job"

  name          = "erp-omie-products-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/erp-omie-products-b2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}


module "glue_job_omie_sellers_to_silver" {
  source = "../glue_job"

  name          = "erp-omie-sellers-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/erp-omie-sellers-b2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}


module "glue_job_omie_bank_accounts_to_silver" {
  source = "../glue_job"

  name          = "erp-omie-bank-accounts-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/erp-omie-bank-accounts-b2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}

module "glue_job_omie_fiscal_coupons_to_silver" {
  source = "../glue_job"

  name          = "erp-omie-fiscal-coupons-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/erp-omie-fiscal-coupons-b2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}

module "glue_job_omie_documents_to_silver" {
  source = "../glue_job"

  name          = "erp-omie-documents-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/erp-omie-documents-b2s-refine.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.bronze_bucket,
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {
  }

  tags = merge(var.common_tags, {
    Env   = var.environment
    Owner = "data-platform"
  })
}



