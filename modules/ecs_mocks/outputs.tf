output "service_name" {
  description = "Nome do serviço ECS criado"
  value       = aws_ecs_service.this.name
}

output "alb_dns_name" {
  description = "DNS do Load Balancer"
  value       = aws_lb.this.dns_name
}

output "application_url" {
  description = "URL HTTPS da aplicação"
  value       = "https://${aws_route53_record.dns.name}"
}

output "security_group_id" {
  description = "Security Group da aplicação"
  value       = aws_security_group.app.id
}

output "log_group_name" {
  description = "CloudWatch Logs group"
  value       = aws_cloudwatch_log_group.this.name
}
