variable "cluster_name" {
  description = "Nome do ECS Cluster onde o Airflow vai rodar"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets privadas onde o Airflow vai rodar"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group para o Airflow"
  type        = string
}

variable "rds_secret_arn" {
  description = "ARN do Secrets Manager com a senha do banco"
  type        = string
}

variable "db_host" {
  description = "Endpoint do banco de dados Postgres"
  type        = string
}

variable "db_username" {
  description = "db username"
  type        = string
}

variable "db_password" {
  description = "db password"
  type        = string
}

variable "db_name" {
  description = "database name"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}
