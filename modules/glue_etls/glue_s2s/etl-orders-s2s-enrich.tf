# JOBS: Orders Silver Commerce -> Silver Enriched (S2S Enrich)
locals {
  orders_s2s_enrich_jobs = {
    orders = {
      name              = "orders-s2s-enrich"
      script_key        = "glue/glue-s2s/orders-s2s-enrich.py"
      type              = "fact"
      number_of_workers = 2
    }

    order_items = {
      name              = "order-items-s2s-enrich"
      script_key        = "glue/glue-s2s/order-items-s2s-enrich.py"
      type              = "fact"
      number_of_workers = 2
    }

    order_payments = {
      name              = "order-payments-s2s-enrich"
      script_key        = "glue/glue-s2s/order-payments-s2s-enrich.py"
      type              = "fact"
      number_of_workers = 2
    }

    order_addresses = {
      name              = "order-addresses-s2s-enrich"
      script_key        = "glue/glue-s2s/order-addresses-s2s-enrich.py"
      type              = "dimension"
      number_of_workers = 2
    }

    order_documents = {
      name              = "order-documents-s2s-enrich"
      script_key        = "glue/glue-s2s/order-documents-s2s-enrich.py"
      type              = "bridge"
      number_of_workers = 2
    }

    order_item_documents = {
      name              = "order-item-documents-s2s-enrich"
      script_key        = "glue/glue-s2s/order-item-documents-s2s-enrich.py"
      type              = "bridge"
      number_of_workers = 2
    }
  }
}

module "glue_job_orders_s2s_enrich" {
  source = "../../glue_job"

  for_each = local.orders_s2s_enrich_jobs

  name = each.value.name

  script_bucket = var.etls_bucket
  script_key    = each.value.script_key
  temp_bucket   = var.etls_bucket

  number_of_workers = each.value.number_of_workers

  data_buckets = [
    var.silver_bucket,
  ]

  use_vpc            = true
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [var.glue_sg_id]

  tags = merge(var.common_tags, {
    Env    = var.environment
    Owner  = "data-platform"
    Layer  = "silver_enriched"
    Domain = "commerce"
    Type   = each.value.type
  })
}
