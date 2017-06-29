/*===============================================================================
  Procedure.: nnlTaxaRetorno
  Autor.....: Júnior Oliveira
  Argumentos: @nu_identificacao - Identificação Cliente
=================================================================================*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nnlTaxaRetorno]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure nnlTaxaRetorno
go

create procedure nnlTaxaRetorno
       @nu_identificacao  char(50) 
AS

SELECT
	count(nu_identificacao) as 'taxa_retorno'
FROM HEADERVENDAGERAL
  INNER JOIN cliente ON cliente.cliente_id = HEADERVENDAGERAL.cliente_id
WHERE 
	cliente.nu_identificacao = (@nu_identificacao)
	AND st_cancelado = 'N'