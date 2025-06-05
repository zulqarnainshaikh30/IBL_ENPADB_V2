SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE Procedure [dbo].[BuyoutInUp_Json]
@jsondata varchar(MAX) = ''
,@UploadID	int	=0
,@CrModApby varchar(20) = ''
,@Result int = 0 Output

As
Begin

Declare @TimeKey int 
Set @TimeKey = (select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')

Declare @EffectiveFromTimeKey int = @TimeKey, @EffectiveToTimeKey int = 49999

Declare @CreatedBy varchar(20) = @CrModApBy , @DateCreated date = GetDate()

IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
    DROP TABLE #Temp 

Select 
 UploadID
 ,SummaryID
 ,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
			,Action
into #temp

From OPENJSON(@jsondata) with 
(
UploadID int
,SummaryID int
,CIFId varchar(max)
,ENBDAcNo varchar(max)
	,BuyoutPartyLoanNo varchar(max)
	,PartnerDPD varchar(max)
	,PartnerDPDAsOnDate Datetime 
	,PartnerAssetClass varchar(max)
	,PartnerNPADate Datetime
   ,Action Char(1)
)


Begin Try
     --Begin Transaction

        Update A
		Set EffectiveToTimeKey= @Timekey - 1
		From BuyoutSummary_Mod A
		Inner Join #temp B
		On A.SummaryID = B.SummaryID
		And A.UploadID = B.UploadID
		Where EffectiveFromTimeKey <= @Timekey
	    And EffectiveToTimeKey >= @Timekey

		----alter Table BuyoutSummary_Mod
		----add Action char(1)

Insert into BuyoutSummary_Mod
			(UploadID
			,SummaryID
			,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated
			,Action)

Select  UploadID
		,SummaryID
		,CIFId
			,ENBDAcNo
			,BuyoutPartyLoanNo
			,PartnerDPD 
			,PartnerDPDAsOnDate
			,PartnerAssetClass
			,PartnerNPADate
		,'NP'
		,@EffectiveFromTimeKey
		,@EffectiveToTimeKey
		,@CreatedBy
		,@DateCreated
		,Action
From #temp B
Where  B.UploadID=@UploadID

Delete from BuyoutSummary_Stg where UploadID=@UploadID

--Commit Transaction

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