/*
* Taxa retorno
*/

DECLARE @taxa_retorno integer
DECLARE @total_gasto float
DECLARE @ticket_medio float

SELECT @taxa_retorno = (SELECT
	count(nu_identificacao) as 'taxa_retorno'
FROM HEADERVENDAGERAL
  INNER JOIN cliente ON cliente.cliente_id = HEADERVENDAGERAL.cliente_id
WHERE 
	cliente.nu_identificacao = 'FER SOCIO'
	AND st_cancelado = 'N')
/*
* Total cliente
*/
SELECT @total_gasto = (SELECT
	sum(valor) as 'total_cliente'
FROM vw_itemvenda
  INNER JOIN cliente ON cliente.cliente_id = vw_itemvenda.cliente_id
WHERE 
	cliente.nu_identificacao = 'FER SOCIO'
	AND st_cancelado = 'N')
/*
* Ticket médio
*/

SELECT @ticket_medio = (@total_gasto / @taxa_retorno)

SELECT @total_gasto as 'total_gasto', @taxa_retorno as 'taxa_retorno', @ticket_medio as 'ticket_medio'

