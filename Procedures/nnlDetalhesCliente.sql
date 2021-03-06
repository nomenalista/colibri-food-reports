/*===============================================================================
  Procedure.: nnlDetalhesCliente
  Autor.....: Júnior Oliveira
  Argumentos: @nu_identificacao - Identificação cliente              
			  @processo_id - Id do processo
=================================================================================*/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nnlDetalhesCliente]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure nnlDetalhesCliente
go

create procedure nnlDetalhesCliente	   
       @nu_identificacao char(50)	   
AS

SELECT 
	nu_identificacao,
	nm_nome,
	'nu_telefone' = case when (nu_telefone is null) then (nu_identificacao) else (nu_telefone) end,
	dt_aniversario,
	nm_email,
	dt_datacadastro

FROM cliente

WHERE 
	nu_identificacao = (@nu_identificacao)




