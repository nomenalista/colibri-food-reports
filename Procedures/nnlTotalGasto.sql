/*===============================================================================
  Procedure.: nnlTotalGasto
  Autor.....: Júnior Oliveira
  Argumentos: @nu_identificacao - Identificação Cliente
=================================================================================*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nnlTotalGasto]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure nnlTotalGasto
go

create procedure nnlTotalGasto
       @nu_identificacao  char(50)
AS

SELECT
	sum(valor) as 'total_cliente'
FROM vw_itemvenda
  INNER JOIN cliente ON cliente.cliente_id = vw_itemvenda.cliente_id
WHERE 
	cliente.nu_identificacao = (@nu_identificacao)
	AND st_cancelado = 'N'