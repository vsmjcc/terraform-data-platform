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