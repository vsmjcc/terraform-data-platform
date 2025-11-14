
resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key

  environment {
    variables = var.environment_variables
  }

  # === VPC CONFIG (só se houver subnets) ===
  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : aws_security_group.lambda[*].id
    }
  }

  # === EFS CONFIG (só se efs_arn for fornecido) ===
  dynamic "file_system_config" {
    for_each = var.efs_arn != null ? [1] : []
    content {
      arn              = var.efs_arn
      local_mount_path = var.efs_mount_path
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}