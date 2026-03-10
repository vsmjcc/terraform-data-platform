
data "aws_subnet" "selected" {
  count = var.use_vpc ? 1 : 0
  id    = var.subnet_ids[0]
}

resource "aws_glue_job" "this" {
  name     = "${var.name}"
  role_arn = aws_iam_role.glue.arn

  glue_version      = var.glue_version
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  execution_class   = var.execution_class
  max_retries       = var.max_retries

  command {
    name            = "glueetl"
    script_location = "s3://${var.script_bucket}/${var.script_key}"
    python_version  = "3"
  }

  default_arguments = merge(
    {
      "--TempDir"                          = "s3://${var.temp_bucket}/${var.temp_prefix}"
      "--enable-continuous-cloudwatch-log" = "true"
      "--enable-metrics"                   = "true"
      "--enable-glue-datacatalog"          = "true"
      "--job-bookmark-option"              = "job-bookmark-enable"
      "--conf"                             = "spark.sql.sources.partitionOverwriteMode=dynamic"
    },
    var.default_arguments
  )


  connections = var.use_vpc ? [aws_glue_connection.vpc[0].name] : []

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.attach_service_managed,
    aws_iam_role_policy_attachment.attach_s3,
    aws_iam_role_policy_attachment.attach_logs_catalog,
    aws_iam_role_policy_attachment.attach_kms
  ]
}
