SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROC [dbo].[SecuritisationCheckerView]

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

  IF (@MenuID='1461')

  BEGIN
		--Select Row_Number()Over(Partition By PoolID,PoolName,SecuritisationType Order By PoolID,PoolName,SecuritisationType)SrNo ,* from (
		Select Row_Number() over(order by PoolID) as SrNo ,
		UploadID
		,PoolID
		,PoolName
		,SecuritisationType
		,NoofAccounts
		,POS
		,SecuritisationExposureAmt
		,Convert(varchar(20),SecuritisationReckoningDate,103)SecuritisationReckoningDate
		,Convert(varchar(20),SecuritisationMarkingDate,103)SecuritisationMarkingDate
		,Convert(varchar(20),MaturityDate,103)MaturityDate
		,SecuritisationPortfolio
		,Convert(varchar(20),DateofRemoval,103)DateofRemoval
		,TotalPosBalance
		,TotalInttReceivable
		,Action
		,InterestAccruedinRs
		from (
		
		Select 
		UploadID
		,PoolID
		,PoolName
		,SecuritisationType
		--,Count(1) NoofAccounts
		--,SUM(POS)POS
		--,SUM(SecuritisationExposureAmt)SecuritisationExposureAmt
		--,MAx(SecuritisationReckoningDate)SecuritisationReckoningDate
		--,MAx(SecuritisationMarkingDate)SecuritisationMarkingDate
		--,MAx(MaturityDate)MaturityDate  --Added by Maniraj 22032021 5:02 PM		
		--,SUM(SecuritisationPortfolio)SecuritisationPortfolio
		--,Max(MaturityDate)DateofRemoval
		--,SUM(TotalPosBalance)TotalPosBalance
		--,SUM(TotalInttReceivable)TotalInttReceivable
		--Changed by jayadev---------------------------------------------------------
		,NoOfAccount AS NoofAccounts
		,POS
		,SecuritisationExposureAmt
		,SecuritisationReckoningDate
		,SecuritisationMarkingDate
		,MaturityDate
		,MaturityDate as DateofRemoval
		,SecuritisationPortfolio
		,TotalPosBalance
		,TotalInttReceivable
		,ACtion
		,InterestAccruedinRs
		From
		SecuritizedSummary_Mod Where --Isnull(AuthorisationStatus,'A') in ('NP','MP','1A')
		 EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
		And UploadID=@UploadID
		--Group By 
		--PoolID,PoolName,SecuritisationType
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