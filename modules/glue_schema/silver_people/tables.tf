locals {
  tables = {

    # =========================
    # employees (funcionários)
    # =========================
    employees = {
      description = "Funcionários (Base DP) normalizada a partir de Google Sheets."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=gsheets/dataset=employees/"

      columns = [
        { name = "area", type = "string", comment = "Área" },
        { name = "full_name", type = "string", comment = "Nome completo" },
        { name = "description", type = "string", comment = "Descrição do cargo" },
        { name = "job_title", type = "string", comment = "Cargo" },
        { name = "seniority_level", type = "string", comment = "Nível de senioridade" },
        { name = "department_description", type = "string", comment = "Descrição do departamento" },
        { name = "cpf", type = "string", comment = "CPF (pode estar anonimizado)" },
        { name = "birthdate", type = "date", comment = "Data de nascimento" },
        { name = "gender", type = "string", comment = "Gênero" },
        { name = "race_color", type = "string", comment = "Raça/cor" },
        { name = "employment_status", type = "string", comment = "Situação do vínculo" },
        { name = "start_date", type = "date", comment = "Data de admissão" },
        { name = "end_date", type = "date", comment = "Data de demissão" },
        { name = "termination_reason", type = "string", comment = "Motivo da demissão" },
        { name = "state", type = "string", comment = "UF (AA)" },
        { name = "reason", type = "string", comment = "Observações/razão" }
      ]

      partition_keys = []
    }

    # ======================================
    # talent_employee_referrals (indicações)
    # ======================================
    talent_employee_referrals = {
      description = "Programa de indicação de talentos (respostas do formulário)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=gsheets/dataset=talent_employee_referrals/"

      columns = [
        { name = "submitted_at", type = "timestamp", comment = "Data/hora de submissão" },
        { name = "referrer_full_name", type = "string", comment = "Nome do colaborador que indicou" },
        { name = "referrer_email", type = "string", comment = "Email do colaborador que indicou (pode estar anonimizado)" },
        { name = "referrer_phone", type = "string", comment = "Telefone do colaborador que indicou" },
        { name = "candidate_resume_url", type = "string", comment = "URL do currículo" },
        { name = "candidate_linkedin_url", type = "string", comment = "URL do LinkedIn do candidato" },
        { name = "referred_role", type = "string", comment = "Vaga indicada" },
        { name = "relationship_to_candidate", type = "string", comment = "Relação com o candidato" },
        { name = "referrer_area", type = "string", comment = "Loja/área do colaborador" },
        { name = "diversity_info", type = "string", comment = "Informação de diversidade" },
        { name = "pc_review", type = "string", comment = "Parecer P&C" },
        { name = "hire_date", type = "string", comment = "Data de admissão (texto livre no sheet)" }
      ]

      partition_keys = []
    }
  }
}


module "tables" {
  source = "../../../modules/glue_table"

  for_each       = local.tables
  database_name  = var.database_name
  table_name     = each.key
  description    = each.value.description
  location       = each.value.location
  columns        = each.value.columns
  partition_keys = each.value.partition_keys

  parameters = {
    classification  = "parquet"
    compressionType = "snappy"
  }
}
