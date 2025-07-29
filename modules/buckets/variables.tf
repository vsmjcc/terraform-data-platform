variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}
