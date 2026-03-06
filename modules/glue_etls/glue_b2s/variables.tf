variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

# Se já existir um SG para Glue, passe aqui. Se null, este módulo cria um.
variable "glue_sg_id" {
  type    = string
  default = null
}

# Buckets (sem ARN)
variable "bronze_bucket" {
  type = string # ex: "zrzs-dev-data-lake-bronze"
}

variable "silver_bucket" {
  type = string # ex: "zrzs-dev-data-lake-silver"
}

variable "etls_bucket" {
  type = string # ex: "zrzs-dev-etls"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
