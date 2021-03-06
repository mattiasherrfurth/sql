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
SELECT * into OROP_RWK
	FROM OPENQUERY(ORAD, '
SELECT *
  FROM TDWHOROP
    WHERE OROP_LINE1_DESC like ''*RW 501%''
		and OROP_ACT_COMPLETED_DTM >= TO_DATE(''2017-01-01'', ''YYYY-MM-DD'')
      ORDER BY OROP_ORDR_NO, OROP_ID
   ');
