drop table if exists Q3s_at_OKFS;
SELECT * into Q3s_at_OKFS
FROM OPENQUERY(ORAD, '
select * from tdwhqnot
  join tdwhorop on 
    qnot_wctr_no = orop_wctr_no
    and qnot_orop_no = orop_no
    and qnot_created_dt = orop_act_start_dtm
    
where
  qnot_typ = ''Q3''
  and orop_id = ''8990''
   ')