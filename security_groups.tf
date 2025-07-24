# resource "aws_security_group" "rds" {
#   name        = "rds-airflow-dev"
#   description = "Allow inbound PostgreSQL from ECS tasks"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     description = "Allow PostgreSQL from VPC"
#     from_port   = 5432
#     to_port     = 5432
#     protocol    = "tcp"
#     cidr_blocks = ["10.30.0.0/16"]  # Ajuste para o CIDR da sua VPC
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_security_group" "airflow" {
#   name        = "airflow-${var.environment}-sg"
#   description = "Security Group for Airflow Tasks"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port   = 8080
#     to_port     = 8080
#     protocol    = "tcp"
#     cidr_blocks = ["201.42.76.74/32"]
#     description = "Isa access to Airflow Webserver"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "airflow-${var.environment}-sg"
#   }
# }
