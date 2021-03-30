SELECT 
	PyramidYieldData.[ILOR_PART_NO],
    PyramidYieldData.[PART_DESC],
    PyramidYieldData.[ORDR_SPRT_SER_NO],
    PyramidYieldData.[DATE],
    PyramidYieldData.[week],
    PyramidYieldData.[ILOR_EVALUATION_CD],
    PyramidYieldData.[ILOR_EMPL_ID],
	PyramidYieldData.[EMPL_FIRST_NM],
	PyramidYieldData.[EMPL_LAST_NM],
    PyramidYieldData.[ORDR_NO],
    PyramidYieldData.[OROP_ID],
    PyramidYieldData.[WCTR_CD],
    PyramidYieldData.[WCTR_DESC],
    PyramidYieldData.[ILOE_PELE_CD],
    PyramidYieldData.[PELE_DESC],
    PyramidYieldData.[ILOR_QTY],
    PyramidYieldData.[ILOR_FAILED_QTY],
	YieldQNs.qnot_no, 
	YieldQNs.qndf_desc,
	YieldQNs.qn_long_text, 
	YieldQNs.qndf_comp_part_no,
	YieldQNs.qnot_typ, 
	YieldQNs.qndf_no, 
	YieldQNs.qnot_created_dt, 
	YieldQNs.qnot_act_end_dt, 
	YieldQNs.qnot_empl_id, 
	YieldQNs.qnot_qnct_tier3_cd, 
	YieldQNs.qnct_tier2_desc, 
	YieldQNs.qndf_type_qnct_tier3_cd, 
	YieldQNs.qn_hours, 
	YieldQNs.qndf_locn_qnct_tier3_cd, 
	YieldQNs.ordr_oper_completed_dt, 
	YieldQNs.ordr_stat, 
	PyramidYieldData.[ILOR_ILOT_NO],
    PyramidYieldData.[ORDR_RTG_NO],
    PyramidYieldData.[OROP_NO],
    PyramidYieldData.[ILOR_ILOE_SEQ_NO],
    PyramidYieldData.[ILOR_NO],
    PyramidYieldData.[ILOE_VALIDITY_CD],
    PyramidYieldData.[ILOE_UNPLANNED_IND],
    PyramidYieldData.[ILOR_END_DT],
    PyramidYieldData.[ILOR_VALIDITY_CD],
    PyramidYieldData.[ILOR_ELEMENT_QNCT_TIER3_CD],
    PyramidYieldData.[ILOR_TXT],
    PyramidYieldData.[ILOE_PROCESS_CD],
    PyramidYieldData.[ILOR_PROCESS_CD],
    PyramidYieldData.[ILOR_1ST_TIME_IND],
    PyramidYieldData.[PELE_QAPP_CD],
    PyramidYieldData.[OROP_QTY],
    PyramidYieldData.[OROP_OOVR_CD],
    PyramidYieldData.[OROP_TYP],
    PyramidYieldData.[OROP_PLNT_ID],
    PyramidYieldData.[PLNT_DESC],
    PyramidYieldData.[WCTR_NO],
    PyramidYieldData.[OROP_WCTR_NO],
    PyramidYieldData.[PCLL_SHORT_NM],
    PyramidYieldData.[WCTR_CCTR_ID],
    PyramidYieldData.[WCTR_WCCT_ID],
    PyramidYieldData.[YIELDCATEGORY],
    PyramidYieldData.[WEBIYIELD],
    PyramidYieldData.[PYRAMIDYIELD],
    PyramidYieldData.[WCCT_DESC],
    PyramidYieldData.[ORDR_OCAT_CD],
    PyramidYieldData.[WBSE_ID],
    PyramidYieldData.[WBSE_CD],
    PyramidYieldData.[WBSE_DESC],
    PyramidYieldData.[GWBS_SMGP_CD],
    PyramidYieldData.[GWBS_SMSG_CD],
    PyramidYieldData.[PPRT_MCMD_CD],
    PyramidYieldData.[MCMD_DESC],
    PyramidYieldData.[MCMD_CELL_NM],
    PyramidYieldData.[OROP_SEQ_NO],
    PyramidYieldData.[MONTH],
    PyramidYieldData.[YEAR],
    PyramidYieldData.[SEQ],
    PyramidYieldData.[TRIPLEINSTANCE],
    PyramidYieldData.[MGMT_PLNT_ID],
    PyramidYieldData.[MGMT_OVERVIEW_GRP_NM],
    PyramidYieldData.[MGMT_YIELD_TARGET],
    PyramidYieldData.[MGMT_CELL_NM],
    PyramidYieldData.[MGMT_PART_NO],
    PyramidYieldData.[MGMT_WCTR_CD],
    PyramidYieldData.[MGMT_PELE_CD],
    PyramidYieldData.[MGMT_COMMENTS],
    PyramidYieldData.[XLDATE],

	Case                                                                 --START of section that adds a field that indicates whether this record is counted in the Pyramid query
		When
			qndf_no Is Null 	                                             --Checks to make sure this is a standard op as opposed to RW, TO etc…
			Or qndf_no = '0001'                                               --Remove this filter if you want to use query to determine Nth time through test.  Note that SEQ will not work
		Then 'N'
		Else 'Y'
    End As show_qn_defects  
	INTO BackupYieldPlusQNs
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