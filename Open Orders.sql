/*-----------------------------------------------------------------------------
-- Title:       OPEN ORDERS
-- Author:      JOSH PUETT
-- Created:     5/6/2019
-- Purpose:     TO IDENTIFY THE OPEN ORDERS FOR A SPECIFIC PART AND ORDER NUMBER

-------------------------------------------------------------------------------
-- Current version:     2
-- Modification History:
--
-- Version 2 - 05/10/2019 - JOSH PUETT
--      ADDED ORDER NUMBER
-----------------------------------------------------------------------------*/

SELECT
TRIM(LEADING 0 FROM ORDR_SPRT_SER_NO),
TRIM(LEADING 0 FROM ORDR_NO),
ORDR_PART_NO,
OROP_RTNG_ID,
OROP_ID,
WCTR_CD,
OROP_LINE1_DESC,
OROP_STAT,
ORDR_COMPLETED_CD

FROM
TDWHWCTR INNER JOIN TDWHOROP ON (WCTR_NO = OROP_WCTR_NO)
INNER JOIN TDWHORDR ON (OROP_ORDR_NO = ORDR_NO)

WHERE
WCTR_CD = 'FLMP02'

GROUP BY
ORDR_SPRT_SER_NO,
ORDR_NO,
ORDR_PART_NO,
OROP_RTNG_ID,
OROP_ID,
WCTR_CD,
OROP_LINE1_DESC,
OROP_STAT,
ORDR_COMPLETED_CD
;