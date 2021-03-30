USE [j20032_herrfurth_test]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP table if exists QN_Table_backup;
SELECT * into QN_Table_backup
FROM OPENQUERY(ORAD, '
SELECT 
	qnot_no,
	qndf_desc,
	note_txt AS QN_long_text,
	qndf_comp_part_no,
	qnot_plnt_id, 
	qnot_typ,
	qndf_no, 
	qnot_created_dt, 
	serial_number, 
	qnot_qty,
	qnot_act_end_dt, 
	qnot_empl_id, 
	qnot_part_no, 
	part_desc,
	qnot_ordr_no, 
	wbse_cd, 
	wbse_desc,
	qnot_qnct_tier3_cd, 
	qnct_tier2_desc, 
	qndf_type_qnct_tier3_cd, 
	qnct_tier3_desc, 
	qndf_sprt_ser_no , 
	wctr_cd, wctr_desc, 
	wctr_wcct_id,
	orop_id, 
	orop_line1_desc, 
	qn_hours, 
	qndf_locn_qnct_tier3_cd,  
	ordr_oper_completed_dt, 
	ordr_stat, 
	ordr_ocat_cd,
	wcct_desc
FROM(
	SELECT 
		qnot_plnt_id, 
		qnot_typ, 
		qnot_no, 
		qndf_no, 
		to_char(qnot_created_dt, ''YYYY-MM-DD'') as qnot_created_dt,
		qnot_act_end_dt, 
		qnot_empl_id, 
		qnot_part_no,
		part_desc, 
		qnot_ordr_no, 
		qnot_sprt_ser_no, 
		qnot_qty,
		wbse_cd, 
		wbse_desc,
		qnot_qnct_tier3_cd, 
		qnct_tier2_desc, 
		qndf_type_qnct_tier3_cd, 
		qnct_tier3_desc, 
		qndf_desc, 
		qndf_comp_part_no, 
		qndf_sprt_ser_no, 
		wctr_cd, wctr_desc, 
		wctr_wcct_id,
		orop_id, 
		orop_line1_desc, 
		SUM(qndt_actual_hrs) AS qn_hours, 
		qndf_locn_qnct_tier3_cd, 
		TRIM(LEADING 0 FROM ordr_sprt_ser_no) serial_number, 
		ordr_oper_completed_dt, 
		ordr_stat, 
		ordr_ocat_cd,
		wcct_desc
	FROM tdwhqnot
		LEFT JOIN tdwhqndf on qndf_qnot_no = qnot_no 
		LEFT JOIN tdwhorop on qnot_orop_no = orop_no and qnot_ordr_rtg_no = orop_ordr_rtg_no 
		LEFT JOIN tdwhwctr on qnot_wctr_no = wctr_no
		LEFT JOIN tdwhwcct on wctr_wcct_id = wcct_id
		LEFT JOIN tdwhqnct on qndf_type_qnct_tier3_cd = qnct_tier3_cd and qndf_type_qnct_tier2_cd = qnct_tier2_cd and qndf_type_qnct_tier1_cd = qnct_tier1_cd 
		LEFT JOIN tdwhordr on qnot_ordr_no = ordr_no 
		LEFT JOIN tdwhwbse on ordr_wbse_id = wbse_id
		LEFT JOIN tdwhpart on qnot_part_no = part_no
		LEFT JOIN tdwhqndt on qndt_qnot_no = qnot_no and qndt_qndf_no = qndf_no
		LEFT JOIN tdwhgwbs on wbse_id = gwbs_wbse_id
	WHERE
		qnot_created_dt >= sysdate - 365
		--qnot_created_dt >= sysdate - 10								-- for testing purposes ONLY
		AND(QNOT_TYP LIKE ''%Q3%'' or QNOT_TYP LIKE ''%F3%'' or QNOT_TYP LIKE ''%Z5%'')
		AND QNOT_PLNT_ID = ''P001''
	GROUP BY
		qnot_plnt_id,
		qnot_typ,
		qnot_no,
		qndf_no,
		qnot_created_dt,
		qnot_act_end_dt,qnot_empl_id,
		qnot_part_no,
		part_desc,
		qnot_ordr_no,
		qnot_sprt_ser_no,
		qnot_qty,
		wbse_cd,
		wbse_desc,
		qnot_qnct_tier3_cd,
		qnct_tier2_desc,
		qndf_type_qnct_tier3_cd,
		qnct_tier3_desc,
		qndf_desc,
		qndf_comp_part_no,
		qndf_sprt_ser_no,
		wctr_cd,
		wctr_desc,
		wctr_wcct_id,
		orop_id,
		orop_line1_desc,
		qndf_locn_qnct_tier3_cd,
		ordr_sprt_ser_no,
		ordr_oper_completed_dt,
		ordr_stat,
		ordr_ocat_cd,
		wcct_desc
)
LEFT JOIN
	cdas.tdwhnote on qnot_no = note_qnot_no and qndf_no = note_qndf_no
WHERE
	note_qndc_no not like ''%0%'' or note_qndc_no is null
')