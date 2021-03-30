/*-----------------------------------------------------------------------------						
-- Title:      Combined Yield						
-- Author:     Jordan Moshe		
-- Created:    4/29/2019						
-- Purpose:    This query pulls data to generate yield that recreate legacy pyramid reports						
--             In addition, WEBI data can be recreated based on the value filters in the WEBIyield and Pyramidyield fields
--             Note that the management overview groups are not joined in with this query.
-------------------------------------------------------------------------------						
-- Current version:     7						
-- Modification History:						
--						
-- Version 1 - 04/29/2019 - Jordan Moshe						
--       Published
-- Version 2 - 05/20/2019 - Jordan Moshe						
--       -Added trim to ordr_sprt_ser_no, 
--       -Switched month field to format M,
--       -Added DATE field that Excel should be able identify as a date, 
--       -Changed references to order number in SEQgetter subquery to part num and serial to accommodate situations where 1 serial has multiple order numbers and differentiated between serialized and not serialized to make this work
--       -Also added order by ilor_iloe_seq_no to SEQgetter so results are counted in the correct order.
--       -Added commented means to get EMDD part groupings through ORAD link
--       -Added orop_typ field to have better visibility on un/planned nature of work because iloe_unplanned_ind shows unplanned on OE ZC55 added operations
--       -Changed SEQgetter subquery filter from iloe_unplanned_ind = 'N' to orop_typ = 'STD'
--       -Filtered out manufacturing work centers not in a specific list
-- Version 3 - 05/30/2019 - Jordan Moshe		
--       -Added Order By clause for ease of using raw results
--       -Added date filter for subquery that's back dated based on results of query to find largest span of order results and dropping outliers.
-- Version 4 - 06/17/2019 - Mattias Herrfurth
--       - Changed order of select clause per Walt Godfrey's request
--       - Add week column (week ends on Sunday)
-- Version 5 - 07/17/2019
--       - Added manufacturing workcenters for JSF evaluation yields
--       - Joined in VDWHEMPL table and added employee first/last name
--       - NOTE: removed section for bringing in part groups through ORAD link
-- Version 5 - 01/23/2020 - Mattias Herrfurth
--       - Filtered down to all dates after 01/01/2019 (i.e. removed 2019 data)
-- Version 6 - 01/29/2020 - Mattias Herrfurth
--       - Fixed week field
-- Version 7 - 01/29/2020 - Mattias Herrfurth
--       - Added handling for filtering to only the past two years
-----------------------------------------------------------------------------*/					

