SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[StockstatementDownloadData]
	
	@ExcelUploadId INT
	
  
AS

----DECLARE @Timekey INT=49999
----	,@UserLoginId VARCHAR(100)='FNASUPERADMIN'
----	,@ExcelUploadId INT=4
----	,@UploadType VARCHAR(50)='Interest reversal'

BEGIN
		SET NOCOUNT ON;
Declare @Timekey INT
 set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
 where A.CurrentStatus='C')
		  		  PRINT @Timekey  
END
BEGIN
		SELECT 'Details' as TableName
		,UploadID
		,SrNo
		,CIF
		,AccountID
		,CustomerLimitSuffix
		,convert(varchar(10),StockStamentDt,103) StockStamentDt
		
		------,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ROW_NUM
		FROM StockStatement_Mod
		WHERE UploadId=@ExcelUploadId
		AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

		--SELECT 'Summary' as TableName, Row_Number() over(order by AUNo) as SrNo
		--,UploadID
		--,SummaryID
		--,AUNo
		--,PoolName
		--,Category
		--,TotalNoofBuyoutParty
		--,TotalPrincipalOutstandinginRs
		--,TotalInterestReceivableinRs
		--,BuyoutOSBalanceinRs
		--,TotalChargesinRs
		--,TotalAccuredInterestinRs
		--------,ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS ROW_NUM
		--FROM BuyoutSummary_Mod
		--WHERE UploadId=@ExcelUploadId
		--AND EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

	
END

GO