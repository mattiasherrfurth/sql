SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mattias Herrfurth
-- Create date: 2023-07-24
-- Description:	Creates a table with data queried from Canary for AFF Poseidon UnitsInspected
-- =============================================
CREATE PROCEDURE MakeTable_PoseidonUnitsInspected
AS
BEGIN
	DROP TABLE IF EXISTS [db_name].[dbo].[Poseidon_UnitsInspected_temp]		-- creating temp table so that live table remains available during query runtime
	SELECT *
	INTO [db_name].[dbo].[Poseidon_UnitsInspected_temp]
	FROM OPENQUERY([linked_server] ,'
		SELECT
			data.tag_name AS tag_name
			,data.time_stamp AS time_stamp
			,data.value AS val
		FROM canarydata.data data
		WHERE (1 <> 0)
			and data.tag_name like ''%Poseidon%UnitsInspected%''
			and data.time_stamp > ''day-2w''
			and data.quality = ''192''
	')
	DROP TABLE IF EXISTS [db_name].[dbo].[Poseidon_UnitsInspected]			-- dropping live table
	SELECT *
	INTO [db_name].[dbo].[Poseidon_UnitsInspected]
	FROM [db_name].[dbo].[Poseidon_UnitsInspected_temp]
	DROP TABLE IF EXISTS [db_name].[dbo].[Poseidon_UnitsInspected_temp]		-- dropping temp table
END
GO
