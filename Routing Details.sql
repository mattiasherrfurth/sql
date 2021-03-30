 SELECT
 RTNG_PART_NO Part,
 RTNG_ID Group_Counter,
 RTNG_TXT Group_Desc, 
 RTNG_TYP Usage,
 RTNG_STAT Stat,
 RTGO_NO Op_Number,
 WCTR_CD Wctr_Cd,
 RTGO_OOCT_CD Ctrl_Key,
 RTGO_LINE1_DESC Op_Desc,
 RTGO_STD_SETUP_RT Setup_STD,
 RTGO_SETUP_QTY Setup_Alloc,
 RTGO_STD_RUN_RT Labor_STD,
 WCTR_CCTR_ID Cctr_ID,
 RTNG_RTGG_ID Group_Number
 
 
 
 FROM TDWHRTNG INNER JOIN TDWHRTGO ON (rtgo_rtgg_id = rtng_rtgg_id and rtgo_rtng_id = rtng_id)
               INNER JOIN TDWHWCTR ON (rtgo_wctr_no = wctr_no)
