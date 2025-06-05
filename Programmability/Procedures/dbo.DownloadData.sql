SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[DownloadData]
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

		Select @Timekey=Max(Timekey) from dbo.SysDayMatrix  
		  where  Date=cast(getdate() as Date)
		  		  PRINT @Timekey  

		--DECLARE @PageFrom INT, @PageTo INT   
  
		--SET @PageFrom = (@perPage*@Page)-(@perPage) +1  
		--SET @PageTo = @perPage*@Page  

IF (@UploadType='IBPC Pool Upload')

BEGIN
		PRINT 'REV'
		--SELECT * FROM(
		SELECT 'Details' as TableName
		, SrNo
		,UploadID
		--,SummaryID
		,PoolID
		,PoolName
		--,CustomerID
		,AccountID
		--,POS
		--,InterestReceivable
		--,OSBalance
		,IBPCExposureinRs
		--,Convert(varchar(20),DateofIBPCreckoning,103)DateofIBPCreckoning
		,Convert(varchar(20),DateofIBPCmarking,103)DateofIBPCmarking
		,Convert(varchar(20),MaturityDate,103)MaturityDate
		------,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ROW_NUM
		,Action
		FROM IBPCPoolDetail_MOD
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

		SELECT 'Summary' as TableName, Row_Number() over(order by PoolID) as SrNo
		,UploadID
		,SummaryID
		,PoolID
		,PoolName
		,PoolType
		,BalanceOutstanding
		,IBPCExposureAmt
		,Convert(Varchar(20),IBPCReckoningDate,103)IBPCReckoningDate
		,Convert(Varchar(20),IBPCMarkingDate,103)IBPCMarkingDate
		,Convert(Varchar(20),MaturityDate,103)MaturityDate
		------,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ROW_NUM
		FROM IBPCPoolSummary_Mod
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

		--)A
		--WHERE ROW_NUM BETWEEN  @PageFrom AND @PageTo
		--ORDER BY ROW_NUM  

END

END
GO