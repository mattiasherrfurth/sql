SELECT
	f.filename
	,f.create_date
	,ti.*
	,ob.*
	,od.*
	,it.*
	,lt.*
	,il.*
FROM schema_name_here.tek_inv_lines il
JOIN schema_name_here.tek_inv_line_total lt ON il.line_total_id = lt.line_total_id
JOIN schema_name_here.tek_inv_term it ON lt.inv_term_id = it.inv_term_id
JOIN schema_name_here.tek_inv_order_detail od ON od.order_detail_id = it.order_detail_id
JOIN schema_name_here.tek_inv_order_by ob ON od.order_by_id = ob.order_by_id
JOIN schema_name_here.tek_invoice ti ON ti.tek_invoice_id = ob.tek_invoice_id
JOIN schema_name_here.files_metadata f ON f.file_id = ti.file_id
WHERE (0<>1)
	AND f.create_date = '2023-09-22 17:02:48.75142+00'
	AND f.filename = 'Invoice_121151_PO5000232985_20230810.pdf'
ORDER BY f.create_date DESC