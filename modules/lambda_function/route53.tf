data "aws_route53_zone" "selected" {
  count   = var.enable_custom_domain ? 1 : 0
  zone_id = var.dns_zone_id
}

resource "aws_apigatewayv2_domain_name" "custom" {
  count = var.enable_http_api && var.enable_custom_domain ? 1 : 0

  domain_name = "${var.function_name}.${data.aws_route53_zone.selected[0].name}"

  domain_name_configuration {
    certificate_arn = var.dns_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "custom_dns" {
  count = var.enable_http_api && var.enable_custom_domain ? 1 : 0

  zone_id = var.dns_zone_id
  name    = "${var.function_name}.${data.aws_route53_zone.selected[0].name}"
  type    = "CNAME"
  ttl     = 300

  records = [
    aws_apigatewayv2_domain_name.custom[0].domain_name_configuration[0].target_domain_name
  ]
}

resource "aws_apigatewayv2_api_mapping" "custom" {
  count       = var.enable_http_api && var.enable_custom_domain ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  domain_name = aws_apigatewayv2_domain_name.custom[0].domain_name
  stage       = aws_apigatewayv2_stage.default[0].name
}
