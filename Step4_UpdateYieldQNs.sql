USE [j20032_yield]
GO
/****** Object:  StoredProcedure [dbo].[UpdateYieldQNs]    Script Date: 11/7/2019 1:56:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[UpdateYieldQNs] AS
drop table if exists YieldQNs;
SELECT * into YieldQNs
FROM backupYieldQNs
DROP table backupYieldQNs;
