USE [j20032_yield]
GO
/****** Object:  StoredProcedure [dbo].[EvalYield]    Script Date: 7/27/2020 1:15:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE _QN_Query AS
DROP table if exists QN_table;

/*-----------------------------------------------------------------------------
-- Title:       EvalYield
-- Author:      Connor Hayes (revisions by Mattias Herrfurth)
-- Created:     4/29/2019
-- Purpose:     This query pulls data to generate yield that recreate legacy pyramid reports						
--              In addition, WEBI data can be recreated based on the value filters in the WEBIyield and Pyramidyield fields

-------------------------------------------------------------------------------
-- Current version:     1

-- NOTE: revision tracking has been implemented in other files, as the OPENQUERY statement is character limited and must be trimmed to fit in this procedure. 
--			The first OPENQUERY in this statement is titled "Combined Yield", and the most recent commented revision can be found in the following location:
--			T:\A\AMEC\Quality Engineering\TABLEAU\QUERIES\ACTIVE

-- Modification History:
--
-- Version 1 - 07/27/2020 - Mattias Herrfurth						
--		Published with revisions to integrate query into database [j20032_yield]
--		Revisions contained to sections:
			- "Put new QNs into QN_table table"
			- "Update existing QNs width new info"
			- "Update all Date Updated fields"
-----------------------------------------------------------------------------*/
/************************************************************************************************
PULL QN DATA FROM DATA WAREHOUSE
*************************************************************************************************/

	DECLARE @QN1 TABLE (
			[QNOT_PLNT_ID] nchar(4), [QNOT_TYP] nchar(2), [QNOT_NO] nchar(12), [QNDF_NO] nchar(4), [QNOT_CREATED_DT] datetime2(7), [SERIAL_NUMBER] nvarchar(18),
			[QNOT_ACT_END_DT] datetime2(7), [QNOT_EMPL_ID] nchar(8), [QNOT_PART_NO] nchar(18), [PARTDESC] nvarchar(40), [ORDR_RTNG_ID] nchar(2), [QNOT_ORDR_NO] nchar(12), [WBSE_CD] nchar(24),
			[WBSE_DESC] nvarchar(40), [QNOT_QNCT_TIER3_CD] nchar(4), [QNCT_TIER2_DESC] nvarchar(40), [QNDF_TYPE_QNCT_TIER3_CD] nchar(4), [QNCT_TIER3_DESC] nvarchar(40),
			[QNDF_DESC] nvarchar(40), [QNDF_COMP_PART_NO] nchar(18), [REMPARTDESC] nvarchar(40), [QNDF_SPRT_SER_NO] nchar(18), [WCTR_CD] nchar(8), [WCTR_DESC] nvarchar(40),
			[WCTR_WCCT_ID] nchar(4), [OROP_ID] nchar(4), [OROP_LINE1_DESC] nvarchar(40), [QNTK_NO] nchar(4), [QNTK_COMPLETED_DT] datetime2(7), [QNTK_QNCT_TIER3_CD] nchar(4),
			[HOURS] float, [QNDF_LOCN_QNCT_TIER3_CD] nchar(4), [NOTE_TXT] ntext, [ORDR_OPER_COMPLETED_DT] datetime2(7), [ORDR_STAT] nchar(10), [ORDR_OCAT_CD] nchar(4),
			[FAILURECAT] varchar(50), [FAILUREMODE] varchar(50), [UPDATED_BY] varchar(50), [UPDATED_ON] date
		);

	Insert @QN1
	Select
		o.[QNOT_PLNT_ID], o.[QNOT_TYP], o.[QNOT_NO], o.[QNDF_NO], o.[QNOT_CREATED_DT], o.[SERIAL_NUMBER],
		o.[QNOT_ACT_END_DT], o.[QNOT_EMPL_ID], 	o.[QNOT_PART_NO], o.[PARTDESC], o.[ORDR_RTNG_ID], o.[QNOT_ORDR_NO], o.[WBSE_CD],
		o.[WBSE_DESC], o.[QNOT_QNCT_TIER3_CD], o.[QNCT_TIER2_DESC], o.[QNDF_TYPE_QNCT_TIER3_CD], o.[QNCT_TIER3_DESC],
		o.[QNDF_DESC], o.[QNDF_COMP_PART_NO], o.[REMPARTDESC], o.[QNDF_SPRT_SER_NO], o.[WCTR_CD], o.[WCTR_DESC],
		o.[WCTR_WCCT_ID], o.[OROP_ID], o.[OROP_LINE1_DESC], o.[QNTK_NO], o.[QNTK_COMPLETED_DT], o.[QNTK_QNCT_TIER3_CD],
		o.[HOURS], o.[QNDF_LOCN_QNCT_TIER3_CD], o.[NOTE_TXT], o.[ORDR_OPER_COMPLETED_DT], o.[ORDR_STAT], o.[ORDR_OCAT_CD],
		o.[FAILURECAT], o.[FAILUREMODE], o.[UPDATED_BY], o.[UPDATED_ON]

	From Openquery(orad,
		'
		SELECT 
			QNOT_PLNT_ID, QNOT_TYP, QNOT_NO, QNDF_NO, QNOT_CREATED_DT, SERIAL_NUMBER, QNOT_ACT_END_DT, QNOT_EMPL_ID, QNOT_PART_NO, PartDesc, 
			ORDR_RTNG_ID, QNOT_ORDR_NO, WBSE_CD, WBSE_DESC, QNOT_QNCT_TIER3_CD, QNCT_TIER2_DESC, QNDF_TYPE_QNCT_TIER3_CD, QNCT_TIER3_DESC, QNDF_DESC, QNDF_COMP_PART_NO, 
			RemPartDesc, QNDF_SPRT_SER_NO , WCTR_CD, WCTR_DESC, WCTR_WCCT_ID, OROP_ID, OROP_LINE1_DESC, QNTK_NO, QNTK_COMPLETED_DT, 
			QNTK_QNCT_TIER3_CD, Hours, QNDF_LOCN_QNCT_TIER3_CD, NOTE_TXT, ORDR_OPER_COMPLETED_DT, ORDR_STAT, ORDR_OCAT_CD,
			NULL as FAILURECAT, NULL as FAILUREMODE, Null as UPDATED_BY, Null as UPDATED_ON

		FROM
			(
			select 
				QNOT_PLNT_ID, QNOT_TYP, QNOT_NO, QNDF_NO, QNOT_CREATED_DT, QNOT_ACT_END_DT, QNOT_EMPL_ID, QNOT_PART_NO, PART1.PART_DESC as PartDesc, 
				ORDR_RTNG_ID, QNOT_ORDR_NO, QNOT_SPRT_SER_NO, WBSE_CD, WBSE_DESC, QNOT_QNCT_TIER3_CD, QNCT_TIER2_DESC, QNDF_TYPE_QNCT_TIER3_CD, QNCT_TIER3_DESC, 
				QNDF_DESC, QNDF_COMP_PART_NO, PART2.PART_DESC as RemPartDesc, QNDF_SPRT_SER_NO , WCTR_CD, WCTR_DESC, WCTR_WCCT_ID, OROP_ID, OROP_LINE1_DESC,
				QNTK_NO, QNTK_COMPLETED_DT, QNTK_QNCT_TIER3_CD,sum(QNDT_ACTUAL_HRS) AS Hours, QNDF_LOCN_QNCT_TIER3_CD, 
				trim(leading 0 from ORDR_SPRT_SER_NO) SERIAL_NUMBER, ORDR_OPER_COMPLETED_DT, ORDR_STAT, ORDR_OCAT_CD

			FROM TDWHQNOT
				LEFT JOIN TDWHQNDF ON QNDF_QNOT_NO = QNOT_NO 
				LEFT JOIN TDWHOROP ON QNDF_OROP_NO = OROP_NO AND QNDF_ORDR_RTG_NO = OROP_ORDR_RTG_NO 
				LEFT JOIN TDWHWCTR ON QNOT_WCTR_NO = WCTR_NO 
				LEFT JOIN TDWHQNCT ON QNDF_TYPE_QNCT_TIER3_CD = QNCT_TIER3_CD AND QNDF_TYPE_QNCT_TIER2_CD = QNCT_TIER2_CD AND QNDF_TYPE_QNCT_TIER1_CD = QNCT_TIER1_CD 
				LEFT JOIN TDWHORDR ON QNOT_ORDR_NO = ORDR_NO 
				LEFT JOIN TDWHWBSE ON ORDR_WBSE_ID = WBSE_ID
				LEFT JOIN TDWHQNTK ON QNTK_QNOT_NO = QNOT_NO AND QNTK_QNDF_NO = QNDF_NO
				LEFT JOIN TDWHQNDT ON QNDT_QNOT_NO = QNOT_NO AND QNDT_QNDF_NO = QNDF_NO
				LEFT JOIN TDWHGWBS ON WBSE_ID = GWBS_WBSE_ID
				LEFT JOIN TDWHPART PART1 ON QNOT_PART_NO = PART1.PART_NO
				LEFT JOIN TDWHPART PART2 ON QNDF_COMP_PART_NO = PART2.PART_NO

			WHERE
				QNOT_CREATED_DT >= SYSDATE - 1000
				AND (QNOT_TYP LIKE ''%Q3%'' or QNOT_TYP LIKE ''%F3%'' or QNOT_TYP LIKE ''%Z5%'')
				AND QNOT_PLNT_ID LIKE ''%P001%''
				And ((QNTK_QNCT_TIER2_CD like ''%PRDISP%'' and QNTK_ACTIVE_IND like ''%Y%'') or QNTK_QNCT_TIER2_CD is null)

			GROUP BY
				QNOT_PLNT_ID, QNOT_TYP, QNOT_NO, QNDF_NO, QNOT_CREATED_DT, QNOT_ACT_END_DT,QNOT_EMPL_ID, QNOT_PART_NO, PART1.PART_DESC,
				ORDR_RTNG_ID, QNOT_ORDR_NO, QNOT_SPRT_SER_NO, WBSE_CD, WBSE_DESC, QNOT_QNCT_TIER3_CD, QNCT_TIER2_DESC, QNDF_TYPE_QNCT_TIER3_CD, QNCT_TIER3_DESC, 
				QNDF_DESC, QNDF_COMP_PART_NO, PART2.PART_DESC, QNDF_SPRT_SER_NO , WCTR_CD, WCTR_DESC, WCTR_WCCT_ID,
				OROP_ID, OROP_LINE1_DESC, QNTK_NO, QNTK_COMPLETED_DT, QNTK_QNCT_TIER3_CD, QNDF_LOCN_QNCT_TIER3_CD, ORDR_SPRT_SER_NO,
				ORDR_OPER_COMPLETED_DT, ORDR_STAT, ORDR_OCAT_CD
			)

		LEFT JOIN CDAS.TDWHNOTE ON QNOT_NO = NOTE_QNOT_NO AND QNDF_NO = NOTE_QNDF_NO 

		WHERE NOTE_QNDC_NO not like ''%0%'' or NOTE_QNDC_NO is null
		') o


/*******************************************************************************************************************/
/*Get Division & Program for all Sector Orders                                                                         */
/*******************************************************************************************************************/

	DECLARE @QN2 TABLE (
		[Division] nchar(10), [Program] nvarchar(50), [Order Number] nchar(12)
	);

	Insert @QN2
	Select
		o.[PCTR_DVSN_CD] as 'Division', o.[PCTR_PROGRAM_NM] as 'Program', o.[MOBJ_ORDR_NO] as 'Order Number'

	From Openquery(orad,
		'
			SELECT 
				MOBJ_ORDR_NO, PCTR_DVSN_CD, PCTR_PROGRAM_NM
			FROM TDWHMOBJ
				JOIN TDWHMOWE on MOBJ_ID = MOWE_MOBJ_ID
				Join TDWHWBSE on MOWE_WBSE_ID = WBSE_ID
				Join TDWHPCTR on WBSE_PCTR_ID = PCTR_ID
			Where
				MOBJ_ORDR_NO not like ''            ''
		') o

/*******************************************************************************************************************/
/*Combine QN1 table with QN2 Table where a Part Number is found                                                    */
/*******************************************************************************************************************/
	DECLARE @QN3 TABLE (
		[Division] nchar(10), [Program] nvarchar(50), [QNOT_PLNT_ID] nchar(4), [QNOT_TYP] nchar(2), [QNOT_NO] nchar(12), [QNDF_NO] nchar(4), [QNOT_CREATED_DT] datetime2(7),
		[SERIAL_NUMBER] nvarchar(18), [QNOT_ACT_END_DT] datetime2(7), [QNOT_EMPL_ID] nchar(8), [QNOT_PART_NO] nchar(18), [PARTDESC] nvarchar(40), [ORDR_RTNG_ID] nchar(2), [QNOT_ORDR_NO] nchar(12),
		[WBSE_CD] nchar(24), [WBSE_DESC] nvarchar(40), [QNOT_QNCT_TIER3_CD] nchar(4), [QNCT_TIER2_DESC] nvarchar(40), [QNDF_TYPE_QNCT_TIER3_CD] nchar(4),
		[QNCT_TIER3_DESC] nvarchar(40), [QNDF_DESC] nvarchar(40), [QNDF_COMP_PART_NO] nchar(18), [REMPARTDESC] nvarchar(40), [QNDF_SPRT_SER_NO] nchar(18), [WCTR_CD] nchar(8),
		[WCTR_DESC] nvarchar(40), [WCTR_WCCT_ID] nchar(4), [OROP_ID] nchar(4), [OROP_LINE1_DESC] nvarchar(40), [QNTK_NO] nchar(4), [QNTK_COMPLETED_DT] datetime2(7),
		[QNTK_QNCT_TIER3_CD] nchar(4), [HOURS] float, [QNDF_LOCN_QNCT_TIER3_CD] nchar(4), [NOTE_TXT] ntext, [ORDR_OPER_COMPLETED_DT] datetime2(7), [ORDR_STAT] nchar(10),
		[ORDR_OCAT_CD] nchar(4), [FAILURECAT] varchar(50), [FAILUREMODE] varchar(50), [UPDATED_BY] varchar(50), [UPDATED_ON] date
	);

	Insert @QN3
	Select
		b.[Division], b.[Program], o.[QNOT_PLNT_ID], o.[QNOT_TYP], o.[QNOT_NO], o.[QNDF_NO], o.[QNOT_CREATED_DT],
		o.[SERIAL_NUMBER], o.[QNOT_ACT_END_DT], o.[QNOT_EMPL_ID], o.[QNOT_PART_NO], o.[PARTDESC], o.[ORDR_RTNG_ID], o.[QNOT_ORDR_NO],
		o.[WBSE_CD], o.[WBSE_DESC], o.[QNOT_QNCT_TIER3_CD], o.[QNCT_TIER2_DESC], o.[QNDF_TYPE_QNCT_TIER3_CD],
		o.[QNCT_TIER3_DESC], o.[QNDF_DESC], o.[QNDF_COMP_PART_NO], o.[REMPARTDESC], o.[QNDF_SPRT_SER_NO], o.[WCTR_CD],
		o.[WCTR_DESC], o.[WCTR_WCCT_ID], o.[OROP_ID], o.[OROP_LINE1_DESC], o.[QNTK_NO], o.[QNTK_COMPLETED_DT],
		o.[QNTK_QNCT_TIER3_CD], o.[HOURS], o.[QNDF_LOCN_QNCT_TIER3_CD], o.[NOTE_TXT], o.[ORDR_OPER_COMPLETED_DT], o.[ORDR_STAT],
		o.[ORDR_OCAT_CD], o.[FAILURECAT], o.[FAILUREMODE], o.[UPDATED_BY], o.[UPDATED_ON]
	From @QN1 o
		Inner Join @QN2 b on o.[QNOT_ORDR_NO] = b.[Order Number]

	Insert @QN3
	Select
		null as 'Division', null as 'Program', o.[QNOT_PLNT_ID], o.[QNOT_TYP], o.[QNOT_NO], o.[QNDF_NO], o.[QNOT_CREATED_DT],
		o.[SERIAL_NUMBER], o.[QNOT_ACT_END_DT], o.[QNOT_EMPL_ID], o.[QNOT_PART_NO], o.[PARTDESC], o.[ORDR_RTNG_ID], o.[QNOT_ORDR_NO],
		o.[WBSE_CD], o.[WBSE_DESC], o.[QNOT_QNCT_TIER3_CD], o.[QNCT_TIER2_DESC], o.[QNDF_TYPE_QNCT_TIER3_CD],
		o.[QNCT_TIER3_DESC], o.[QNDF_DESC], o.[QNDF_COMP_PART_NO], o.[REMPARTDESC], o.[QNDF_SPRT_SER_NO], o.[WCTR_CD],
		o.[WCTR_DESC], o.[WCTR_WCCT_ID], o.[OROP_ID], o.[OROP_LINE1_DESC], o.[QNTK_NO], o.[QNTK_COMPLETED_DT],
		o.[QNTK_QNCT_TIER3_CD], o.[HOURS], o.[QNDF_LOCN_QNCT_TIER3_CD], o.[NOTE_TXT], o.[ORDR_OPER_COMPLETED_DT], o.[ORDR_STAT],
		o.[ORDR_OCAT_CD], o.[FAILURECAT], o.[FAILUREMODE], o.[UPDATED_BY], o.[UPDATED_ON]
	From @QN1 o

	Where 
		Not Exists(
			Select * From @QN3 as a
			Where
				a.[QNOT_ORDR_NO] = o.[QNOT_ORDR_NO]
		)


/*******************************************************************************************************************/
/*Put new QNs into QN_table table                                                                                    */
/*******************************************************************************************************************/
	INSERT INTO QN_table SELECT getdate() as 'Data Update', * FROM @QN3 as l WHERE not exists(
		SELECT * FROM QN_table 
		WHERE 
			QN_table.QNOT_NO = l.QNOT_NO 
			AND QN_table.QNDF_NO = l.QNDF_NO
	);



/*******************************************************************************************************************/
/*Update existing QNs width new info                                                                               */
/*******************************************************************************************************************/
	UPDATE QN_table 
	SET 
	QN_table.QNDF_NO = QNLanding.QNDF_NO,
	QN_table.QNOT_ACT_END_DT = QNLanding.QNOT_ACT_END_DT,
	QN_table.QNOT_QNCT_TIER3_CD = QNLanding.QNOT_QNCT_TIER3_CD,
	QN_table.QNCT_TIER2_DESC = QNLanding.QNCT_TIER2_DESC,
	QN_table.QNDF_TYPE_QNCT_TIER3_CD = QNLanding.QNDF_TYPE_QNCT_TIER3_CD,
	QN_table.QNCT_TIER3_DESC = QNLanding.QNCT_TIER3_DESC,
	QN_table.QNDF_DESC = QNLanding.QNDF_DESC,
	QN_table.QNDF_COMP_PART_NO = QNLanding.QNDF_COMP_PART_NO,
	QN_table.RemPartDesc = QNLanding.RemPartDesc,
	QN_table.QNDF_SPRT_SER_NO = QNLanding.QNDF_SPRT_SER_NO,
	QN_table.OROP_LINE1_DESC = QNLanding.OROP_LINE1_DESC,
	QN_table.QNTK_NO = QNLanding.QNTK_NO,
	QN_table.QNTK_COMPLETED_DT = QNLanding.QNTK_COMPLETED_DT,
	QN_table.QNTK_QNCT_TIER3_CD = QNLanding.QNTK_QNCT_TIER3_CD,
	QN_table.HOURS = QNLanding.HOURS,
	QN_table.QNDF_LOCN_QNCT_TIER3_CD = QNLanding.QNDF_LOCN_QNCT_TIER3_CD,
	QN_table.NOTE_TXT = QNLanding.NOTE_TXT,
	QN_table.ORDR_OPER_COMPLETED_DT = QNLanding.ORDR_OPER_COMPLETED_DT,
	QN_table.ORDR_STAT = QNLanding.ORDR_STAT,
	QN_table.Division = QNLanding.Division,
	QN_table.Program = QNLanding.Program

	FROM @QN3 as QNLanding

	WHERE 
		QN_table.QNOT_NO = QNLANDING.QNOT_NO
		AND QN_table.QNDF_NO = QNLanding.QNDF_NO

/*******************************************************************************************************************/
/*Update all Date Updated fields                                                                                   */
/*******************************************************************************************************************/
	UPDATE QN_table 
	SET QN_table.[Data Update] = getdate()


