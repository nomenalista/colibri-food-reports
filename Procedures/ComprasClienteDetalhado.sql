SELECT 
	dt_contabil,
	vw_itemvenda.material_id,	
	prd_nome,
	qtd,
	vl_unitario,
	valor,		
	vw_itemvenda.cliente_id,
	nm_nome	

FROM vw_itemvenda

  INNER JOIN material ON material.material_id = vw_itemvenda.material_id
  INNER JOIN cliente ON cliente.cliente_id = vw_itemvenda.cliente_id

WHERE 
	cliente.nu_identificacao = '4884346646'
	AND st_cancelado = 'N'


