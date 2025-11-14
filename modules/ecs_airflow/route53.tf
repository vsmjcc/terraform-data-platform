resource "aws_route53_record" "airflow_dns" {
  zone_id = var.dns_zone_id
  name    = "airflow.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.airflow.dns_name]
}