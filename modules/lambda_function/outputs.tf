output "lambda_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}


output "http_api_url" {
  value = (
    length(aws_apigatewayv2_domain_name.custom) > 0
    ? "https://${aws_apigatewayv2_domain_name.custom[0].domain_name}"
    : (
      length(aws_apigatewayv2_api.this) > 0
      ? "${aws_apigatewayv2_api.this[0].api_endpoint}"
      : null
    )
  )
}