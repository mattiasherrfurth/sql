USE [j20032_yield]
GO
/****** Object:  StoredProcedure [dbo].[EvalYield]    Script Date: 11/7/2019 1:56:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[EvalYield] AS
/*-----------------------------------------------------------------------------
-- Title:       EvalYield
-- Author:      Jordan Moshe
-- Created:     Q1 2019
-- Purpose:     This query gets the evaluation information for inspection and test operations

-------------------------------------------------------------------------------
-- Current version:     2

-- NOTE: revision tracking has been implemented in other files, version 2 is the first version to have tracking in the procedure

-- Modification History:
--
-- Version 1 - Q1 2019 - Mattias Herrfurth
--      Published
-- Version 2 - 10/29/2019 - Mattias Herrfurth
--		Implemented revision tracking
--      Aligning week number to financial calendar
-----------------------------------------------------------------------------*/
drop table if exists backupPyramidYieldData;
SELECT * into backupPyramidYieldData
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

	alter table backupPyramidYieldData add XLDATE datetime;
	update backupPyramidYieldData set XLDATE = cast(ilor_end_dt as smalldatetime);
	Alter table backuppyramidyielddata alter column MONTH integer;
	Alter table backuppyramidyielddata alter column YEAR integer;
