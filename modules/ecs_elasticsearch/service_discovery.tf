resource "aws_service_discovery_service" "elasticsearch" {
  name = var.name

  dns_config {
    namespace_id = var.service_discovery_namespace_id
    dns_records {
      type = "A"
      ttl  = 10
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}