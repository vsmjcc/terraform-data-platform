locals {
  tables = {

    omie_products = {
      description = "Catálogo de produtos do Omie (flattened a nível de produto)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_products/"

      columns = [
        # Identificação básica
        { name = "product_id", type = "bigint", comment = "ID interno do produto no Omie (codigo_produto)" },
        { name = "product_code", type = "string", comment = "Código principal do produto (codigo)" },
        { name = "integration_code", type = "string", comment = "Código de integração do produto (codigo_produto_integracao)" },
        { name = "description", type = "string", comment = "Descrição do produto (descricao)" },
        { name = "unit", type = "string", comment = "Unidade de medida (unidade)" },
        { name = "ncm", type = "string", comment = "Código NCM do produto" },
        { name = "ean", type = "string", comment = "Código de barras EAN" },

        # Preço base
        { name = "unit_price", type = "double", comment = "Valor unitário cadastrado (valor_unitario)" },

        # Família / categoria
        { name = "family_id", type = "bigint", comment = "ID da família de produtos (codigo_familia)" },
        { name = "family_name", type = "string", comment = "Descrição da família (descricao_familia)" },

        # Tipo de item / natureza
        { name = "item_type", type = "string", comment = "Tipo do item no Omie (tipoItem: 00=mercadoria, 02=uso/consumo, 99=serviço/etc)" },

        # Variação / lote (se for usado no futuro)
        { name = "has_variation", type = "boolean", comment = "Indica se o produto possui variação (produto_variacao)" },
        { name = "has_batch_control", type = "boolean", comment = "Indica se o produto possui controle de lote (produto_lote)" },

        # Dimensões e peso (se vierem a ser usados em logística)
        { name = "weight_net", type = "double", comment = "Peso líquido" },
        { name = "weight_gross", type = "double", comment = "Peso bruto" },
        { name = "height", type = "double", comment = "Altura" },
        { name = "width", type = "double", comment = "Largura" },
        { name = "depth", type = "double", comment = "Profundidade" },

        # Marca / modelo
        { name = "brand", type = "string", comment = "Marca do produto" },
        { name = "model", type = "string", comment = "Modelo do produto" },

        # Textos longos internos
        { name = "detailed_description", type = "string", comment = "Descrição detalhada (descr_detalhada)" },
        { name = "internal_notes", type = "string", comment = "Observações internas (obs_internas)" },

        # Flags de exibição
        { name = "show_description_nf", type = "boolean", comment = "Exibir descrição na NFe (exibir_descricao_nfe)" },
        { name = "show_description_order", type = "boolean", comment = "Exibir descrição no pedido (exibir_descricao_pedido)" },

        # Recomendações fiscais / comércio
        { name = "cnpj_manufacturer", type = "string", comment = "CNPJ do fabricante (recomendacoes_fiscais.cnpj_fabricante)" },
        { name = "allow_coupon", type = "boolean", comment = "Permite cupom fiscal (recomendacoes_fiscais.cupom_fiscal)" },
        { name = "marketplace_enabled", type = "boolean", comment = "Habilitado para marketplace (recomendacoes_fiscais.market_place)" },
        { name = "origin_code", type = "string", comment = "Origem da mercadoria (recomendacoes_fiscais.origem_mercadoria)" },

        # Tributação principal (mantida mais enxuta)
        { name = "cst_icms", type = "string", comment = "CST ICMS" },
        { name = "csosn_icms", type = "string", comment = "CSOSN ICMS (Simples Nacional)" },
        { name = "icms_rate", type = "double", comment = "Alíquota de ICMS" },
        { name = "icms_base_reduction", type = "double", comment = "Redução de base de cálculo do ICMS" },

        { name = "cst_pis", type = "string", comment = "CST PIS" },
        { name = "pis_rate", type = "double", comment = "Alíquota de PIS" },

        { name = "cst_cofins", type = "string", comment = "CST COFINS" },
        { name = "cofins_rate", type = "double", comment = "Alíquota de COFINS" },

        { name = "cfop", type = "string", comment = "CFOP padrão do produto" },

        # IBPT (mantendo apenas as alíquotas consolidadas)
        { name = "ibpt_state_rate", type = "double", comment = "Alíquota IBPT estadual (dadosIbpt.aliqEstadual)" },
        { name = "ibpt_federal_rate", type = "double", comment = "Alíquota IBPT federal (dadosIbpt.aliqFederal)" },
        { name = "ibpt_municipal_rate", type = "double", comment = "Alíquota IBPT municipal (dadosIbpt.aliqMunicipal)" },

        # Estoque (snapshot do cadastro – não substitui fato de estoque)
        { name = "stock_quantity", type = "double", comment = "Quantidade em estoque informada no cadastro" },
        { name = "stock_minimum", type = "double", comment = "Estoque mínimo" },

        # Status / flags de uso
        { name = "is_blocked", type = "boolean", comment = "Produto bloqueado (bloqueado)" },
        { name = "block_delete", type = "boolean", comment = "Bloqueia exclusão (bloquear_exclusao)" },
        { name = "is_imported_api", type = "boolean", comment = "Indica se foi importado via API (importado_api)" },
        { name = "is_inactive", type = "boolean", comment = "Indica se o produto está inativo (inativo)" },

        # Datas / autoria (construídas a partir de info.dInc/dAlt + hInc/hAlt na silver)
        { name = "created_at", type = "timestamp", comment = "Data/hora de inclusão no Omie" },
        { name = "created_by", type = "string", comment = "Usuário que incluiu o produto no Omie" },
        { name = "updated_at", type = "timestamp", comment = "Data/hora da última alteração no Omie" },
        { name = "updated_by", type = "string", comment = "Usuário que realizou a última alteração" },

        # Metadados de origem / ingestão
        { name = "source_cnpj", type = "string", comment = "CNPJ da empresa no Omie (params.cnpj / _cnpj)" },
        { name = "source_system", type = "string", comment = "Sistema de origem (ex: Omie)" }
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

    # S2S: produtos Omie refinados (subset de colunas para análise)
    omie_products_refined = {
      description = "Produtos Omie refinados (S2S): subset de colunas (identificação, estoque, datas); particionado por ingestion_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_products_refined/"

      columns = [
        { name = "product_id", type = "bigint", comment = "ID interno do produto no Omie" },
        { name = "product_code", type = "string", comment = "Código do produto" },
        { name = "description", type = "string", comment = "Descrição do produto" },
        { name = "stock_quantity", type = "double", comment = "Quantidade em estoque" },
        { name = "stock_minimum", type = "double", comment = "Estoque mínimo" },
        { name = "created_at", type = "timestamp", comment = "Data/hora de inclusão no Omie" },
        { name = "launch_end_date", type = "date", comment = "Data de fim do período no Omie" },
        { name = "updated_by", type = "string", comment = "Usuário da última alteração" }
      ]

      partition_keys = [
        { name = "ingestion_date", type = "date", comment = "Data de ingestão (YYYY-MM-DD)" }
      ]
    }

    omie_product_characteristics = {
      description = "Características de produtos do Omie (uma linha por produto x característica)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_product_characteristics/"

      columns = [
        # Chaves de ligação
        { name = "product_id", type = "bigint", comment = "ID interno do produto no Omie (codigo_produto)" },
        { name = "product_code", type = "string", comment = "Código principal do produto (codigo)" },

        # Identificação da característica
        { name = "characteristic_id", type = "bigint", comment = "ID interno da característica no Omie (nCodCaract)" },
        { name = "characteristic_name", type = "string", comment = "Nome da característica (cNomeCaract)" },
        { name = "characteristic_value", type = "string", comment = "Valor da característica (cConteudo)" },

        # Flags de exibição
        { name = "show_on_invoice", type = "boolean", comment = "Exibir na NFe (cExibirItemNF)" },
        { name = "show_on_order", type = "boolean", comment = "Exibir no pedido (cExibirItemPedido)" },
        { name = "show_on_production_order", type = "boolean", comment = "Exibir na ordem de produção (cExibirOrdemProd)" },

        # Código de integração da característica (se vier a ser usado)
        { name = "characteristic_integration_code", type = "string", comment = "Código de integração da característica (cCodIntCaract)" },

        # Metadados
        { name = "source_cnpj", type = "string", comment = "CNPJ da empresa no Omie" },
        { name = "source_system", type = "string", comment = "Sistema de origem (ex: Omie)" }
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

    omie_sellers = {
      description = "Vendedores cadastrados no Omie (ERP) - Silver (estado atual, 1 linha por vendedor)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_sellers/"

      columns = [
        # Identificação básica
        { name = "seller_id", type = "bigint", comment = "ID interno do vendedor no Omie (codigo)" },
        { name = "seller_code", type = "string", comment = "Código de integração / identificação do vendedor (codInt)" },
        { name = "seller_name", type = "string", comment = "Nome do vendedor (nome)" },

        # Contato
        { name = "email", type = "string", comment = "E-mail do vendedor (email)" },

        # Comissão
        { name = "commission_rate", type = "double", comment = "Percentual de comissão do vendedor (comissao)" },

        # Permissões / flags de uso
        { name = "can_invoice_orders", type = "boolean", comment = "Se o vendedor pode faturar pedido (fatura_pedido: 'S'/'N')" },
        { name = "can_view_orders", type = "boolean", comment = "Se o vendedor pode visualizar pedidos (visualiza_pedido: 'S'/'N')" },
        { name = "is_inactive", type = "boolean", comment = "Se o vendedor está inativo no Omie (inativo: 'S'/'N')" },

        # Metadados de ingestão / origem
        { name = "ingestion_run_id", type = "string", comment = "ID da execução de ingestão (run_id)" },
        { name = "generated_at", type = "timestamp", comment = "Data/hora de geração do arquivo pelo conector (generated_at)" },
        { name = "source_cnpj", type = "string", comment = "CNPJ da empresa no Omie (params.cnpj)" },
        { name = "source_system", type = "string", comment = "Sistema de origem (ex: 'omie')" }
      ]

      # Partição por data de ingestão (histórico na bronze; silver pode ser snapshot atual)
      partition_keys = [
        {
          name    = "ingestion_date"
          type    = "date"
          comment = "Data de ingestão dos vendedores (YYYY-MM-DD)"
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

    omie_bank_accounts = {
      description = "Contas bancárias / correntes cadastradas no Omie (ERP) - Silver (estado atual, 1 linha por conta)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_bank_accounts/"

      columns = [
        # Identificação básica
        { name = "bank_account_id", type = "bigint", comment = "ID interno da conta no Omie (nCodCC)" },
        { name = "integration_code", type = "string", comment = "Código de integração da conta (cCodCCInt)" },
        { name = "description", type = "string", comment = "Descrição / nome da conta (descricao)" },

        # Banco e agência
        { name = "bank_code", type = "string", comment = "Código do banco (codigo_banco)" },
        { name = "agency_code", type = "string", comment = "Código da agência (codigo_agencia)" },
        { name = "account_number", type = "string", comment = "Número da conta corrente (numero_conta_corrente)" },

        # Tipo de conta
        { name = "account_type_code", type = "string", comment = "Tipo da conta (tipo_conta_corrente: CC, CA, CX, CR, AC, AD, CV...)" },
        { name = "account_group_type", type = "string", comment = "Tipo/grupo da conta (tipo: CC=Conta Corrente, CA=Aplicação, CX=Caixa, CR=Cartão de Crédito, AC=Conta de Adquirente, AD=Adiantamento, CV=Conta de Vales, etc.)" },

        # Situação / uso
        { name = "is_blocked", type = "boolean", comment = "Conta bloqueada (bloqueado: 'S'/'N')" },
        { name = "is_inactive", type = "boolean", comment = "Conta inativa (inativo: 'S'/'N')" },
        { name = "exclude_from_cashflow", type = "boolean", comment = "Excluir do fluxo de caixa (nao_fluxo: 'S'/'N')" },
        { name = "exclude_from_summary", type = "boolean", comment = "Excluir de relatórios/resumos financeiros (nao_resumo: 'S'/'N')" },

        # Configuração de cobrança / boletos
        { name = "billing_enabled", type = "boolean", comment = "Conta habilitada para cobrança/boletos (cobr_sn: 'S'/'N')" },
        { name = "boleto_enabled", type = "boolean", comment = "Conta habilitada para emissão de boletos (bol_sn: 'S'/'N')" },
        { name = "boleto_instr_1", type = "string", comment = "Instrução de boleto 1 (bol_instr1)" },
        { name = "boleto_instr_2", type = "string", comment = "Instrução de boleto 2 (bol_instr2)" },
        { name = "boleto_instr_3", type = "string", comment = "Instrução de boleto 3 (bol_instr3)" },
        { name = "boleto_instr_4", type = "string", comment = "Instrução de boleto 4 (bol_instr4)" },

        # Parâmetros financeiros básicos
        { name = "interest_rate", type = "double", comment = "Percentual de juros para cobrança (per_juros)" },
        { name = "fine_rate", type = "double", comment = "Percentual de multa para cobrança (per_multa)" },
        { name = "recomposition_days", type = "int", comment = "Dias para recomposição (dias_rcomp)" },

        # Pix
        { name = "pix_enabled", type = "boolean", comment = "Conta habilitada para Pix (pix_sn: 'S'/'N')" },

        # PDV / adquirência (quando usado em cartão / TEF / adquirente)
        { name = "pdv_category", type = "string", comment = "Categoria da conta no PDV/contábil (pdv_categoria)" },
        { name = "pdv_send", type = "boolean", comment = "Enviar vendas/lançamentos para essa conta (pdv_enviar: 'S'/'N')" },
        { name = "pdv_settlement_days", type = "int", comment = "Dias de vencimento/repasse padrão (pdv_dias_venc)" },
        { name = "pdv_max_installments", type = "int", comment = "Número máximo de parcelas (pdv_num_parcelas)" },
        { name = "pdv_installment_limit", type = "int", comment = "Limite de parcelas permitido (pdv_limite_pacelas)" },
        { name = "pdv_sync_detail", type = "boolean", comment = "Sincronizar analítico/detalhado (pdv_sincr_analitica: 'S'/'N')" },
        { name = "pdv_tef_type", type = "int", comment = "Tipo de TEF / integração PDV (pdv_tipo_tef)" },
        { name = "pdv_admin_code", type = "bigint", comment = "Código da administradora / adquirente (pdv_cod_adm)" },
        { name = "pdv_admin_fee", type = "double", comment = "Taxa administrativa da adquirente (pdv_taxa_adm)" },
        { name = "pdv_store_fee", type = "double", comment = "Taxa da loja (pdv_taxa_loja)" },

        # Saldos / limites
        { name = "opening_balance", type = "double", comment = "Saldo inicial cadastrado na abertura (saldo_inicial)" },
        { name = "opening_balance_date", type = "date", comment = "Data do saldo inicial (saldo_data)" },
        { name = "credit_limit", type = "double", comment = "Limite de crédito / cheque especial (valor_limite)" },

        # Contato / relacionamento (opcionalmente úteis)
        { name = "manager_name", type = "string", comment = "Nome do gerente da conta (nome_gerente)" },
        { name = "phone", type = "string", comment = "Telefone de contato (telefone)" },
        { name = "email", type = "string", comment = "E-mail de contato (email)" },

        # Observações
        { name = "notes", type = "string", comment = "Observações gerais da conta (observacao)" },

        # Datas / autoria (montadas na silver a partir de data_inc/hora_inc e data_alt/hora_alt)
        { name = "created_at", type = "timestamp", comment = "Data/hora de inclusão da conta no Omie (data_inc + hora_inc)" },
        { name = "created_by", type = "string", comment = "Usuário que incluiu a conta no Omie (user_inc)" },
        { name = "updated_at", type = "timestamp", comment = "Data/hora da última alteração (data_alt + hora_alt)" },
        { name = "updated_by", type = "string", comment = "Usuário da última alteração (user_alt)" },

        # Metadados de ingestão / origem
        { name = "ingestion_run_id", type = "string", comment = "ID da execução de ingestão (run_id)" },
        { name = "generated_at", type = "timestamp", comment = "Data/hora de geração do arquivo pelo conector (generated_at)" },
        { name = "source_cnpj", type = "string", comment = "CNPJ da empresa no Omie (params.cnpj)" },
        { name = "source_system", type = "string", comment = "Sistema de origem (ex: 'omie')" }
      ]

      # Partição por data de ingestão (histórico por batch na bronze; aqui você pode manter se quiser reprocessar fácil)
      partition_keys = [
        {
          name    = "ingestion_date"
          type    = "date"
          comment = "Data de ingestão das contas (YYYY-MM-DD)"
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

    # omie_fiscal_coupons_header = {
    #   description = "Cabeçalho de cupons fiscais do Omie (uma linha por cupom, com totais e vínculos a cliente/vendedor)."
    #   location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_fiscal_coupons_header/"

    #   columns = [
    #     # Identificação básica
    #     { name = "coupon_id",          type = "bigint",    comment = "ID interno do cupom no Omie (nIdCupom)" },
    #     { name = "coupon_key",         type = "string",    comment = "Chave do cupom fiscal (cChaveCupom)" },
    #     { name = "coupon_number",      type = "bigint",    comment = "Número do cupom (nNumCupom)" },
    #     { name = "coupon_series",      type = "string",    comment = "Série do cupom (nSerieCupom)" },
    #     { name = "coupon_model",       type = "string",    comment = "Modelo do cupom (cModeloCupom, ex.: 65)" },

    #     # Datas / horários de emissão
    #     { name = "emission_date",      type = "date",      comment = "Data de emissão do cupom (dDtEmissaoCupom)" },
    #     { name = "emission_time",      type = "string",    comment = "Hora de emissão do cupom (cHrEmissaoCupom, HH:MM:SS)" },
    #     { name = "emission_datetime",  type = "timestamp", comment = "Data/hora de emissão do cupom (construído na silver)" },

    #     # Contingência e status
    #     { name = "is_contingency",     type = "boolean",   comment = "Indicador de contingência (cContingencia = 'S'/'N')" },
    #     { name = "is_cancelled",       type = "boolean",   comment = "Cupom cancelado? (info.cCupomCancelado)" },
    #     { name = "is_returned",        type = "boolean",   comment = "Cupom devolvido? (info.cCupomDevolvido)" },

    #     # Vínculos
    #     { name = "client_id",          type = "bigint",    comment = "ID do cliente no Omie (idCliente)" },
    #     { name = "seller_id",          type = "bigint",    comment = "ID do vendedor no Omie (idVendedor)" },
    #     { name = "cash_register_seq",  type = "bigint",    comment = "Sequência do caixa (seqCaixa)" },
    #     { name = "coupon_seq",         type = "bigint",    comment = "Sequência do cupom (seqCupom)" },

    #     # Totais do cupom
    #     { name = "amount_total",       type = "double",    comment = "Valor total do cupom (nValorCupom)" },
    #     { name = "amount_tax_icms",    type = "double",    comment = "Valor de ICMS do cupom (nValorICMS)" },
    #     { name = "amount_tax_pis",     type = "double",    comment = "Valor de PIS do cupom (nValorPIS)" },
    #     { name = "amount_tax_cofins",  type = "double",    comment = "Valor de COFINS do cupom (nValorCOFINS)" },
    #     { name = "amount_fee",         type = "double",    comment = "Valor de taxa adicional (nValorTaxa)" },

    #     # Auditoria Omie (inclusão/alteração)
    #     { name = "created_date",       type = "date",      comment = "Data de inclusão do cupom no Omie (info.dDtInclusao)" },
    #     { name = "created_time",       type = "string",    comment = "Hora de inclusão do cupom no Omie (info.cHrInclusao)" },
    #     { name = "created_at",         type = "timestamp", comment = "Data/hora de inclusão no Omie (derivado)" },
    #     { name = "created_by",         type = "string",    comment = "Usuário que incluiu (info.uInc)" },

    #     { name = "updated_date",       type = "date",      comment = "Data de alteração do cupom no Omie (info.dDtAlteracao)" },
    #     { name = "updated_time",       type = "string",    comment = "Hora de alteração do cupom no Omie (info.cHrAlteracao)" },
    #     { name = "updated_at",         type = "timestamp", comment = "Data/hora de alteração no Omie (derivado)" },
    #     { name = "updated_by",         type = "string",    comment = "Usuário que alterou (info.uAlt)" },

    #     # Metadados de ingestão
    #     { name = "run_id",             type = "string",    comment = "ID da execução de ingestão" },
    #     { name = "generated_at",       type = "timestamp", comment = "Timestamp de geração do arquivo de origem" },
    #     { name = "source_cnpj",        type = "string",    comment = "CNPJ da empresa no Omie (params.cnpj)" },
    #     { name = "source_system",      type = "string",    comment = "Sistema de origem (ex.: Omie)" }
    #   ]

    #   partition_keys = [
    #     {
    #       name    = "ingestion_date"
    #       type    = "date"
    #       comment = "Data de ingestão do batch (YYYY-MM-DD)"
    #       projection = {
    #         type          = "date"
    #         format        = "yyyy-MM-dd"
    #         range         = "2020-01-01,NOW"
    #         interval      = "1"
    #         interval_unit = "DAYS"
    #       }
    #     }
    #   ]
    # }

    # omie_fiscal_coupons_items = {
    #   description = "Itens de cupons fiscais do Omie (uma linha por cupom x item)."
    #   location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_fiscal_coupons_items/"

    #   columns = [
    #     # Chave do cupom (FK)
    #     { name = "coupon_id",          type = "bigint",    comment = "ID interno do cupom no Omie (nIdCupom)" },
    #     { name = "coupon_key",         type = "string",    comment = "Chave do cupom fiscal (cChaveCupom)" },
    #     { name = "coupon_number",      type = "bigint",    comment = "Número do cupom (nNumCupom)" },

    #     # Identificação do item
    #     { name = "item_id",            type = "bigint",    comment = "ID interno do item no Omie (idItem)" },
    #     { name = "item_sequence",      type = "bigint",    comment = "Sequência do item no cupom (nSequencia)" },

    #     # Produto
    #     { name = "product_id",         type = "bigint",    comment = "ID do produto no Omie (idProduto)" },
    #     { name = "product_code",       type = "string",    comment = "Código do produto (cCodigo / emiProduto)" },
    #     { name = "product_name",       type = "string",    comment = "Descrição do produto (xProd)" },
    #     { name = "unit",               type = "string",    comment = "Unidade de medida (cUn)" },
    #     { name = "ncm",                type = "string",    comment = "Código NCM do item (cNCM)" },
    #     { name = "cfop",               type = "string",    comment = "CFOP do item (cCFOP)" },

    #     # Quantidade e valores
    #     { name = "quantity",           type = "double",    comment = "Quantidade (nQuant)" },
    #     { name = "unit_price",         type = "double",    comment = "Preço unitário (vUnit)" },
    #     { name = "item_amount",        type = "double",    comment = "Valor do item (vItem)" },
    #     { name = "discount_amount",    type = "double",    comment = "Desconto no item (vDesc)" },
    #     { name = "addition_amount",    type = "double",    comment = "Acréscimo no item (vAcresc)" },
    #     { name = "other_amount",       type = "double",    comment = "Outros valores (nValorOutros)" },

    #     # Tributação no item
    #     { name = "icms_rate",          type = "double",    comment = "Alíquota ICMS do item (nAliqICMS)" },
    #     { name = "pis_rate",           type = "double",    comment = "Alíquota PIS do item (nAliqPIS)" },
    #     { name = "cofins_rate",        type = "double",    comment = "Alíquota COFINS do item (nAliqCOFINS)" },

    #     { name = "icms_amount",        type = "double",    comment = "Valor ICMS do item (nValorICMS)" },
    #     { name = "pis_amount",         type = "double",    comment = "Valor PIS do item (nValorPIS)" },
    #     { name = "cofins_amount",      type = "double",    comment = "Valor COFINS do item (nValorCOFINS)" },

    #     # Status do item
    #     { name = "is_cancelled",       type = "boolean",   comment = "Item cancelado? (cCupomCancelado)" },
    #     { name = "is_returned",        type = "boolean",   comment = "Item devolvido? (cCupomDevolvido)" },

    #     # Metadados de ingestão
    #     { name = "run_id",             type = "string",    comment = "ID da execução de ingestão" },
    #     { name = "generated_at",       type = "timestamp", comment = "Timestamp de geração do arquivo de origem" },
    #     { name = "source_cnpj",        type = "string",    comment = "CNPJ da empresa no Omie (params.cnpj)" },
    #     { name = "source_system",      type = "string",    comment = "Sistema de origem (ex.: Omie)" }
    #   ]

    #   partition_keys = [
    #     {
    #       name    = "ingestion_date"
    #       type    = "date"
    #       comment = "Data de ingestão do batch (YYYY-MM-DD)"
    #       projection = {
    #         type          = "date"
    #         format        = "yyyy-MM-dd"
    #         range         = "2020-01-01,NOW"
    #         interval      = "1"
    #         interval_unit = "DAYS"
    #       }
    #     }
    #   ]
    # }

    # omie_fiscal_coupons_payments = {
    #   description = "Pagamentos de cupons fiscais do Omie (uma linha por cupom x parcela/pagamento)."
    #   location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_fiscal_coupons_payments/"

    #   columns = [
    #     # Chave do cupom (FK)
    #     { name = "coupon_id",          type = "bigint",    comment = "ID interno do cupom no Omie (nIdCupom)" },
    #     { name = "coupon_key",         type = "string",    comment = "Chave do cupom fiscal (cChaveCupom)" },
    #     { name = "coupon_number",      type = "bigint",    comment = "Número do cupom (nNumCupom)" },

    #     # Identificação da parcela
    #     { name = "payment_sequence",   type = "bigint",    comment = "Sequência do pagamento (nSequencia)" },
    #     { name = "installment_code",   type = "string",    comment = "Identificação da parcela (cNumParcela, ex.: 001/003)" },

    #     # Título / documento
    #     { name = "title_id",           type = "bigint",    comment = "Código do título financeiro (nCodTitulo)" },
    #     { name = "doc_type",           type = "string",    comment = "Tipo de documento/pagamento (cTipoDoc, ex.: CRD, CRC)" },

    #     # Conta corrente
    #     { name = "bank_account_id",    type = "bigint",    comment = "ID da conta corrente no Omie (idContaCorrente)" },
    #     { name = "account_category",   type = "string",    comment = "Categoria da conta / centro de custo (cCategoria)" },

    #     # Valores e vencimento
    #     { name = "due_date",           type = "date",      comment = "Data de vencimento da parcela (dDtVencimento)" },
    #     { name = "document_amount",    type = "double",    comment = "Valor do documento/parcela (nValorDocumento)" },
    #     { name = "fee_amount",         type = "double",    comment = "Valor de taxa (nValorTaxa)" },

    #     # Metadados de ingestão
    #     { name = "run_id",             type = "string",    comment = "ID da execução de ingestão" },
    #     { name = "generated_at",       type = "timestamp", comment = "Timestamp de geração do arquivo de origem" },
    #     { name = "source_cnpj",        type = "string",    comment = "CNPJ da empresa no Omie (params.cnpj)" },
    #     { name = "source_system",      type = "string",    comment = "Sistema de origem (ex.: Omie)" }
    #   ]

    #   partition_keys = [
    #     {
    #       name    = "ingestion_date"
    #       type    = "date"
    #       comment = "Data de ingestão do batch (YYYY-MM-DD)"
    #       projection = {
    #         type          = "date"
    #         format        = "yyyy-MM-dd"
    #         range         = "2020-01-01,NOW"
    #         interval      = "1"
    #         interval_unit = "DAYS"
    #       }
    #     }
    #   ]
    # }

    omie_documents = {
      description = "Omie fiscal documents (todos os modelos retornados por /contador/xml/ListarDocumentos). Uma linha por documento."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=documents/"

      columns = [
        # Linhagem / metadados de ingestão
        { name = "source", type = "string", comment = "Fonte do dado (ex.: omie)" },
        { name = "dataset", type = "string", comment = "Nome do dataset de origem (ex.: omie_documents)" },
        { name = "run_id", type = "string", comment = "Identificador da execução de ingestão no bronze" },
        { name = "ingestion_ts", type = "timestamp", comment = "Timestamp de ingestão no bronze" },

        # Identificador canônico
        { name = "document_id", type = "string", comment = "ID interno canônico (hash da chave ou do payload)" },

        # Chave / modelo / numeração
        { name = "document_key", type = "string", comment = "Chave fiscal do documento (ex.: chave NF-e/NFC-e), quando existir" },
        { name = "reference_key", type = "string", comment = "Chave da nota referenciada (refNFe) em devoluções/complementos" }, # NOVO
        { name = "model_code", type = "string", comment = "Modelo fiscal: 55=NF-e, 65=NFC-e, 59=CF-e-SAT, etc." },
        { name = "document_type", type = "string", comment = "Document type: NF-e, NFC-e, CF-e-SAT, etc." },

        { name = "operation_code", type = "string", comment = "Código de operação no Omie (ex.: cOperacao da API, quando disponível)" },
        { name = "serie", type = "string", comment = "Série do documento" },
        { name = "number", type = "string", comment = "Número do documento (nNF, número do cupom, etc.)" },
        { name = "purchase_order", type = "string", comment = "Número do pedido de compra/venda (xPed)" }, # NOVO

        # Status / ambiente
        { name = "status_code", type = "string", comment = "Código de status informado pelo Omie/SEFAZ (ex.: cStatus)" },
        { name = "status_desc", type = "string", comment = "Descrição do status, se derivada (ex.: 'Autorizado o uso da NF-e')" },
        { name = "environment", type = "string", comment = "Ambiente: 1=produção, 2=homologação, outro conforme XML" },
        { name = "environment_desc", type = "string", comment = "Descrição do ambiente: Produção, Homologação" }, # NOVO

        # Datas
        { name = "issue_datetime_raw", type = "string", comment = "Data/hora de emissão no formato original (ex.: 2025-11-24T12:40:49-03:00)" },
        { name = "issue_datetime", type = "timestamp", comment = "Data/hora de emissão normalizada" },
        { name = "issue_date", type = "date", comment = "Data de emissão (YYYY-MM-DD)" },

        # Direção / finalidade / flags fiscais (quando vierem no XML – NF-e/NFC-e)
        { name = "direction", type = "string", comment = "Sentido da operação (tpNF: 0=entrada, 1=saída), quando disponível" },
        { name = "direction_desc", type = "string", comment = "Descrição do sentido: Entrada, Saída" }, # NOVO
        { name = "purpose", type = "string", comment = "Finalidade da NF (finNFe: 1=normal, 2=complementar, 3=ajuste, 4=devolução)" },
        { name = "purpose_desc", type = "string", comment = "Descrição da finalidade: Normal, Complementar, Ajuste, Devolução" }, # NOVO
        { name = "presence_indicator", type = "string", comment = "Indicador de presença (indPres), quando existir" },
        { name = "presence_desc", type = "string", comment = "Descrição da presença: Presencial, Internet, etc." }, # NOVO
        { name = "is_final_consumer", type = "boolean", comment = "Indicador de consumidor final (indFinal), quando existir" },

        # Logística / Transporte
        { name = "freight_mode", type = "string", comment = "Modalidade do frete (modFrete)" },                     # NOVO
        { name = "freight_mode_desc", type = "string", comment = "Descrição do frete: CIF, FOB, Sem Frete, etc." }, # NOVO

        # Emitente
        { name = "issuer_cnpj", type = "string", comment = "CNPJ do emitente" },
        { name = "issuer_name", type = "string", comment = "Nome/Razão social do emitente" },
        { name = "issuer_state", type = "string", comment = "UF do emitente, quando disponível" },
        { name = "issuer_city_code", type = "string", comment = "Código IBGE do município do emitente, quando disponível" },
        # Endereço Emitente (Novos)
        { name = "issuer_address", type = "string", comment = "Logradouro do emitente (xLgr)" },
        { name = "issuer_number", type = "string", comment = "Número do endereço do emitente (nro)" },
        { name = "issuer_neighborhood", type = "string", comment = "Bairro do emitente (xBairro)" },
        { name = "issuer_zipcode", type = "string", comment = "CEP do emitente (CEP)" },

        # Destinatário / consumidor
        { name = "recipient_cnpj", type = "string", comment = "CNPJ do destinatário (quando PJ)" },
        { name = "recipient_cpf", type = "string", comment = "CPF do destinatário (quando PF)" },
        { name = "recipient_name", type = "string", comment = "Nome do destinatário ou consumidor" },
        { name = "recipient_state", type = "string", comment = "UF do destinatário, quando disponível" },
        { name = "recipient_city_code", type = "string", comment = "Código IBGE do município do destinatário, quando disponível" },
        # Endereço Destinatário (Novos)
        { name = "recipient_address", type = "string", comment = "Logradouro do destinatário (xLgr)" },
        { name = "recipient_number", type = "string", comment = "Número do endereço do destinatário (nro)" },
        { name = "recipient_neighborhood", type = "string", comment = "Bairro do destinatário (xBairro)" },
        { name = "recipient_zipcode", type = "string", comment = "CEP do destinatário (CEP)" },

        # Natureza / CFOP agregado (opcional)
        { name = "operation_nature", type = "string", comment = "Natureza da operação (natOp) do XML, quando houver" },
        { name = "observation", type = "string", comment = "Observação do documento" },

        # Totais (em nível de documento – sempre que existirem)
        { name = "total_products", type = "decimal(18,2)", comment = "Valor total dos produtos (vProd) do XML" },
        { name = "total_discounts", type = "decimal(18,2)", comment = "Valor total de descontos (vDesc) do XML" },
        { name = "total_invoice", type = "decimal(18,2)", comment = "Valor total da nota (vNF) do XML" },
        { name = "total_freight", type = "decimal(18,2)", comment = "Valor total do frete (vFrete)" },            # NOVO
        { name = "total_insurance", type = "decimal(18,2)", comment = "Valor total do seguro (vSeg)" },           # NOVO
        { name = "total_expenses", type = "decimal(18,2)", comment = "Valor total de outras despesas (vOutro)" }, # NOVO
        { name = "total_payments", type = "decimal(18,2)", comment = "Soma dos pagamentos (vPag) registrados no XML" },

        # Campos “raw” vindos direto do Omie (úteis para auditoria)
        { name = "raw_id_omie", type = "string", comment = "ID do documento no Omie (ex.: nIdNF, nIdCupom, nIdReceb)" },
        { name = "raw_number_omie", type = "string", comment = "Número do documento informado pelo Omie (nNumero)" },
        { name = "raw_value_omie", type = "decimal(18,2)", comment = "Valor do documento informado pelo Omie (nValor)" },
        { name = "raw_status_omie", type = "string", comment = "Status do documento informado pelo Omie (cStatus)" }
      ]

      partition_keys = [
        { name = "created_date", type = "string", comment = "Partição por data lógica de criação (issue_date ou fallback), formato YYYY-MM-DD" }
      ]
    }

    omie_document_items = {
      description = "Itens dos documentos fiscais Omie (NF-e, NFC-e e demais modelos que possuam itens). Uma linha por item."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=document_items/"

      columns = [
        { name = "document_id", type = "string", comment = "ID interno do documento (chave estrangeira para omie_documents.document_id)" },

        # Identificação do item
        { name = "item_number", type = "int", comment = "Número sequencial do item (nItem)" },
        { name = "product_code", type = "string", comment = "Código do produto (cProd)" },
        { name = "product_name", type = "string", comment = "Descrição do produto (xProd)" },
        { name = "ncm", type = "string", comment = "NCM do produto" },
        { name = "cfop", type = "string", comment = "CFOP do item" },
        { name = "tax_benefit_code", type = "string", comment = "Código de benefício fiscal (cBenef)" },

        # Quantidade / valores
        { name = "quantity", type = "double", comment = "Quantidade comercializada (qCom)" },
        { name = "unit", type = "string", comment = "Unidade comercial (uCom)" },
        { name = "unit_price", type = "decimal(18,2)", comment = "Valor unitário (vUnCom)" },
        { name = "total_price", type = "decimal(18,2)", comment = "Valor total do item (vProd)" },
        { name = "discount_value", type = "decimal(18,2)", comment = "Desconto no item (vDesc)" },

        # ICMS
        { name = "origin", type = "string", comment = "Origem da mercadoria (orig)" },
        { name = "origin_desc", type = "string", comment = "Descrição da origem: nacional, importada etc. (derivado de orig)" },
        { name = "cst_icms", type = "string", comment = "CST do ICMS" },
        { name = "csosn_icms", type = "string", comment = "CSOSN do ICMS, quando aplicável" },
        { name = "icms_rate", type = "decimal(18,2)", comment = "Alíquota do ICMS (pICMS)" },
        { name = "icms_base", type = "decimal(18,2)", comment = "Base de cálculo do ICMS (vBC)" },
        { name = "icms_value", type = "decimal(18,2)", comment = "Valor do ICMS (vICMS)" },
        { name = "icms_reduction_rate", type = "decimal(18,2)", comment = "Percentual de redução da base do ICMS (pRedBC)" },
        { name = "icms_exempt_value", type = "decimal(18,2)", comment = "Valor do ICMS desonerado (vICMSDeson)" },
        { name = "icms_exempt_reason", type = "string", comment = "Motivo da desoneração do ICMS (motDesICMS)" },
        { name = "icms_exempt_deduction_flag", type = "string", comment = "Indica se a desoneração foi deduzida do item (indDeduzDeson)" },

        # FCP
        { name = "fcp_base", type = "decimal(18,2)", comment = "Base de cálculo do FCP (vBCFCP)" },
        { name = "fcp_rate", type = "decimal(18,2)", comment = "Alíquota do FCP (pFCP)" },
        { name = "fcp_value", type = "decimal(18,2)", comment = "Valor do FCP (vFCP)" },

        # PIS
        { name = "pis_cst", type = "string", comment = "CST do PIS" },
        { name = "pis_base", type = "decimal(18,2)", comment = "Base de cálculo do PIS (vBC)" },
        { name = "pis_rate", type = "decimal(18,2)", comment = "Alíquota do PIS (pPIS)" },
        { name = "pis_value", type = "decimal(18,2)", comment = "Valor do PIS (vPIS)" },

        # COFINS
        { name = "cofins_cst", type = "string", comment = "CST do COFINS" },
        { name = "cofins_base", type = "decimal(18,2)", comment = "Base de cálculo do COFINS (vBC)" },
        { name = "cofins_rate", type = "decimal(18,2)", comment = "Alíquota do COFINS (pCOFINS)" },
        { name = "cofins_value", type = "decimal(18,2)", comment = "Valor do COFINS (vCOFINS)" },

        # IBS / CBS
        { name = "ibscbs_cst", type = "string", comment = "CST do IBS/CBS" },
        { name = "ibscbs_class_trib", type = "string", comment = "Código de classificação tributária IBS/CBS (cClassTrib)" },
        { name = "ibscbs_base", type = "decimal(18,2)", comment = "Base de cálculo do IBS/CBS (gIBSCBS.vBC)" },

        { name = "ibs_value", type = "decimal(18,2)", comment = "Valor total do IBS (vIBS)" },
        { name = "ibs_uf_rate", type = "decimal(18,4)", comment = "Alíquota do IBS UF (pIBSUF)" },
        { name = "ibs_uf_value", type = "decimal(18,2)", comment = "Valor do IBS UF (vIBSUF)" },
        { name = "ibs_municipality_rate", type = "decimal(18,4)", comment = "Alíquota do IBS municipal (pIBSMun)" },
        { name = "ibs_municipality_value", type = "decimal(18,2)", comment = "Valor do IBS municipal (vIBSMun)" },

        { name = "cbs_rate", type = "decimal(18,4)", comment = "Alíquota da CBS (pCBS)" },
        { name = "cbs_value", type = "decimal(18,2)", comment = "Valor da CBS (vCBS)" },

        # Metadados extras que você queira derivar
        { name = "is_gift", type = "boolean", comment = "Flag para itens brinde/cortesia, se derivado" }
      ]

      partition_keys = [
        { name = "created_date", type = "string", comment = "Partição alinhada com omie_documents (YYYY-MM-DD)" }
      ]
    }

    omie_document_payments = {
      description = "Pagamentos dos documentos fiscais Omie (formas de pagamento por documento)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=document_payments/"

      columns = [
        { name = "document_id", type = "string", comment = "ID interno do documento (FK para omie_documents.document_id)" },

        { name = "payment_seq", type = "int", comment = "Sequência do pagamento no documento" },
        { name = "payment_type", type = "string", comment = "Tipo de pagamento (tPag - ex.: 01=dinh., 03=cartão, 90=sem pagamento, 99=outros)" },
        { name = "payment_desc", type = "string", comment = "Descrição do tipo de pagamento: Dinheiro, Cartão, Boleto, etc." }, # NOVO
        { name = "amount", type = "decimal(18,2)", comment = "Valor do pagamento (vPag)" },

        # Campos específicos de cartão quando existirem
        { name = "card_brand", type = "string", comment = "Bandeira do cartão (tBand)" },
        { name = "card_auth_code", type = "string", comment = "Código de autorização (cAut)" },

        # Outros campos genéricos caso apareçam em SAT ou modelos diferentes
        { name = "payment_info_raw", type = "string", comment = "Campo texto/JSON com informações adicionais de pagamento específicas de cada modelo, se necessário" }
      ]

      partition_keys = [
        { name = "created_date", type = "string", comment = "Partição alinhada com omie_documents (YYYY-MM-DD)" }
      ]
    }

    # S2S: itens de documentos refinados (subset de colunas, partição ingestion_date)
    omie_document_items_refined = {
      description = "Itens de documentos Omie refinados (S2S): subset de colunas para análise; particionado por ingestion_date."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=document_items_refined/"

      columns = [
        { name = "document_id", type = "string", comment = "ID interno do documento (FK para omie_documents)" },
        { name = "product_code", type = "string", comment = "Código do produto" },
        { name = "product_name", type = "string", comment = "Descrição do produto" },
        { name = "quantity", type = "double", comment = "Quantidade comercializada" },
        { name = "unit_price", type = "decimal(18,2)", comment = "Valor unitário" },
        { name = "total_price", type = "decimal(18,2)", comment = "Valor total do item" },
        { name = "discount_value", type = "decimal(18,2)", comment = "Desconto no item" },
        { name = "issue_datetime_raw", type = "string", comment = "Data/hora de emissão no formato original da origem" },
        { name = "issue_datetime", type = "timestamp", comment = "Data/hora de emissão do documento" },
        { name = "issue_date", type = "date", comment = "Data de emissão (YYYY-MM-DD)" }
      ]

      partition_keys = [
        { name = "ingestion_date", type = "date", comment = "Data de ingestão (YYYY-MM-DD), derivada de created_date na origem" }
      ]
    }

    protheus_customers = {
      description = "Cadastro de clientes do Protheus (SA1010) normalizado para consumo analítico."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=protheus/dataset=protheus_customers/"

      columns = [
        { name = "source", type = "string", comment = "Sistema de origem (protheus)" },
        { name = "dataset", type = "string", comment = "Dataset lógico (customers)" },

        { name = "customer_document", type = "string", comment = "CPF/CNPJ normalizado (somente dígitos)" },
        { name = "customer_name", type = "string", comment = "Nome do cliente" },
        { name = "customer_name_short", type = "string", comment = "Nome reduzido" },
        { name = "customer_type", type = "string", comment = "Tipo pessoa (A1_PESSOA)" },

        { name = "email", type = "string", comment = "Email do cliente" },
        { name = "phone_country_code", type = "string", comment = "DDI" },
        { name = "phone_area_code", type = "string", comment = "DDD" },
        { name = "phone_number", type = "string", comment = "Telefone" },

        { name = "address_street", type = "string", comment = "Logradouro" },
        { name = "address_complement", type = "string", comment = "Complemento" },
        { name = "address_neighborhood", type = "string", comment = "Bairro" },
        { name = "address_city", type = "string", comment = "Município" },
        { name = "address_state", type = "string", comment = "UF" },
        { name = "address_zipcode", type = "string", comment = "CEP (somente dígitos)" },
        { name = "address_country", type = "string", comment = "País" },
        { name = "address_country_code", type = "string", comment = "Código do país" },
        { name = "city_code", type = "string", comment = "Código do município (A1_COD_MUN)" },

        { name = "customer_profile", type = "string", comment = "Perfil (A1_PERFIL)" },
        { name = "customer_class", type = "string", comment = "Classe (A1_TIPCLI)" },

        { name = "created_at_erp", type = "date", comment = "Data de cadastro no ERP (A1_DTCAD)" },
        { name = "created_time_erp", type = "string", comment = "Hora de cadastro no ERP (A1_HRCAD)" },
        { name = "first_purchase_date_erp", type = "date", comment = "Primeira compra (A1_PRICOM)" },
        { name = "last_purchase_date_erp", type = "date", comment = "Última compra (A1_ULTCOM)" },

        { name = "customer_code", type = "string", comment = "Código do cliente no Protheus (A1_COD)" },
        { name = "customer_store", type = "string", comment = "Loja do cliente no Protheus (A1_LOJA)" },
        { name = "branch", type = "string", comment = "Filial (A1_FILIAL)" },

        { name = "is_deleted", type = "boolean", comment = "Registro marcado como deletado (D_E_L_E_T_='*')" },
        { name = "recno", type = "bigint", comment = "R_E_C_N_O_" },
        { name = "recdel", type = "bigint", comment = "R_E_C_D_E_L_" },
        { name = "updated_at_erp", type = "timestamp", comment = "Timestamp técnico do Protheus (S_T_A_M_P_)" },
      ]

      partition_keys = [
        {
          name    = "created_date"
          type    = "date"
          comment = "Data da partição (derivada da ingestion_date da bronze)"
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

    protheus_products = {
      description = "Cadastro de produtos do Protheus (SB1010) normalizado pelo job erp-protheus-products-b2s."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=protheus/dataset=protheus_products/"

      columns = [
        { name = "source", type = "string", comment = "Sistema de origem (protheus)" },
        { name = "dataset", type = "string", comment = "Dataset lógico (products)" },

        { name = "product_code", type = "string", comment = "Código do produto (B1_COD)" },
        { name = "omie_product_code", type = "string", comment = "SKU Omie (B1_XSKUOMI)" },
        { name = "description", type = "string", comment = "Descrição (B1_DESC)" },
        { name = "product_type", type = "string", comment = "Tipo (B1_TIPO)" },
        { name = "product_collection", type = "string", comment = "Coleção (B1_XCOLECC)" },
        { name = "product_collection_year", type = "int", comment = "Tipo (B1_XANOLCT)" },
        { name = "unit", type = "string", comment = "Unidade de medida (B1_UM)" },
        { name = "group_code", type = "string", comment = "Grupo (B1_GRUPO)" },
        { name = "ncm", type = "string", comment = "NCM / posição IPI (B1_POSIPI)" },

        { name = "branch", type = "string", comment = "Filial (B1_FILIAL)" },

        { name = "is_deleted", type = "boolean", comment = "Registro marcado como deletado (D_E_L_E_T_='*')" },
        { name = "recno", type = "bigint", comment = "R_E_C_N_O_" },
        { name = "updated_at_erp", type = "timestamp", comment = "Timestamp técnico do Protheus (S_T_A_M_P_)" },
        { name = "ingestion_date", type = "date", comment = "Data de criação do (YYYY-MM-DD)" },
      ]

      partition_keys = [
        {
          name    = "created_date"
          type    = "date"
          comment = "Data da partição (derivada da ingestion_date da bronze)"
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

    protheus_nf_out = {
      description = "Notas fiscais de saída (cabeçalho) do Protheus (SF2010) normalizadas."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=protheus/dataset=protheus_nf_out/"

      columns = [
        { name = "source", type = "string", comment = "Sistema de origem (protheus)" },
        { name = "dataset", type = "string", comment = "Dataset lógico (nf_out)" },

        { name = "nf_number", type = "string", comment = "Número da NF (F2_DOC)" },
        { name = "nf_series", type = "string", comment = "Série da NF (F2_SERIE)" },
        { name = "nf_key", type = "string", comment = "Chave da NF-e (F2_CHVNFE)" },

        { name = "customer_code", type = "string", comment = "Cliente (F2_CLIENTE)" },
        { name = "customer_store", type = "string", comment = "Loja do cliente (F2_LOJA)" },

        { name = "issue_date", type = "date", comment = "Data de emissão (F2_EMISSAO)" },
        { name = "total_gross", type = "double", comment = "Valor bruto (F2_VALBRUT)" },
        { name = "freight_value", type = "double", comment = "Frete (F2_FRETE)" },
      ]

      partition_keys = [
        {
          name    = "created_date"
          type    = "date"
          comment = "Data da partição (derivada da ingestion_date da bronze)"
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

    protheus_nf_out_items = {
      description = "Notas fiscais de saída (itens) do Protheus (SD2010) normalizadas."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=protheus/dataset=protheus_nf_out_items/"

      columns = [
        { name = "source", type = "string", comment = "Sistema de origem (protheus)" },
        { name = "dataset", type = "string", comment = "Dataset lógico (nf_out_items)" },

        { name = "nf_number", type = "string", comment = "Número da NF (D2_DOC)" },
        { name = "nf_series", type = "string", comment = "Série da NF (D2_SERIE)" },
        { name = "item_number", type = "int", comment = "Número do item (D2_ITEM)" },

        { name = "product_code", type = "string", comment = "Código do produto (D2_COD)" },
        { name = "cfop", type = "string", comment = "CFOP (D2_CF)" },

        { name = "quantity", type = "double", comment = "Quantidade (D2_QUANT)" },
        { name = "unit_price", type = "double", comment = "Preço unitário (D2_PRUNIT)" },
        { name = "discount_value", type = "double", comment = "Desconto (D2_DESCON)" },
        { name = "total_value", type = "double", comment = "Total do item (D2_TOTAL)" },

        { name = "issue_date", type = "date", comment = "Data de emissão (D2_EMISSAO)" },
      ]

      partition_keys = [
        {
          name    = "created_date"
          type    = "date"
          comment = "Data da partição (derivada da ingestion_date da bronze)"
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

    protheus_orders = {
      description = "Pedidos do Protheus (SC5010) normalizados."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=protheus/dataset=protheus_orders/"

      columns = [
        { name = "source", type = "string", comment = "Sistema de origem (protheus)" },
        { name = "dataset", type = "string", comment = "Dataset lógico (orders)" },

        { name = "branch_code", type = "string", comment = "Filial do pedido (C5_FILIAL)" },
        { name = "order_id", type = "string", comment = "Número do pedido no Protheus (C5_NUM)" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido na Shopify armazenado no Protheus (C5_PEDECOM)" },
        { name = "customer_order_xid", type = "string", comment = "Identificador adicional do pedido/cliente (C5_XID)" },

        { name = "customer_code", type = "string", comment = "Código do cliente (C5_CLIENTE)" },
        { name = "customer_store", type = "string", comment = "Loja do cliente (C5_LOJACLI)" },

        { name = "issue_date", type = "date", comment = "Data de emissão do pedido (C5_EMISSAO)" },
        { name = "freight_value", type = "double", comment = "Valor do frete (C5_FRETE)" },
        { name = "freight_type", type = "string", comment = "Tipo do frete (C5_TPFRETE)" },
        { name = "expenses_value", type = "double", comment = "Outras despesas (C5_DESPESA)" },
        { name = "payment_condition_code", type = "string", comment = "Código da condição de pagamento (C5_CONDPAG)" },

        { name = "updated_at", type = "timestamp", comment = "Timestamp técnico do Protheus (S_T_A_M_P_)" },
      ]

      partition_keys = [
        {
          name    = "created_date"
          type    = "date"
          comment = "Data da partição (derivada da ingestion_date da bronze)"
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

    protheus_order_items = {
      description = "Itens de pedidos do Protheus (SC6010) normalizados."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=protheus/dataset=protheus_order_items/"

      columns = [
        { name = "source", type = "string", comment = "Sistema de origem (protheus)" },
        { name = "dataset", type = "string", comment = "Dataset lógico (order_items)" },

        { name = "branch_code", type = "string", comment = "Filial do pedido (C6_FILIAL)" },
        { name = "order_id", type = "string", comment = "Número do pedido no Protheus (C6_NUM)" },
        { name = "item_number", type = "int", comment = "Número do item do pedido (C6_ITEM)" },

        { name = "product_code", type = "string", comment = "Código do produto (C6_PRODUTO)" },
        { name = "quantity", type = "double", comment = "Quantidade vendida (C6_QTDVEN)" },
        { name = "unit_price", type = "double", comment = "Preço unitário (C6_PRCVEN)" },
        { name = "total_value", type = "double", comment = "Valor total do item (C6_VALOR)" },
        { name = "tes_code", type = "string", comment = "TES do item (C6_TES)" },

        { name = "issue_date", type = "date", comment = "Data de emissão do pedido (C5_EMISSAO)" },
        { name = "shopify_order_id", type = "string", comment = "ID do pedido na Shopify armazenado no Protheus (C5_PEDECOM)" },
        { name = "customer_order_xid", type = "string", comment = "Identificador adicional do pedido/cliente (C5_XID)" },
        { name = "customer_code", type = "string", comment = "Código do cliente (C5_CLIENTE)" },
        { name = "customer_store", type = "string", comment = "Loja do cliente (C5_LOJACLI)" },

        { name = "item_updated_at", type = "timestamp", comment = "Timestamp técnico do item no Protheus" },
        { name = "order_updated_at", type = "timestamp", comment = "Timestamp técnico do pedido no Protheus" },
        { name = "updated_at", type = "timestamp", comment = "Maior timestamp técnico disponível entre item e pedido" },
      ]

      partition_keys = [
        {
          name    = "created_date"
          type    = "date"
          comment = "Data da partição (derivada da ingestion_date da bronze)"
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

    omie_stocks = {
      description = "Snapshot de estoque do Omie por produto, local de estoque e data de posição."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_stocks/"

      columns = [
        # Identificação do produto
        { name = "product_id", type = "bigint", comment = "ID interno do produto no Omie (produto.nCodProd)" },
        { name = "product_code", type = "string", comment = "Código do produto (produto.cCodigo)" },
        { name = "product_description", type = "string", comment = "Descrição do produto (produto.cDescricao)" },
        { name = "unit", type = "string", comment = "Unidade do produto (produto.cUnidade)" },

        # Métricas de estoque
        { name = "stock_balance", type = "double", comment = "Saldo em estoque (produto.nSaldo)" },
        { name = "reserved_stock", type = "double", comment = "Estoque reservado (produto.nSaldoReservado)" },
        { name = "available_stock", type = "double", comment = "Estoque disponível (produto.nSaldoDisponivel)" },
        { name = "blocked_stock", type = "double", comment = "Estoque bloqueado (produto.nSaldoBloqueado)" },
        { name = "in_transit_stock", type = "double", comment = "Estoque em trânsito (produto.nSaldoEmTransito)" },

        # Valores
        { name = "stock_value", type = "double", comment = "Valor do estoque (produto.nValorEstoque)" },
        { name = "average_cost", type = "double", comment = "Custo médio (produto.nCustoMedio)" },
        { name = "sale_price", type = "double", comment = "Preço de venda (produto.nPrecoVenda)" },

        # Local de estoque
        { name = "warehouse_location_id", type = "bigint", comment = "ID do local de estoque (_local_estoque.codigo_local_estoque ou produto.nCodLocalEstoque)" },
        { name = "warehouse_location_code", type = "string", comment = "Código do local de estoque (_local_estoque.codigo ou produto.cCodLocalEstoque)" },

        # Data de posição
        { name = "position_date", type = "date", comment = "Data da posição do estoque, derivada de date_range_br.start, produto.dDataPosicao ou ingestion_date" },

        # Metadados
        { name = "run_id", type = "string", comment = "Identificador da execução de ingestão" },
        { name = "generated_at", type = "timestamp", comment = "Timestamp de geração do payload bruto" },
        { name = "source_cnpj", type = "string", comment = "CNPJ da empresa no Omie" },
        { name = "source_system", type = "string", comment = "Sistema de origem, fixado como omie" }
      ]

      partition_keys = [
        {
          name    = "ingestion_date"
          type    = "date"
          comment = "Data de ingestão do snapshot de estoque (YYYY-MM-DD)"
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

    omie_customers = {
      description = "Customers from Omie ERP refined in Silver (one row per customer, latest version by customer_key)."
      location    = "s3://${var.bucket}/domain=${var.domain}/source=omie/dataset=omie_customers/"

      columns = [
        # Source / lineage
        { name = "domain", type = "string", comment = "Logical data domain from source envelope" },
        { name = "source", type = "string", comment = "Source system name (omie)" },
        { name = "dataset", type = "string", comment = "Dataset name from source envelope" },
        { name = "run_id", type = "string", comment = "Ingestion run identifier" },
        { name = "generated_at", type = "string", comment = "Source file generation timestamp from bronze envelope" },
        { name = "source_cnpj", type = "string", comment = "Source company CNPJ used during extraction (matriz account)" },
        { name = "source_date_from_br", type = "string", comment = "Original extraction start date in Brazilian format (DD/MM/YYYY)" },
        { name = "source_date_to_br", type = "string", comment = "Original extraction end date in Brazilian format (DD/MM/YYYY)" },
        { name = "source_page_number", type = "bigint", comment = "Source page number from Omie pagination" },
        { name = "source_total_pages", type = "bigint", comment = "Total number of pages informed by Omie for the extraction" },

        # Customer identifiers
        { name = "customer_key", type = "string", comment = "Business key used for deduplication (coalesce of Omie ID, integration ID, document or email)" },
        { name = "customer_omie_id", type = "string", comment = "Internal customer identifier in Omie" },
        { name = "customer_integration_id", type = "string", comment = "Customer integration identifier from Omie" },
        { name = "customer_document", type = "string", comment = "Customer CPF or CNPJ digits only" },

        # Customer profile
        { name = "customer_name", type = "string", comment = "Customer legal name / full name" },
        { name = "customer_trade_name", type = "string", comment = "Customer trade name / short name" },
        { name = "customer_person_type", type = "string", comment = "Customer person type (PF or PJ)" },
        { name = "customer_email", type = "string", comment = "Customer e-mail in lowercase" },
        { name = "customer_contact_name", type = "string", comment = "Customer contact name" },

        # Contact
        { name = "customer_phone_area_code", type = "string", comment = "Phone area code (DDD)" },
        { name = "customer_phone_number", type = "string", comment = "Phone number digits only" },

        # Address
        { name = "address_street", type = "string", comment = "Street / address line" },
        { name = "address_number", type = "string", comment = "Address number" },
        { name = "address_complement", type = "string", comment = "Address complement" },
        { name = "address_neighborhood", type = "string", comment = "Address neighborhood" },
        { name = "address_city", type = "string", comment = "Address city" },
        { name = "address_state", type = "string", comment = "Address state (UF)" },
        { name = "address_zipcode", type = "string", comment = "ZIP code digits only" },
        { name = "address_country_code", type = "string", comment = "Country code from Omie" },
        { name = "city_code", type = "string", comment = "IBGE city code" },

        # Registrations
        { name = "state_registration", type = "string", comment = "State registration" },
        { name = "municipal_registration", type = "string", comment = "Municipal registration" },

        # Status flags
        { name = "is_inactive", type = "boolean", comment = "Whether customer is inactive in Omie" },
        { name = "is_billing_blocked", type = "boolean", comment = "Whether customer billing is blocked" },
        { name = "is_delete_blocked", type = "boolean", comment = "Whether customer deletion is blocked" },
        { name = "is_foreign", type = "boolean", comment = "Whether customer is foreign" },
        { name = "send_attachments", type = "boolean", comment = "Whether attachments should be sent" },
        { name = "is_imported_via_api", type = "boolean", comment = "Whether customer was imported via API" },

        # ERP timestamps / authorship
        { name = "created_at_erp", type = "timestamp", comment = "Customer creation timestamp in Omie ERP" },
        { name = "updated_at_erp", type = "timestamp", comment = "Customer last update timestamp in Omie ERP" },
        { name = "created_by_erp", type = "string", comment = "User that created the customer in Omie" },
        { name = "updated_by_erp", type = "string", comment = "User that last updated the customer in Omie" },
        { name = "created_date", type = "date", comment = "Date portion of created_at_erp" },
        { name = "updated_date", type = "date", comment = "Date portion of updated_at_erp" },

        # Tags
        { name = "customer_tags", type = "string", comment = "Customer tags concatenated by pipe" }
      ]

      partition_keys = [
        {
          name    = "ingestion_date"
          type    = "date"
          comment = "Ingestion date of the refined Omie customers batch (YYYY-MM-DD)"
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
  environment    = var.environment
  database_name  = var.database_name
  table_name     = each.key
  description    = each.value.description
  location       = each.value.location
  columns        = each.value.columns
  partition_keys = each.value.partition_keys
  parameters     = { classification = "parquet", compressionType = "snappy" }
}

