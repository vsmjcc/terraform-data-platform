variable "private_subnet_ids" {
  description = "Subnets privadas usadas para os volumes"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC para criação dos SGs dos volumes"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}
