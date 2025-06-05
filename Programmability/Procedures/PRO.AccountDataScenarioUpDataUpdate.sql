SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [PRO].[AccountDataScenarioUpDataUpdate]
				@CustomerAcid Varchar(30)=''
				,@FirstDtOfDisb Varchar(20) = NULL
				,@ProductAlt_Key Int = 0
				,@Balance Decimal(18,2) = 0
				,@DrawingPower Decimal(18,2) = 0
				,@CurrentLimit Decimal(18,2) = 0
				,@ContiExcessDt Varchar(20) = NULL
				,@StockStDt Varchar(20) = NULL
				,@DebitSinceDt Varchar(20) = NULL
				,@LastCrDate Varchar(20) = NULL
				,@CurQtrCredit Decimal(18,2) = 0
				,@CurQtrInt Decimal(18,2) = 0
				--,@InttServiced Varchar(20) = NULL
				--,@IntNotServicedDt Varchar(20) = NULL
				,@OverDueSinceDt Varchar(20) = NULL
				,@ReviewDueDt Varchar(20) = NULL
				--,@SecurityValue Decimal(18,2) = 0
				,@DFVAmt Decimal(18,2) = 0
				,@GovtGtyAmt Decimal(18,2) = 0
				,@WriteOffAmount Decimal(18,2) = 0
				,@UnAdjSubSidy Decimal(18,2) = 0
				,@Asset_Norm Varchar(20) = NULL
				,@AddlProvision Decimal(18,2) = 0
				,@PrincOverdueSinceDt Varchar(20) = NULL
				,@IntOverdueSinceDt Varchar(20) = NULL
				,@OtherOverdueSinceDt Varchar(20) = NULL
				,@RepossessionDate Varchar(20) = NULL
				,@UnserviedInt Decimal(18,2) = 0
				,@AdvanceRecovery Decimal(18,2) = 0
				,@RePossession Varchar(20) = NULL
				,@RCPending Varchar(20) = NULL
				,@PaymentPending Varchar(20) = NULL
				,@WheelCase Varchar(20) = NULL
				,@RFA Varchar(20) = NULL
				,@IsNonCooperative Varchar(20) = NULL
				,@Sarfaesi Varchar(20) = NULL
				,@WeakAccount Varchar(20) = NULL
				,@PrvQtrRV Decimal(18,2) = NULL
				,@CurntQtrRv Decimal(18,2) = NULL
				,@FraudDt Varchar(20) = NULL
				,@FraudFlag Varchar(20) = NULL
				,@OperationFlag Int=0
				,@Result Int=0 OutPut

As

SET DATEFORMAT DMY

IF (@OperationFlag=2)

BEGIN

Update Pro.ACCOUNTCAL Set 
FirstDtOfDisb = @FirstDtOfDisb
,ProductAlt_Key = @ProductAlt_Key
,Balance = @Balance
,DrawingPower = @DrawingPower
,CurrentLimit = @CurrentLimit
,ContiExcessDt =Convert(Varchar(20),@ContiExcessDt,103)
,StockStDt = COnvert(Varchar(20),@StockStDt,103)
,DebitSinceDt = Convert(Varchar(20),@DebitSinceDt,103)
,LastCrDate = Convert(Varchar(20),@LastCrDate,103)
,CurQtrCredit = @CurQtrCredit
,CurQtrInt = @CurQtrInt
--,InttServiced = @InttServiced
--,IntNotServicedDt = Convert(Varchar(20),@IntNotServicedDt,103)
,OverDueSinceDt = Convert(Varchar(20),@OverDueSinceDt,103)
,ReviewDueDt = Convert(Varchar(20),@ReviewDueDt,103)
--,SecurityValue = @SecurityValue
,DFVAmt = @DFVAmt
,GovtGtyAmt = @GovtGtyAmt
,WriteOffAmount = @WriteOffAmount
,UnAdjSubSidy = @UnAdjSubSidy
,Asset_Norm = @Asset_Norm
,AddlProvision = @AddlProvision
,PrincOverdueSinceDt = Convert(Varchar(20),@PrincOverdueSinceDt,103)
,IntOverdueSinceDt = Convert(Varchar(20),@IntOverdueSinceDt,103)
,OtherOverdueSinceDt = Convert(Varchar(20),@OtherOverdueSinceDt,103)
,RepossessionDate = Convert(Varchar(20),@RepossessionDate,103)
,UnserviedInt = @UnserviedInt
,AdvanceRecovery = @AdvanceRecovery
,RePossession = @RePossession
,RCPending = @RCPending
,PaymentPending = @PaymentPending
,WheelCase = @WheelCase
,RFA = @RFA
,IsNonCooperative = @IsNonCooperative
,Sarfaesi = @Sarfaesi
,WeakAccount = @WeakAccount

From Pro.ACCOUNTCAL
Where CustomerAcID=@CustomerAcid


Update A set A.PrvQtrRV=@PrvQtrRV,A.CurntQtrRv=@CurntQtrRv,A.FraudDt=Convert(Varchar(20),@FraudDt,103)
,A.SplCatg1Alt_Key =( Case When @FraudFlag='Y' Then 870 end)
--Select * 
from Pro.CustomerCal A
Inner JOin Pro.AccountCal B ON A.Refcustomerid=B.RefcustomerID
Where B.CustomerAcID=@CustomerAcid


Update Pro.ACCOUNTCAL Set 
FirstDtOfDisb = Case when FirstDtOfDisb='1900-01-01' then NULL Else FirstDtOfDisb End
,ContiExcessDt =Case when ContiExcessDt='1900-01-01' then NULL Else ContiExcessDt End
,StockStDt = Case when StockStDt='1900-01-01' then NULL Else StockStDt End
,DebitSinceDt = Case when DebitSinceDt='1900-01-01' then NULL Else DebitSinceDt End
,LastCrDate = Case when LastCrDate='1900-01-01' then NULL Else LastCrDate End

,OverDueSinceDt = Case when OverDueSinceDt='1900-01-01' then NULL Else OverDueSinceDt End
,ReviewDueDt = Case when ReviewDueDt='1900-01-01' then NULL Else ReviewDueDt End

,PrincOverdueSinceDt = Case when PrincOverdueSinceDt='1900-01-01' then NULL Else PrincOverdueSinceDt End
,IntOverdueSinceDt = Case when IntOverdueSinceDt='1900-01-01' then NULL Else IntOverdueSinceDt End
,OtherOverdueSinceDt = Case when OtherOverdueSinceDt='1900-01-01' then NULL Else OtherOverdueSinceDt End
,RepossessionDate = Case when RepossessionDate='1900-01-01' then NULL Else RepossessionDate End


From Pro.ACCOUNTCAL
--Where CustomerAcID=@CustomerAcid



Update A set A.FraudDt=Case when A.FraudDt='1900-01-01' then NULL Else A.FraudDt End
from Pro.CustomerCal A
Inner JOin Pro.AccountCal B ON A.Refcustomerid=B.RefcustomerID
--Where B.CustomerAcID=@CustomerAcid


Set @Result=1

RETURN @Result
--Select @Result

END



GO