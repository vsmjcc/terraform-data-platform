# JOB: GSC Silver (Normalização) -> Silver (Enriquecimento)

module "glue_job_gsc_metrics_s2s_refine" {
  source = "../glue_job"

  name = "marketing-gsc-metrics-s2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/marketing-gsc-metrics-s2s-refine.py"
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
