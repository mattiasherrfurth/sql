select
  qnot_part_no,
  qndf_created_dt,
  sum(qndf_int_defective_qty) as qn_count
from
  tdwhqndf
    join tdwhqnot on qndf_qnot_no = qnot_no
group by
  qnot_part_no,
  qndf_created_dt