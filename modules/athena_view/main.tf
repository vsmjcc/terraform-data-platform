data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_glue_catalog_table" "view" {
  count         = length(var.columns) == 0 ? 1 : 0
  database_name = var.database_name
  name          = var.view_name

  depends_on = [terraform_data.athena_view]
}

locals {
  qs_enabled = try(var.quicksight.enabled, false)

  quicksight_type_map = {
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
    real      = "DECIMAL"
    decimal   = "DECIMAL"
    numeric   = "DECIMAL"
    boolean   = "BOOLEAN"
    bool      = "BOOLEAN"
    date      = "DATETIME"
    timestamp = "DATETIME"
  }

  resolved_columns = length(var.columns) > 0 ? var.columns : [
    for c in data.aws_glue_catalog_table.view[0].storage_descriptor[0].columns : {
      name            = c.name
      type            = c.type
      quicksight_type = lookup(local.quicksight_type_map, lower(c.type), "STRING")
    }
  ]

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

  rendered_sql = trimspace(var.sql)

  dataset_id   = replace(var.view_name, "_", "-")
  dataset_name = var.view_name

  create_refresh_schedule = (
    local.qs_enabled
    && upper(try(var.quicksight.import_mode, "SPICE")) == "SPICE"
    && try(var.quicksight.create_refresh_schedule, false)
  )
}

resource "terraform_data" "athena_view" {
  triggers_replace = {
    database_name          = var.database_name
    view_name              = var.view_name
    sql                    = local.rendered_sql
    region                 = data.aws_region.current.name
    athena_workgroup       = var.athena_workgroup
    athena_output_location = var.athena_output_location
    data_catalog           = var.data_catalog
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command = <<-EOT
      set -euo pipefail

      QUERY=$(cat <<'SQL'
      CREATE OR REPLACE VIEW "${var.database_name}"."${var.view_name}" AS
      ${local.rendered_sql}
      SQL
      )

      EXEC_ID=$(aws athena start-query-execution \
        --region '${data.aws_region.current.name}' \
        --work-group '${var.athena_workgroup}' \
        --query-string "$QUERY" \
        --query-execution-context Database='${var.database_name}',Catalog='${var.data_catalog}' \
        --result-configuration OutputLocation='${var.athena_output_location}' \
        --query 'QueryExecutionId' \
        --output text)

      while true; do
        STATE=$(aws athena get-query-execution \
          --region '${data.aws_region.current.name}' \
          --query-execution-id "$EXEC_ID" \
          --query 'QueryExecution.Status.State' \
          --output text)

        case "$STATE" in
          SUCCEEDED)
            echo "Athena view ${var.database_name}.${var.view_name} criada/atualizada com sucesso."
            break
            ;;
          FAILED|CANCELLED)
            aws athena get-query-execution \
              --region '${data.aws_region.current.name}' \
              --query-execution-id "$EXEC_ID"
            echo "Falha ao criar/atualizar view ${var.database_name}.${var.view_name}."
            exit 1
            ;;
          *)
            sleep 3
            ;;
        esac
      done
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-lc"]
    command = <<-EOT
      set -euo pipefail

      QUERY='DROP VIEW IF EXISTS "${self.triggers_replace.database_name}"."${self.triggers_replace.view_name}"'

      EXEC_ID=$(aws athena start-query-execution \
        --region '${self.triggers_replace.region}' \
        --work-group '${self.triggers_replace.athena_workgroup}' \
        --query-string "$QUERY" \
        --query-execution-context Database='${self.triggers_replace.database_name}',Catalog='${self.triggers_replace.data_catalog}' \
        --result-configuration OutputLocation='${self.triggers_replace.athena_output_location}' \
        --query 'QueryExecutionId' \
        --output text)

      while true; do
        STATE=$(aws athena get-query-execution \
          --region '${self.triggers_replace.region}' \
          --query-execution-id "$EXEC_ID" \
          --query 'QueryExecution.Status.State' \
          --output text)

        case "$STATE" in
          SUCCEEDED)
            echo "Athena view ${self.triggers_replace.database_name}.${self.triggers_replace.view_name} removida com sucesso."
            break
            ;;
          FAILED|CANCELLED)
            aws athena get-query-execution \
              --region '${self.triggers_replace.region}' \
              --query-execution-id "$EXEC_ID"
            echo "Falha ao remover view ${self.triggers_replace.database_name}.${self.triggers_replace.view_name}."
            exit 1
            ;;
          *)
            sleep 3
            ;;
        esac
      done
    EOT
  }
}

resource "aws_quicksight_data_set" "this" {
  count = local.qs_enabled ? 1 : 0

  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = local.dataset_id
  name           = local.dataset_name
  import_mode    = upper(try(var.quicksight.import_mode, "SPICE"))

  physical_table_map {
    physical_table_map_id = "main"

    relational_table {
      data_source_arn = var.quicksight_data_sources[var.quicksight.data_source_key].arn
      schema          = var.database_name
      name            = var.view_name

      dynamic "input_columns" {
        for_each = local.resolved_columns
        content {
          name = input_columns.value.name
          type = coalesce(
            try(input_columns.value.quicksight_type, null),
            lookup(local.quicksight_type_map, lower(try(input_columns.value.type, "string")), "STRING")
          )
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

  depends_on = [terraform_data.athena_view]
}

resource "aws_quicksight_refresh_schedule" "this" {
  count = local.create_refresh_schedule ? 1 : 0

  aws_account_id = data.aws_caller_identity.current.account_id
  data_set_id    = aws_quicksight_data_set.this[0].data_set_id
  schedule_id    = try(var.quicksight.schedule_id, "daily")

  schedule {
    schedule_frequency {
      interval = try(var.quicksight.refresh_interval, "DAILY")
    }

    refresh_type = try(var.quicksight.refresh_type, "FULL_REFRESH")

    start_after_date_time = var.quicksight.start_after_date_time
  }
}