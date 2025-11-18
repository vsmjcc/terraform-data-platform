locals {
  aws_accounts_by_env = {
    dev  = "414669981241"
    prod = "151632973153"
  }

  expected_aws_account_id = local.aws_accounts_by_env[var.environment]
}

data "aws_caller_identity" "current" {}

resource "null_resource" "guardrail_account" {
  lifecycle {
    precondition {
      condition = data.aws_caller_identity.current.account_id == local.expected_aws_account_id

      error_message = <<EOF
Conta AWS incorreta!

Você está logada na conta: ${data.aws_caller_identity.current.account_id}

Para o ambiente "${var.environment}", a conta esperada é:
- ${local.expected_aws_account_id}

Abortando o deploy para evitar alterações na conta errada.
EOF
    }
  }
}
