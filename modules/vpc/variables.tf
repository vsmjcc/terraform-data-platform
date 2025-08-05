variable "vpc_cidr_block" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }

variable "private_azs" {
  description = "Availability Zones para subnets privadas"
  type        = list(string)
}

variable "public_azs" {
  description = "Availability Zones para subnets públicas"
  type        = list(string)
}

variable "nat_gateway_id" {
  description = "ID do NAT Gateway para rotas privadas (opcional)"
  type        = string
  default     = null
}

variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "region" {
  description = "Região AWS"
  type        = string
}

variable "enable_vpc_flow_logs" {
  description = "Ativa logs de fluxo da VPC para S3"
  type        = bool
  default     = false
}