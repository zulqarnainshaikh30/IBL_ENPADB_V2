SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[SecuritizedPoolInUp_Json]
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
 UploadID,SummaryID,PoolID,PoolName,SecuritisationType,POS,SecuritisationExposureAmt,
 SecuritisationReckoningDate,SecuritisationMarkingDate,MaturityDate,NoOfAccount,TotalPosBalance,TotalInttReceivable,InterestAccruedinRs
into #temp

From OPENJSON(@jsondata) with 
(
UploadID Int ,SummaryID int,PoolID varchar(max),PoolName varchar(max),SecuritisationType varchar(max),POS decimal (18,2)
,SecuritisationExposureAmt	decimal	(18,2),SecuritisationReckoningDate varchar(20),SecuritisationMarkingDate varchar(20),
MaturityDate varchar(20),NoOfAccount Int,TotalPosBalance Decimal(18,2), TotalInttReceivable Decimal(18,2),InterestAccruedinRs Decimal(18,2)	
)

Begin Try
     Begin Transaction

        Update A
		Set EffectiveToTimeKey= @Timekey - 1
		From SecuritizedSummary_Mod A
		Inner Join #temp B
		On A.SummaryID = B.SummaryID
		And A.UploadID = B.UploadID
		Where EffectiveFromTimeKey <= @Timekey
	    And EffectiveToTimeKey >= @Timekey
		print'3'
Insert into SecuritizedSummary_Mod
			(UploadID
			,SummaryID
			,PoolID
			,PoolName
			,SecuritisationType
			,Pos
			,SecuritisationExposureAmt
			,SecuritisationReckoningDate
			,SecuritisationMarkingDate
			,MaturityDate
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated
			,NoOfAccount
			,TotalPosBalance
			,TotalInttReceivable
			,InterestAccruedinRs)

Select  UploadID
		,SummaryID
		,PoolID
		,PoolName
		,SecuritisationType
		,POS
		,SecuritisationExposureAmt
		,Convert(date,SecuritisationReckoningDate,103)
		,Convert(date,SecuritisationMarkingDate,103)
		,Convert(date,MaturityDate,103)   
		,'NP'
		,@EffectiveFromTimeKey
		,@EffectiveToTimeKey
		,@CreatedBy
		,@DateCreated
		,NoOfAccount
		,TotalPosBalance
		,TotalInttReceivable
		,InterestAccruedinRs
From #temp B
Where  B.UploadID=@UploadID
Delete from SecuritizedSummary_stg where UploadID=@UploadID
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