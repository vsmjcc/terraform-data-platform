
variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "db_username" {
  description = "Usuário do banco de dados"
  type        = string
}

variable "db_password" {
  description = "Senha do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Host do banco de dados"
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "ecr_repo_url" {
  description = "URL do repositório ECR (sem tag)"
  type        = string
}

variable "aws_region" {
  description = "Região AWS (ex: us-east-1)"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas para o ECS"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Lista de subnets públicas para o ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID da VPC onde os recursos serão criados"
  type        = string
}

variable "worker_count" {
  description = "Quantidade de workers para o Airflow"
  type        = number
  default     = 1
}

variable "redis_host" {
  description = "Redis endpoint para CeleryExecutor"
  type        = string
}

variable "efs_id" {
  description = "ID do EFS que armazenará os DAGs"
  type        = string
}

variable "efs_access_point_id" {
  description = "Access Point do EFS para montar o volume"
  type        = string
}

variable "efs_security_group_id" {
  type        = string
  default     = null
  description = "ID do SG do EFS que os containers precisa acessar (para liberar porta 2049)"
}

variable "dns_zone_id" {
  description = "ID da zona hospedada no Route 53"
  type        = string
  default     = null
}

variable "dns_zone_name" {
  description = "Nome da zona hospedada no Route 53"
  type        = string
  default     = null
}

variable "dns_certificate_arn" {
  description = "ARN do certificado SSL (ACM)"
  type        = string
  default     = null
}