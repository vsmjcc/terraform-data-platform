# --- METADATA OUTPUTS ---
output "metadata_service_name" {
  description = "Nome do serviço ECS Metadata"
  value       = aws_ecs_service.metadata.name
}
output "metadata_security_group_id" {
  description = "ID do Security Group do Metadata"
  value       = aws_security_group.metadata.id
}
output "metadata_host" {
  description = "DNS do Metadata via Service Discovery"
  value       = "${aws_service_discovery_service.metadata.name}.${var.service_discovery_namespace_name}"
}

# --- SEARCH OUTPUTS ---
output "search_service_name" {
  description = "Nome do serviço ECS Search"
  value       = aws_ecs_service.search.name
}
output "search_security_group_id" {
  description = "ID do Security Group do Search"
  value       = aws_security_group.search.id
}
output "search_host" {
  description = "DNS do Search via Service Discovery"
  value       = "${aws_service_discovery_service.search.name}.${var.service_discovery_namespace_name}"
}

# --- FRONTEND OUTPUTS ---
output "frontend_service_name" {
  description = "Nome do serviço ECS Frontend"
  value       = aws_ecs_service.frontend.name
}
output "frontend_security_group_id" {
  description = "ID do Security Group do Frontend"
  value       = aws_security_group.frontend.id
}