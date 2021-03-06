/*===============================================================================
  Procedure.: nnlRankingClientePorProduto
  Autor.....: Júnior Oliveira
  Argumentos: @material_id  - Codigo do Produto             
              @nr_resultados - Número de resultados
			  @processo_id - Id do processo
=================================================================================*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nnlRankingClientePorProduto]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure nnlRankingClientePorProduto
go

create procedure nnlRankingClientePorProduto
	   @material_id integer,
       @nr_resultados integer = 30,
	   @processo_id integer = 0
AS

-- Declara id do processo
SELECT	@processo_id = ROUND(((999 - 1 -1) * RAND() + 1), 0)

-- Cria tabela temporária
CREATE TABLE #tmpRankingClientePorProduto ( 
         nu_identificacao varchar(50) null,
         nm_nome varchar(200) null,
         nm_sexo varchar(50) null,
         dt_aniversario varchar(50) null,
		 nu_telefone varchar(50) null,
		 qtd numeric null,
		 valor float null,
		 processo_id integer not null)

-- Insere os dados na tabela temporária
INSERT #tmpRankingClientePorProduto

SELECT 
	nu_identificacao,
	cliente.nm_nome,
	cliente.nm_sexo,
	cliente.dt_aniversario,
	'nu_telefone' = case when (nu_telefone is null) then (nu_identificacao) else (nu_telefone) end,	
	qtd,
	valor,
	'processo_id' = @processo_id

FROM vw_itemvenda

  INNER JOIN cliente ON cliente.cliente_id = vw_itemvenda.cliente_id

WHERE 
	material_id = (@material_id)
	AND CLIENTE.NU_IDENTIFICACAO NOT IN ('CLIENTE VENDA', 'cortesia bar', 'teste', 'estacionament', 'ação', 'ACAO', 'ESTACIONAMENTO', 'SEGURANCA', 'COCKTAIL', 'ANIVERSARIO')
	AND CLIENTE.NU_IDENTIFICACAO NOT LIKE 'perda%'
	AND CLIENTE.NU_IDENTIFICACAO NOT LIKE 'cortesia%'
	AND CLIENTE.NM_NOME NOT IN ('ERRO DIGITACAO', 'SEGURANÇA', 'teste', 'ESTACIONAMENTO', 'ação', 'ACAO', 'SEGURANCA', 'COCKTAIL', 'ANIVERSARIO', 'CORTESSIA BAR')
	AND CLIENTE.NM_NOME NOT LIKE 'cortesia%'
	AND CLIENTE.NM_NOME NOT LIKE 'perda%'
	AND CLIENTE.NM_NOME NOT LIKE 'EVENTO%'
	AND CLIENTE.NM_NOME NOT LIKE 'COMIDA%'
	AND CLIENTE.NM_NOME NOT LIKE 'BEBIDA%'
	AND st_cancelado = 'N'

-- Consulta a tabela temporária
SELECT top (@nr_resultados)
	nu_identificacao,	
	nm_nome,
	nm_sexo,
	dt_aniversario,
	nu_telefone,
	sum(qtd) as 'qtd_produto',
	sum(valor) as 'total_gasto'

from #tmpRankingClientePorProduto

WHERE 
	processo_id = @processo_id

group by 	
	nu_identificacao,
	nm_nome,	
	nm_sexo,
	dt_aniversario,
	nu_telefone

order by total_gasto DESC

-- Deleta a tabela temporária
drop table #tmpRankingClientePorProduto



