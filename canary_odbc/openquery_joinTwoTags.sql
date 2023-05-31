with cpu_total as (
	select * from openquery([CANARY_YW4-YWVAP190154] ,'
	SELECT
		data.tag_name AS tag_name
		,data.time_stamp AS time_stamp
		,data.value AS value
		,data.quality AS quality
		,data.aggregate_id AS aggregate_id
	FROM canarydata.data data
	WHERE data.tag_name like ''%CPU Usage Total''
	')
),
cpu_hist as (
	select * from openquery([CANARY_YW4-YWVAP190154] ,'
	SELECT
		data.tag_name AS tag_name
		,data.time_stamp AS time_stamp
		,data.value AS value
		,data.quality AS quality
		,data.aggregate_id AS aggregate_id
	FROM canarydata.data data
	WHERE data.tag_name like ''%CPU Usage Historian''
	')
)
select tot.time_stamp,
	tot.[value] as CPU_Usage_Total,
	hist.[value] as CPU_Usage_Historian
from cpu_total tot join cpu_hist hist on tot.time_stamp = hist.time_stamp