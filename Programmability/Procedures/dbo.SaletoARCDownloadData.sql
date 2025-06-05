SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SaletoARCDownloadData]
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
----	,@UploadType VARCHAR(50)='Sale to ARC Upload'

BEGIN
		SET NOCOUNT ON;

		Select @Timekey=Max(Timekey) from dbo.SysDayMatrix  
		  where  Date=cast(getdate() as Date)
		  		  PRINT @Timekey  

		--DECLARE @PageFrom INT, @PageTo INT   
  
		--SET @PageFrom = (@perPage*@Page)-(@perPage) +1  
		--SET @PageTo = @perPage*@Page  

IF (@UploadType='Sale to ARC Upload')

BEGIN
		PRINT 'REV'
		--SELECT * FROM(
		SELECT 'SaletoARC Details' as TableName
		--, SrNo
		,UploadID
		--,SourceSystem
		,CustomerID
		--,CustomerName
		,AccountID
		,BalanceOutstanding as BalanceOSinRs
		,POS as PrincipalOutstandinginRs
		,InterestReceivable as InterestReceivableinRs
		,Convert(Varchar(20),DtofsaletoARC,103)DtofsaletoARC
		,Convert(Varchar(20),DateofApproval,103)DateofApproval
		,AmountSold as ExposuretoARCinRs
		------,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ROW_NUM
		FROM SaletoARC_Mod
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

		SELECT 'Summary' as TableName--, Row_Number() over(order by PoolID) as SrNo
		,UploadID
		,SummaryID
		,TotalPOSinRs
		,TotalInttReceivableinRs
		,TotaloutstandingBalanceinRs
		,ExposuretoARCinRs
		,Convert(Varchar(20),DateOfSaletoARC,103)DateOfSaletoARC
		,Convert(Varchar(20),DateOfApproval,103)DateOfApproval

		------,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ROW_NUM
		FROM SaletoARCSummary_Mod
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey


		--)A
		--WHERE ROW_NUM BETWEEN  @PageFrom AND @PageTo
		--ORDER BY ROW_NUM  

END



END
GO