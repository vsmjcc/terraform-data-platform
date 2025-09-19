
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
  }
}

locals {
  lambda_name = "${var.name_prefix}-lambda"
  role_name   = "${var.name_prefix}-role"
  policy_name = "${var.name_prefix}-policy"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_iam_role" "lambda_role" {
  name               = local.role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action   = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = local.policy_name
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect: "Allow",
        Action: ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"],
        Resource: "*"
      },
      { Effect: "Allow", Action: ["tag:GetResources"], Resource: "*" },
      {
        Effect: "Allow",
        Action: [
          "ecs:ListClusters",
          "ecs:ListServices",
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:ListTagsForResource",
          "ecs:TagResource",      
          "ecs:UntagResource"     
        ],
        Resource: "*"
      },

      {
        Effect: "Allow",
        Action: [
          "autoscaling:DescribeAutoScalingGroups","autoscaling:UpdateAutoScalingGroup",
          "autoscaling:CreateOrUpdateTags","autoscaling:DeleteTags"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "ec2:DescribeInstances","ec2:StopInstances","ec2:StartInstances",
          "ec2:CreateTags","ec2:DescribeTags"
        ],
        Resource: "*"
      },
      {
        Effect: "Allow",
        Action: [
          "rds:DescribeDBInstances","rds:StopDBInstance","rds:StartDBInstance",
          "rds:ListTagsForResource"
        ],
        Resource: "*"
      }
    ]
  })
}


resource "aws_lambda_function" "this" {
  function_name = local.lambda_name
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.12"
  handler       = "app.handler"
  memory_size   = var.lambda_memory_mb
  timeout       = var.lambda_timeout_seconds

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TAG_KEY   = var.tag_key
      TAG_VALUES = join(",", var.tag_values)
      MANAGE_ECS = tostring(var.manage_ecs)
      MANAGE_ASG = tostring(var.manage_asg)
      MANAGE_EC2 = tostring(var.manage_ec2)
      MANAGE_RDS = tostring(var.manage_rds)
      ECS_DESIRED_DEFAULT_ON_START = tostring(var.ecs_desired_default_on_start)
      ASG_DEFAULT_MIN = tostring(var.asg_default_on_start.min)
      ASG_DEFAULT_MAX = tostring(var.asg_default_on_start.max)
      ASG_DEFAULT_DESIRED = tostring(var.asg_default_on_start.desired)
      ACTION = "stop"
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

resource "aws_cloudwatch_event_rule" "stop" {
  name                = "${var.name_prefix}-stop-rule"
  schedule_expression = var.stop_cron_utc
  tags                = var.tags
}

resource "aws_cloudwatch_event_rule" "start" {
  name                = "${var.name_prefix}-start-rule"
  schedule_expression = var.start_cron_utc
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "stop" {
  rule      = aws_cloudwatch_event_rule.stop.name
  target_id = "lambda-stop"
  arn       = aws_lambda_alias.stop.arn
  input     = jsonencode({ "action": "stop" })
}

resource "aws_cloudwatch_event_target" "start" {
  rule      = aws_cloudwatch_event_rule.start.name
  target_id = "lambda-start"
  arn       = aws_lambda_alias.start.arn
  input     = jsonencode({ "action": "start" })
}

resource "aws_lambda_permission" "allow_events_start" {
  statement_id  = "AllowEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  qualifier     = aws_lambda_alias.start.name   # <-- alias start
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start.arn  # <-- regra start
}

resource "aws_lambda_permission" "allow_events_stop" {
  statement_id  = "AllowEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  qualifier     = aws_lambda_alias.stop.name    # <-- alias stop
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop.arn   # <-- regra stop
}

output "lambda_name" { value = aws_lambda_function.this.function_name }
output "stop_rule_arn" { value = aws_cloudwatch_event_rule.stop.arn }
output "start_rule_arn" { value = aws_cloudwatch_event_rule.start.arn }
