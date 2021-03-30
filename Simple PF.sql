SELECT
            zzcm_part_no PART_NUM,
            trim(leading 0 from zzcm_ordr_no) ORDER_NUMBER,
            zzcm_yr YEAR,
            zzcm_mopd_nm MONTH,
            ZZCM_OROP_ACT_COMPLETED_DT DAY,
            zzcm_ordr_qty ORDER_QTY,
            orop_typ Operation_Type,
            orop_completed_qty COMPLETED_QTY,
            zzcm_orop_act_completed_dt OP_COMPLETED_DATE,
            trim(leading 0 from zzcm_sprt_ser_no) SERIAL_NUM, 
            zzcm_wctr_cd WORK_CENTER_CODE, 
            zzcm_cctr_id COST_CENTER_ID, 
            zzcm_pers_last_nm ||', '||zzcm_pers_first_nm EMPLOYEE,
            zzcm_orop_stat OPERATION_STATUS, 
            zzcm_yapp_no PAY_PERIOD, 
            zzcm_orop_id OPERATION_NUM, 
            zzcm_orop_line1_desc OPERATION_DESC, 
            zzcm_oovr_cd VARIANCE_CODE,
            zzcm_ocat_cd ORDER_CATEGORY_CODE, 
            zzcm_mpgm_nm PROGRAM_NAME,
            sum(zzcm_actual_hrs) ACTUAL_HRS,
            sum(zzcm_earned_hrs) EARNED_HRS


FROM
tdwhzzcm left join tdwhorop on (zzcm_orop_no = orop_no and orop_ordr_no = zzcm_ordr_no)
        
  
  
WHERE
zzcm_yr = '2018'
AND orop_typ = 'STD'
AND zzcm_cctr_id = 'MY'


GROUP BY

            zzcm_part_no,
            trim(leading 0 from zzcm_ordr_no),
            zzcm_yr,
            zzcm_mopd_nm,
            ZZCM_OROP_ACT_COMPLETED_DT,
            zzcm_ordr_qty,
            orop_typ,
            orop_completed_qty,
            zzcm_orop_act_completed_dt,
            trim(leading 0 from zzcm_sprt_ser_no), 
            zzcm_wctr_cd, 
            zzcm_cctr_id, 
            zzcm_pers_last_nm ||', '||zzcm_pers_first_nm,
            zzcm_orop_stat, 
            zzcm_yapp_no, 
            zzcm_orop_id, 
            zzcm_orop_line1_desc, 
            zzcm_oovr_cd,
            zzcm_ocat_cd, 
            zzcm_mpgm_nm 

;
