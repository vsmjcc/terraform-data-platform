output "role_arn" { value = aws_iam_role.glue.arn }
output "job_name" { value = aws_glue_job.this.name }
output "script_s3_uri" { value = "s3://${var.script_bucket}/${var.script_key}" }
output "glue_connection" { value = var.use_vpc ? aws_glue_connection.vpc[0].name : null }
