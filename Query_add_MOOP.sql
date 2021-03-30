WITH MOOP_tbl as(
	SELECT * 
	FROM OPENQUERY(ORAD, '
	select * from tdwhmoop
	   ')
	   ),
Insp_tbl as(
	SELECT 	
		[XLDATE],
		[PCLL_SHORT_NM],
		[WBSE_CD],
		[ILOR_PART_NO],
		[ORDR_SPRT_SER_NO],
		[ORDR_NO],
		[OROP_ID],
		[ILOR_EMPL_ID],
		[ILOR_EVALUATION_CD],
		[qnot_no],
		[EMPL_FIRST_NM],
		[EMPL_LAST_NM] 
	FROM [j20032_yield].[dbo].[YieldPlusQNs] 
	WHERE [DATE] >= DATEADD(Year, -3, getdate()) 
		AND [OROP_PLNT_ID] = 'P001'
		AND [YIELDCATEGORY] = 'INSPECTION'
		)
SELECT
	[XLDATE],
	[PCLL_SHORT_NM],
	[WBSE_CD],
	[MOOP_MPGM_ID],
	[ILOR_PART_NO],
	[ORDR_SPRT_SER_NO],
	[ORDR_NO],
	[OROP_ID],
	[ILOR_EMPL_ID],
	[ILOR_EVALUATION_CD],
	[qnot_no],
	[EMPL_FIRST_NM],
	[EMPL_LAST_NM]  
FROM Insp_tbl
	LEFT JOIN MOOP_tbl On
		[WBSE_CD] = [MOOP_WBSE_CD]