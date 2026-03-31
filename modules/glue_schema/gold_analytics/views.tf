locals {
  views = {
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

          f.sessions,
          f.report_date
        FROM ${var.database_name}.ga4_fact_sessions_daily f
        LEFT JOIN gold_analytics.ga4_dim_date d
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