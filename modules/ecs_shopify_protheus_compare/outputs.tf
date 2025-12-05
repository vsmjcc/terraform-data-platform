output "service_name" {
  description = "Nome do serviço ECS criado"
  value       = aws_ecs_service.shopify.name
}

output "alb_dns_name" {
  description = "DNS direto do Load Balancer (sem Route53)"
  value       = aws_lb.shopify.dns_name
}

output "application_url" {
  description = "URL final da aplicação (HTTPS)"
  value       = "https://${aws_route53_record.shopify_dns.name}"
}

output "security_group_id" {
  description = "ID do Security Group da aplicação (caso precise liberar acesso extra)"
  value       = aws_security_group.shopify_app.id
}

output "log_group_name" {
  description = "Nome do grupo de logs no CloudWatch"
  value       = aws_cloudwatch_log_group.shopify.name
}