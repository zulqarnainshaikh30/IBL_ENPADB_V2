SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SecuritizedDownloadData]
	@Timekey INT
	,@UserLoginId VARCHAR(100)
	,@ExcelUploadId INT
	,@UploadType VARCHAR(50)
	--,@Page SMALLINT =1     
 --   ,@perPage INT = 30000   
AS

----DECLARE @Timekey INT=49999
----	,@UserLoginId VARCHAR(100)='FNASUPERADMIN'
----	,@ExcelUploadId INT=4
----	,@UploadType VARCHAR(50)='Interest reversal'

BEGIN
		SET NOCOUNT ON;

		Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')
		  		  PRINT @Timekey  

		--DECLARE @PageFrom INT, @PageTo INT   
  
		--SET @PageFrom = (@perPage*@Page)-(@perPage) +1  
		--SET @PageTo = @perPage*@Page  

IF (@UploadType='Securitized Upload')

BEGIN
		PRINT 'REV'
		--SELECT * FROM(
		SELECT 'Details' as TableName
		-- ,SrNo
		,UploadID
		--,SummaryID
		,PoolID
		,PoolName
		,SecuritisationType
		,CustomerID
		,AccountID
		,POS
		,InterestReceivable
		,OSBalance
		,SecuritisationExposureinRs
		,Convert(Varchar(20),DateofSecuritisationreckoning,103)DateofSecuritisationreckoning
		,Convert(Varchar(20),DateofSecuritisationmarking,103)DateofSecuritisationmarking
		,Convert(Varchar(20),MaturityDate,103)MaturityDate
		------,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ROW_NUM
		,Action
		,InterestAccruedinRs
		FROM SecuritizedDetail_MOD
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

		SELECT 'Summary' as TableName, Row_Number() over(order by PoolID) as SrNo
		,UploadID
		,SummaryID
		,PoolID
		,PoolName
		,SecuritisationType
		,POS
		,SecuritisationExposureAmt
		,Convert(varchar(20),SecuritisationReckoningDate,103)SecuritisationReckoningDate
		,Convert(varchar(20),SecuritisationMarkingDate,103)SecuritisationMarkingDate
		--,SecuritisationPortfolio
		,Convert(Varchar(20),MaturityDate,103)MaturityDate
		------,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ROW_NUM
		,Action
		FROM SecuritizedSummary_Mod
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

		--)A
		--WHERE ROW_NUM BETWEEN  @PageFrom AND @PageTo
		--ORDER BY ROW_NUM  

END



END
GO