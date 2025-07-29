variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nome do bucket (deve ser único globalmente)"
  type        = string
}

variable "versioning_enabled" {
  description = "Se o versionamento estará habilitado"
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Se deve forçar a destruição do bucket (mesmo com arquivos)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags do bucket"
  type        = map(string)
  default     = {}
}

variable "block_public_access" {
  description = "Se deve bloquear acesso público (altamente recomendado)"
  type        = bool
  default     = true
}