USE [j20032_herrfurth_test]
GO
-- When the ANSI_NULL database option is set to ON, then a comparison with NULL records yields UNKNOWN. Hence, no rows are returned. 
-- If you compare anything with NULL, it will result as UNKNOWN, and also the NULL = NULL comparison will be considered as UNKNOWN. 
-- You cannot compare NULL against anything. This is an ISO standard when dealing with NULL records.
SET ANSI_NULLS ON
GO
-- Causes SQL Server to follow the ISO rules regarding quotation mark delimiting identifiers and literal strings.
-- When SET QUOTED_IDENTIFIER is ON, identifiers can be delimited by double quotation marks, and literals must be delimited by single quotation marks. 
-- When SET QUOTED_IDENTIFIER is OFF, identifiers cannot be quoted and must follow all Transact-SQL rules for identifiers.
SET QUOTED_IDENTIFIER ON
GO
-- OPENQUERY is used to connect to another database.
-- Executes the specified pass-through query on the specified linked server. This server is an ORAD data source. 
-- NOTE: the OPENQUERY statement is character limited. 
--			The query in this statement is titled "Combined Yield", and the most recent commented revision can be found in the following location:
--			T:\A\AMEC\Quality Engineering\TABLEAU\QUERIES\ACTIVE
DROP table if exists CC_RWK_WCTR_QNs;
SELECT OROP_QNOT_NO,OROP_QNDF_NO,OROP_RWK_DESC,OROP_ORDR_RTG_NO,OROP_NO,OROP_LINE1_DESC,OROP_ORDR_NO,OROP_ID,OROP_WCTR_NO,OROP_PLNT_ID,OROP_QTY,OROP_COMPLETED_QTY,OROP_OOCT_CD,OROP_TYP,OROP_OOVR_CD,WCTR_ID,WCTR_BCTR_ID,WCTR_DESC,WCTR_NO,WCTR_PLNT_ID,WCTR_CD,WCTR_WSEC_ID,WCTR_WCCT_ID,WCTR_CCTR_ID,QNOT_NO,QNOT_TYP,QNOT_WCTR_NO,QNOT_ILOT_NO,QNOT_GRPT_CD,QNOT_PART_NO,QNOT_SPRT_SER_NO,QNOT_PART_REV_NO,QNOT_QTY,QNOT_ORDR_RTG_NO,QNOT_OROP_NO,QNOT_ORDR_NO,QNOT_PTBT_NO,QNDF_QNOT_NO,QNDF_NO,QNDF_DESC,QNDF_CREATED_EMPL_ID,QNDF_CHANGED_EMPL_ID,QNDF_TYPE_QNCT_TIER2_CD,QNDF_TYPE_QNCT_TIER3_CD,QNDF_LOCN_QNCT_TIER2_CD,QNDF_LOCN_QNCT_TIER3_CD,QNDF_SPRT_SER_NO,QNDF_COMP_PART_NO,QNDF_QAPP_CD,QNDF_ILOT_NO,QNDF_ORDR_RTG_NO,QNDF_OROP_NO,QNDF_ILOE_SEQ_NO,QNDF_QNTK_QNCT_TIER2_CD,QNDF_QNTK_QNCT_TIER3_CD,QNDF_PRDISP_TASK_TXT,QNCT_TIER2_CD,QNCT_TIER3_CD,QNCT_TIER2_DESC,QNCT_TIER3_DESC,QNCT_DCAT_CD,MGMT_PLNT_ID,MGMT_OVERVIEW_GRP_NM,MGMT_YIELD_TARGET,MGMT_CELL_NM,MGMT_PART_NO,MGMT_WCTR_CD,MGMT_PELE_CD,MGMT_COMMENTS
	into CC_RWK_WCTR_QNs
	FROM OPENQUERY(ORAD, '
-- creating temp table for OROP joined with WCTR
WITH RWK_tbl as
(
SELECT 
-- splitting out OROP_LINE1_DESC into QN number and QN item number to be able to join on
LPAD(SUBSTR(t.OROP_LINE1_DESC, 5, INSTR(t.OROP_LINE1_DESC, ''/'')-5), 12, ''0'') AS OROP_QNOT_NO, -- adding zero padding for matching TDWHQNOT/QNDF format
SUBSTR(t.OROP_LINE1_DESC, INSTR(t.OROP_LINE1_DESC, ''/'')+1,4) AS OROP_QNDF_NO,
SUBSTR(t.OROP_LINE1_DESC, INSTR(t.OROP_LINE1_DESC, ''/'')+6) AS OROP_RWK_DESC,
t.*,
w.*
  FROM TDWHOROP t
  Join TDWHWCTR w On wctr_no = orop_wctr_no
    WHERE 
      OROP_LINE1_DESC like ''*RW 501%''
      and OROP_ACT_COMPLETED_DTM >= TO_DATE(''2017-01-01'', ''YYYY-MM-DD'')
      and OROP_PLNT_ID = ''P001''
      and WCTR_CCTR_ID in (''DB'') -- line to change for filtering to different cells in the factory
    ORDER BY OROP_ORDR_NO, OROP_ID
)

SELECT * 
  FROM RWK_tbl
    -- have to join in QNOT/QNDF after creating the following tables:
    --  QNOT - QN header information
    --  QNDF - QN defect summary
    --  QNCT - QN defect descriptions / details
    Left Join TDWHQNOT q on QNOT_NO = OROP_QNOT_NO
    Left Join TDWHQNDF d on QNDF_QNOT_NO = OROP_QNOT_NO and QNDF_NO = OROP_QNDF_NO
    Left Join TDWHQNCT n on QNCT_TIER2_CD = QNDF_TYPE_QNCT_TIER2_CD and QNCT_TIER3_CD = QNDF_TYPE_QNCT_TIER3_CD
   ')
	Left Outer Join OPENQUERY(MFGYLDANALYTICS_EMDD_APPS, '
		select 
			mgmtGrp.plnt_id mgmt_plnt_id,
			mgmtGrp.mgmt_overview_grp_nm,
			yield_target mgmt_yield_target,
			cell_nm mgmt_cell_nm,
			part_no mgmt_part_no,
			wctr_cd mgmt_wctr_cd,
			pele_cd mgmt_pele_cd,
			triple.cmnts mgmt_comments
    from pyramidmetrics.tmse_part_grouping@EMDD mgmtGrp
    join pyramidmetrics.tmse_part_group@EMDD triple on 
        mgmtGrp.mgmt_overview_grp_nm = triple.mgmt_overview_grp_nm
        and mgmtGrp.plnt_id = triple.plnt_id
    where is_active = 1
       ') On

       orop_plnt_id = mgmt_plnt_id
       and QNOT_PART_NO = mgmt_part_no
       --and iloe_pele_cd = mgmt_pele_cd
       and wctr_cd = mgmt_wctr_cd
       --and tripleinstance = 1
;