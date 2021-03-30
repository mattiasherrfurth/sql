/*-----------------------------------------------------------------------------
-- Title:       RNs BY PART NUMBER
-- Author:      JOSH PUETT
-- Created:     5/10/2019
-- Purpose:     TO IDENTIFY THE NUMBER OF RNs BY PART NUMBER

-------------------------------------------------------------------------------
-- Current version:     A
-- Modification History:
--
-- Version A - 05/10/2019 - JOSH PUETT
--      TO IDENTIFY THE NUMBER OF RNs BY PART NUMBER
-----------------------------------------------------------------------------*/

SELECT
PART_NO,
PDRN_RNOT_NO,
PDRN_DOCC_CD,
PDRN_CREATED_DT,
PDRN_RELEASE_DT,
MOOP_MCMD_CD,

decode (MOOP_cctr_id, --changes in area names
            'MW        ',	'AMEC',
            'MY        ',	'AMEC',
            'TM        ',	'AMEC',
            'AB        ',	'ANT',
            'DH        ',	'ANT',
            'TG        ',	'ANT',
            'T5        ',	'ANT',
            'QC        ',	'EW',
            'AL        ',	'EW',
            'TZ        ',	'EW',
            'AP        ',	'EW',
            'WR        ',	'FLEX',
            'WM        ',	'FLEX',
            'Q7        ',	'FLEX',
            'QJ        ',	'FLEX',
            'WP        ',	'FLEX',
            'MA        ',	'MDF',
            'FJ        ',	'MDF',
            'F2        ',	'MDF',
            'DC        ',	'MDF',
            'M6        ',	'MDF',
            'M8        ',	'MDF',
            'TD        ',	'PROC',
            'AJ        ',	'PROC',
            'T2        ',	'REX',
            'TW        ',	'REX',
            'AQ        ',	'REX',
            'LQ1       ',	'RSIT',
            'LC1       ',	'RSIT',
            'FD        ',	'RSIT',
            'DB        ',	'SMT',
            'W6        ',	'SMT',
            'DP1       ',	'SMT',
            'T3        ',	'SMT',
            'MB        ',	'SMT',
            'FN        ',	'SMT',
            'FL        ',	'SMT',
            'XA        ', 'SMT',
            'WU        ',	'STI',
            'TA        ',	'SUB',
            'MG        ',	'SUB',
            'MK        ',	'SUB', 
            ' ') CHARGED_AREA

FROM
TDWHPDRN INNER JOIN TDWHPART ON (PDRN_PART_NO = PART_NO)
INNER JOIN TDWHMOOP ON (PART_NO = MOOP_PART_NO)

WHERE
MOOP_MCMD_CD in ('BD3','NDW','DT3')

GROUP BY
PART_NO,
PDRN_RNOT_NO,
PDRN_DOCC_CD,
PDRN_CREATED_DT,
PDRN_RELEASE_DT,
MOOP_MCMD_CD,
MOOP_CCTR_ID
;