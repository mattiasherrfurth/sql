DROP TABLE IF EXISTS temp_canary;
SELECT * INTO temp_canary
FROM OPENQUERY([CANARY_YW4-YWVAP190154] ,'
	SELECT
		data.tag_name AS tag_name
		,data.time_stamp AS time_stamp
		,data.value AS val
	FROM canarydata.data data
	WHERE data.tag_name like ''%Palomar8214%StationState%''
		and data.time_stamp > ''day-1d''
		and data.quality = ''192''
	')
DECLARE @cols AS NVARCHAR(MAX), @query AS NVARCHAR(MAX);
SET @cols = STUFF((SELECT DISTINCT ',' + QUOTENAME(c.tag_name)
			FROM temp_canary c
			FOR XML PATH(''), TYPE
			).value('.','NVARCHAR(MAX)')
		,1,1,'')
SET @query = 'SELECT time_stamp, '+@cols+' FROM
				(
					SELECT *
					FROM temp_canary
				) x
				PIVOT
				(
					MAX(VAL)
					FOR tag_name IN ('+@cols+')
				) p'
EXECUTE (@query)
DROP TABLE temp_canary