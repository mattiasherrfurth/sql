USE [j20032_herrfurth_test]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP table if exists Ops_test;
SELECT * into Ops_test
FROM OPENQUERY(ORAD, '
SELECT
	ordr_part_no,
	TO_CHAR(orop_act_completed_dtm, ''DD/MM/YYYY'') as op_date,
	SUM(orop_qty) as pn_qty_per_day
FROM tdwhorop
	INNER JOIN tdwhordr on 
		ordr_rtg_no = orop_ordr_rtg_no
		and orop_ordr_no = ordr_no
WHERE
	orop_act_completed_dtm >= sysdate - 365
	--orop_act_completed_dtm >= sysdate - 14					-- for testing purposes ONLY
GROUP BY
	ordr_part_no,
	TO_CHAR(orop_act_completed_dtm, ''DD/MM/YYYY'')
ORDER BY
	to_char(orop_act_completed_dtm, ''DD/MM/YYYY'')
')