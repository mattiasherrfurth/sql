/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) *
  FROM [j20032_yield].[dbo].[YieldPlusQNs]
	WHERE 
		OROP_PLNT_ID = 'P010' and
		[YEAR] = '2020' and
		[MONTH] = '1' and
		WCCT_DESC = 'Inspection Labor' and
		ILOR_EVALUATION_CD = 'REJECTED' and
		qndf_no = '0001'