SELECT
	h.wafer_map_header_id
	,h.file_id
	,h.device
	,h.lot
	,h.wafer
	,h.bcequ
	,h.fnloc
	,h.refpx
	,h.refpy
	,h.dutms
	,h.xdies
	,h.ydies
	,h.rowct
	,h.colct
	,h.create_date as header_create_date
	,r.wafer_map_result_id
	,r.create_date as wafer_create_date
	,r.wafer_result_die_bin_row
	,r.wafer_result_die_bin_column
	,r.wafer_result_die_bin_value
	,f.filetype
	,f.filename
	,f.filesize
	,f.filedate
	,f.file_submission_date
	,f.create_date AS file_create_date
	,f.provider
FROM schema_name_here.tek_wafer_map_headers h
	JOIN schema_name_here.tek_wafer_map_results r ON h.wafer_map_header_id = r.wafer_map_header_id
	JOIN schema_name_here.files_metadata f ON h.file_id = f.file_id