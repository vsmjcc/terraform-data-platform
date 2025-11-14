resource "aws_apigatewayv2_api" "this" {
  count         = var.enable_http_api ? 1 : 0
  name          = "${var.function_name}-http-api"  # ← padronizado
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "api_gateway" {
  count         = var.enable_http_api ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this[0].execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "this" {
  count             = var.enable_http_api ? 1 : 0
  api_id            = aws_apigatewayv2_api.this[0].id
  integration_type  = "AWS_PROXY"
  integration_uri   = aws_lambda_function.this.invoke_arn
  integration_method = "POST"
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