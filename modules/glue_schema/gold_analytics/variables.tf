variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "bucket" {
  type = string
}

variable "database_name" {
  type = string
}

variable "domain" {
  type = string
}

variable "athena_workgroup" {
  type    = string
  default = "primary"
}

variable "athena_output_location" {
  description = "Bucket/prefix para resultados do Athena, ex: s3://zrzs-dev-athena-results/primary/"
  type        = string
}

variable "quicksight_data_sources" {
  description = "Mapa de data sources do QuickSight já criados, por chave lógica (ex.: gold)"
  type = map(object({
    arn = string
  }))
  default = {}
}
