USE [j20032_herrfurth_test]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP table if exists join_test;
SELECT
	QN_Table_backup.*,
	pn_qty_per_day
INTO join_test
FROM QN_Table_backup
	LEFT JOIN Ops_test on
		qnot_part_no = ordr_part_no
		and qnot_created_dt = op_date
