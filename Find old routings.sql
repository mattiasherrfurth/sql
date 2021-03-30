/*-----------------------------------------------------------------------------
-- Title:       Find old routings
-- Author:      Jordan Moshe
-- Created:     4/23/2019
-- Purpose:     This query is used to pull routings that may be outdated and in need of updating.
--              The routings pulled by this query may then be put in a list to be mass put-on-hold
--              Make sure to change prepopulated where clause filters to suit your needs
-------------------------------------------------------------------------------
-- Current version:     1
-- Modification History:
--
-- Version 1 - 4/23/2019 - Jordan Moshe
--      Query created
--      
-----------------------------------------------------------------------------*/

SELECT DISTINCT
   rtng_part_no as Part_Number,                                                  --Part number
   rtng_rtgg_id as Group_Number,                                                 --Group number
   rtng_id as Group_Counter,                                                     --Group counter
   rtng_stat as Status,                                                          --Routing status
   rtng_created_dt as Routing_Created_Dt,                                        --Created date
   rtng_activity_dt as Routing_Last_Edited_Dt,                                   --Latest created/edited date of this routing
   latestOrdrDt as Latest_Order_Dt                                               --Creation date of latest order created from this routing
FROM
   tdwhrtng left join
                     (  SELECT                                                   --Begin subquery to get lasted order created with a particular routing
                           ordr_rtng_id,
                           ordr_rtng_rtgg_id,
                           Max(ordr_created_dt) as latestOrdrDt
                        FROM tdwhordr
                        GROUP BY
                           ordr_rtng_id,
                           ordr_rtng_rtgg_id
                     ) latestordr on                                             --End subquery to get lasted order created with a particular routing
      ordr_rtng_id = rtng_id 
      and ordr_rtng_rtgg_id = rtng_rtgg_id
   inner join tdwhrtgo on 
      rtgo_rtgg_id = rtng_rtgg_id 
      and rtgo_rtng_id = rtng_id
   inner join tdwhwctr on 
      rtgo_wctr_no  = wctr_no 
WHERE
   (wctr_cctr_id in ('MA') OR wctr_cd in ('FJKB02'))                             --Choose the cost centers and/or work centers to find routings
   and rtng_active_ind = 'Y'                                                     --Only "active" routings
   and rtng_stat = 'RELEASED'                                                    --Only routings that are currently released (Stat 4)
   and latestOrdrDt < To_date('2016-01-01', 'YYYY-MM-DD')                        --Routings that have an order created based on it before this date
   and rtng_created_dt < To_date('2016-01-01', 'YYYY-MM-DD')                     --Routings that were created before this date
   and rtng_activity_dt < To_date('2016-01-01', 'YYYY-MM-DD')                    --Routings that were created/edited before this date
   and rtng_plnt_id = 'P001'                                                     --Only routings in this plant
;
