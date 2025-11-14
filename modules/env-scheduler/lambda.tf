
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = local.lambda_name
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.12"
  handler          = "app.handler"
  memory_size      = var.lambda_memory_mb
  timeout          = var.lambda_timeout_seconds
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TAG_KEY                     = var.tag_key
      TAG_VALUES                  = join(",", var.tag_values)
      MANAGE_ECS                  = tostring(var.manage_ecs)
      MANAGE_ASG                  = tostring(var.manage_asg)
      MANAGE_EC2                  = tostring(var.manage_ec2)
      MANAGE_RDS                  = tostring(var.manage_rds)
      ECS_DESIRED_DEFAULT_ON_START = tostring(var.ecs_desired_default_on_start)
      ASG_DEFAULT_MIN             = tostring(var.asg_default_on_start.min)
      ASG_DEFAULT_MAX             = tostring(var.asg_default_on_start.max)
      ASG_DEFAULT_DESIRED         = tostring(var.asg_default_on_start.desired)
      ACTION                      = "stop"  # será sobrescrito pelo EventBridge
    }
  }

  tags = var.tags
}

resource "aws_lambda_alias" "stop" {
  name             = "stop"
  function_name    = aws_lambda_function.this.arn
  function_version = "$LATEST"
}

resource "aws_lambda_alias" "start" {
  name             = "start"
  function_name    = aws_lambda_function.this.arn
  function_version = "$LATEST"
}