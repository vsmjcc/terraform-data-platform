locals {
  resource_prefix = "${var.name}-${var.environment}"
  domain_name     = "${var.subdomain}.${var.dns_zone_name}"

  repository_name = coalesce(var.ecr_repository_name, var.name)

  resolved_container_image = var.container_image != null ? var.container_image : (
    var.create_ecr_repository ? "${aws_ecr_repository.app[0].repository_url}:${var.image_tag}" : null
  )

  container_environment = [
    for k, v in var.environment_variables : {
      name  = k
      value = v
    }
  ]

  container_secrets = [
    for k, v in var.secrets : {
      name      = k
      valueFrom = v
    }
  ]
}