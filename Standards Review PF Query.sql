SELECT
            zzcm_part_no PART_NUM,	
            zzcm_yr YEAR,	
            zzcm_mopd_nm MONTH,	
            ZZCM_OROP_ACT_COMPLETED_DT DAY,	
            zzcm_orop_act_completed_dt OP_COMPLETED_DATE,
            trim(leading 0 from zzcm_ordr_no) ORDER_NUMBER,	
            trim(leading 0 from zzcm_sprt_ser_no) SERIAL_NUM, 	
            zzcm_wctr_cd WORK_CENTER_CODE, 	
            zzcm_cctr_id COST_CENTER_ID, 	
            zzcm_pers_last_nm ||', '||zzcm_pers_first_nm EMPLOYEE,	
            zzcm_orop_stat OPERATION_STATUS, 	
            zzcm_wbse_cd GROUP_WBS, 	
            zzcm_yapp_no PAY_PERIOD, 	
            zzcm_orop_id OPERATION_NUM, 	
            zzcm_orop_line1_desc OPERATION_DESC,	
            zzcm_mpgm_nm PROGRAM_NAME, 	
            zzcm_tpcd_id || zzcm_tcst_id HOUR_TYPE_IND,	          	
                  case when CONCAT(ZZCM_TPCD_ID, ZZCM_TCST_ID) IN ('H10', 'H20', 'N10', 'N20') then zzcm_actual_hrs else 0 end PF_ELAPSED_HOURS,	
                  case when CONCAT(ZZCM_TPCD_ID, ZZCM_TCST_ID) IN ('H10', 'H20', 'N10', 'N20') then zzcm_earned_hrs else 0 end STANDARD_HOURS
                  
FROM tdwhzzcm 
    LEFT JOIN tdwhorop on zzcm_orop_no = orop_no and orop_ordr_no = zzcm_ordr_no	
  	
 WHERE	
  ZZCM_OROP_STAT IN ('COMPLETED', 'CONFIRMED', 'RELEASED', 'UNKNOWN', 'PCONFIRMED')	
  AND CONCAT(ZZCM_TPCD_ID, ZZCM_TCST_ID) IN ('H10', 'H20', 'N10', 'N20')
  AND ZZCM_YR IN ('2018', '2019')	
  AND OROP_TYP = 'STD'
