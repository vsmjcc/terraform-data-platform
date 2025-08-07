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

variable "efs_arn" {
  type        = string
  default     = null
  description = "ARN do EFS Access Point (para montar EFS na Lambda)"
}

variable "efs_mount_path" {
  type        = string
  default     = "/mnt/efs"
  description = "Caminho local onde o EFS será montado"
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnets privadas da VPC onde a Lambda deve rodar"
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "Security groups da Lambda (requerido se usar VPC)"
}

variable "vpc_id" {
  description = "ID da VPC usada para o SG da Lambda (obrigatório se create_sg for true)"
  type        = string
  default     = null
}

variable "efs_security_group_id" {
  type        = string
  default     = null
  description = "ID do SG do EFS que a Lambda precisa acessar (para liberar porta 2049)"
}

variable "allow_efs_ingress" {
  description = "Se deve adicionar uma regra no SG do EFS para permitir acesso da Lambda"
  type        = bool
  default     = false
}

variable "enable_custom_domain" {
  description = "Se true, cria o domínio customizado com certificado"
  type        = bool
  default     = false
}

variable "dns_zone_id" {
  description = "ID da zona hospedada no Route 53"
  type        = string
  default     = null
}

variable "dns_certificate_arn" {
  description = "ARN do certificado SSL (ACM)"
  type        = string
  default     = null
}