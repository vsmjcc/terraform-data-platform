variable "vpc_id" {
  description = "VPC ID para o Redis"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subnets privadas para o Redis"
  type        = list(string)
}

variable "aws_region" {
  description = "Região da AWS usada para configurar o CloudWatch Logs"
  type        = string
}

variable "name" {
  description = "Nome base do serviço Redis"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "Nome do ECS cluster"
  type        = string
}

variable "allowed_security_groups" {
  description = "SGs que terão acesso ao Redis"
  type        = list(string)
  default     = []
}

variable "service_discovery_namespace_id" {
  description = "ID do namespace do Cloud Map (ex: zerezes.local)"
  type        = string
}

variable "service_discovery_namespace_name" {
  description = "Ex: zerezes.local"
  type        = string
}