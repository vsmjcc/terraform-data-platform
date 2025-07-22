# Makefile - Terraform Data Platform (Zerezes)

AWS_PROFILE_DEV=zerezes-data-dev
AWS_PROFILE_PROD=zerezes-data-prod

TFVARS_DEV=envs/dev/main.tfvars
TFVARS_PROD=envs/prod/main.tfvars

##########
# Dev
##########

login-dev:
	aws sso login --profile $(AWS_PROFILE_DEV)

init-dev:
	AWS_PROFILE=$(AWS_PROFILE_DEV) terraform init -reconfigure

plan-dev:
	AWS_PROFILE=$(AWS_PROFILE_DEV) terraform plan -var-file=$(TFVARS_DEV)

apply-dev:
	AWS_PROFILE=$(AWS_PROFILE_DEV) terraform apply -var-file=$(TFVARS_DEV)

destroy-dev:
	AWS_PROFILE=$(AWS_PROFILE_DEV) terraform destroy -var-file=$(TFVARS_DEV)

refresh-dev:
	AWS_PROFILE=$(AWS_PROFILE_DEV) terraform refresh -var-file=$(TFVARS_DEV)

##########
# Prod
##########

login-prod:
	aws sso login --profile $(AWS_PROFILE_PROD)

init-prod:
	AWS_PROFILE=$(AWS_PROFILE_PROD) terraform init -reconfigure

plan-prod:
	AWS_PROFILE=$(AWS_PROFILE_PROD) terraform plan -var-file=$(TFVARS_PROD)

apply-prod:
	AWS_PROFILE=$(AWS_PROFILE_PROD) terraform apply -var-file=$(TFVARS_PROD)

destroy-prod:
	AWS_PROFILE=$(AWS_PROFILE_PROD) terraform destroy -var-file=$(TFVARS_PROD)

refresh-prod:
	AWS_PROFILE=$(AWS_PROFILE_PROD) terraform refresh -var-file=$(TFVARS_PROD)

##########
# Geral
##########

validate:
	terraform validate

fmt:
	terraform fmt -recursive
