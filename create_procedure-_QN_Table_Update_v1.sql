USE [j20032_yield]
GO
/****** Object:  StoredProcedure [dbo].[EvalYield]    Script Date: 7/27/2020 1:15:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE _QN_Update AS
/*-----------------------------------------------------------------------------
-- Title:       QN Table Update
-- Author:      Mattias Herrfurth
-- Created:     08/12/2020
-- Purpose:     This query is used to update the QN table, such that the table 
--				does not need to be removed for the duration of the QN_Query procedure.

-------------------------------------------------------------------------------
-- Current version:     1

-- Modification History:
--
-- Version 1 - 08/12/2020 - Mattias Herrfurth						
--		Published
-----------------------------------------------------------------------------*/
drop table if exists QN_Table;
SELECT * into QN_Table
FROM QN_Table_backup
drop table QN_Table_backup;