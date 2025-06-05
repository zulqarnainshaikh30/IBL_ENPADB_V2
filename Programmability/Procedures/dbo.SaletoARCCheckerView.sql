SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[SaletoARCCheckerView]

@MenuID INT=10,  
@UserLoginId  VARCHAR(20)='FnaAdmin',  
@Timekey INT=49999,
@UploadID as Int
WITH RECOMPILE  
AS 


BEGIN

BEGIN TRY  

     
	 SET DATEFORMAT DMY

 
 Select   @Timekey=Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)

  PRINT @Timekey  

  IF (@MenuID='1462')

  BEGIN
		Select 
		--Row_Number() over(order by PoolID) as SrNo ,
		UploadID
		,NoofAccounts
		,TotalPOSinRs
		,TotalInttReceivableinRs
		,TotaloutstandingBalanceinRs
		,ExposuretoARCinRs
		,Convert(varchar(20),DateOfSaletoARC,103)DateOfSaletoARC
		,Convert(varchar(20),DateOfApproval,103)DateOfApproval
		,Action
		
		from (
		
		Select 
		--Count(1) NoofAccounts
		--NoofAccounts
		--,SUM(TotalPOSinRs)TotalPOSinRs
		--,SUM(TotalInttReceivableinRs)TotalInttReceivableinRs
		--,SUM(TotaloutstandingBalanceinRs)TotaloutstandingBalanceinRs
		--,SUM(ExposuretoARCinRs)ExposuretoARCinRs
		--,MAX(DateOfSaletoARC)DateOfSaletoARC
		--,MAX(DateOfApproval)DateOfApproval
		UploadID
		,NoofAccounts
		,TotalPOSinRs
		,TotalInttReceivableinRs
		,TotaloutstandingBalanceinRs
		,ExposuretoARCinRs
		,DateOfSaletoARC
		,DateOfApproval
		,Action
		From
		SaletoARCSummary_Mod Where --Isnull(AuthorisationStatus,'A') in ('NP','MP') And
		 EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
		And UploadID=@UploadID
		--Group By 
		--PoolID,PoolName,PoolType
		)A

	END
End Try
BEGIN CATCH
	

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()


END CATCH

END
  
GO