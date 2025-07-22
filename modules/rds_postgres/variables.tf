variable "identifier" {
  description = "Identificador do RDS"
  type        = string
}

variable "username" {
  description = "Usuário master"
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnet IDs privadas"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID do Security Group para o RDS"
  type        = string
}