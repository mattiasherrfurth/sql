SELECT
	table_name
	,column_name
	,data_type
	,character_maximum_length
FROM information_schema.columns
WHERE (0<>1)
	AND table_schema = 'schema-name'
	AND table_name IN (
		SELECT table_name
		FROM information_schema.tables
		WHERE (0<>1)
			AND table_name LIKE 'asn%'
			OR table_name = 'files_metadata'
		)
ORDER BY table_name,column_name