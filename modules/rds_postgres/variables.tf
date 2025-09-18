variable "environment" {
  description = "Ambiente (ex: dev, staging, prod)"
  type        = string
}

variable "identifier" {
  description = "Identificador do RDS"
  type        = string
}

variable "db_name" {
  description = "database name"
  type        = string
}

variable "username" {
  description = "Usuário master"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID "
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnet IDs privadas"
  type        = list(string)
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "IDs das subnets privadas usadas para gerar regras de acesso no SG"
}