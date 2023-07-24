SELECT *
INTO [db_name].[dbo].[Poseidon_UnitsInspected]
FROM OPENQUERY([linked_server] ,'
SELECT
	data.tag_name AS tag_name
	,data.time_stamp AS time_stamp
	,data.value AS val
FROM canarydata.data data
WHERE (1 <> 0)
	and data.tag_name like ''%Poseidon%UnitsInspected%''
	and data.time_stamp > ''day-2w''
	and data.quality = ''192''
')