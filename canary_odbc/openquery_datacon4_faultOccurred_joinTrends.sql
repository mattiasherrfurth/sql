with fo_ts_tbl as(
select *
from openquery([CANARY_YW4-YWVAP190154] ,'
SELECT
	data.tag_name AS tag_name
	,data.time_stamp AS time_stamp
	,data.value AS val
FROM canarydata.data data
WHERE data.tag_name like ''AMEC.Datacon4.%.FaultOcc%TimeStamp''
	and data.time_stamp > ''day-1d''
	and data.quality = ''192''
')
),
fo_desc_tbl as(
select *
from openquery([CANARY_YW4-YWVAP190154] ,'
SELECT
	data.tag_name AS tag_name
	,data.time_stamp AS time_stamp
	,data.value AS val
FROM canarydata.data data
WHERE data.tag_name like ''AMEC.Datacon4.%.FaultOcc%Fault.Description''
	and data.time_stamp > ''day-1d''
	and data.quality = ''192''
')
),
fo_fc_tbl as(
select *
from openquery([CANARY_YW4-YWVAP190154] ,'
SELECT
	data.tag_name AS tag_name
	,data.time_stamp AS time_stamp
	,data.value AS val
FROM canarydata.data data
WHERE data.tag_name like ''AMEC.Datacon4.%.FaultOcc%Fault.FaultCode''
	and data.time_stamp > ''day-1d''
	and data.quality = ''192''
')
)
select t.*
	,c.val as faultcode
	,d.val as faultdesc
from fo_ts_tbl t
	left join fo_fc_tbl c on t.time_stamp = c.time_stamp
	left join fo_desc_tbl d on t.time_stamp = d.time_stamp