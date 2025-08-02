module "airflow_dags_volume" {
  source = "../efs_volume"

  name                  = "airflow-${var.environment}-dags-efs"
  subnet_ids            = var.private_subnet_ids
  create_security_group = true
  vpc_id                = var.vpc_id

  access_point_path = "/airflow-dags"
  access_point_uid  = 1000
  access_point_gid  = 1000

  tags = {
    Environment = var.environment
    Service     = "airflow"
  }
}

locals {
  volume_modules = {
    airflow_dags = module.airflow_dags_volume
  }
}
