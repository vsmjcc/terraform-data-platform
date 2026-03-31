locals {
  views = {
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
        FROM gold_marketing.fact_gsc_metrics f
        LEFT JOIN gold_marketing.dim_device_gsc d
          ON f.device_id = d.id
        LEFT JOIN gold_marketing.dim_query_gsc q
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
