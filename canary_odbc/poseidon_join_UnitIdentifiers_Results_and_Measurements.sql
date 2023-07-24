with timestamps as(
SELECT *
FROM [db_name].[dbo].[Poseidon_UnitsInspected]
WHERE (1 <> 0)
	and tag_name like '%Poseidon1A%'
	and tag_name like '%TimeStamp'
)
,insps as(
SELECT
	-- handling for when the unit position number has one digit vs. two digits
	CASE
		WHEN PATINDEX('%:[0-9][0-9].%',[tag_name]) = 0 THEN left([tag_name],(charindex(':',[tag_name])+1))
		WHEN PATINDEX('%:[0-9][0-9].%',[tag_name]) > 0 THEN left([tag_name],(charindex(':',[tag_name])+2))
	END AS tag_key
	,CASE
		WHEN PATINDEX('%:[0-9][0-9].%',[tag_name]) = 0 THEN right([tag_name],(len([tag_name])-charindex(':',[tag_name])-2))
		WHEN PATINDEX('%:[0-9][0-9].%',[tag_name]) > 0 THEN right([tag_name],(len([tag_name])-charindex(':',[tag_name])-3))
	END AS measurement
	,[time_stamp]
	,[val]
FROM [db_name].[dbo].[Poseidon_UnitsInspected]
WHERE (1 <> 0)
	and tag_name like '%Poseidon1A%:%'
	and tag_name not like '%UniqueIdentifier'
	and tag_name not like '%InspectionName'
)
,ids as(SELECT * FROM insps WHERE measurement = 'UnitIdentifier')
,results as(SELECT * FROM insps WHERE measurement = 'OverallResult')
,vals as(SELECT * FROM insps WHERE measurement not in ('UnitIdentifier','OverallResult'))
select 
	t.val as Time_Stamp
	,v.*
	,i.val as UnitIdentifier
	,r.val as OverallResult
from timestamps t
	left join vals v on t.time_stamp = v.time_stamp
	left join ids i on v.tag_key = i.tag_key and v.time_stamp = i.time_stamp
	left join results r on v.tag_key = r.tag_key and v.time_stamp = r.time_stamp
ORDER BY t.time_stamp