--Jordan's custom source query v8 4-4-19
WITH
   myZZIL As 
      (
      SELECT
         ordr_no,
         orop_id, 
         wctr_cd,
         wctr_desc, 
         ilor_ilot_no, 
         ordr_rtg_no, 
         iloe_ordr_rtg_no,   --redundant
         orop_no, 
         iloe_pele_cd, 
         ilor_iloe_seq_no, 
         ilor_no, 
         ilor_part_no, 
         part_desc, 
         ordr_sprt_ser_no,
         iloe_validity_cd,
         iloe_unplanned_ind,
         ilor_qty, 
         ilor_failed_qty, 
         ilor_empl_id, 
         ilor_end_dt,
         ilor_evaluation_cd, 
         ilor_validity_cd,
         ilor_element_qnct_tier3_cd, 
         ilor_txt, 
         iloe_process_cd,
         ilor_process_cd, 
         ilor_1st_time_ind,
         pele_desc,
         pele_qapp_cd,
         orop_qty, 
         orop_oovr_cd, 
         orop_plnt_id, 
         trim(plnt_desc) plnt_desc, 
         wctr_no, 
         orop_wctr_no,     --redundant
         wctr_cctr_id,
         wctr_wcct_id,
         Decode(wcct_id, 'Z001', 'Manufacturing',
                         'Z002', 'Test',
                         'Z003', 'Inspection') as YieldCategory,
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
               And ilor_validity_cd In ('VALID')
            Then 'Y'
            Else 'N'
         End As yieldRelevant,                                                   --END of section that adds a field that indicates whether this record is counted in the WEBI query
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
      WHERE
         ILOR_END_DT >= TO_DATE('2018-01-01', 'YYYY-MM-DD') And ILOR_END_DT <= sysdate
         And ilor_validity_cd In ('VALID')
         --And ilor_ordr_rtg_no = '0005364017'                            --Includes only order/s specified
      )
SELECT
   myZZIL.*,
   TO_CHAR(ilor_end_dt,'MON') "MONTH",
   TO_CHAR(ilor_end_dt,'YYYY') "YEAR",
   SEQ,
   tripleInstance,
   nthTime
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
                  ROW_NUMBER() OVER (PARTITION BY iloe_pele_cd, iloe_ordr_rtg_no ORDER BY orop_id) As SEQ,
                  ROW_NUMBER() OVER (PARTITION BY iloe_pele_cd, iloe_ordr_rtg_no, orop_wctr_no ORDER BY orop_id) As tripleInstance,
                  ROW_NUMBER() OVER (PARTITION BY iloe_ordr_rtg_no, orop_no, iloe_pele_cd ORDER BY ilor_end_dt, ilor_no) As nthTime             --Numbers off the results recorded for an order, op number, and insp char by date
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
               WHERE  
                  --ILOR_END_DT >= TO_DATE('2018-01-01', 'YYYY-MM-DD') And ILOR_END_DT <= sysdate    --This can be deleted.  Only for testing purposes to make things run faster.
                  Trim(orop_oovr_cd) is Null                                     --Checks to make sure this is a standard op as opposed to RW, TO etc…
                  And iloe_unplanned_ind = 'N'                                   --Remove this filter if you want to use query to determine Nth time through test.  Note that SEQ will not work
                  And ilor_validity_cd In ('VALID')                              --Brings in strange records otherwise
                  --And SUBSTR(ILOR_NO,-3) = '001'                                 --Checks that this is the first result recorded for the insp char
                  --And ilor_validity_cd In ('VALID')                            --Removes "invalid" insp char results
                  --And iloe_process_cd != '{FORCE}'                             --Removes force closed insp chars
             ) SEQgetter On                                                      --END Subquery for adding sequence number of inspection characteristic in order in column named "SEQ" as well as "tripleInstance" which is the instance number of the IC, WCTR, PN triple on an order.  Only values of 1 are assigned to a management overview
     ordr_rtg_no = Seq_ordr_rtg_no 
     And wctr_no = Seq_wctr_no
     And iloe_pele_cd = Seq_pele_cd
     And ilor_iloe_seq_no = Seq_iloe_seq_no
     And orop_id = Seq_orop_id
--   Left Join emportal.tmse_part_grouping@EMDD pg On                            --Work in progress to link in Master Parts List
--      orop_plnt_id = plant
--      and ilor_part_no
WHERE
   ilor_end_dt >= To_date('2018-01-01', 'YYYY-MM-DD') And ilor_end_dt <= Sysdate
   And iloe_process_cd != '{FORCE}'                                              --Exclude force closed insp char elements
   And Trim(orop_oovr_Cd) Is Null 	                                             --Checks to make sure this is a standard op as opposed to RW, TO etc…
   --And iloe_unplanned_ind = 'N'                                                  --Remove this filter if you want to use query to determine Nth time through test.  Note that SEQ will not work
   --And Substr(ilor_no,-3) = '001'                                                --Checks that this is the first result recorded for the insp char
   --And ilor_1st_time_ind = 'Y'                                                   --Filter for only first time results
   --And ilor_element_qnct_tier3_cd Not In('BA', 'SA', 'SR')                       --Exclude results with reason tier 3 QN category revisions, screen accept, and screen reject.
   --And ilor_validity_cd In ('VALID')                                             
   --And iloe_PELE_CD = '003BCH'
  ;
