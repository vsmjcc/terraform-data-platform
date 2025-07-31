variable "function_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "handler" {
  description = "Handler da função"
  type        = string
  default     = "main.handler"
}

variable "runtime" {
  description = "Runtime da função Lambda"
  type        = string
  default     = "python3.11"
}

variable "memory_size" {
  type        = number
  default     = 128
}

variable "timeout" {
  type        = number
  default     = 10
}

variable "enable_http_api" {
  description = "Se deve criar um API Gateway HTTP vinculado à função Lambda"
  type        = bool
  default     = false
}

variable "public_access" {
  description = "Se o API Gateway deve permitir invocação pública"
  type        = bool
  default     = false
}

variable "s3_bucket" {
  description = "Bucket S3 que contém o código da função Lambda"
  type        = string
}

variable "s3_key" {
  description = "Chave do arquivo .zip no S3 com o código da Lambda"
  type        = string
}

variable "environment_variables" {
  description = "Variáveis de ambiente da Lambda"
  type        = map(string)
  default     = {}
}

variable "log_retention_in_days" {
  description = "Retention for the Lambda CloudWatch Logs group"
  type        = number
  default     = 30
}

variable "create_log_group" {
  description = "Whether to pre-create the CloudWatch Logs group for the Lambda"
  type        = bool
  default     = true
}