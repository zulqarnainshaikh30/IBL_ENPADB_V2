SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SummaryGridData]
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
 Select @Timekey=Max(Timekey) from dbo.DimDayMatrix  
  where  Date=cast(getdate() as Date)
    PRINT @Timekey  

	Select 'IBPCData' as TableName, ROW_NUMBER() over(Order by PoolID) as SrNo
			,UploadID
			,SummaryID
			,PoolID
			,PoolName
			,PoolType
			,NoOfAccount
			,BalanceOutstanding
			,IBPCExposureAmt
			,Convert(Varchar(20),IBPCReckoningDate,103)IBPCReckoningDate
			,Convert(Varchar(20),IBPCMarkingDate,103)IBPCMarkingDate
			,Convert(Varchar(20),MaturityDate,103)MaturityDate
			,TotalPosBalance
			,TotalInttReceivable
			 from IBPCPoolSummary_stg
	Where UploadID=@UploadId

	exec GetIBPCPoolType
END
GO