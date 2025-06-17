variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefixo padrão para os buckets"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
