SELECT 
	CDAS_TDWHORDR.ORDR_PART_NO, 
	CDAS_TDWHORDR.ORDR_SPRT_SER_NO, 
	CDAS_TDWHOROP.OROP_ID, 
	CDAS_TDWHILOR.ILOR_END_DT, 
	CDAS_TDWHILOR.ILOR_EVALUATION_CD, 
	CDAS_TDWHILOE.ILOE_PELE_CD, 
	CDAS_TDWHWCTR.WCTR_WCCT_ID, 
	CDAS_TDWHWCTR.WCTR_DESC, 
	CDAS_TDWHWCTR.WCTR_NO, 
	CDAS_TDWHILOR.ILOR_ELEMENT_QNCT_TIER3_CD, 
	CDAS_TDWHILOR.ILOR_VALIDITY_CD, 
	CDAS_TDWHILOR.ILOR_PROCESS_CD,
	CDAS_TDWHILOE.ILOE_END_DT INTO test
FROM (((CDAS_TDWHORDR 
	INNER JOIN CDAS_TDWHOROP 
		ON CDAS_TDWHORDR.ORDR_NO = CDAS_TDWHOROP.OROP_ORDR_NO) 
	INNER JOIN CDAS_TDWHILOE 
		ON (CDAS_TDWHOROP.OROP_ORDR_RTG_NO = CDAS_TDWHILOE.ILOE_ORDR_RTG_NO) 
		AND (CDAS_TDWHOROP.OROP_NO = CDAS_TDWHILOE.ILOE_OROP_NO)) 
	INNER JOIN CDAS_TDWHILOR 
		ON (CDAS_TDWHILOE.ILOE_ILOT_NO = CDAS_TDWHILOR.ILOR_ILOT_NO) 
		AND (CDAS_TDWHILOE.ILOE_ORDR_RTG_NO = CDAS_TDWHILOR.ILOR_ORDR_RTG_NO) 
		AND (CDAS_TDWHILOE.ILOE_OROP_NO = CDAS_TDWHILOR.ILOR_OROP_NO) 
		AND (CDAS_TDWHILOE.ILOE_SEQ_NO = CDAS_TDWHILOR.ILOR_ILOE_SEQ_NO)) 
	INNER JOIN CDAS_TDWHWCTR 
		ON CDAS_TDWHOROP.OROP_WCTR_NO = CDAS_TDWHWCTR.WCTR_NO
WHERE (
	((CDAS_TDWHOROP.OROP_ID)="4500") 
	AND ((CDAS_TDWHILOR.ILOR_END_DT)>Now()-80) 
	AND ((CDAS_TDWHILOR.ILOR_EVALUATION_CD)="ACCEPTED" Or (CDAS_TDWHILOR.ILOR_EVALUATION_CD)="REJECTED") 
	AND ((CDAS_TDWHILOE.ILOE_PELE_CD)="INPSCINP") 
	AND ((CDAS_TDWHWCTR.WCTR_NO)="10013822") 
	AND ((CDAS_TDWHILOR.ILOR_ELEMENT_QNCT_TIER3_CD) Not In ("B","SA","SR")) 
	AND ((CDAS_TDWHILOR.ILOR_VALIDITY_CD)<>"UNKNOWN"));
