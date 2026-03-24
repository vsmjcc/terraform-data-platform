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

variable "backend_container_port" {
  description = "Porta exposta pelo container backend."
  type        = number
  default     = 8000
}

variable "backend_cpu" {
  description = "Quantidade de CPU alocada para a task ECS."
  type        = number
  default     = 512
}

variable "backend_memory" {
  description = "Quantidade de memória (MB) alocada para a task ECS."
  type        = number
  default     = 1024
}

variable "backend_desired_count" {
  description = "Quantidade desejada de instâncias do serviço ECS."
  type        = number
  default     = 1
}

variable "backend_health_check_path" {
  description = "Endpoint utilizado para health check do backend."
  type        = string
  default     = "/health"
}

variable "backend_environment_variables" {
  description = "Variáveis de ambiente do backend (mapa chave => valor)."
  type        = map(string)
  default     = {}
}

variable "backend_secrets" {
  description = "Secrets do backend no formato nome => ARN (Secrets Manager ou SSM)."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags aplicadas aos recursos AWS."
  type        = map(string)
  default     = {}
}