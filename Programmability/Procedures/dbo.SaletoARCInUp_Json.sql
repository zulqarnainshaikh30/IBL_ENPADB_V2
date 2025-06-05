SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[SaletoARCInUp_Json]
@jsondata varchar(MAX) = ''
,@UploadID	int	=0
,@CrModApby varchar(20) = ''
,@Result int = 0 Output

As
Begin

Declare @TimeKey int 
Set @TimeKey =  (select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')
Declare @EffectiveFromTimeKey int = @TimeKey, @EffectiveToTimeKey int = 49999

Declare @CreatedBy varchar(20) = @CrModApBy , @DateCreated date = GetDate()

IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
    DROP TABLE #Temp 

Select 
 UploadID,SummaryID,NoofAccounts,TotalPOSinRs,TotalInttReceivableinRs,TotaloutstandingBalanceinRs,ExposuretoARCinRs,DateOfSaletoARC,DateOfApproval,Action
into #temp

From OPENJSON(@jsondata) with 
(
UploadID	int	   
,SummaryID	int	
,NoofAccounts int   
,TotalPOSinRs	decimal(18,2)    
,TotalInttReceivableinRs	decimal(18,2)   
,TotaloutstandingBalanceinRs	decimal(18,2)   
,ExposuretoARCinRs	decimal(18,2)    
,DateOfSaletoARC varchar(20)    
,DateOfApproval	varchar(20)
,Action char(1)
)


Begin Try
     Begin Transaction

        Update A
		Set EffectiveToTimeKey= @Timekey - 1
		From SaletoARCSummary_Mod A
		Inner Join #temp B
		On A.SummaryID = B.SummaryID
		And A.UploadID = B.UploadID
		Where EffectiveFromTimeKey <= @Timekey
	    And EffectiveToTimeKey >= @Timekey

Insert into SaletoARCSummary_Mod
			(UploadID
			,SummaryID
			,NoofAccounts
			,TotalPOSinRs
			,TotalInttReceivableinRs
			,TotaloutstandingBalanceinRs
			,ExposuretoARCinRs
			,DateOfSaletoARC
			,DateOfApproval			
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated
			,Action
			)

Select		UploadID
			,SummaryID
			,NoofAccounts
			,TotalPOSinRs
			,TotalInttReceivableinRs
			,TotaloutstandingBalanceinRs
			,ExposuretoARCinRs
			,Convert(date ,DateOfSaletoARC,103)
			,Convert(date ,DateOfApproval,103)		
			,'NP'
		,@EffectiveFromTimeKey
		,@EffectiveToTimeKey
		,@CreatedBy
		,@DateCreated
		,Action
		From #temp B
Where  B.UploadID=@UploadID

Delete from SaletoARCSummary_stg where UploadID=@UploadID

Commit Transaction

 Set @Result = 1
 Return @Result

 End Try
     Begin Catch
	     Rollback Tran
		 Select Error_Message() as ErrorDesc
		 Set @Result = -1
		 Print 'Error'
		 Return @Result
    End Catch

End
	



GO