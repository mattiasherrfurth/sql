USE [j20032_herrfurth_test]
GO
-- When the ANSI_NULL database option is set to ON, then a comparison with NULL records yields UNKNOWN. Hence, no rows are returned. 
-- If you compare anything with NULL, it will result as UNKNOWN, and also the NULL = NULL comparison will be considered as UNKNOWN. 
-- You cannot compare NULL against anything. This is an ISO standard when dealing with NULL records.
SET ANSI_NULLS ON
GO
-- Causes SQL Server to follow the ISO rules regarding quotation mark delimiting identifiers and literal strings.
-- When SET QUOTED_IDENTIFIER is ON, identifiers can be delimited by double quotation marks, and literals must be delimited by single quotation marks. 
-- When SET QUOTED_IDENTIFIER is OFF, identifiers cannot be quoted and must follow all Transact-SQL rules for identifiers.
SET QUOTED_IDENTIFIER ON
GO
-- OPENQUERY is used to connect to another database.
-- Executes the specified pass-through query on the specified linked server. This server is an ORAD data source. 
-- NOTE: the OPENQUERY statement is character limited. 
--			The query in this statement is titled "Combined Yield", and the most recent commented revision can be found in the following location:
--			T:\A\AMEC\Quality Engineering\TABLEAU\QUERIES\ACTIVE
DROP table if exists OROP_RWK_WCTR_QNs;
SELECT * into OROP_RWK_WCTR_QNs
	FROM OPENQUERY(ORAD, '
WITH RWK_tbl as
(
SELECT 
LPAD(SUBSTR(t.OROP_LINE1_DESC, 5, INSTR(t.OROP_LINE1_DESC, ''/'')-5), 12, ''0'') AS OROP_QNOT_NO,
SUBSTR(t.OROP_LINE1_DESC, INSTR(t.OROP_LINE1_DESC, ''/'')+1,4) AS OROP_QNDF_NO,
t.*,
w.*
  FROM TDWHOROP t
  Join TDWHWCTR w On wctr_no = orop_wctr_no
    WHERE 
      OROP_LINE1_DESC like ''*RW 501%''
      and OROP_ACT_COMPLETED_DTM >= TO_DATE(''2017-01-01'', ''YYYY-MM-DD'')
      and OROP_PLNT_ID = ''P001''
      and WCTR_CCTR_ID in (''MY'',''MW'',''TM'')
    ORDER BY OROP_ORDR_NO, OROP_ID
)

SELECT * 
  FROM RWK_tbl
    Left Join TDWHQNOT q on QNOT_NO = OROP_QNOT_NO
    Left Join TDWHQNDF d on QNDF_QNOT_NO = OROP_QNOT_NO and QNDF_NO = OROP_QNDF_NO
   ');
