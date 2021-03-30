

SELECT
   RTrim([ILOR_PART_NO]) & " - " & [PART_DESC] AS [Part Number],
   Val([ORDR_SPRT_SER_NO]) AS [Serial No],
   CDAS_TDWHILOR.ILOR_EMPL_ID AS Employee,
   CDAS_TDWHILOR.ILOR_END_DT AS [Date],
   CDAS_TDWHOROP.OROP_QTY AS Qty,
   CDAS_TDWHOROP.OROP_ID AS Oper,
   CDAS_TDWHOROP.OROP_ORDR_NO AS [Order],
   RTrim([WBSE_CD]) & " - " & [WBSE_DESC] AS WBS,
   Trim([WCTR_CD]) & " - " & [WCTR_DESC] AS [Work Center],
   CDAS_TDWHILOR.ILOR_EVALUATION_CD AS Result,
   CDAS_TDWHOROP.OROP_OOVR_CD AS [Variance Reason],
   Trim([OROP_PLNT_ID]) & " - " & [PLNT_DESC] AS Plant,
   [Production Scheduler Code Description].[Cell Description],
   [ILOE_PELE_CD] & " - " & [ILOE_PELE_DESC] AS [Insp Char],
   Year([ILOR_END_DT]) AS [Year],
   Month([ILOR_END_DT]) AS [Month],
   IIf([ILOR_EVALUATION_CD] = "ACCEPTED", [OROP_QTY], 0) AS ACCEPTED,
   IIf([ILOR_EVALUATION_CD] = "REJECTED", [ILOR_FAILED_QTY], 0) AS REJECTED,
   CDAS_TDWHOROP.OROP_NO,
   CDAS_TDWHWCTR.WCTR_CD,
   CDAS_TDWHILOR.ILOR_PART_NO AS Part,
   CDAS_TDWHWCTR.WCTR_CD AS Center,
   CDAS_TDWHILOE.ILOE_PELE_CD,
   CDAS_TDWHWCTR.WCTR_WCCT_ID,
   CDAS_TDWHGWBS.GWBS_SMGP_CD AS Div,
   IIf([GWBS_SMSG_CD] = "", [WBSE_DESC], [GWBS_SMSG_CD]) AS Prog,
   CDAS_TDWHORDR.ORDR_OCAT_CD INTO [All Results] 
FROM
   (
(((((((CDAS_TDWHORDR 
      INNER JOIN
         (
(CDAS_TDWHILOR 
            INNER JOIN
               CDAS_TDWHILOE 
               ON (CDAS_TDWHILOR.ILOR_ILOT_NO = CDAS_TDWHILOE.ILOE_ILOT_NO) 
               AND 
               (
                  CDAS_TDWHILOR.ILOR_ORDR_RTG_NO = CDAS_TDWHILOE.ILOE_ORDR_RTG_NO 
               )
               AND 
               (
                  CDAS_TDWHILOR.ILOR_OROP_NO = CDAS_TDWHILOE.ILOE_OROP_NO 
               )
               AND 
               (
                  CDAS_TDWHILOR.ILOR_ILOE_SEQ_NO = CDAS_TDWHILOE.ILOE_SEQ_NO 
               )
) 
            INNER JOIN
               CDAS_TDWHOROP 
               ON (CDAS_TDWHILOE.ILOE_ORDR_RTG_NO = CDAS_TDWHOROP.OROP_ORDR_RTG_NO) 
               AND 
               (
                  CDAS_TDWHILOE.ILOE_OROP_NO = CDAS_TDWHOROP.OROP_NO 
               )
         )
         ON CDAS_TDWHORDR.ORDR_RTG_NO = CDAS_TDWHOROP.OROP_ORDR_RTG_NO) 
      LEFT JOIN
         CDAS_TDWHWBSE 
         ON CDAS_TDWHORDR.ORDR_WBSE_ID = CDAS_TDWHWBSE.WBSE_ID) 
      INNER JOIN
         CDAS_TDWHWCTR 
         ON CDAS_TDWHOROP.OROP_WCTR_NO = CDAS_TDWHWCTR.WCTR_NO) 
      LEFT JOIN
         CDAS_TDWHPLNT 
         ON CDAS_TDWHOROP.OROP_PLNT_ID = CDAS_TDWHPLNT.PLNT_ID) 
      INNER JOIN
         CDAS_TDWHPPRT 
         ON (CDAS_TDWHORDR.ORDR_PART_NO = CDAS_TDWHPPRT.PPRT_PART_NO) 
         AND 
         (
            CDAS_TDWHOROP.OROP_PLNT_ID = CDAS_TDWHPPRT.PPRT_PLNT_ID 
         )
) 
      LEFT JOIN
         CDAS_TDWHPART 
         ON CDAS_TDWHILOR.ILOR_PART_NO = CDAS_TDWHPART.PART_NO) 
      INNER JOIN
         CDAS_TDWHOOVR 
         ON CDAS_TDWHOROP.OROP_OOVR_CD = CDAS_TDWHOOVR.OOVR_CD) 
      LEFT JOIN
         [Production Scheduler Code Description] 
         ON CDAS_TDWHPPRT.PPRT_MCMD_CD = [Production Scheduler Code Description].MCMD_CD
   )
   LEFT JOIN
      CDAS_TDWHGWBS 
      ON CDAS_TDWHWBSE.WBSE_ID = CDAS_TDWHGWBS.GWBS_WBSE_ID 
WHERE
   (
((CDAS_TDWHILOR.ILOR_END_DT) > Now() - 62) 
      AND 
      (
(CDAS_TDWHILOR.ILOR_EVALUATION_CD) = "ACCEPTED" 
         Or 
         (
            CDAS_TDWHILOR.ILOR_EVALUATION_CD 
         )
         = "REJECTED" 
      )
      AND 
      (
(CDAS_TDWHILOE.ILOE_PELE_CD) <> "TSTOFS" 
      )
      AND 
      (
(CDAS_TDWHWCTR.WCTR_WCCT_ID) = "Z002" 
         Or 
         (
            (CDAS_TDWHWCTR.WCTR_WCCT_ID) = "Z003"
         )
          
         Or 
         (
            (CDAS_TDWHWCTR.WCTR_WCCT_ID) = "Z001" 
            AND (CDAS_TDWHILOE.ILOE_PELE_CD) = "FLEXPRE"
         )
         Or
         (
            (CDAS_TDWHWCTR.WCTR_WCCT_ID) = "Z001"
            AND (CDAS_TDWHILOE.ILOE_PELE_CD) = "FLEXFIN"
         )
      )
      AND 
      (
(CDAS_TDWHILOR.ILOR_ELEMENT_QNCT_TIER3_CD) <> "B" 
         And 
         (
            CDAS_TDWHILOR.ILOR_ELEMENT_QNCT_TIER3_CD 
         )
         <> "SA" 
         And 
         (
            CDAS_TDWHILOR.ILOR_ELEMENT_QNCT_TIER3_CD 
         )
         <> "SR" 
      )
      AND 
      (
(CDAS_TDWHILOR.ILOR_VALIDITY_CD) <> "UNKNOWN" 
      )
      AND 
      (
(CDAS_TDWHILOE.ILOE_PROCESS_CD) <> "FORCE" 
      )
      AND 
      (
(CDAS_TDWHILOR.ILOR_PROCESS_CD) <> "FORCE" 
      )
   )
ORDER BY
   CDAS_TDWHOROP.OROP_ORDR_NO,
   Trim([WCTR_CD]) & " - " & [WCTR_DESC],
   CDAS_TDWHILOR.ILOR_EVALUATION_CD DESC;

