output "airflow_alb_dns_name" {
  description = "URL pública do Airflow Webserver"
  value       = aws_lb.airflow.dns_name
}

output "airflow_sg_id" {
  value = aws_security_group.airflow.id
}

output "airflow_url" {
  description = "URL pública do Airflow com HTTPS"
  value       = "https://airflow.${var.dns_zone_name}"
}