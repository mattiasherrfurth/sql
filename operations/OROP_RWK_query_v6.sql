-- creating temp table for OROP joined with WCTR
WITH RWK_tbl as
(
SELECT 
-- splitting out OROP_LINE1_DESC into QN number and QN item number to be able to join on
LPAD(SUBSTR(t.OROP_LINE1_DESC, 5, INSTR(t.OROP_LINE1_DESC, '/')-5), 12, '0') AS _OROP_QNOT_NO, -- adding zero padding for matching TDWHQNOT/QNDF format
SUBSTR(t.OROP_LINE1_DESC, INSTR(t.OROP_LINE1_DESC, '/')+1,4) AS _OROP_QNDF_NO,
SUBSTR(t.OROP_LINE1_DESC, INSTR(t.OROP_LINE1_DESC, '/')+6) AS _OROP_RWK_DESC,
t.*,
w.*
  FROM TDWHOROP t
  Join TDWHWCTR w On WCTR_NO = OROP_WCTR_NO
  Join TDWHORDR o On ORDR_NO = OROP_ORDR_NO
    WHERE 
      OROP_LINE1_DESC like '*RW 501%'
      and OROP_ACT_COMPLETED_DTM >= TO_DATE('2017-01-01', 'YYYY-MM-DD')
      and OROP_PLNT_ID = 'P001'
      and WCTR_CCTR_ID in ('MY','MW','TM')
    ORDER BY OROP_ORDR_NO, OROP_ID
)

SELECT * 
  FROM RWK_tbl
    -- have to join in QNOT/QNDF after creating the following tables:
    --  QNOT - QN header information
    --  QNDF - QN defect summary
    --  QNCT - QN defect descriptions / details
    -- 
    Left Join TDWHQNOT q on QNOT_NO = _OROP_QNOT_NO
    Left Join TDWHQNDF d on QNDF_QNOT_NO = OROP_QNOT_NO and QNDF_NO = _OROP_QNDF_NO
    Left Join TDWHQNCT n on QNCT_TIER2_CD = QNDF_TYPE_QNCT_TIER2_CD and QNCT_TIER3_CD = QNDF_TYPE_QNCT_TIER3_CD