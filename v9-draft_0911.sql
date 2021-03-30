with QN_tbl as(
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
    qndf_int_defective_qty,
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
    select 
      QNOT_PLNT_ID, 
      QNOT_TYP, 
      QNOT_NO, 
      QNDF_NO, 
      QNOT_CREATED_DT, 
      QNOT_ACT_END_DT, 
      QNOT_EMPL_ID, 
      QNOT_PART_NO,
      part_desc, 
      QNOT_ORDR_NO, 
      QNOT_SPRT_SER_NO, 
      QNOT_QTY,
      qndf_int_defective_qty,
      WBSE_CD, 
      wbse_desc,
      QNOT_QNCT_TIER3_CD, 
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
      sum(QNDT_ACTUAL_HRS) AS qn_hours, 
      QNDF_LOCN_QNCT_TIER3_CD, 
      trim(leading 0 from ORDR_SPRT_SER_NO) SERIAL_NUMBER, 
      ORDR_OPER_COMPLETED_DT, 
      ORDR_STAT, 
      ORDR_OCAT_CD,
      WCCT_DESC
  
    FROM TDWHQNOT
      LEFT JOIN TDWHQNDF ON QNDF_QNOT_NO = QNOT_NO 
      LEFT JOIN TDWHOROP ON QNOT_OROP_NO = OROP_NO AND QNOT_ORDR_RTG_NO = OROP_ORDR_RTG_NO 
      LEFT JOIN TDWHWCTR ON QNOT_WCTR_NO = WCTR_NO
      LEFT JOIN TDWHWCCT ON WCTR_WCCT_ID = WCCT_ID
      LEFT JOIN TDWHQNCT ON QNDF_TYPE_QNCT_TIER3_CD = QNCT_TIER3_CD AND QNDF_TYPE_QNCT_TIER2_CD = QNCT_TIER2_CD AND QNDF_TYPE_QNCT_TIER1_CD = QNCT_TIER1_CD 
      LEFT JOIN TDWHORDR ON QNOT_ORDR_NO = ORDR_NO 
      LEFT JOIN TDWHWBSE ON ORDR_WBSE_ID = WBSE_ID
      LEFT JOIN TDWHPART ON QNOT_PART_NO = PART_NO
      LEFT JOIN TDWHQNDT ON QNDT_QNOT_NO = QNOT_NO AND QNDT_QNDF_NO = QNDF_NO
      LEFT JOIN TDWHGWBS ON WBSE_ID = GWBS_WBSE_ID
  
    WHERE
    
      --QNOT_CREATED_DT >= SYSDATE - 365
      QNOT_CREATED_DT >= SYSDATE - 10								-- FOR TESTING PURPOSES, revert to other filter later
    
      AND(
        QNOT_TYP LIKE '%Q3%' 
        or QNOT_TYP LIKE '%F3%' 
        or QNOT_TYP LIKE '%Z5%'
        )
      AND QNOT_PLNT_ID = 'P001'
  
    GROUP BY
      QNOT_PLNT_ID,
      QNOT_TYP,
      QNOT_NO,
      QNDF_NO,
      QNOT_CREATED_DT,
      QNOT_ACT_END_DT,QNOT_EMPL_ID,
      QNOT_PART_NO,
      part_desc,
      QNOT_ORDR_NO,
      QNOT_SPRT_SER_NO,
      QNOT_QTY,
      qndf_int_defective_qty,
      WBSE_CD,
      wbse_desc,
      QNOT_QNCT_TIER3_CD,
      QNCT_TIER2_DESC,
      QNDF_TYPE_QNCT_TIER3_CD,
      QNCT_TIER3_DESC,
      QNDF_DESC,
      QNDF_COMP_PART_NO,
      QNDF_SPRT_SER_NO ,
      WCTR_CD,
      WCTR_DESC,
      WCTR_WCCT_ID,
      OROP_ID,
      OROP_LINE1_DESC,
      QNDF_LOCN_QNCT_TIER3_CD,
      ORDR_SPRT_SER_NO,
      ORDR_OPER_COMPLETED_DT,
      ORDR_STAT,
      ORDR_OCAT_CD,
      WCCT_DESC
  )
  
  LEFT JOIN CDAS.TDWHNOTE ON QNOT_NO = NOTE_QNOT_NO AND QNDF_NO = NOTE_QNDF_NO 
  
  WHERE NOTE_QNDC_NO not like '%0%' or NOTE_QNDC_NO is null
)
SELECT 
  QN_tbl.*,
  pn_qty_per_day
FROM
  QN_tbl
  Left Join(
      select
        ordr_part_no,
        to_char(orop_act_completed_dtm, 'DD/MM/YYYY') as op_date,
        sum(orop_completed_qty) as pn_qty_per_day
      from tdwhorop
      inner join tdwhordr on 
        ordr_rtg_no = orop_ordr_rtg_no
        and orop_ordr_no = ordr_no
      group by
        ordr_part_no,
        to_char(orop_act_completed_dtm, 'DD/MM/YYYY')
      order by
        to_char(orop_act_completed_dtm, 'DD/MM/YYYY')
  ) 
  on qnot_part_no = ordr_part_no and to_char(qnot_created_dt, 'DD/MM/YYYY') = op_date
      
  