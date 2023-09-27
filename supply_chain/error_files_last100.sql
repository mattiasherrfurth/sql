SELECT f.filename
	,e.error_timestamp
	,e.error_id
	,e.source
	,e.error_subject
	,e.error_message
	,e.create_date
FROM schema_name_here.errors e
	JOIN schema_name_here.files_metadata f ON e.file_id = f.file_id
WHERE e.error_timestamp IS NOT NULL
ORDER BY e.error_timestamp DESC
FETCH FIRST 100 ROWS ONLY