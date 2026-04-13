locals {
  views = {
    dm_product_catalog = {
      sql = <<-SQL
        SELECT
          id,
          product_id,
          product_code,
          description,
          created_at,
          launch_end_date,
          updated_by
        FROM ${var.database_name}.dim_product
      SQL

      quicksight = {
        enabled                 = true
        data_source_key         = "gold"
        import_mode             = "SPICE"
        create_refresh_schedule = true
        start_after_date_time   = "2026-04-07T03:00:00"
        schedule_id             = "daily"
        refresh_interval        = "DAILY"
        refresh_type            = "FULL_REFRESH"
      }
    }

    dm_revenue_daily = {
      sql = <<-SQL
        SELECT
          f.date,
          d.day,
          d.month,
          d.quarter,
          d.semester,
          d.year,

          f.total_sales_quantity,
          f.total_gross_sale_amount,
          f.total_discount_amount,
          f.total_realized_sale_amount,

          f.launch_sales_quantity,
          f.launch_gross_sale_amount,
          f.launch_discount_amount,
          f.launch_realized_sale_amount

        FROM ${var.database_name}.fact_revenue_daily f
        LEFT JOIN ${var.database_name}.ga4_dim_date d
          ON f.date = d.date
      SQL

      quicksight = {
        enabled                 = true
        data_source_key         = "gold"
        import_mode             = "SPICE"
        create_refresh_schedule = true
        start_after_date_time   = "2026-04-07T03:00:00"
        schedule_id             = "daily"
        refresh_interval        = "DAILY"
        refresh_type            = "FULL_REFRESH"
      }
    }

    dm_product_sales = {
      sql = <<-SQL
        SELECT
          f.date,
          d.day,
          d.month,
          d.quarter,
          d.semester,
          d.year,

          f.product_id,
          COALESCE(p.product_id, -99) AS omie_product_id,
          COALESCE(p.product_code, 'NA') AS product_code,
          COALESCE(p.description, 'NA') AS product_description,
          p.created_at,
          p.launch_end_date,
          COALESCE(p.updated_by, 'NA') AS updated_by,

          f.source_system,
          f.source_item_id,
          f.source_document_id,
          f.quantity,
          f.gross_sale_amount,
          f.discount_amount,
          f.realized_sale_amount,
          f.is_launch_sale
        FROM ${var.database_name}.fact_product_sales f
        LEFT JOIN ${var.database_name}.dim_product p
          ON f.product_id = p.id
        LEFT JOIN ${var.database_name}.ga4_dim_date d
          ON f.date = d.date
      SQL

      quicksight = {
        enabled                 = true
        data_source_key         = "gold"
        import_mode             = "SPICE"
        create_refresh_schedule = true
        start_after_date_time   = "2026-04-07T03:00:00"
        schedule_id             = "daily"
        refresh_interval        = "DAILY"
        refresh_type            = "FULL_REFRESH"
      }
    }

    dm_launch_share_monthly = {
      sql = <<-SQL
        SELECT
          f.month,
          d.month AS month_number,
          d.quarter,
          d.semester,
          d.year,
          f.total_realized_sale_amount,
          f.launch_realized_sale_amount,
          f.launch_revenue_share
        FROM ${var.database_name}.fact_launch_revenue_share_monthly f
        LEFT JOIN ${var.database_name}.ga4_dim_date d
          ON f.month = d.date
      SQL

      quicksight = {
        enabled                 = true
        data_source_key         = "gold"
        import_mode             = "SPICE"
        create_refresh_schedule = true
        start_after_date_time   = "2026-04-07T03:00:00"
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
        LEFT JOIN ${var.database_name}.ga4_dim_date d
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

    dm_ga4_sessions_daily = {
      sql = <<-SQL
        SELECT
          f.date,
          d.day,
          d.month,
          d.quarter,
          d.semester,
          d.year,

          f.source_medium_id,
          COALESCE(sm.source, 'NA') AS source,
          COALESCE(sm.medium, 'NA') AS medium,

          f.campaign_id,
          COALESCE(c.campaign, 'NA') AS campaign,

          f.report_date
        FROM ${var.database_name}.ga4_fact_sessions_daily f
        LEFT JOIN ${var.database_name}.ga4_dim_date d
          ON f.date = d.date
        LEFT JOIN ${var.database_name}.ga4_dim_source_medium sm
          ON f.source_medium_id = sm.id
        LEFT JOIN ${var.database_name}.ga4_dim_campaign c
          ON f.campaign_id = c.id
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

    dm_gsc_metrics = {
      sql = <<-SQL
        SELECT
          f.date,
          f.device_id,
          COALESCE(d.device, 'NA') AS device,
          f.query_id,
          COALESCE(q.query, 'NA') AS query,
          f.clicks,
          f.impressions,
          CASE
            WHEN f.impressions > 0 THEN CAST(f.clicks AS DOUBLE) / CAST(f.impressions AS DOUBLE)
            ELSE NULL
          END AS ctr
        FROM ${var.database_name}.fact_gsc_metrics f
        LEFT JOIN ${var.database_name}.dim_device_gsc d
          ON f.device_id = d.id
        LEFT JOIN ${var.database_name}.dim_query_gsc q
          ON f.query_id = q.id
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