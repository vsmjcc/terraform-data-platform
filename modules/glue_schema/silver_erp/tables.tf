locals {
  tables = {
    omie_products = {
      description = "Catálogo de produtos do Omie (flattened a nível de produto)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_products/"

      columns = [
        # Identificação básica
        { name = "product_id",            type = "bigint",   comment = "ID interno do produto no Omie (codigo_produto)" },
        { name = "product_code",          type = "string",   comment = "Código principal do produto (codigo)" },
        { name = "integration_code",      type = "string",   comment = "Código de integração do produto (codigo_produto_integracao)" },
        { name = "description",           type = "string",   comment = "Descrição do produto (descricao)" },
        { name = "unit",                  type = "string",   comment = "Unidade de medida (unidade)" },
        { name = "ncm",                   type = "string",   comment = "Código NCM do produto" },
        { name = "ean",                   type = "string",   comment = "Código de barras EAN" },

        # Preço base
        { name = "unit_price",            type = "double",   comment = "Valor unitário cadastrado (valor_unitario)" },

        # Família / categoria
        { name = "family_id",             type = "bigint",   comment = "ID da família de produtos (codigo_familia)" },
        { name = "family_name",           type = "string",   comment = "Descrição da família (descricao_familia)" },

        # Tipo de item / natureza
        { name = "item_type",             type = "string",   comment = "Tipo do item no Omie (tipoItem: 00=mercadoria, 02=uso/consumo, 99=serviço/etc)" },

        # Variação / lote (se for usado no futuro)
        { name = "has_variation",         type = "boolean",  comment = "Indica se o produto possui variação (produto_variacao)" },
        { name = "has_batch_control",     type = "boolean",  comment = "Indica se o produto possui controle de lote (produto_lote)" },

        # Dimensões e peso (se vierem a ser usados em logística)
        { name = "weight_net",            type = "double",   comment = "Peso líquido" },
        { name = "weight_gross",          type = "double",   comment = "Peso bruto" },
        { name = "height",                type = "double",   comment = "Altura" },
        { name = "width",                 type = "double",   comment = "Largura" },
        { name = "depth",                 type = "double",   comment = "Profundidade" },

        # Marca / modelo
        { name = "brand",                 type = "string",   comment = "Marca do produto" },
        { name = "model",                 type = "string",   comment = "Modelo do produto" },

        # Textos longos internos
        { name = "detailed_description",  type = "string",   comment = "Descrição detalhada (descr_detalhada)" },
        { name = "internal_notes",        type = "string",   comment = "Observações internas (obs_internas)" },

        # Flags de exibição
        { name = "show_description_nf",   type = "boolean",  comment = "Exibir descrição na NFe (exibir_descricao_nfe)" },
        { name = "show_description_order",type = "boolean",  comment = "Exibir descrição no pedido (exibir_descricao_pedido)" },

        # Recomendações fiscais / comércio
        { name = "cnpj_manufacturer",     type = "string",   comment = "CNPJ do fabricante (recomendacoes_fiscais.cnpj_fabricante)" },
        { name = "allow_coupon",          type = "boolean",  comment = "Permite cupom fiscal (recomendacoes_fiscais.cupom_fiscal)" },
        { name = "marketplace_enabled",   type = "boolean",  comment = "Habilitado para marketplace (recomendacoes_fiscais.market_place)" },
        { name = "origin_code",           type = "string",   comment = "Origem da mercadoria (recomendacoes_fiscais.origem_mercadoria)" },

        # Tributação principal (mantida mais enxuta)
        { name = "cst_icms",              type = "string",   comment = "CST ICMS" },
        { name = "csosn_icms",            type = "string",   comment = "CSOSN ICMS (Simples Nacional)" },
        { name = "icms_rate",             type = "double",   comment = "Alíquota de ICMS" },
        { name = "icms_base_reduction",   type = "double",   comment = "Redução de base de cálculo do ICMS" },

        { name = "cst_pis",               type = "string",   comment = "CST PIS" },
        { name = "pis_rate",              type = "double",   comment = "Alíquota de PIS" },

        { name = "cst_cofins",            type = "string",   comment = "CST COFINS" },
        { name = "cofins_rate",           type = "double",   comment = "Alíquota de COFINS" },

        { name = "cfop",                  type = "string",   comment = "CFOP padrão do produto" },

        # IBPT (mantendo apenas as alíquotas consolidadas)
        { name = "ibpt_state_rate",       type = "double",   comment = "Alíquota IBPT estadual (dadosIbpt.aliqEstadual)" },
        { name = "ibpt_federal_rate",     type = "double",   comment = "Alíquota IBPT federal (dadosIbpt.aliqFederal)" },
        { name = "ibpt_municipal_rate",   type = "double",   comment = "Alíquota IBPT municipal (dadosIbpt.aliqMunicipal)" },

        # Estoque (snapshot do cadastro – não substitui fato de estoque)
        { name = "stock_quantity",        type = "double",   comment = "Quantidade em estoque informada no cadastro" },
        { name = "stock_minimum",         type = "double",   comment = "Estoque mínimo" },

        # Status / flags de uso
        { name = "is_blocked",            type = "boolean",  comment = "Produto bloqueado (bloqueado)" },
        { name = "block_delete",          type = "boolean",  comment = "Bloqueia exclusão (bloquear_exclusao)" },
        { name = "is_imported_api",       type = "boolean",  comment = "Indica se foi importado via API (importado_api)" },
        { name = "is_inactive",           type = "boolean",  comment = "Indica se o produto está inativo (inativo)" },

        # Datas / autoria (construídas a partir de info.dInc/dAlt + hInc/hAlt na silver)
        { name = "created_at",            type = "timestamp",comment = "Data/hora de inclusão no Omie" },
        { name = "created_by",            type = "string",   comment = "Usuário que incluiu o produto no Omie" },
        { name = "updated_at",            type = "timestamp",comment = "Data/hora da última alteração no Omie" },
        { name = "updated_by",           type = "string",    comment = "Usuário que realizou a última alteração" },

        # Metadados de origem / ingestão
        { name = "source_cnpj",           type = "string",   comment = "CNPJ da empresa no Omie (params.cnpj / _cnpj)" },
        { name = "source_system",         type = "string",   comment = "Sistema de origem (ex: Omie)" }
      ]

      # Particionado por data de ingestão do batch
      partition_keys = [
        {
          name    = "ingestion_date"
          type    = "date"
          comment = "Data de ingestão do produto (YYYY-MM-DD)"
          projection = {
            type          = "date"
            format        = "yyyy-MM-dd"
            range         = "2020-01-01,NOW"
            interval      = "1"
            interval_unit = "DAYS"
          }
        }
      ]
    }

    omie_product_characteristics = {
      description = "Características de produtos do Omie (uma linha por produto x característica)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_product_characteristics/"

      columns = [
        # Chaves de ligação
        { name = "product_id",                  type = "bigint",  comment = "ID interno do produto no Omie (codigo_produto)" },
        { name = "product_code",                type = "string",  comment = "Código principal do produto (codigo)" },

        # Identificação da característica
        { name = "characteristic_id",           type = "bigint",  comment = "ID interno da característica no Omie (nCodCaract)" },
        { name = "characteristic_name",         type = "string",  comment = "Nome da característica (cNomeCaract)" },
        { name = "characteristic_value",        type = "string",  comment = "Valor da característica (cConteudo)" },

        # Flags de exibição
        { name = "show_on_invoice",            type = "boolean", comment = "Exibir na NFe (cExibirItemNF)" },
        { name = "show_on_order",              type = "boolean", comment = "Exibir no pedido (cExibirItemPedido)" },
        { name = "show_on_production_order",   type = "boolean", comment = "Exibir na ordem de produção (cExibirOrdemProd)" },

        # Código de integração da característica (se vier a ser usado)
        { name = "characteristic_integration_code", type = "string", comment = "Código de integração da característica (cCodIntCaract)" },

        # Metadados
        { name = "source_cnpj",                type = "string",  comment = "CNPJ da empresa no Omie" },
        { name = "source_system",              type = "string",  comment = "Sistema de origem (ex: Omie)" }
      ]

      partition_keys = [
        {
          name    = "ingestion_date"
          type    = "date"
          comment = "Data de ingestão do produto (YYYY-MM-DD)"
          projection = {
            type          = "date"
            format        = "yyyy-MM-dd"
            range         = "2020-01-01,NOW"
            interval      = "1"
            interval_unit = "DAYS"
          }
        }
      ]
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
  parameters     = { classification = "parquet", compressionType = "snappy" }
}

