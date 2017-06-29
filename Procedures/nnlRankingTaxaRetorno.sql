/*===============================================================================
  Procedure.: nnlRankingTaxaRetorno
  Autor.....: Júnior Oliveira
  Argumentos: @dt_incio  - Data inicial
              @dt_fim    - Data final
              @nr_resultados - Número de resultados
			  @processo_id - Id do processo
=================================================================================*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nnlRankingTaxaRetorno]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure nnlRankingTaxaRetorno

go
create procedure nnlRankingTaxaRetorno
       @dt_inicio  char(10) = '1900-01-01',
       @dt_fim    char(10) = '2900-01-01',	   
       @nr_resultados integer = 30,
	   @processo_id integer = 0
AS

-- Declara id do processo
SELECT	@processo_id = ROUND(((999 - 1 -1) * RAND() + 1), 0)

-- Cria tabela temporária
CREATE TABLE #tmpRankingTaxaRetorno ( 
         nu_identificacao varchar(50) null,
         nm_nome varchar(200) null,         
         dt_aniversario varchar(50) null,
		 nu_telefone varchar(50) null,
		 taxa_retorno integer null,		 
		 processo_id integer not null)

-- Insere os dados na tabela temporária
INSERT #tmpRankingTaxaRetorno

SELECT 
	Clientes.NU_IDENTIFICACAO,
	Clientes.nm_nome,	
	Clientes.dt_aniversario,
	'nu_telefone' = case when (nu_telefone is null) then (nu_identificacao) else (nu_telefone) end,		
	'taxa_retorno' = (SELECT
							count(nu_identificacao) as 'taxa_retorno'
						FROM HEADERVENDAGERAL
							INNER JOIN cliente ON cliente.cliente_id = HEADERVENDAGERAL.cliente_id
						WHERE 
							dt_contabil BETWEEN @dt_inicio AND @dt_fim
							AND cliente.nu_identificacao = Clientes.NU_IDENTIFICACAO
							AND st_cancelado = 'N'),
	'processo_id' = @processo_id							
	
FROM CLIENTE as Clientes

WHERE 
	Clientes.NU_IDENTIFICACAO NOT IN ('CLIENTE VENDA', 'cortesia bar', 'teste', 'estacionament', 'ação', 'ACAO', 'ESTACIONAMENTO', 'SEGURANCA', 'COCKTAIL', 'ANIVERSARIO')
	AND Clientes.NU_IDENTIFICACAO NOT LIKE 'perda%'
	AND Clientes.NU_IDENTIFICACAO NOT LIKE 'cortesia%'
	AND Clientes.NM_NOME NOT IN ('ERRO DIGITACAO', 'SEGURANÇA', 'teste', 'ESTACIONAMENTO', 'ação', 'ACAO', 'SEGURANCA', 'COCKTAIL', 'ANIVERSARIO', 'CORTESSIA BAR')
	AND Clientes.NM_NOME NOT LIKE 'cortesia%'
	AND Clientes.NM_NOME NOT LIKE 'perda%'
	AND Clientes.NM_NOME NOT LIKE 'EVENTO%'
	AND Clientes.NM_NOME NOT LIKE 'COMIDA%'
	AND Clientes.NM_NOME NOT LIKE 'BEBIDA%'
	AND Clientes.NM_NOME NOT LIKE 'NENNHUM%'

-- Consulta a tabela temporária
select top (@nr_resultados) * 
FROM #tmpRankingTaxaRetorno 
WHERE processo_id = @processo_id
order by taxa_retorno desc

-- Deleta a tabela temporária
drop table #tmpRankingTaxaRetorno