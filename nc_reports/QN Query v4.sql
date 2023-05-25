/*-----------------------------------------------------------------------------
-- Title:       Yield QN Query
-- Author:      Anonymous
-- Created:     06/17/2019
-- Purpose:     This query pulls QNs to support the Tableau Yield reports.

-------------------------------------------------------------------------------
-- Current version:     1
-- Modification History:
--
-- Version 1 - 06/05/2019 - Jordan Moshe
--      Published
-- Version 2 - 06/05/2019 - Mattias Herrfurth
--      - removed all references to TDWHQNTK
-- Version 3 - 09/26/2019 - Mattias Herrfurth
--      - joining TDWHOROP to QNOT instead of QNDF
--      - background: the QNDF table contains nulls for orop id 
-- Version 4 - 01/23/2020 - Mattias Herrfurth
--       - Filtered down to all dates after 01/01/2019 (i.e. removed 2018 data)
-----------------------------------------------------------------------------*/ 

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
   qnot_act_end_dt, 
   qnot_empl_id, 
   qnot_part_no, 
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
--   qntk_no, 
--   qntk_completed_dt, 
--   qntk_qnct_tier3_cd, 
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
--      QNTK_NO, 
--      QNTK_COMPLETED_DT, 
--      QNTK_QNCT_TIER3_CD, 
      sum(QNDT_ACTUAL_HRS) AS qn_hours, 
      QNDF_LOCN_QNCT_TIER3_CD, 
      trim(leading 0 from ORDR_SPRT_SER_NO) SERIAL_NUMBER, 
      ORDR_OPER_COMPLETED_DT, 
      ORDR_STAT, 
      ORDR_OCAT_CD

   FROM TDWHQNOT
      LEFT JOIN TDWHQNDF ON QNDF_QNOT_NO = QNOT_NO 
      LEFT JOIN TDWHOROP ON QNOT_OROP_NO = OROP_NO AND QNOT_ORDR_RTG_NO = OROP_ORDR_RTG_NO 
      LEFT JOIN TDWHWCTR ON QNOT_WCTR_NO = WCTR_NO 
      LEFT JOIN TDWHQNCT ON QNDF_TYPE_QNCT_TIER3_CD = QNCT_TIER3_CD AND QNDF_TYPE_QNCT_TIER2_CD = QNCT_TIER2_CD AND QNDF_TYPE_QNCT_TIER1_CD = QNCT_TIER1_CD 
      LEFT JOIN TDWHORDR ON QNOT_ORDR_NO = ORDR_NO 
      LEFT JOIN TDWHWBSE ON ORDR_WBSE_ID = WBSE_ID
--      LEFT JOIN TDWHQNTK ON QNTK_QNOT_NO = QNOT_NO AND QNTK_QNDF_NO = QNDF_NO
      LEFT JOIN TDWHPART ON QNOT_PART_NO = PART_NO
      LEFT JOIN TDWHQNDT ON QNDT_QNOT_NO = QNOT_NO AND QNDT_QNDF_NO = QNDF_NO
      LEFT JOIN TDWHGWBS ON WBSE_ID = GWBS_WBSE_ID

   WHERE
      QNOT_CREATED_DT >= TO_DATE('2019-01-01', 'YYYY-MM-DD')
      AND (QNOT_TYP LIKE '%Q3%' or QNOT_TYP LIKE '%F3%' or QNOT_TYP LIKE '%Z5%')
      --AND QNOT_PLNT_ID LIKE '%P076%'
--      And ((QNTK_QNCT_TIER2_CD like '%PRDISP%' and QNTK_ACTIVE_IND like '%Y%') or QNTK_QNCT_TIER2_CD is null)


   GROUP BY
      QNOT_PLNT_ID, QNOT_TYP, QNOT_NO, QNDF_NO, QNOT_CREATED_DT, QNOT_ACT_END_DT,QNOT_EMPL_ID, QNOT_PART_NO, QNOT_ORDR_NO, QNOT_SPRT_SER_NO, WBSE_CD, wbse_desc,
      QNOT_QNCT_TIER3_CD, QNCT_TIER2_DESC, QNDF_TYPE_QNCT_TIER3_CD, QNCT_TIER3_DESC, QNDF_DESC, QNDF_COMP_PART_NO, QNDF_SPRT_SER_NO , WCTR_CD, WCTR_DESC, WCTR_WCCT_ID,
      OROP_ID, OROP_LINE1_DESC, QNDF_LOCN_QNCT_TIER3_CD, ORDR_SPRT_SER_NO,
      ORDR_OPER_COMPLETED_DT, ORDR_STAT, ORDR_OCAT_CD
   )

LEFT JOIN CDAS.TDWHNOTE ON QNOT_NO = NOTE_QNOT_NO AND QNDF_NO = NOTE_QNDF_NO 

WHERE NOTE_QNDC_NO not like '%0%' or NOTE_QNDC_NO is null
;