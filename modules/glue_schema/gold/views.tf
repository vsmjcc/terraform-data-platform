locals {
  views = {
    dm_product_sales_daily = {
      sql = <<-SQL
        SELECT
          f.date,
          f.product_id,
          COALESCE(p.product_id, -99) AS omie_product_id,
          COALESCE(p.product_code, 'NA') AS product_code,
          COALESCE(p.description, 'NA') AS product_description,
          p.created_at,
          p.launch_end_date,
          COALESCE(p.updated_by, 'NA') AS updated_by,

          f.document_id,
          f.quantity,
          f.gross_sale_amount,
          f.discount_amount,
          f.realized_sale_amount,
          f.is_launch_product,
          COALESCE(f.launch_type, 'NA') AS launch_type
        FROM ${var.database_name}.fact_product_sales f
        LEFT JOIN ${var.database_name}.dim_product p
          ON f.product_id = p.id
      SQL

      quicksight = {
        enabled                 = true
        data_source_key         = "gold"
        import_mode             = "SPICE"
        create_refresh_schedule = true
        start_after_date_time   = "2026-04-01T03:00:00"
        schedule_id             = "daily"
        refresh_interval        = "DAILY"
        refresh_type            = "FULL_REFRESH"
      }
    }

    dm_new_customers_daily = {
      sql = <<-SQL
        SELECT
          f.date,
          d.day,
          d.month,
          d.quarter,
          d.semester,
          d.year,
          f.new_customers_count
        FROM ${var.database_name}.fact_new_customers_daily f
        LEFT JOIN gold_analytics.ga4_dim_date d
          ON f.date = d.date
      SQL



      quicksight = {
        enabled                 = true
        data_source_key         = "gold"
        import_mode             = "SPICE"
        create_refresh_schedule = true
        start_after_date_time   = "2026-04-01T03:00:00"
        schedule_id             = "daily"
        refresh_interval        = "DAILY"
        refresh_type            = "FULL_REFRESH"
      }
    }
  }
}

module "views" {
  source = "../../../modules/athena_view"

  for_each = local.views

  environment             = var.environment
  database_name           = var.database_name
  view_name               = each.key
  sql                     = each.value.sql
  columns                 = try(each.value.columns, [])
  athena_workgroup        = var.athena_workgroup
  athena_output_location  = var.athena_output_location
  quicksight              = try(each.value.quicksight, null)
  quicksight_data_sources = var.quicksight_data_sources
}