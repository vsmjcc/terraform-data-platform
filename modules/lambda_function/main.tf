resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size

  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key

  environment {
    variables = var.environment_variables
  }

  lifecycle {
    ignore_changes = [
      s3_key,
      s3_bucket,
      source_code_hash
    ]
  }
}

resource "aws_apigatewayv2_api" "this" {
  count          = var.enable_http_api ? 1 : 0
  name           = "${var.function_name}-api"
  protocol_type  = "HTTP"
}

resource "aws_lambda_permission" "allow_apigw" {
  count         = var.enable_http_api && var.public_access ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this[0].execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "this" {
  count               = var.enable_http_api ? 1 : 0
  api_id              = aws_apigatewayv2_api.this[0].id
  integration_type    = "AWS_PROXY"
  integration_uri     = aws_lambda_function.this.invoke_arn
  integration_method  = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "this" {
  count     = var.enable_http_api ? 1 : 0
  api_id    = aws_apigatewayv2_api.this[0].id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.this[0].id}"
}

resource "aws_apigatewayv2_stage" "default" {
  count       = var.enable_http_api ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  name        = "$default"
  auto_deploy = true
}
