
output "lambda_arn" { value = aws_lambda_function.this.arn }
output "event_rules" { value = { stop = aws_cloudwatch_event_rule.stop.arn, start = aws_cloudwatch_event_rule.start.arn } }
