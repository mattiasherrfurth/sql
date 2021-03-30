select
  ordr_part_no,
  to_char(orop_act_completed_dtm, 'DD/MM/YYYY') as op_date,
  sum(orop_completed_qty) as pn_qty_per_day
from tdwhorop
inner join tdwhordr on 
  ordr_rtg_no = orop_ordr_rtg_no
  and orop_ordr_no = ordr_no
where
  op_date >= sysdate - 365
group by
  ordr_part_no,
  to_char(orop_act_completed_dtm, 'DD/MM/YYYY')
order by
  to_char(orop_act_completed_dtm, 'DD/MM/YYYY')