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
  input     = jsonencode({ "action" = "stop" })
}

resource "aws_cloudwatch_event_target" "start" {
  rule      = aws_cloudwatch_event_rule.start.name
  target_id = "lambda-start"
  arn       = aws_lambda_alias.start.arn
  input     = jsonencode({ "action" = "start" })
}