variable "environment" {
  description = "Ambiente da aplicação (ex: dev, prod)."
  type        = string
}

variable "aws_region" {
  description = "Região AWS onde os recursos serão provisionados."
  type        = string
}

variable "zone_id" {
  description = "ID da Hosted Zone no Route53."
  type        = string
}

variable "zone_name" {
  description = "Nome da zona DNS (ex: data.zerezes.dev)."
  type        = string
}

variable "certificate_arn" {
  description = "ARN do certificado ACM (us-east-1) utilizado pelo CloudFront e ALB."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o backend será executado."
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas para execução do ECS."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Lista de subnets públicas para o Application Load Balancer."
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "Nome do cluster ECS onde o serviço será criado."
  type        = string
}

variable "subdomain" {
  description = "Subdomínio base da aplicação (ex: settings)."
  type        = string
  default     = "settings"
}

variable "backend_container_image" {
  description = "Imagem do container backend. Opcional. Quando não informado, será usado o ECR criado automaticamente."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags aplicadas aos recursos AWS."
  type        = map(string)
  default     = {}
}