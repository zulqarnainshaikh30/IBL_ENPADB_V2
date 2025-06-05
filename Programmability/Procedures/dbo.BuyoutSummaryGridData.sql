SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[BuyoutSummaryGridData]
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
 Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
 where A.CurrentStatus='C')
    PRINT @Timekey  

	Select 'BuyoutData' as TableName, ROW_NUMBER() over(Order by CIFId) as SrNo
			,UploadID
			,SummaryID
			,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
			 from BuyoutSummary_Mod
	Where UploadID=@UploadId

END



GO