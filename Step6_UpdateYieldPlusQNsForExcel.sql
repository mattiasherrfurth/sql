USE [j20032_yield]
GO
/****** Object:  StoredProcedure [dbo].[UpdateYieldPlusQNsForExcel]    Script Date: 11/7/2019 1:56:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[UpdateYieldPlusQNsForExcel] AS
DROP table if exists YieldPlusQNs;
SELECT * into YieldPlusQNs
FROM  BackupYieldPlusQNs
DROP table BackupYieldPlusQNs;