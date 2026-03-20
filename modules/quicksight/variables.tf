variable "environment" {
  description = "Ambiente (ex.: dev, staging, prod)"
  type        = string
}

variable "account_name" {
  description = "Nome da conta QuickSight. Necessário apenas se create_account_subscription = true."
  type        = string
  default     = null
}

variable "notification_email" {
  description = "Email administrativo do QuickSight. Usado em account settings e opcionalmente na criação da assinatura."
  type        = string
  default     = null
}

variable "edition" {
  description = "Edição do QuickSight. Necessário apenas se create_account_subscription = true."
  type        = string
  default     = "ENTERPRISE"

  validation {
    condition     = contains(["STANDARD", "ENTERPRISE", "ENTERPRISE_AND_Q"], var.edition)
    error_message = "edition deve ser STANDARD, ENTERPRISE ou ENTERPRISE_AND_Q."
  }
}

variable "authentication_method" {
  description = "Método de autenticação do QuickSight. Necessário apenas se create_account_subscription = true."
  type        = string
  default     = "IAM_IDENTITY_CENTER"

  validation {
    condition = contains([
      "IAM_AND_QUICKSIGHT",
      "IAM_ONLY",
      "ACTIVE_DIRECTORY",
      "IAM_IDENTITY_CENTER"
    ], var.authentication_method)
    error_message = "authentication_method inválido."
  }
}

variable "iam_identity_center_instance_arn" {
  description = "ARN da instância do IAM Identity Center. Se null, tenta descobrir automaticamente."
  type        = string
  default     = null
}

variable "admin_group_names" {
  description = "Lista de grupos admin. Usado apenas se create_account_subscription = true."
  type        = list(string)
  default     = []
}

variable "author_group_names" {
  description = "Lista de grupos author. Usado apenas se create_account_subscription = true."
  type        = list(string)
  default     = []
}

variable "reader_group_names" {
  description = "Lista de grupos reader. Usado apenas se create_account_subscription = true."
  type        = list(string)
  default     = []
}

variable "create_account_subscription" {
  description = "Se true, cria a assinatura inicial do QuickSight. Para contas já existentes, manter false."
  type        = bool
  default     = false
}

variable "create_account_settings" {
  description = "Define se o módulo deve aplicar configurações básicas da conta QuickSight."
  type        = bool
  default     = true
}

variable "default_namespace" {
  description = "Namespace padrão do QuickSight."
  type        = string
  default     = "default"
}

variable "termination_protection_enabled" {
  description = "Impede a exclusão acidental da conta QuickSight."
  type        = bool
  default     = true
}

variable "public_sharing_enabled" {
  description = "Habilita compartilhamento público no QuickSight."
  type        = bool
  default     = false
}

variable "athena_data_sources" {
  description = <<EOT
Mapa de data sources Athena oficiais a serem criadas no QuickSight.
Exemplo:
{
  athena_primary = {
    name           = "Athena Primary"
    data_source_id = "athena-primary"
    work_group     = "primary"
  }
}
EOT

  type = map(object({
    name           = string
    data_source_id = optional(string)
    work_group     = optional(string, "primary")
    ssl_properties = optional(object({
      disable_ssl = optional(bool, false)
    }), null)
    permissions = optional(list(object({
      principal = string
      actions   = list(string)
    })), [])
  }))
  default = {}
}

variable "create_vpc_connection" {
  description = "Se true, cria uma VPC connection para bancos privados."
  type        = bool
  default     = false
}

variable "vpc_connection_id" {
  description = "ID da VPC connection do QuickSight."
  type        = string
  default     = null
}

variable "vpc_connection_name" {
  description = "Nome da VPC connection do QuickSight."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "Subnets usadas na VPC connection do QuickSight."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "Security groups usados na VPC connection do QuickSight."
  type        = list(string)
  default     = []
}

variable "role_arn" {
  description = "IAM role usada pela VPC connection do QuickSight."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags padrão do módulo."
  type        = map(string)
  default     = {}
}