--SELECT * into backupYieldQNs
SELECT TOP (1000) * 
FROM OPENQUERY(ORAD, '
SELECT 
   qnot_no,
   qnot_typ,
   qnot_part_no,
   serial_number,
   qndf_desc,
   qnot_created_dt,
   qntk_qnct_tier2_cd,
   qntk_qnct_tier3_cd,
   qndf_type_qnct_tier3_cd, 
   qnct_tier3_desc, 
   note_txt AS QN_long_text,
   qndf_comp_part_no,
   qnot_plnt_id, 
   qntk_no, 
   qntk_completed_dt, 
   qndf_no,   
   qnot_act_end_dt, 
   qnot_empl_id, 
   qnot_ordr_no, 
   wbse_cd, 
   wbse_desc,
   qnot_qnct_tier3_cd, 
   qnct_tier2_desc, 
   qndf_sprt_ser_no , 
   wctr_cd, wctr_desc, 
   wctr_wcct_id,
   orop_id, 
   orop_line1_desc, 
   qn_hours, 
   qndf_locn_qnct_tier3_cd,  
   ordr_oper_completed_dt, 
   ordr_stat, 
   ordr_ocat_cd
   --NULL as FAILURECAT, 
   --NULL as FAILUREMODE, 
   --Null as UPDATED_BY, 
   --Null as UPDATED_ON

FROM
   (
   select 
      QNOT_PLNT_ID, 
      QNOT_TYP, 
      QNOT_NO, 
      QNDF_NO, 
      QNOT_CREATED_DT, 
      QNOT_ACT_END_DT, 
      QNOT_EMPL_ID, 
      QNOT_PART_NO, 
      QNOT_ORDR_NO, 
      QNOT_SPRT_SER_NO, 
      WBSE_CD, 
      wbse_desc,
      QNOT_QNCT_TIER3_CD, 
	  QNTK_QNCT_TIER2_CD,
	  QNTK_QNCT_TIER3_CD,
      QNCT_TIER2_DESC, 
      QNDF_TYPE_QNCT_TIER3_CD, 
      QNCT_TIER3_DESC, 
      QNDF_DESC, 
      QNDF_COMP_PART_NO, 
      QNDF_SPRT_SER_NO, 
      WCTR_CD, WCTR_DESC, 
      WCTR_WCCT_ID,
      OROP_ID, 
      OROP_LINE1_DESC, 
      QNTK_NO, 
      QNTK_COMPLETED_DT,  
      sum(QNDT_ACTUAL_HRS) AS qn_hours, 
      QNDF_LOCN_QNCT_TIER3_CD, 
      trim(leading 0 from ORDR_SPRT_SER_NO) SERIAL_NUMBER, 
      ORDR_OPER_COMPLETED_DT, 
      ORDR_STAT, 
      ORDR_OCAT_CD

   FROM TDWHQNOT
      LEFT JOIN TDWHQNDF ON QNDF_QNOT_NO = QNOT_NO 
      LEFT JOIN TDWHOROP ON QNDF_OROP_NO = OROP_NO AND QNDF_ORDR_RTG_NO = OROP_ORDR_RTG_NO 
      LEFT JOIN TDWHWCTR ON QNOT_WCTR_NO = WCTR_NO 
      LEFT JOIN TDWHQNCT ON QNDF_TYPE_QNCT_TIER3_CD = QNCT_TIER3_CD AND QNDF_TYPE_QNCT_TIER2_CD = QNCT_TIER2_CD AND QNDF_TYPE_QNCT_TIER1_CD = QNCT_TIER1_CD 
      LEFT JOIN TDWHORDR ON QNOT_ORDR_NO = ORDR_NO 
      LEFT JOIN TDWHWBSE ON ORDR_WBSE_ID = WBSE_ID
      LEFT JOIN TDWHQNTK ON QNTK_QNOT_NO = QNOT_NO AND QNTK_QNDF_NO = QNDF_NO
      LEFT JOIN TDWHPART ON QNOT_PART_NO = PART_NO
      LEFT JOIN TDWHQNDT ON QNDT_QNOT_NO = QNOT_NO AND QNDT_QNDF_NO = QNDF_NO
      LEFT JOIN TDWHGWBS ON WBSE_ID = GWBS_WBSE_ID

   WHERE
      QNOT_CREATED_DT >= TO_DATE(''2018-01-01'', ''YYYY-MM-DD'')
      AND (QNOT_TYP LIKE ''%Q3%'' or QNOT_TYP LIKE ''%F3%'' or QNOT_TYP LIKE ''%Z5%'')
      --AND QNOT_PLNT_ID LIKE ''%P076%''
      --And ((QNTK_QNCT_TIER2_CD like ''%PRDISP%'' and QNTK_ACTIVE_IND like ''%Y%'') or QNTK_QNCT_TIER2_CD is null)


   GROUP BY
      QNOT_PLNT_ID, QNOT_TYP, QNOT_NO, QNDF_NO, QNOT_CREATED_DT, QNOT_ACT_END_DT,QNOT_EMPL_ID, QNOT_PART_NO, QNOT_ORDR_NO, QNOT_SPRT_SER_NO, WBSE_CD, wbse_desc,
      QNOT_QNCT_TIER3_CD, QNCT_TIER2_DESC, QNDF_TYPE_QNCT_TIER3_CD, QNTK_QNCT_TIER2_CD, QNTK_QNCT_TIER3_CD, QNCT_TIER3_DESC, QNDF_DESC, QNDF_COMP_PART_NO, QNDF_SPRT_SER_NO , WCTR_CD, WCTR_DESC, WCTR_WCCT_ID,
      OROP_ID, OROP_LINE1_DESC, QNTK_NO, QNTK_COMPLETED_DT, QNDF_LOCN_QNCT_TIER3_CD, ORDR_SPRT_SER_NO,
      ORDR_OPER_COMPLETED_DT, ORDR_STAT, ORDR_OCAT_CD
   )

LEFT JOIN CDAS.TDWHNOTE ON QNOT_NO = NOTE_QNOT_NO AND QNDF_NO = NOTE_QNDF_NO 

WHERE NOTE_QNDC_NO not like ''%0%'' or NOTE_QNDC_NO is null
')