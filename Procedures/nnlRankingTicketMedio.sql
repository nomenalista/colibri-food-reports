/*===============================================================================
  Procedure.: nnlRankingTicketMedio
  Autor.....: Júnior Oliveira
  Argumentos: @dt_incio  - Data inicial
              @dt_fim    - Data final
              @nr_resultados - Número de resultados
			  @processo_id - Id do processo
=================================================================================*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nnlRankingTicketMedio]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure nnlRankingTicketMedio

go
create procedure nnlRankingTicketMedio
       @dt_inicio  char(10) = '1900-01-01',
       @dt_fim    char(10) = '2900-01-01',	   
       @nr_resultados integer = 30,
	   @processo_id integer = 0
AS

-- Declara id do processo
SELECT	@processo_id = ROUND(((999 - 1 -1) * RAND() + 1), 0)

-- Cria tabela temporária
CREATE TABLE #tmpRankingTicketMedio ( 
         nu_identificacao varchar(50) null,
         nm_nome varchar(200) null,         
         dt_aniversario varchar(50) null,
		 nu_telefone varchar(50) null,
		 total_gasto float null,
		 taxa_retorno integer null,
		 processo_id integer not null)

-- Insere os dados na tabela temporária
INSERT #tmpRankingTicketMedio

SELECT 
	Clientes.NU_IDENTIFICACAO,
	Clientes.nm_nome,	
	Clientes.dt_aniversario,
	'nu_telefone' = case when (nu_telefone is null) then (nu_identificacao) else (nu_telefone) end,	
	'total_gasto' = (SELECT
							sum(valor) as 'total_gasto'
						FROM vw_itemvenda
						INNER JOIN cliente ON cliente.cliente_id = vw_itemvenda.cliente_id
						WHERE 
							dt_contabil BETWEEN @dt_inicio AND @dt_fim
							AND cliente.nu_identificacao = Clientes.NU_IDENTIFICACAO
							AND st_cancelado = 'N'),	
	'taxa_retorno' = (SELECT
							count(nu_identificacao) as 'taxa_retorno'
						FROM HEADERVENDAGERAL
							INNER JOIN cliente ON cliente.cliente_id = HEADERVENDAGERAL.cliente_id
						WHERE 
							dt_contabil BETWEEN @dt_inicio AND @dt_fim
							AND cliente.nu_identificacao = Clientes.NU_IDENTIFICACAO
							AND st_cancelado = 'N'),								
	'processo_id' = @processo_id							
	
FROM HEADERVENDAGERAL
	
	INNER JOIN CLIENTE as Clientes ON Clientes.cliente_id = HEADERVENDAGERAL.cliente_id

WHERE 
	dt_contabil BETWEEN @dt_inicio AND @dt_fim							
	AND st_cancelado = 'N'	
	AND NU_IDENTIFICACAO NOT IN ('CLIENTE VENDA', 'cortesia bar', 'teste', 'estacionament', 'ação', 'ACAO', 'ESTACIONAMENTO', 'SEGURANCA', 'COCKTAIL', 'ANIVERSARIO')
	AND NU_IDENTIFICACAO NOT LIKE 'perda%'
	AND NU_IDENTIFICACAO NOT LIKE 'cortesia%'
	AND NM_NOME NOT IN ('ERRO DIGITACAO', 'SEGURANÇA', 'teste', 'ESTACIONAMENTO', 'ação', 'ACAO', 'SEGURANCA', 'COCKTAIL', 'ANIVERSARIO', 'CORTESSIA BAR')
	AND NM_NOME NOT LIKE 'cortesia%'
	AND NM_NOME NOT LIKE 'perda%'
	AND NM_NOME NOT LIKE 'EVENTO%'
	AND NM_NOME NOT LIKE 'COMIDA%'
	AND NM_NOME NOT LIKE 'BEBIDA%'
	AND NM_NOME NOT LIKE 'NENNHUM%'

-- Consulta a tabela temporária
SELECT top (@nr_resultados)
	nu_identificacao,	
	nm_nome,
	dt_aniversario,
	nu_telefone,
	total_gasto,
	taxa_retorno,
	'ticket_medio' = (total_gasto / taxa_retorno)

from #tmpRankingTicketMedio

WHERE 
	processo_id = @processo_id

group by 	
	nu_identificacao,
	nm_nome,	
	dt_aniversario,
	nu_telefone,
	total_gasto,
	taxa_retorno

order by taxa_retorno desc, 'ticket_medio' desc

-- Deleta a tabela temporária
drop table #tmpRankingTicketMedio