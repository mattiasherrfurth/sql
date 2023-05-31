SELECT 
	PyramidYieldData.*,
	YieldQNs.qnot_typ, 
	YieldQNs.qnot_no, 
	YieldQNs.qndf_no, 
	YieldQNs.qnot_created_dt, 
	YieldQNs.qnot_act_end_dt, 
	YieldQNs.qnot_empl_id, 
	YieldQNs.qnot_qnct_tier3_cd, 
	YieldQNs.qnct_tier2_desc, 
	YieldQNs.qndf_type_qnct_tier3_cd, 
	YieldQNs.qnct_tier3_desc, 
	YieldQNs.qndf_desc, 
	YieldQNs.qndf_comp_part_no, 
	YieldQNs.qntk_no, 
	YieldQNs.qntk_completed_dt, 
	YieldQNs.qntk_qnct_tier3_cd, 
	YieldQNs.hours, 
	YieldQNs.qndf_locn_qnct_tier3_cd, 
	YieldQNs.note_txt, 
	YieldQNs.ordr_oper_completed_dt, 
	YieldQNs.ordr_stat
FROM
	PyramidYieldData 
	Left Join YieldQNs 
	On 
	YieldQNs.qnot_no =
	(
		SELECT TOP 1 QNOT_NO
		FROM YieldQNs
		WHERE
		QNOT_ORDR_NO = ORDR_NO
		And pyramidyielddata.Orop_id = YieldQNs.OROP_ID
		ORDER BY QNOT_CREATED_DT
	)