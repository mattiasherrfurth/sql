USE [j20032_yield]
GO
/****** Object:  StoredProcedure [dbo].[UpdateEvalYield]    Script Date: 11/7/2019 1:56:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[UpdateEvalYield] AS
drop table if exists PyramidYieldData;
SELECT * into PyramidYieldData
FROM backupPyramidYieldData
drop table backupPyramidYieldData;
