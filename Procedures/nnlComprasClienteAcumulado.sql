/*===============================================================================
  Procedure.: nnlComprasClienteAcumulado
  Autor.....: Júnior Oliveira
  Argumentos: @nu_identificacao - Identificação cliente              
			  @processo_id - Id do processo
=================================================================================*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nnlComprasClienteAcumulado]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure nnlComprasClienteAcumulado
go

create procedure nnlComprasClienteAcumulado	   
       @nu_identificacao char(50),
	   @processo_id integer = 0
AS

-- Declara id do processo
SELECT	@processo_id = ROUND(((999 - 1 -1) * RAND() + 1), 0)

-- Cria tabela temporária
CREATE TABLE #tmpComprasClienteAcumulado ( 
         nu_identificacao varchar(50) null,
         prd_nome_compra varchar(60) null,
         material_id integer not null,
         qtd numeric null,		 
		 valor float null,
		 processo_id integer not null)

-- Insere os dados na tabela temporária
INSERT #tmpComprasClienteAcumulado

SELECT 
	nu_identificacao,
	prd_nome_compra,
	vw_itemvenda.material_id,
	qtd,
	valor,
	'processo_id' = (@processo_id)

FROM vw_itemvenda

  INNER JOIN material ON material.material_id = vw_itemvenda.material_id
  INNER JOIN cliente ON cliente.cliente_id = vw_itemvenda.cliente_id

WHERE 
	nu_identificacao = (@nu_identificacao)
	AND st_cancelado = 'N'

-- Consulta a tabela temporária
SELECT material_id, 	
	prd_nome_compra,
	sum(qtd) as 'qtd_produto',
	sum(valor) as 'total_produto'

FROM #tmpComprasClienteAcumulado

WHERE
	nu_identificacao = (@nu_identificacao)
	AND processo_id = (@processo_id)

GROUP BY 
	material_id, 	
	prd_nome_compra
	
ORDER BY total_produto DESC

-- Deleta a tabela temporária
DROP TABLE #tmpComprasClienteAcumulado



