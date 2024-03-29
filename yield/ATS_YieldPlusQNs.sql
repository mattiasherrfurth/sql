USE [j20032_yield]
GO
/****** Object:  StoredProcedure [dbo].[GetYieldPlusQNsForExcel]    Script Date: 4/2/2020 10:46:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- running the Pyramid procedures for 334K511G01 (ATS Product)
drop table if exists ATS_YieldPlusQNs;
SELECT 
	*
	Case						--START of section that adds a field that indicates whether this record is counted in the Pyramid query
		When
			qndf_no Is Null			--Checks to make sure this is a standard op as opposed to RW, TO etc…
			Or qndf_no = '0001'		--Remove this filter if you want to use query to determine Nth time through test.  Note that SEQ will not work
		Then 'N'
		Else 'Y'
	End As show_qn_defects  
	INTO ATS_YieldPlusQNs
FROM ATS_YieldData 
	Left Join ATS_YieldQNs 
	On 
	ATS_YieldQNs.qnot_no =
	(
		SELECT TOP 1 QNOT_NO
		FROM ATS_YieldQNs
		WHERE
		QNOT_ORDR_NO = ORDR_NO
		And ATS_YieldData.Orop_id = ATS_YieldQNs.OROP_ID
		ORDER BY QNOT_CREATED_DT
	)
