SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[SaletoARCSummaryGridData]
	 @UserLoginId VARCHAR(100)=null
	,@Menuid INT=null
	,@UploadId int=null
	
AS
--DECLARE @Timekey INT=49999
--	,@UserLoginId VARCHAR(100)='FNASUPERADMIN'
--	,@Menuid INT=161
BEGIN
		SET NOCOUNT ON;

    Declare @Timekey int
 set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
 where A.CurrentStatus='C')
    PRINT @Timekey  

	Select 'SaletoARCData' as TableName --, ROW_NUMBER() over(Order by PoolID) as SrNo
			,UploadID
			,SummaryID
			,NoofAccounts
			,TotalPOSinRs
			,TotalInttReceivableinRs
			,TotaloutstandingBalanceinRs
			,ExposuretoARCinRs
			,Convert(Varchar(20),DateOfSaletoARC,103)DateOfSaletoARC
			,Convert(Varchar(20),DateOfApproval,103)DateOfApproval
			,Action
			 from SaletoARCSummary_stg
	Where UploadID=@UploadId

	--exec GetIBPCPoolType
END
GO