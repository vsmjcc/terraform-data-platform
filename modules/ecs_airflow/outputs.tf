output "airflow_alb_dns_name" {
  description = "URL pública do Airflow Webserver"
  value       = aws_lb.airflow.dns_name
}

output "airflow_sg_id" {
  value = aws_security_group.airflow.id
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.airflow.domain_name
}