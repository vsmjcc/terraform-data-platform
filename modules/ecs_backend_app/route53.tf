resource "aws_route53_record" "app" {
  zone_id = var.dns_zone_id
  name    = local.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}