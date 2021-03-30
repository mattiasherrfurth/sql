/*-----------------------------------------------------------------------------
-- Title:       PRTs on Routing ops
-- Author:      Jordan Moshe
-- Created:     5/22/2019
-- Purpose:     This query can be used to get all the PRTs attached to routing 
operations.  Common filters used with this query are work center or material 
numbers can be used to return all routings that go through those work centers 
or on those materials. Can also be used as a where-used by typing in document 
name.

-------------------------------------------------------------------------------
-- Current version:     1
-- Modification History:
--
-- Version 1 - 05/22/2019 - Jordan Moshe
--      Published
-----------------------------------------------------------------------------*/

SELECT 
   rtng_plnt_id as Plant,
   rtng_part_no As "Part number", 
   rtng_rtgg_id As "Group number", 
   rtng_id As "Group counter", 
   rtng_typ As Usage, 
   rtng_stat As Status, 
   rtgo_no As Operation, 
   wctr_cd As "Work Center", 
   rtgr_docu_no As "Doc number",
   rtgr_docv_typ as "Doc type"
FROM 
   TDWHRTNG 
   INNER JOIN TDWHRTGO ON 
      rtng_id = rtgo_rtng_id
      And rtng_rtgg_id = rtgo_rtgg_id
   INNER JOIN TDWHRTGR ON
      rtgo_id = rtgr_rtgo_id
      And rtgo_rtng_id = rtgr_rtng_id
      And rtgo_rtgg_id = rtgr_rtgg_id 
   INNER JOIN TDWHWCTR ON 
      rtgo_wctr_no = wctr_no
WHERE
   rtng_typ = '1'                                                                --Only "preferred" routings, usage 1
   And rtgo_active_ind = 'Y'                                                     --Only active routing operations
   And rtng_active_ind = 'Y'                                                     --Only active routings
   And rtng_plnt_id = 'P001'                                                     --Only BWI routings
   --And wctr_cd in ('FLJUKI','FJPAINT')                                         --Uncomment to filter on a work center list
;
