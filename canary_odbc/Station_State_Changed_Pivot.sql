select 
time_stamp Canary_TS, 
[AMEC.Datacon4.ResourcePerformance.StationStateChanged.TimeStamp] CFX_TS, 
[AMEC.Datacon4.ResourcePerformance.StationStateChanged.$type] type,
[AMEC.Datacon4.ResourcePerformance.StationStateChanged.MessageName] MessageName,
[AMEC.Datacon4.ResourcePerformance.StationStateChanged.NewState] NewState,
[AMEC.Datacon4.ResourcePerformance.StationStateChanged.OldState] OldState,
[AMEC.Datacon4.ResourcePerformance.StationStateChanged.Source] Source
FROM(
	select *
	from openquery([CANARY_YW4-YWVAP190154] ,'
	SELECT
		data.tag_name AS tag_name
		,data.time_stamp AS time_stamp
		,data.value AS val
	FROM canarydata.data data
	WHERE data.tag_name like ''AMEC.Datacon4.%.StationState%''
		and data.time_stamp > ''day-1w''
		and data.quality = ''192''
	')
	PIVOT (MAX(val)
	for tag_name IN(
		[AMEC.Datacon4.ResourcePerformance.StationStateChanged.TimeStamp], 
		[AMEC.Datacon4.ResourcePerformance.StationStateChanged.$type],
		[AMEC.Datacon4.ResourcePerformance.StationStateChanged.MessageName], 
		[AMEC.Datacon4.ResourcePerformance.StationStateChanged.NewState],
		[AMEC.Datacon4.ResourcePerformance.StationStateChanged.OldState],
		[AMEC.Datacon4.ResourcePerformance.StationStateChanged.Source]
		)
	)as Initial_Pivot
) as Named_Pivot
order by Canary_TS desc