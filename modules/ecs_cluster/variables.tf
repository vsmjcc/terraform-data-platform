variable "cluster_name" {
  description = "Nome base do ECS Cluster"
  type        = string
}

variable "environment" {
  description = "Ambiente (ex: dev, prod)"
  type        = string
}