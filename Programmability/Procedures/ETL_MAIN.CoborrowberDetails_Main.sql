SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[CoborrowberDetails_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN

DECLARE @TIMEKEY INT = (SELECT TIMEKEY FROM IBL_ENPA_DB_V2.DBO.SYSDATAMATRIX WHERE CurrentStatus='C')
	SET NOCOUNT ON;

			insert into CurDat.CoborrowberDetails
					(
						AsOnDate
						,NCIFID_PrimaryAccount
						,SourceSystemName_PrimaryAccount
						,CustomerId_PrimaryAccount
						,CustomerACID_PrimaryAccount
						,NCIFID_COBORROWER
						,EffectiveFromTimeKey
						,EffectiveToTimeKey
					)
				SELECT 
					AS_ON_DATE
					,ENT_CIF
					,SOURCE
					,SRC_CIF
					,ACC_NO
					,COBO_ENT_CIF
					,@TIMEKEY
					,49999
				FROM IBL_ENPA_TEMPDB_V2.DBO.TEMPCOBORROWER_ALLSOURCE
END
GO