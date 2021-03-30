/*-----------------------------------------------------------------------------
-- Title:       Inspector Selector Table
-- Author:      Mattias
-- Created:     Q3 2019
-- Purpose:     This query pulls in only Inspection Labor columns from the YieldPlusQNs table.

-------------------------------------------------------------------------------
-- Current version:     6
-- Modification History:
--
-- Version 1 - Q3 2019 - Mattias Herrfurth
--      Published
-- Version 2 - 10/01/2019 - Mattias Herrfurth
--      Adding column qnot_no, qnot_typ
-- Version 3 - 10/01/2019 - Mattias Herrfurth
--      Creating table for QN tasks for joining in predisposition information
-- Version 4 - 10/01/2019 - Mattias Herrfurth
--      Version 3 update didn't work as intended, but does not inhibit Tableau report (debug later)
--		Including quantity in table
-- Version 5 - 10/08/2019 - Mattias Herrfurth
--      Including workcenter (WCCT_CD)
--		Changing JOIN to LEFT JOIN
-- Version 6 - 10/23/2019 - Mattias Herrfurth
--      Dropping filter for BWI plant P001
-- Version 7 - 03/10/2020 - Mattias Herrfurth
--      Dropping filter for BWI plant P001
-----------------------------------------------------------------------------*/

--drop table if exists QN_TBL;
--drop table if exists backupInspPN_YieldQNs;
SELECT * INTO QN_TBL
FROM
	OPENQUERY(ORAD,'
		SELECT
			QNTK_QNOT_NO,
			QNTK_NO,
			QNTK_QNDF_NO,
			QNTK_CREATED_DT,
			QNTK_QNCT_TIER2_CD,
			QNTK_QNCT_TIER3_CD
		FROM 
			TDWHQNTK
		WHERE
			QNTK_QNCT_TIER2_CD = ''PRDISP'' AND
			QNTK_CREATED_DT > ''01-JAN-19''
			')

SELECT 	
	[XLDATE],
	[PCLL_SHORT_NM],
	[WCTR_CD],
	[ILOR_PART_NO],
	[ORDR_SPRT_SER_NO],
	[ORDR_NO],
	[ILOR_QTY],
	[OROP_ID],
	[ILOR_EMPL_ID],
	[ILOR_EVALUATION_CD],
	[QNOT_NO],
	[QNOT_TYP],
	[QNTK_NO],
	[QNTK_QNDF_NO],
	[QNTK_CREATED_DT],
	[QNTK_QNCT_TIER2_CD],
	[QNTK_QNCT_TIER3_CD],
	[EMPL_FIRST_NM],
	[EMPL_LAST_NM]
-- INTO backupInspPN_YieldQNs
FROM [j20032_yield].[dbo].[YieldPlusQNs]
	LEFT JOIN QN_TBL
		ON QNOT_NO = QNTK_QNOT_NO
WHERE 
	[DATE] >= DATEADD(Year, -2, getdate()) AND
    --[OROP_PLNT_ID] = 'P001' AND
    [YIELDCATEGORY] = 'INSPECTION'