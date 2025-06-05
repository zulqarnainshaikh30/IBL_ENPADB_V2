SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE Procedure [dbo].[IBPCPoolInUp_Json]
@jsondata varchar(MAX) = ''
,@UploadID	int	=0
,@CrModApby varchar(20) = ''
,@Result int = 0 Output

As
Begin

Declare @TimeKey int 
set @TimeKey =  (select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')

Declare @EffectiveFromTimeKey int = @TimeKey, @EffectiveToTimeKey int = 49999

Declare @CreatedBy varchar(20) = @CrModApBy , @DateCreated date = GetDate()

IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
    DROP TABLE #Temp 

Select 
 UploadID,SummaryID,PoolID,PoolName,PoolType,BalanceOutstanding,IBPCExposureAmt,IBPCReckoningDate,IBPCMarkingDate,MaturityDate,NoOfAccount,TotalPosBalance,TotalInttReceivable
into #temp

From OPENJSON(@jsondata) with 
(
UploadID Int ,SummaryID int,PoolID	varchar	(max),PoolName	varchar(max),PoolType	varchar(max)	,BalanceOutstanding	decimal	(16,2)
,IBPCExposureAmt	decimal	(16,2),IBPCReckoningDate	varchar(20),IBPCMarkingDate	varchar(20),MaturityDate	varchar(20),NoOfAccount Int,TotalPosBalance Decimal(16,2), TotalInttReceivable Decimal(16,2)	
)


Begin Try
     Begin Transaction

        Update A
		Set EffectiveToTimeKey= @Timekey - 1
		From IBPCPoolSummary_MOD A
		Inner Join #temp B
		On A.SummaryID = B.SummaryID
		And A.UploadID = B.UploadID
		Where EffectiveFromTimeKey <= @Timekey
	    And EffectiveToTimeKey >= @Timekey

Insert into IBPCPoolSummary_MOD
			(UploadID
			,SummaryID
			,PoolID
			,PoolName
			,PoolType
			,BalanceOutstanding
			,IBPCExposureAmt
			,IBPCReckoningDate
			,IBPCMarkingDate
			,MaturityDate
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated
			,NoOfAccount
			,TotalPosBalance
			,TotalInttReceivable)

Select  UploadID
		,SummaryID
		,PoolID
		,PoolName
		,PoolType
		,BalanceOutstanding
		,IBPCExposureAmt
		,Convert(date ,IBPCReckoningDate,103)
		,Convert(date ,IBPCMarkingDate	,103)
		,Convert(date ,MaturityDate   	,103)
		,'NP'
		,@EffectiveFromTimeKey
		,@EffectiveToTimeKey
		,@CreatedBy
		,@DateCreated
		,NoOfAccount
		,TotalPosBalance
		,TotalInttReceivable
From #temp B
Where  B.UploadID=@UploadID

Delete from IBPCPoolSummary_stg where UploadID=@UploadID

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