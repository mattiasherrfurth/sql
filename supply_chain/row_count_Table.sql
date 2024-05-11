SELECT
	N.NSPNAME AS TABLE_SCHEMA
	,C.RELNAME AS TABLE_NAME
	,C.RELTUPLES AS ROWS
FROM PG_CLASS C
	JOIN PG_NAMESPACE N ON N.OID = C.RELNAMESPACE
WHERE (0<>1)
	AND C.RELKIND = 'r'
	AND N.NSPNAME NOT IN ('information_schema','pg_catalog')
ORDER BY C.RELTUPLES DESC;

-- map types loaded 
SELECT
	N.NSPNAME AS TABLE_SCHEMA
	,C.RELNAME AS TABLE_NAME
	,C.RELTUPLES AS ROWS
FROM PG_CLASS C
	JOIN PG_NAMESPACE N ON N.OID = C.RELNAMESPACE
WHERE (0<>1)
	AND C.RELKIND = 'r'
	AND N.NSPNAME NOT IN ('information_schema','pg_catalog')
	AND C.RELNAME LIKE '%map%'
ORDER BY C.RELTUPLES DESC;

-- test types loaded 
SELECT
	N.NSPNAME AS TABLE_SCHEMA
	,C.RELNAME AS TABLE_NAME
	,C.RELTUPLES AS ROWS
FROM PG_CLASS C
JOIN PG_NAMESPACE N ON N.OID = C.RELNAMESPACE
WHERE (0<>1)
	AND C.RELKIND = 'r'
	AND N.NSPNAME NOT IN ('information_schema','pg_catalog')
	AND C.RELNAME LIKE '%asn%'
ORDER BY C.RELTUPLES DESC;