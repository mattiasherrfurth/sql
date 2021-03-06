USE [j20032_yield]
GO
/****** Object:  StoredProcedure [dbo].[CompleteYieldQuery]    Script Date: 11/7/2019 2:05:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CompleteYieldQuery] AS
/*-----------------------------------------------------------------------------
-- Title:       Yield Plus QNs Query
-- Author:      Mattias Herrfurth
-- Created:     10/30/2019
-- Purpose:     This query combines two previously separate queries to product the YieldPlusQNs table in one procedure

-------------------------------------------------------------------------------
-- Current version:     2
-- Modification History:
--
-- Version 1 - 10/30/2019 - Mattias Herrfurth
--      Published
-- Version 2 - 11/05/2019 - Mattias Herrfurth
--      Attempting to fix issue in table names for Yield / QN Join Block
-----------------------------------------------------------------------------*/

-- Yield Query Block --
drop table if exists completeYield;
SELECT * into completeYield
FROM OPENQUERY(ORAD, '
--Combined yield v5
WITH
   myZZIL As 
      (
      SELECT
         ilor_part_no, 
         part_desc, 
         Trim(Leading 0 From ordr_sprt_ser_no) as ordr_sprt_ser_no,
         ilor_end_dt,
         to_char(ilor_end_dt + 3,''ww'') as week,
         ilor_evaluation_cd,
         ilor_empl_id,
         empl_first_nm,
         empl_last_nm,
         ordr_no,
         orop_id, 
         wctr_cd,
         wctr_desc, 
         iloe_pele_cd, 
         pele_desc,
         ilor_qty, 
         ilor_failed_qty, 
         ilor_ilot_no, 
         ordr_rtg_no, 
         orop_no, 
         ilor_iloe_seq_no, 
         ilor_no, 
         iloe_validity_cd,
         iloe_unplanned_ind,
         ilor_validity_cd,
         ilor_element_qnct_tier3_cd,
         ilor_txt,
         iloe_process_cd,
         ilor_process_cd, 
         ilor_1st_time_ind,
         pele_qapp_cd,
         orop_qty, 
         orop_oovr_cd, 
         orop_typ,
         orop_plnt_id, 
         trim(plnt_desc) plnt_desc, 
         wctr_no, 
         orop_wctr_no,
         pcll_short_nm,
         wctr_cctr_id,
         wctr_wcct_id,
         Decode(wcct_id, ''Z001'', ''Manufacturing'',
                         ''Z002'', ''Test'',
                         ''Z003'', ''Inspection'',
                         ''Z004'', ''Administrative'',
                         ''Z010'', ''QE'') as YieldCategory,
         Case                                                                    
            When                                                                 
               pele_qapp_cd Not In (''ANT'', ''ATL'', ''AUD'', ''CDT'', ''CFE'', 
                                    ''CLO'', ''DDR'', ''EDT'', ''FAP'', ''FMR'', ''FRW'', ''GAT'', ''GFE'', ''KIT'', ''LKT'', ''MFD'', 
                                    ''MFG'', ''OFS'', ''OSA'', ''PEP'', ''REE'', ''RES'', ''RMR'', ''RN'' , ''SCM'', ''SCS'', 
                                    ''SCT'', ''SQT'', ''SRH'', ''SRL'', ''SRT'', ''TRS'', ''TTO'', ''TUN'') 
               And wcct_id in (''Z002'',''Z003'')                                    
               And ilor_1st_time_ind = ''Y''                                       
               And ordr_posc_cd = ''STDMRP''                                       
               And ordr_ocat_cd in (''ZP11'',''ZP19'',''ZP17'')                        
               And ilor_validity_cd In (''VALID'')                                 
            Then ''Y''
            Else ''N''
         End As WEBIYield,                                                    
         Case                                                                 
            When
               Trim(orop_oovr_Cd) Is Null 	                                             
            Then ''Y''
            Else ''N''
         End As PyramidYield,                                                    
         wcct_desc,
         ordr_ocat_cd, 
         wbse_id, 
         wbse_cd, 
         wbse_desc,
         nvl(gwbs_smgp_cd,'' '') gwbs_smgp_cd, 
         nvl(gwbs_smsg_cd,'' '') gwbs_smsg_cd,
         pprt_mcmd_cd, 
         nvl(trim(pmcd_desc),'' '') mcmd_desc, 
         nvl(pcll_cell_nm,'' '') mcmd_cell_nm, 
         qnct_tier3_desc, 
         orop_seq_no
      FROM
         TDWHILOE 
         Join TDWHILOR On
            ilor_ilot_no = iloe_ilot_no  
            And ilor_ordr_rtg_no = iloe_ordr_rtg_no  
            And ilor_orop_no = iloe_orop_no  
            And ilor_iloe_seq_no = iloe_seq_no 
         Join TDWHORDR On
            iloe_ordr_rtg_no = ordr_rtg_no
         Join TDWHOROP On 
            iloe_ordr_rtg_no = orop_ordr_rtg_no
            And iloe_orop_no = orop_no
         Join TDWHWCTR On
            wctr_no = orop_wctr_no
         Join TDWHWCCT On
            wctr_wcct_id = wcct_id
         Join TDWHPART On
            ilor_part_no = part_no
         Join TDWHPLNT On
            orop_plnt_id = plnt_id
         Join TDWHWBSE On
            ordr_wbse_id = wbse_id
         Join TDWHPPRT On
            ordr_part_no = pprt_part_no
            And ordr_plnt_id = pprt_plnt_id
         Join TDWHPELE On
            iloe_pele_cd = pele_cd
         Join TDWHQNCT On
            ilor_element_qnct_tier1_cd = qnct_tier1_cd
            And ilor_element_qnct_tier2_cd = qnct_tier2_cd
            And ilor_element_qnct_tier3_cd = qnct_tier3_cd
         Left Join TDWHGWBS On
            wbse_id = gwbs_wbse_id
         Left Join TDWHPMCD On
            pprt_plnt_id = pmcd_plnt_id
            And pprt_mcmd_cd = pmcd_mcmd_cd
         Left Join TDWHPCLL On
            pmcd_plnt_id = pcll_plnt_id
            And pmcd_pcll_cd = pcll_cd
         Left Join VDWHEMPL On
            EMPL_ID = ILOR_EMPL_ID   
      WHERE
         ILOR_END_DT >= TO_DATE(''2018-01-01'', ''YYYY-MM-DD'') And ILOR_END_DT <= sysdate 
         And ilor_validity_cd In (''VALID'')
         And wcct_id in (''Z001'',''Z002'',''Z003'')
         And Not (wctr_wcct_id = ''Z001'' And Not wctr_cd In (''MY1FLEXA'',''MY1FLEXB'',''MYACTFIN'',''MYJUICE'',''MYDVHVP'',''MY1TRHER'',''MYTRCRCK'',''MYXRAY''))
      )
SELECT
   myZZIL.*,
   Trim(Leading 0 From To_char(ilor_end_dt,''MM'')) "MONTH",
   Cast(To_char(ilor_end_dt,''YYYY'') as integer) "YEAR",
   To_Char(ilor_end_dt,''MM/DD/YYYY'') "DATE",
   SEQ,
   tripleInstance
FROM
   myZZIL 
   Left Join (
               SELECT
                  iloe_seq_no as Seq_iloe_seq_no,
                  orop_wctr_no As Seq_wctr_no,
                  iloe_pele_cd As Seq_pele_cd,
                  ilor_part_no As Seq_part_no,
                  orop_id As Seq_orop_id,
                  iloe_ordr_rtg_no As Seq_ordr_rtg_no,
                  Case
                     When Trim(ordr_sprt_ser_no) Is Null
                     Then
                        ROW_NUMBER() OVER (PARTITION BY iloe_pele_cd, iloe_ordr_rtg_no ORDER BY orop_id)
                     Else
                        ROW_NUMBER() OVER (PARTITION BY iloe_pele_cd, ilor_part_no, ordr_sprt_ser_no ORDER BY orop_id, ilor_iloe_seq_no)
                  End As SEQ,
                  Case
                     When Trim(ordr_sprt_ser_no) Is Null
                     Then
                        ROW_NUMBER() OVER (PARTITION BY iloe_pele_cd, iloe_ordr_rtg_no, orop_wctr_no ORDER BY orop_id)
                     Else
                        ROW_NUMBER() OVER (PARTITION BY iloe_pele_cd, ilor_part_no, ordr_sprt_ser_no, orop_wctr_no ORDER BY orop_id, ilor_iloe_seq_no)
                  End As tripleInstance
               FROM
                  TDWHILOE
                  Join TDWHILOR On
                     ilor_ilot_no = iloe_ilot_no
                     And ilor_ordr_rtg_no = iloe_ordr_rtg_no
                     And ilor_orop_no = iloe_orop_no
                     And ilor_iloe_seq_no = iloe_seq_no
                  Join TDWHOROP On
                     iloe_ordr_rtg_no = orop_ordr_rtg_no
                     And iloe_orop_no = orop_no
                  Join TDWHORDR On
                     orop_ordr_rtg_no = ordr_rtg_no
               WHERE
                  ILOR_END_DT >= TO_DATE(''2014-01-01'', ''YYYY-MM-DD'') And ILOR_END_DT <= sysdate
                  And Trim(orop_oovr_cd) is Null
                  And orop_typ = ''STD''                              
                  And ilor_validity_cd In (''VALID'')
             ) SEQgetter On
     ordr_rtg_no = Seq_ordr_rtg_no
     And wctr_no = Seq_wctr_no
     And iloe_pele_cd = Seq_pele_cd
     And ilor_iloe_seq_no = Seq_iloe_seq_no
     And orop_id = Seq_orop_id
WHERE
   ilor_end_dt >= To_date(''2018-01-01'', ''YYYY-MM-DD'') And ilor_end_dt <= Sysdate
   And iloe_process_cd != ''{FORCE}''
ORDER BY
   ordr_no,
   orop_id,
   ilor_iloe_seq_no
   ')
       Left Join OPENQUERY(MFGYLDANALYTICS_EMDD_APPS, '

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
       and ilor_part_no = mgmt_part_no
       and iloe_pele_cd = mgmt_pele_cd
       and wctr_cd = mgmt_wctr_cd
       and tripleinstance = 1;

	alter table completeYield add XLDATE datetime;
	update completeYield set XLDATE = cast(ilor_end_dt as smalldatetime);
	Alter table completeYield alter column MONTH integer;
	Alter table completeYield alter column YEAR integer;

-- QN Query Block --
DROP table if exists completeQNs;
SELECT * into completeQNs
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
      QNOT_CREATED_DT >= TO_DATE(''2018-01-01'', ''YYYY-MM-DD'')
      AND (QNOT_TYP LIKE ''%Q3%'' or QNOT_TYP LIKE ''%F3%'' or QNOT_TYP LIKE ''%Z5%'')
      --AND QNOT_PLNT_ID LIKE ''%P076%''
--      And ((QNTK_QNCT_TIER2_CD like ''%PRDISP%'' and QNTK_ACTIVE_IND like ''%Y%'') or QNTK_QNCT_TIER2_CD is null)


   GROUP BY
      QNOT_PLNT_ID, QNOT_TYP, QNOT_NO, QNDF_NO, QNOT_CREATED_DT, QNOT_ACT_END_DT,QNOT_EMPL_ID, QNOT_PART_NO, QNOT_ORDR_NO, QNOT_SPRT_SER_NO, WBSE_CD, wbse_desc,
      QNOT_QNCT_TIER3_CD, QNCT_TIER2_DESC, QNDF_TYPE_QNCT_TIER3_CD, QNCT_TIER3_DESC, QNDF_DESC, QNDF_COMP_PART_NO, QNDF_SPRT_SER_NO , WCTR_CD, WCTR_DESC, WCTR_WCCT_ID,
      OROP_ID, OROP_LINE1_DESC, QNDF_LOCN_QNCT_TIER3_CD, ORDR_SPRT_SER_NO,
      ORDR_OPER_COMPLETED_DT, ORDR_STAT, ORDR_OCAT_CD
   )

LEFT JOIN CDAS.TDWHNOTE ON QNOT_NO = NOTE_QNOT_NO AND QNDF_NO = NOTE_QNDF_NO 

WHERE NOTE_QNDC_NO not like ''%0%'' or NOTE_QNDC_NO is null
')

-- Yield / QN Join Block --
drop table if exists completeYieldPlusQNs_backup;
SELECT 
	completeYield.[ILOR_PART_NO],
    completeYield.[PART_DESC],
    completeYield.[ORDR_SPRT_SER_NO],
    completeYield.[DATE],
    completeYield.[week],
    completeYield.[ILOR_EVALUATION_CD],
    completeYield.[ILOR_EMPL_ID],
	completeYield.[EMPL_FIRST_NM],
	completeYield.[EMPL_LAST_NM],
    completeYield.[ORDR_NO],
    completeYield.[OROP_ID],
    completeYield.[WCTR_CD],
    completeYield.[WCTR_DESC],
    completeYield.[ILOE_PELE_CD],
    completeYield.[PELE_DESC],
    completeYield.[ILOR_QTY],
    completeYield.[ILOR_FAILED_QTY],
	completeQNs.qnot_no, 
	completeQNs.qndf_desc,
	completeQNs.qn_long_text, 
	completeQNs.qndf_comp_part_no,
	completeQNs.qnot_typ, 
	completeQNs.qndf_no, 
	completeQNs.qnot_created_dt, 
	completeQNs.qnot_act_end_dt, 
	completeQNs.qnot_empl_id, 
	completeQNs.qnot_qnct_tier3_cd, 
	completeQNs.qnct_tier2_desc, 
	completeQNs.qndf_type_qnct_tier3_cd,
	completeQNs.qnct_tier3_desc, 
	completeQNs.qn_hours, 
	completeQNs.qndf_locn_qnct_tier3_cd, 
	completeQNs.ordr_oper_completed_dt, 
	completeQNs.ordr_stat, 
	completeYield.[ILOR_ILOT_NO],
    completeYield.[ORDR_RTG_NO],
    completeYield.[OROP_NO],
    completeYield.[ILOR_ILOE_SEQ_NO],
    completeYield.[ILOR_NO],
    completeYield.[ILOE_VALIDITY_CD],
    completeYield.[ILOE_UNPLANNED_IND],
    completeYield.[ILOR_END_DT],
    completeYield.[ILOR_VALIDITY_CD],
    completeYield.[ILOR_ELEMENT_QNCT_TIER3_CD],
    completeYield.[ILOR_TXT],
    completeYield.[ILOE_PROCESS_CD],
    completeYield.[ILOR_PROCESS_CD],
    completeYield.[ILOR_1ST_TIME_IND],
    completeYield.[PELE_QAPP_CD],
    completeYield.[OROP_QTY],
    completeYield.[OROP_OOVR_CD],
    completeYield.[OROP_TYP],
    completeYield.[OROP_PLNT_ID],
    completeYield.[PLNT_DESC],
    completeYield.[WCTR_NO],
    completeYield.[OROP_WCTR_NO],
    completeYield.[PCLL_SHORT_NM],
    completeYield.[WCTR_CCTR_ID],
    completeYield.[WCTR_WCCT_ID],
    completeYield.[YIELDCATEGORY],
    completeYield.[WEBIYIELD],
    completeYield.[PYRAMIDYIELD],
    completeYield.[WCCT_DESC],
    completeYield.[ORDR_OCAT_CD],
    completeYield.[WBSE_ID],
    completeYield.[WBSE_CD],
    completeYield.[WBSE_DESC],
    completeYield.[GWBS_SMGP_CD],
    completeYield.[GWBS_SMSG_CD],
    completeYield.[PPRT_MCMD_CD],
    completeYield.[MCMD_DESC],
    completeYield.[MCMD_CELL_NM],
    completeYield.[OROP_SEQ_NO],
    completeYield.[MONTH],
    completeYield.[YEAR],
    completeYield.[SEQ],
    completeYield.[TRIPLEINSTANCE],
    completeYield.[MGMT_PLNT_ID],
    completeYield.[MGMT_OVERVIEW_GRP_NM],
    completeYield.[MGMT_YIELD_TARGET],
    completeYield.[MGMT_CELL_NM],
    completeYield.[MGMT_PART_NO],
    completeYield.[MGMT_WCTR_CD],
    completeYield.[MGMT_PELE_CD],
    completeYield.[MGMT_COMMENTS],
    completeYield.[XLDATE],

	Case                                                                 --START of section that adds a field that indicates whether this record is counted in the Pyramid query
		When
			qndf_no Is Null 	                                             --Checks to make sure this is a standard op as opposed to RW, TO etc…
			Or qndf_no = '0001'                                               --Remove this filter if you want to use query to determine Nth time through test.  Note that SEQ will not work
		Then 'N'
		Else 'Y'
    End As show_qn_defects  
	INTO completeYieldPlusQNs_backup
FROM
	--PyramidYieldData 
	completeYield
	--Left Join YieldQNs 
	Left Join completeQNs
	On 
	completeQNs.qnot_no =
	(
		SELECT TOP 1 QNOT_NO
		FROM completeQNs
		WHERE
		QNOT_ORDR_NO = ORDR_NO
		And completeYield.Orop_id = completeQNs.OROP_ID
		ORDER BY QNOT_CREATED_DT
	)