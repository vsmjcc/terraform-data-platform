output "lambda_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "http_api_url" {
  value       = var.enable_http_api ? aws_apigatewayv2_api.this[0].api_endpoint : null
  description = "Endpoint HTTP do API Gateway (se aplicável)"
}
