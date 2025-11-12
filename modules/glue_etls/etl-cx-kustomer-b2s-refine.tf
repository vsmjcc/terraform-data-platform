# JOB:  kustomer users -> Silver

module "glue_job_cx_kustomer_users_to_silver" {
  source = "../glue_job"

  name          = "cx-kustomer-users-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/cx-kustomer-users-b2s-refine.py"
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


# JOB:  kustomer tags -> Silver

module "glue_job_cx_kustomer_tags_to_silver" {
  source = "../glue_job"

  name          = "cx-kustomer-tags-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/cx-kustomer-tags-b2s-refine.py"
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


# JOB:  kustomer queues -> Silver

module "glue_job_cx_kustomer_queues_to_silver" {
  source = "../glue_job"

  name          = "cx-kustomer-queues-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/cx-kustomer-queues-b2s-refine.py"
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


# JOB:  kustomer customers -> Silver

module "glue_job_cx_kustomer_customers_to_silver" {
  source = "../glue_job"

  name          = "cx-kustomer-customers-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/cx-kustomer-customers-b2s-refine.py"
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

# JOB:  kustomer conversations -> Silver

module "glue_job_cx_kustomer_conversations_to_silver" {
  source = "../glue_job"

  name          = "cx-kustomer-conversations-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/cx-kustomer-conversations-b2s-refine.py"
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

# JOB:  kustomer messages -> Silver

module "glue_job_cx_kustomer_messages_to_silver" {
  source = "../glue_job"

  name          = "cx-kustomer-messages-b2s-refine"

  script_bucket = var.etls_bucket
  script_key    = "glue/cx-kustomer-messages-b2s-refine.py"
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



