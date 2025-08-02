variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "packages_bucket_name" {
  description = "packages bucket name"
  type        = string
}

variable "bronze_bucket_name" {
  description = "Broze bucket name"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
  default     = null
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnets privadas da VPC onde a Lambda deve rodar"
}

variable "volumes" {
  description = "Mapa com informações dos volumes EFS"
  type = map(object({
    efs_id            = string
    efs_arn           = string
    security_group_id = string
  }))
}