WITH
   myZZIL As 
      (
      SELECT
         ilor_part_no, 
         part_desc, 
         Trim(Leading 0 From ordr_sprt_ser_no) as ordr_sprt_ser_no,
         ilor_end_dt,
         to_char(ilor_end_dt + 2, 'iw') as week,
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
         orop_wctr_no,     --redundant
         pcll_short_nm,
         wctr_cctr_id,
         wctr_wcct_id,
         Decode(wcct_id, 'Z001', 'Manufacturing',
                         'Z002', 'Test',
                         'Z003', 'Inspection',
                         'Z004', 'Administrative',
                         'Z010', 'QE') as YieldCategory,
         Case                                                                    --START of section that adds a field that indicates whether this record is counted in the WEBI query
            When                                                                 
               pele_qapp_cd Not In ('ANT', 'ATL', 'AUD', 'CDT', 'CFE', 
                                    'CLO', 'DDR', 'EDT', 'FAP', 'FMR', 'FRW', 'GAT', 'GFE', 'KIT', 'LKT', 'MFD', 
                                    'MFG', 'OFS', 'OSA', 'PEP', 'REE', 'RES', 'RMR', 'RN' , 'SCM', 'SCS', 
                                    'SCT', 'SQT', 'SRH', 'SRL', 'SRT', 'TRS', 'TTO', 'TUN') --Quality appraisal code filter as defined by WEBI query
               And wcct_id in ('Z002','Z003')                                    --Inspection and test work center types only as defined by WEBI
               And ilor_1st_time_ind = 'Y'                                       --First time insp char appears at a cost center on a routing via mapped SAP field. Filter is as defined by WEBI
               And ordr_posc_cd = 'STDMRP'                                       --Production order subcategory which determines possible OCAT codes. Filter is as defined by WEBI.
               And ordr_ocat_cd in ('ZP11','ZP19','ZP17')                        --Only include standard production orders, prototype work, and zp17. Filter is as defined by WEBI.
               And ilor_validity_cd In ('VALID')                                 --Only "valid" results. Filter is as defined by WEBI.
            Then 'Y'
            Else 'N'
         End As WEBIYield,                                                   --END of section that adds a field that indicates whether this record is counted in the WEBI query   
         Case                                                                 --START of section that adds a field that indicates whether this record is counted in the Pyramid query
            When
               Trim(orop_oovr_Cd) Is Null 	                                             --Checks to make sure this is a standard op as opposed to RW, TO etc…
               --And iloe_unplanned_ind = 'N'                                               --Remove this filter if you want to use query to determine Nth time through test.  Note that SEQ will not work
            Then 'Y'
            Else 'N'
         End As PyramidYield,                                                   --END of section that adds a field that indicates whether this record is counted in the WEBI query  
         wcct_desc,
         ordr_ocat_cd, 
         wbse_id, 
         wbse_cd, 
         wbse_desc,
         nvl(gwbs_smgp_cd,' ') gwbs_smgp_cd, 
         nvl(gwbs_smsg_cd,' ') gwbs_smsg_cd,
         pprt_mcmd_cd, 
         nvl(trim(pmcd_desc),' ') mcmd_desc, 
         nvl(pcll_cell_nm,' ') mcmd_cell_nm, 
--         qnot_no,
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
--         Left Join TDWHQNOT On
--            qnot_ordr_rtg_no = orop_ordr_rtg_no 
--            And qnot_orop_no = orop_no
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
         to_char(ILOR_END_DT, 'yyyy') between trunc(to_char(sysdate, 'YYYY')) - 1 and trunc(to_char(sysdate, 'YYYY'))
         And ILOR_END_DT >= TO_DATE('2019-01-01', 'YYYY-MM-DD') And ILOR_END_DT <= sysdate  --This date is 1 of 2 locations that time range must be changed
         And ilor_validity_cd In ('VALID')
         And wcct_id in ('Z001','Z002','Z003')                                   --Manufacturing, Inspection, and test work center types only as defined by WEBI
         And Not (wctr_wcct_id = 'Z001' And Not wctr_cd In ('MY1FLEXA','MY1FLEXB','MYACTFIN','MYJUICE','MYDVHVP','MY1TRHER','MYTRCRCK','MYXRAY'))    --Manufacturing work centers that have interesting yield results (most mfg work centers don't)
         --And Trim(Leading 0 From ordr_sprt_ser_no) = '1812'                      --(for testing) Includes only serial number/s specified
      )
SELECT
   myZZIL.*,
   --mgmtPartGrp.*,                                                              (Uncomment when bringing in EMDD part groupings, only possible if being run in oracle with a user ID with EMDD access)
   Trim(Leading 0 From To_char(ilor_end_dt,'MM')) "MONTH",
   Cast(To_char(ilor_end_dt,'YYYY') as integer) "YEAR",
   To_Char(ilor_end_dt,'MM/DD/YYYY') "DATE",
   SEQ,
   tripleInstance
   --nthTime
FROM
   myZZIL 
   Left Join (                                                                        --START Subquery for adding sequence number of inspection characteristic in order in column named "SEQ" as well as "tripleInstance" which is the instance number of the IC, WCTR, PN triple on an order.  Only values of 1 are assigned to a management overview
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
                        ROW_NUMBER() OVER (PARTITION BY iloe_pele_cd, iloe_ordr_rtg_no ORDER BY orop_id)                                      --Numbers off the occurances of an IC for an order
                     Else
                        ROW_NUMBER() OVER (PARTITION BY iloe_pele_cd, ilor_part_no, ordr_sprt_ser_no ORDER BY orop_id, ilor_iloe_seq_no)                                      --Numbers off the occurances of an IC for an order
                  End As SEQ,
                  Case
                     When Trim(ordr_sprt_ser_no) Is Null
                     Then
                        ROW_NUMBER() OVER (PARTITION BY iloe_pele_cd, iloe_ordr_rtg_no, orop_wctr_no ORDER BY orop_id)             --Numbers off the occurances of and IC/work center combo for an order
                     Else
                        ROW_NUMBER() OVER (PARTITION BY iloe_pele_cd, ilor_part_no, ordr_sprt_ser_no, orop_wctr_no ORDER BY orop_id, ilor_iloe_seq_no)             --Numbers off the occurances of and IC/work center combo for an order
                  End As tripleInstance
--                  Case                                                         --Comment And orop_typ = 'STD' filter if trying to get accurate Nth time results.  Note that SEQ will not work if doing this.
--                     When Trim(ordr_sprt_ser_no) Is Null
--                        Then
--                           ROW_NUMBER() OVER (PARTITION BY iloe_ordr_rtg_no, orop_no, iloe_pele_cd ORDER BY ilor_end_dt, ilor_no) As nthTime             --Numbers off the results recorded for an order, op number, and insp char by date
--                        Else
--   
--                           ROW_NUMBER() OVER (PARTITION BY ilor_part_no, ordr_sprt_ser_no, orop_no, iloe_pele_cd ORDER BY ilor_end_dt, ilor_no) As nthTime             --Numbers off the results recorded for an order, op number, and insp char by date
--                  End As nthTime
               FROM 
                  --myZZIL                                                         --This can be deleted.  Only for testing purposes to make things run faster.
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
                  ILOR_END_DT >= TO_DATE('2014-01-01', 'YYYY-MM-DD') And ILOR_END_DT <= sysdate    --This filter is optional.  Only to make things run faster.  Subquery should not be date filtered or this date backdated from the rest of the query to take into account results on orders occuring before general date range being considered to get accurate SEQ results
                  And Trim(orop_oovr_cd) is Null                                 --Checks to make sure this is a standard op as opposed to RW, TO etc…  Remove this filter if you want to use query to determine Nth time through test.  Note that SEQ will not work
                  And orop_typ = 'STD'                                           --Remove this filter if you want to use query to determine Nth time through test.  Note that SEQ will not work
                  And ilor_validity_cd In ('VALID')                              --Brings in strange records otherwise
                  --And iloe_unplanned_ind = 'N'                                   --Remove this filter if you want to use query to determine Nth time through test.  Note that SEQ will not work  (commented and replaced with orop_typ = 'STD' JM, see change log)
                  --And Trim(Leading 0 From ordr_sprt_ser_no) = '1812'             --(for testing) Includes only serial number/s specified
                  --And SUBSTR(ILOR_NO,-3) = '001'                                 --Checks that this is the first result recorded for the insp char
                  --And ilor_validity_cd In ('VALID')                              --Removes "invalid" insp char results
                  --And iloe_process_cd != '{FORCE}'                               --Removes force closed insp chars
             ) SEQgetter On                                                        --END Subquery for adding sequence number of inspection characteristic in order in column named "SEQ" as well as "tripleInstance" which is the instance number of the IC, WCTR, PN triple on an order.  Only values of 1 are assigned to a management overview
     ordr_rtg_no = Seq_ordr_rtg_no 
     And wctr_no = Seq_wctr_no
     And iloe_pele_cd = Seq_pele_cd
     And ilor_iloe_seq_no = Seq_iloe_seq_no
     And orop_id = Seq_orop_id

WHERE
   to_char(ILOR_END_DT, 'yyyy') between trunc(to_char(sysdate, 'YYYY')) - 1 and trunc(to_char(sysdate, 'YYYY'))
   And ilor_end_dt >= To_date('2019-01-01', 'YYYY-MM-DD') And ilor_end_dt <= Sysdate  --This date is 1 of 2 locations that time range must be changed
   And iloe_process_cd != '{FORCE}'                                              --Exclude force closed insp char elements 
   --And ilor_evaluation_cd not in ('ACCEPTED','REJECTED')                         --This might speed up the query but have not yet checked how it affects results
   --And not yieldRelevant is Null                                                 --Removes records that don't fall into a yield type (basically removes some rework ops and things that aren't first time)
   --And Trim(orop_oovr_Cd) Is Null 	                                             --Checks to make sure this is a standard op as opposed to RW, TO etc…
   --And iloe_unplanned_ind = 'N'                                                  --Remove this filter if you want to use query to determine Nth time through test.  Note that SEQ will not work
   --And Substr(ilor_no,-3) = '001'                                                --Checks that this is the first result recorded for the insp char
   --And ilor_1st_time_ind = 'Y'                                                   --Filter for only first time results (as defined by WEBI)
   --And ilor_element_qnct_tier3_cd Not In('BA', 'SA', 'SR')                       --Exclude results with reason tier 3 QN category revisions, screen accept, and screen reject.
   --And ilor_validity_cd In ('VALID')                                             --(for testing)
   --And iloe_PELE_CD = 'AVIBCH'                                                   --(for testing)
ORDER BY
   ordr_no,
   orop_id,
   ilor_iloe_seq_no
  ;
