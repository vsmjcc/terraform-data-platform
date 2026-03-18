# ============================================================
# GOLD - DIM DATE
# ============================================================

module "glue_job_dim_date_s2g" {
  source = "../glue_job"

  name          = "dim-date-s2g"
  script_bucket = var.etls_bucket
  script_key    = "glue/dimensions/dim_date.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.gold_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Layer = "gold"
    Type  = "dimension"
  })
}

# ============================================================
# GOLD - DIM SOURCE MEDIUM (GA4)
# ============================================================

module "glue_job_dim_source_medium_s2g" {
  source = "../glue_job"

  name          = "dim-source-medium-s2g"
  script_bucket = var.etls_bucket
  script_key    = "glue/dimensions/dim_source_medium_ga4.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
    var.gold_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Layer = "gold"
    Type  = "dimension"
  })
}

# ============================================================
# GOLD - DIM CAMPAIGN (GA4)
# ============================================================

module "glue_job_dim_campaign_s2g" {
  source = "../glue_job"

  name          = "dim-campaign-s2g"
  script_bucket = var.etls_bucket
  script_key    = "glue/dimensions/dim_campaign_ga4.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
    var.gold_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Layer = "gold"
    Type  = "dimension"
  })
}

# ============================================================
# GOLD - DIM DEVICE (GSC)
# ============================================================

module "glue_job_dim_device_gsc_s2g" {
  source = "../glue_job"

  name          = "dim-device-gsc-s2g"
  script_bucket = var.etls_bucket
  script_key    = "glue/dimensions/dim_device_gsc.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
    var.gold_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Layer = "gold"
    Type  = "dimension"
  })
}

# ============================================================
# GOLD - DIM QUERY (GSC)
# ============================================================

module "glue_job_dim_query_gsc_s2g" {
  source = "../glue_job"

  name          = "dim-query-gsc-s2g"
  script_bucket = var.etls_bucket
  script_key    = "glue/dimensions/dim_query_gsc.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
    var.gold_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Layer = "gold"
    Type  = "dimension"
  })
}

# ============================================================
# GOLD - DIM PRODUCT (Omie)
# ============================================================

module "glue_job_dim_product_s2g" {
  source = "../glue_job"

  name          = "dim-product-s2g"
  script_bucket = var.etls_bucket
  script_key    = "glue/dimensions/dim_product.py"
  temp_bucket   = var.etls_bucket

  data_buckets = [
    var.silver_bucket,
    var.gold_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [local.glue_sg_id]

  default_arguments = {}

  tags = merge(var.common_tags, {
    Layer = "gold"
    Type  = "dimension"
  })
}
