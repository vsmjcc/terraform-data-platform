data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  qs_enabled = try(var.quicksight.enabled, false)

  qs_type_map = {
    string    = "STRING"
    varchar   = "STRING"
    char      = "STRING"

    bigint    = "INTEGER"
    int       = "INTEGER"
    integer   = "INTEGER"
    smallint  = "INTEGER"
    tinyint   = "INTEGER"

    double    = "DECIMAL"
    float     = "DECIMAL"
    decimal   = "DECIMAL"

    boolean   = "BIT"
    bool      = "BIT"

    timestamp = "DATETIME"
    date      = "DATETIME"
  }

  qs_admin_actions = [
    "quicksight:DescribeDataSet",
    "quicksight:DescribeDataSetPermissions",
    "quicksight:PassDataSet",
    "quicksight:DescribeIngestion",
    "quicksight:ListIngestions",
    "quicksight:UpdateDataSet",
    "quicksight:DeleteDataSet",
    "quicksight:CreateIngestion",
    "quicksight:CancelIngestion",
    "quicksight:UpdateDataSetPermissions"
  ]

  qs_author_actions = [
    "quicksight:DescribeDataSet",
    "quicksight:DescribeDataSetPermissions",
    "quicksight:PassDataSet",
    "quicksight:DescribeIngestion",
    "quicksight:ListIngestions"
  ]

  qs_permissions = [
    {
      principal = "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/default/aws-quicksight-${var.environment}-admins"
      actions   = local.qs_admin_actions
    },
    {
      principal = "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:group/default/aws-quicksight-${var.environment}-authors"
      actions   = local.qs_author_actions
    }
  ]
}

resource "aws_quicksight_data_set" "this" {
  count = local.qs_enabled ? 1 : 0

  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = var.table_name
  name           = var.table_name
  import_mode    = try(var.quicksight.import_mode, "SPICE")

  physical_table_map {
    physical_table_map_id = "main"

    relational_table {
      data_source_arn = var.quicksight_data_sources[var.quicksight.data_source_key].arn
      schema          = var.database_name
      name            = var.table_name

      dynamic "input_columns" {
        for_each = var.columns
        content {
          name = input_columns.value.name
          type = lookup(local.qs_type_map, lower(input_columns.value.type), "STRING")
        }
      }
    }
  }

  dynamic "permissions" {
    for_each = local.qs_permissions
    content {
      principal = permissions.value.principal
      actions   = permissions.value.actions
    }
  }
}


resource "aws_quicksight_refresh_schedule" "this" {
  count = local.qs_enabled ? 1 : 0

  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.this[0].data_set_id
  schedule_id    = "daily"

  schedule {
    schedule_frequency {
      interval = "DAILY"
    }

    refresh_type = "FULL_REFRESH"

    start_after_date_time = "2026-03-21T03:00:00"
  }
}