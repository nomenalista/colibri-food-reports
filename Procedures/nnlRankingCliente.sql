/*===============================================================================
  Procedure.: nnlRankingCliente
  Autor.....: Júnior Oliveira
  Argumentos: @dt_incio  - Data inicial
              @dt_fim    - Data final
              @nr_resultados - Número de resultados
			  @processo_id - Id do processo
=================================================================================*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nnlRankingCliente]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure nnlRankingCliente
go

create procedure nnlRankingCliente
       @dt_inicio  char(10) = '1900-01-01',
       @dt_fim    char(10) = '2900-01-01',	   
       @nr_resultados integer = 30,
	   @processo_id integer = 0
AS

-- Declara id do processo
SELECT	@processo_id = ROUND(((999 - 1 -1) * RAND() + 1), 0)

-- Cria tabela temporária
CREATE TABLE #tmpRankingCliente ( 
         nu_identificacao varchar(50) null,
         nm_nome varchar(200) null,
         nm_sexo varchar(50) null,
         dt_aniversario varchar(50) null,
		 nu_telefone varchar(50) null,
		 valor float null,
		 processo_id integer not null)

-- Insere os dados na tabela temporária
INSERT #tmpRankingCliente

SELECT 
	nu_identificacao,
	cliente.nm_nome,
	cliente.nm_sexo,
	cliente.dt_aniversario,
	'nu_telefone' = case when (nu_telefone is null) then (nu_identificacao) else (nu_telefone) end,	
	valor,
	'processo_id' = @processo_id

FROM vw_itemvenda

  INNER JOIN cliente ON cliente.cliente_id = vw_itemvenda.cliente_id

WHERE 
	dt_contabil BETWEEN @dt_inicio AND @dt_fim
	AND CLIENTE.NU_IDENTIFICACAO NOT IN ('CLIENTE VENDA', 'cortesia bar', 'teste', 'estacionament', 'ação', 'ACAO', 'ESTACIONAMENTO', 'SEGURANCA', 'COCKTAIL', 'ANIVERSARIO')
	AND CLIENTE.NU_IDENTIFICACAO NOT LIKE 'perda%'
	AND CLIENTE.NU_IDENTIFICACAO NOT LIKE 'cortesia%'
	AND CLIENTE.NM_NOME NOT IN ('ERRO DIGITACAO', 'SEGURANÇA', 'teste', 'ESTACIONAMENTO', 'ação', 'ACAO', 'SEGURANCA', 'COCKTAIL', 'ANIVERSARIO', 'CORTESSIA BAR')
	AND CLIENTE.NM_NOME NOT LIKE 'cortesia%'
	AND CLIENTE.NM_NOME NOT LIKE 'perda%'
	AND CLIENTE.NM_NOME NOT LIKE 'EVENTO%'
	AND CLIENTE.NM_NOME NOT LIKE 'COMIDA%'
	AND CLIENTE.NM_NOME NOT LIKE 'BEBIDA%'
	AND CLIENTE.NM_NOME NOT LIKE 'NENNHUM%'
	AND st_cancelado = 'N'

-- Consulta a tabela temporária
SELECT top (@nr_resultados)
	nu_identificacao,	
	nm_nome,
	nm_sexo,
	dt_aniversario,
	nu_telefone,
	sum(valor) as 'total_gasto'

from #tmpRankingCliente

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
drop table #tmpRankingCliente



