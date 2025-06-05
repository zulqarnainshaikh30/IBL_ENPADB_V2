SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO









CREATE PROC [PRO].[InsertIntoCalTablesforDummy]

--@Date as Varchar(20)='2020-09-30'
@Result Int = 0 OutPut
As

BEGIN

SET DATEFORMAT DMY

Declare @Date as Varchar(20)='2020-09-30'

Declare @TimeKey as Int =(Select TimeKey from sysdaymatrix where Cast(Date as Date)=Cast(@Date as Date))


--------------------------Insert into Account Cal


delete  from dbo.TestCaseAccountCalDummyData where RefCustomerID is null

update dbo.TestCaseAccountCalDummyData set ContiExcessDt=NULL            WHERE ContiExcessDt='NULL'
update dbo.TestCaseAccountCalDummyData set StockStDt        =NULL		   WHERE  StockStDt='NULL'
update dbo.TestCaseAccountCalDummyData set DebitSinceDt=NULL			   WHERE DebitSinceDt='NULL'
update dbo.TestCaseAccountCalDummyData set LastCrDate=NULL			   WHERE LastCrDate='NULL'
update dbo.TestCaseAccountCalDummyData set IntNotServicedDt=NULL		   WHERE IntNotServicedDt='NULL'
update dbo.TestCaseAccountCalDummyData set OverDueSinceDt=NULL		   WHERE OverDueSinceDt='NULL'
update dbo.TestCaseAccountCalDummyData set ReviewDueDt=NULL			   WHERE ReviewDueDt='NULL'
update dbo.TestCaseAccountCalDummyData set CreditsinceDt=NULL			   WHERE CreditsinceDt='NULL'
update dbo.TestCaseAccountCalDummyData set InitialNpaDt=NULL			   WHERE InitialNpaDt='NULL'
update dbo.TestCaseAccountCalDummyData set FinalNpaDt=NULL			   WHERE FinalNpaDt='NULL'
update dbo.TestCaseAccountCalDummyData set SMA_Dt=NULL				   WHERE SMA_Dt='NULL'
update dbo.TestCaseAccountCalDummyData set UpgDate=NULL				   WHERE UpgDate='NULL'
update dbo.TestCaseAccountCalDummyData set MOC_Dt=NULL				   WHERE MOC_Dt='NULL'
update dbo.TestCaseAccountCalDummyData set PNPA_DATE=NULL				   WHERE PNPA_DATE='NULL'
update dbo.TestCaseAccountCalDummyData set PrincOverdueSinceDt=NULL	   WHERE PrincOverdueSinceDt='NULL'
update dbo.TestCaseAccountCalDummyData set IntOverdueSinceDt=NULL		   WHERE IntOverdueSinceDt='NULL'
update dbo.TestCaseAccountCalDummyData set OtherOverdueSinceDt=NULL	   WHERE OtherOverdueSinceDt='NULL'
update dbo.TestCaseAccountCalDummyData set CurrentLimitDt=NULL	   WHERE CurrentLimitDt='NULL' 
update dbo.TestCaseAccountCalDummyData set PNPA_DATE=NULL	   WHERE PNPA_DATE=NULL


delete  from dbo.TestCaseAccountCalDummyData where RefCustomerID is null

DELETE FROM PRO.ACCOUNTCAL
INSERT INTO PRO.ACCOUNTCAL

 (
 AccountEntityID
,UcifEntityID
,CustomerEntityID
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,UCIF_ID
,BranchCode
,FacilityType
,AcOpenDt
,FirstDtOfDisb
,ProductAlt_Key
,SchemeAlt_key
,SubSectorAlt_Key
,SplCatg1Alt_Key
,SplCatg2Alt_Key
,SplCatg3Alt_Key
,SplCatg4Alt_Key
,SourceAlt_Key
,ActSegmentCode
,InttRate
,Balance
,BalanceInCrncy
,CurrencyAlt_Key
,DrawingPower
,CurrentLimit
,CurrentLimitDt
,ContiExcessDt
,StockStDt
,DebitSinceDt
,LastCrDate
,PreQtrCredit
,PrvQtrInt
,CurQtrCredit
,CurQtrInt
,InttServiced
,IntNotServicedDt
,OverdueAmt
,OverDueSinceDt
,ReviewDueDt
,SecurityValue
,DFVAmt
,GovtGtyAmt
,CoverGovGur
,WriteOffAmount
,UnAdjSubSidy
,CreditsinceDt
,DPD_IntService
,DPD_NoCredit
,DPD_Overdrawn
,DPD_Overdue
,DPD_Renewal
,DPD_StockStmt
,DPD_Max
,DPD_FinMaxType
,DegReason
,Asset_Norm
,REFPeriodMax
,RefPeriodOverdue
,RefPeriodOverDrawn
,RefPeriodNoCredit
,RefPeriodIntService
,RefPeriodStkStatement
,RefPeriodReview
,NetBalance
,ApprRV
,SecuredAmt
,UnSecuredAmt
,ProvDFV
,Provsecured
,ProvUnsecured
,ProvCoverGovGur
,AddlProvision
,TotalProvision
,BankProvsecured
,BankProvUnsecured
,BankTotalProvision
,RBIProvsecured
,RBIProvUnsecured
,RBITotalProvision
,InitialNpaDt
,FinalNpaDt
,SMA_Dt
,UpgDate
,InitialAssetClassAlt_Key
,FinalAssetClassAlt_Key
,ProvisionAlt_Key
,PNPA_Reason
------,SMA_Class
,SMA_Reason
,FlgMoc
,MOC_Dt
,CommonMocTypeAlt_Key
,DPD_SMA
,FlgDeg
,FlgDirtyRow
,FlgInMonth
,FlgSMA
,FlgPNPA
,FlgUpg
,FlgFITL
,FlgAbinitio
,NPA_Days
,RefPeriodOverdueUPG
,RefPeriodOverDrawnUPG
,RefPeriodNoCreditUPG
,RefPeriodIntServiceUPG
,RefPeriodStkStatementUPG
,RefPeriodReviewUPG
,EffectiveFromTimeKey
,EffectiveToTimeKey
,AppGovGur
,UsedRV
,ComputedClaim
,UPG_RELAX_MSME
,DEG_RELAX_MSME
,PNPA_DATE
,NPA_Reason
,PnpaAssetClassAlt_key
,DisbAmount
,PrincOutStd
,PrincOverdue
,PrincOverdueSinceDt
,DPD_PrincOverdue
,IntOverdue
,IntOverdueSinceDt
,DPD_IntOverdueSince
,OtherOverdue
,OtherOverdueSinceDt
,DPD_OtherOverdueSince
,RelationshipNumber
,AccountFlag
,CommercialFlag_AltKey
,Liability
,CD
,AccountStatus
,AccountBlkCode1
,AccountBlkCode2
,ExposureType
,Mtm_Value
,BankAssetClass
,NpaType
,SecApp
,BorrowerTypeID
,LineCode
,ProvPerSecured
,ProvPerUnSecured
,MOCReason
,AddlProvisionPer
,FlgINFRA
,RepossessionDate
--,DateOfData
,DerecognisedInterest1
,DerecognisedInterest2
,ProductCode
,FlgLCBG
,UnserviedInt
,OriginalBranchcode
,AdvanceRecovery
,NotionalInttAmt
,PrvAssetClassAlt_Key
,MOCTYPE
)

select
 NULL AS  AccountEntityID
,NULL AS  UcifEntityID
,NULL AS CustomerEntityID
,CustomerAcID
,RefCustomerID
,SourceSystemCustomerID
,UCIF_ID
,BranchCode
,FacilityType
,AcOpenDt
,FirstDtOfDisb
,ProductAlt_Key
,SchemeAlt_key
,SubSectorAlt_Key
,NULL AS SplCatg1Alt_Key
,NULL AS SplCatg2Alt_Key
,NULL AS SplCatg3Alt_Key
,NULL AS SplCatg4Alt_Key
,SourceAlt_Key
,ActSegmentCode
,NULL AS InttRate
,Balance
,BalanceInCrncy
,CurrencyAlt_Key
,CASE WHEN DrawingPower='NULL'  OR  DrawingPower='' THEN 0 ELSE (CAST(ISNULL(DrawingPower,0) AS decimal(18,2))) END AS  DrawingPower
,CASE WHEN CurrentLimit='NULL'  OR  CurrentLimit='' THEN 0 ELSE (CAST(ISNULL(CurrentLimit,0) AS decimal(18,2))) END AS CurrentLimit
,CurrentLimitDt AS   CurrentLimitDt
,CASE WHEN ContiExcessDt='NULL'  OR  ContiExcessDt='' THEN NULL ELSE  ContiExcessDt END AS   ContiExcessDt
,CASE WHEN StockStDt='NULL'  OR  StockStDt='' THEN NULL ELSE StockStDt END AS  StockStDt
,CASE WHEN DebitSinceDt='NULL'  OR  DebitSinceDt='' THEN NULL ELSE DebitSinceDt END  AS DebitSinceDt
,CASE WHEN LastCrDate='NULL'  OR  LastCrDate='' THEN NULL ELSE LastCrDate  END AS  LastCrDate
,CASE WHEN PreQtrCredit='NULL'  OR  PreQtrCredit='' THEN 0 ELSE (CAST(ISNULL(PreQtrCredit,0) AS decimal(18,2))) END AS  PreQtrCredit
,CASE WHEN PrvQtrInt='NULL'  OR  PrvQtrInt='' THEN 0 ELSE (CAST(ISNULL(PrvQtrInt,0) AS decimal(18,2))) END AS PrvQtrInt
,CASE WHEN CurQtrCredit='NULL'  OR  CurQtrCredit='' THEN 0 ELSE (CAST(ISNULL(CurQtrCredit,0) AS decimal(18,2)))  END AS CurQtrCredit
,CASE WHEN CurQtrInt='NULL'  OR  CurQtrInt='' THEN 0 ELSE (CAST(ISNULL(CurQtrInt,0) AS decimal(18,2))) END AS CurQtrInt
,CASE WHEN InttServiced='Y' THEN 'Y' ELSE 'N'  END AS  InttServiced
,CASE WHEN IntNotServicedDt='NULL'  OR  IntNotServicedDt='' THEN NULL ELSE IntNotServicedDt  END AS IntNotServicedDt
,CASE WHEN OverdueAmt='NULL'  OR  OverdueAmt='' THEN 0 ELSE (CAST(ISNULL(OverdueAmt,0) AS decimal(18,2))) END AS   OverdueAmt
,OverDueSinceDt  AS OverDueSinceDt
,CASE WHEN ReviewDueDt='NULL'  OR  ReviewDueDt='' THEN NULL ELSE ReviewDueDt END AS ReviewDueDt
,SecurityValue
,DFVAmt
,GovtGtyAmt
,CoverGovGur
,WriteOffAmount
,UnAdjSubSidy
,CASE WHEN CreditsinceDt='NULL'  OR  CreditsinceDt='' THEN NULL ELSE CreditsinceDt END AS CreditsinceDt
,CASE WHEN DPD_IntService='NULL'  OR  DPD_IntService='' THEN 0 ELSE (CAST(ISNULL(DPD_IntService,0) AS decimal(18,2))) END AS  DPD_IntService
,CASE WHEN DPD_NoCredit='NULL'  OR  DPD_NoCredit='' THEN 0 ELSE (CAST(ISNULL(DPD_NoCredit,0) AS decimal(18,2))) END AS  DPD_NoCredit
,CASE WHEN DPD_Overdrawn='NULL'  OR  DPD_Overdrawn='' THEN 0 ELSE (CAST(ISNULL(DPD_Overdrawn,0) AS decimal(18,2))) END AS DPD_Overdrawn
,CASE WHEN DPD_Overdue='NULL'  OR  DPD_Overdue='' THEN 0 ELSE (CAST(ISNULL(DPD_Overdue,0) AS decimal(18,2))) END AS   DPD_Overdue
,CASE WHEN DPD_Renewal='NULL'  OR  DPD_Renewal='' THEN 0 ELSE (CAST(ISNULL(DPD_Renewal,0) AS decimal(18,2))) END AS   DPD_Renewal
,CASE WHEN DPD_StockStmt='NULL'  OR  DPD_StockStmt='' THEN 0 ELSE (CAST(ISNULL(DPD_StockStmt,0) AS decimal(18,2))) END AS   DPD_StockStmt
,CASE WHEN DPD_Max='NULL'  OR  DPD_Max='' THEN 0 ELSE (CAST(ISNULL(DPD_Max,0) AS decimal(18,2))) END AS DPD_Max
,DPD_FinMaxType
,DegReason
,Asset_Norm
,REFPeriodMax
,RefPeriodOverdue
,RefPeriodOverDrawn
,RefPeriodNoCredit
,RefPeriodIntService
,RefPeriodStkStatement
,RefPeriodReview
,CASE WHEN NetBalance='NULL'  OR  NetBalance='' THEN 0 ELSE (CAST(ISNULL(NetBalance,0) AS decimal(18,2))) END AS NetBalance
,ApprRV  AS ApprRV
,SecuredAmt AS SecuredAmt
,UnSecuredAmt AS UnSecuredAmt
,ProvDFV AS ProvDFV
,Provsecured AS Provsecured
,ProvUnsecured  AS ProvUnsecured
,CASE WHEN ProvCoverGovGur='NULL'  OR  ProvCoverGovGur='' THEN 0 ELSE (CAST(ISNULL(ProvCoverGovGur,0) AS decimal(18,2))) END AS ProvCoverGovGur
,AddlProvision AS  AddlProvision
,TotalProvision AS TotalProvision
,BankProvsecured AS BankProvsecured
,BankProvUnsecured AS BankProvUnsecured
,BankTotalProvision AS BankTotalProvision
,RBIProvsecured AS RBIProvsecured
,CASE WHEN RBIProvUnsecured='NULL'  OR  RBIProvUnsecured='' THEN 0 ELSE (CAST(ISNULL(RBIProvUnsecured,0) AS decimal(18,2))) END AS RBIProvUnsecured
,CASE WHEN RBITotalProvision='NULL'  OR  RBITotalProvision='' THEN 0 ELSE (CAST(ISNULL(RBITotalProvision,0) AS decimal(18,2))) END AS RBITotalProvision
,CASE WHEN InitialNpaDt='NULL'  OR  InitialNpaDt='' THEN NULL ELSE InitialNpaDt END AS  InitialNpaDt
,FinalNpaDt AS   FinalNpaDt
,CASE WHEN SMA_Dt='NULL'  OR  SMA_Dt='' THEN NULL ELSE CONVERT(Date,SMA_Dt, 103) END AS  SMA_Dt
,CASE WHEN UpgDate='NULL'  OR  UpgDate='' THEN NULL ELSE CONVERT(Date,UpgDate, 103) END AS  UpgDate
,InitialAssetClassAlt_Key
,FinalAssetClassAlt_Key
,ProvisionAlt_Key
,PNPA_Reason
------,SMA_Class
,SMA_Reason
,CASE WHEN FlgMoc='Y' THEN 'Y' ELSE 'N'  END AS FlgMoc
,CASE WHEN MOC_Dt='NULL'  OR  MOC_Dt='' THEN NULL ELSE CONVERT(Date,MOC_Dt, 103) END AS MOC_Dt
,CASE WHEN CommonMocTypeAlt_Key='NULL'  OR  CommonMocTypeAlt_Key='' THEN 0 ELSE (CAST(ISNULL(CommonMocTypeAlt_Key,0) AS decimal(18,2))) END AS  CommonMocTypeAlt_Key
,CASE WHEN DPD_SMA='NULL'  OR  DPD_SMA='' THEN 0 ELSE (CAST(ISNULL(DPD_SMA,0) AS decimal(18,2))) END AS DPD_SMA
,FlgDeg
,'N' AS FlgDirtyRow
,'N' AS FlgInMonth
,CASE WHEN FlgSMA='Y' THEN 'Y' ELSE 'N' END AS FlgSMA
,CASE WHEN FlgPNPA='Y' THEN 'Y' ELSE 'N'  END AS FlgPNPA
,CASE WHEN FlgUpg='Y' THEN 'Y' ELSE 'N'  END AS FlgUpg
,CASE WHEN FlgFITL='Y' THEN 'Y' ELSE 'N'  END AS FlgFITL
,CASE WHEN FlgAbinitio='Y' THEN 'Y' ELSE 'N'  END AS FlgAbinitio
,CASE WHEN NPA_Days='NULL'  OR  NPA_Days='' THEN 0 ELSE (CAST(ISNULL(NPA_Days,0) AS decimal(18,0))) END AS NPA_Days
,RefPeriodOverdueUPG
,RefPeriodOverDrawnUPG
,RefPeriodNoCreditUPG
,RefPeriodIntServiceUPG
,RefPeriodStkStatementUPG
,RefPeriodReviewUPG
,@TimeKey EffectiveFromTimeKey
,@TimeKey EffectiveToTimeKey
,CASE WHEN AppGovGur='NULL'  OR  AppGovGur='' THEN 0 ELSE (CAST(ISNULL(AppGovGur,0) AS decimal(18,0))) END AS AppGovGur
,UsedRV AS UsedRV
,NULL AS ComputedClaim
,'N' AS UPG_RELAX_MSME
,'N' AS DEG_RELAX_MSME
,PNPA_DATE AS   PNPA_DATE
,NPA_Reason
,PnpaAssetClassAlt_key
,CASE WHEN DisbAmount='NULL'  OR  DisbAmount='' THEN 0 ELSE (CAST(ISNULL(DisbAmount,0) AS decimal(18,0))) END AS  DisbAmount
,CASE WHEN PrincOutStd='NULL'  OR  PrincOutStd='' THEN 0 ELSE (CAST(ISNULL(PrincOutStd,0) AS decimal(18,0))) END AS  PrincOutStd
,CASE WHEN PrincOverdue='NULL'  OR  PrincOverdue='' THEN 0 ELSE (CAST(ISNULL(PrincOverdue,0) AS decimal(18,0))) END AS  PrincOverdue
,CASE WHEN PrincOverdueSinceDt='NULL'  OR  PrincOverdueSinceDt='' THEN NULL ELSE CONVERT(Date,PrincOverdueSinceDt, 103) END AS  PrincOverdueSinceDt
,CASE WHEN DPD_PrincOverdue='NULL'  OR  DPD_PrincOverdue='' THEN 0 ELSE (CAST(ISNULL(DPD_PrincOverdue,0) AS decimal(18,0))) END AS  DPD_PrincOverdue
,CASE WHEN IntOverdue='NULL'  OR  IntOverdue='' THEN 0 ELSE (CAST(ISNULL(IntOverdue,0) AS decimal(18,0))) END AS  IntOverdue
,CASE WHEN IntOverdueSinceDt='NULL'  OR  IntOverdueSinceDt='' THEN NULL ELSE CONVERT(Date,IntOverdueSinceDt, 103) END AS  IntOverdueSinceDt
,CASE WHEN DPD_IntOverdueSince='NULL'  OR  DPD_IntOverdueSince='' THEN 0 ELSE (CAST(ISNULL(DPD_IntOverdueSince,0) AS decimal(18,0))) END AS  DPD_IntOverdueSince
,CASE WHEN OtherOverdue='NULL'  OR  OtherOverdue='' THEN 0 ELSE (CAST(ISNULL(OtherOverdue,0) AS decimal(18,0))) END AS  OtherOverdue
,CASE WHEN OtherOverdueSinceDt='NULL'  OR  OtherOverdueSinceDt='' THEN NULL ELSE CONVERT(Date,OtherOverdueSinceDt, 103) END AS OtherOverdueSinceDt
,CASE WHEN DPD_OtherOverdueSince='NULL'  OR  DPD_OtherOverdueSince='' THEN 0 ELSE (CAST(ISNULL(DPD_OtherOverdueSince,0) AS decimal(18,0))) END AS   DPD_OtherOverdueSince
,RelationshipNumber
,AccountFlag
,CASE WHEN CommercialFlag_AltKey='NULL'  OR  CommercialFlag_AltKey='' THEN 0 ELSE (CAST(ISNULL(CommercialFlag_AltKey,0) AS decimal(18,0))) END AS  CommercialFlag_AltKey
,Liability
,CD
,AccountStatus
,AccountBlkCode1
,AccountBlkCode2
,ExposureType
,CASE WHEN Mtm_Value='NULL'  OR  Mtm_Value='' THEN 0 ELSE (CAST(ISNULL(Mtm_Value,0) AS decimal(18,0))) END  AS Mtm_Value
,BankAssetClass
,NpaType
,SecApp
,CASE WHEN BorrowerTypeID='NULL'  OR  BorrowerTypeID='' THEN NULL ELSE (CAST(ISNULL(BorrowerTypeID,0) AS decimal(18,0))) END  AS BorrowerTypeID
,LineCode
,CASE WHEN ProvPerSecured='NULL'  OR  ProvPerSecured='' THEN 0 ELSE (CAST(ISNULL(ProvPerSecured,0) AS decimal(18,2))) END AS ProvPerSecured
,CASE WHEN ProvPerUnSecured='NULL'  OR  ProvPerUnSecured='' THEN 0 ELSE (CAST(ISNULL(ProvPerUnSecured,0) AS decimal(18,2))) END AS ProvPerUnSecured
,MOCReason
,CASE WHEN AddlProvisionPer='NULL'  OR  AddlProvisionPer='' THEN 0 ELSE (CAST(ISNULL(AddlProvisionPer,0) AS decimal(18,2))) END AS AddlProvisionPer
,CASE WHEN FlgINFRA='Y' THEN 'Y' ELSE 'N'  END AS FlgINFRA
,NULL AS RepossessionDate
--,NULL AS DateOfData
,NULL AS DerecognisedInterest1
,NULL AS DerecognisedInterest2
,ProductCode
,CASE WHEN FlgLCBG='Y' THEN 'Y' ELSE 'N'  END AS FlgLCBG
,CASE WHEN UnserviedInt='NULL'  OR  UnserviedInt='' THEN 0 ELSE (CAST(ISNULL(UnserviedInt,0) AS decimal(18,2))) END AS UnserviedInt
,OriginalBranchcode
,CASE WHEN AdvanceRecovery='NULL'  OR  AdvanceRecovery='' THEN 0 ELSE (CAST(ISNULL(AdvanceRecovery,0) AS decimal(18,2))) END AS AdvanceRecovery
,CASE WHEN NotionalInttAmt='NULL'  OR  NotionalInttAmt='' THEN 0 ELSE (CAST(ISNULL(NotionalInttAmt,0) AS decimal(18,2))) END AS NotionalInttAmt
,CASE WHEN PrvAssetClassAlt_Key='NULL'  OR  NotionalInttAmt='' THEN NULL ELSE (CAST(ISNULL(PrvAssetClassAlt_Key,0) AS decimal(18,2))) END AS PrvAssetClassAlt_Key
,MOCTYPE
 from dbo.TestCaseAccountCalDummyData
 
 
 
 
UPDATE PRO.ACCOUNTCAL SET CustomerEntityID=UCIF_ID,AccountEntityID=CUSTOMERACID,DPD_IntService=0,	DPD_NoCredit=0,	DPD_Overdrawn	=0,
DPD_Overdue=0,	DPD_Renewal	=0,DPD_StockStmt=0,	DPD_Max=0,DPD_FinMaxType=NULL,
DegReason=NULL,ProvisionAlt_Key=0,SMA_Class=NULL,NPA_Reason=NULL, PnpaAssetClassAlt_key=1

update PRO.ACCOUNTCAL set FinalAssetClassAlt_Key=1,FlgDeg='N' where FlgDeg='Y'
update PRO.ACCOUNTCAL set FinalAssetClassAlt_Key=InitialAssetClassAlt_Key,flgupg='N' ,FinalNpaDt=InitialNpaDt where flgupg='y'

--UPDATE PRO.ACCOUNTCAL SET CustomerEntityID=UCIF_ID,AccountEntityID=CUSTOMERACID,DPD_IntService=0,	DPD_NoCredit=0,	DPD_Overdrawn	=0,
--DPD_Overdue=0,	DPD_Renewal	=0,DPD_StockStmt=0,	DPD_Max=0,DPD_FinMaxType=NULL,DegReason=NULL,ProvisionAlt_Key=0,SMA_Class=NULL,FlgDeg='N',NPA_Reason=NULL, PnpaAssetClassAlt_key=1

update pro.ACCOUNTCAL set RefPeriodOverdueUPG=0,RefPeriodOverDrawnUPG=0,RefPeriodNoCreditUPG=30,
RefPeriodIntServiceUPG=0,RefPeriodStkStatementUPG=90,RefPeriodReviewUPG=90
update pro.accountcal set FinalNpaDt=null where  FinalAssetClassAlt_Key=1

update pro.accountcal set SMA_Dt=NULL,FlgPNPA='N',PNPA_DATE=NULL,FlgSMA='N'


------------------------------ End Account Cal --------------------------

----------------------------------- Insert into Customer Cal ------------------------------


delete  from dbo.TestCaseCustomerCalDummyData where RefCustomerID is null
DELETE FROM PRO.CUSTOMERCAL
INSERT INTO PRO.CUSTOMERCAL

 (
 BranchCode
,UCIF_ID
,UcifEntityID
,CustomerEntityID
,ParentCustomerID

,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,CustSegmentCode
,ConstitutionAlt_Key
,PANNO
,AadharCardNO
,SrcAssetClassAlt_Key
,SysAssetClassAlt_Key
,SplCatg1Alt_Key
,SplCatg2Alt_Key
,SplCatg3Alt_Key
,SplCatg4Alt_Key
,SMA_Class_Key
,PNPA_Class_Key
,PrvQtrRV
,CurntQtrRv
,TotProvision
,RBITotProvision
,BankTotProvision
,SrcNPA_Dt
,SysNPA_Dt
,DbtDt
,DbtDt2
,DbtDt3
,LossDt
,MOC_Dt
,ErosionDt
,SMA_Dt
,PNPA_Dt
--,ProcessingDt
,Asset_Norm
,FlgDeg
,FlgUpg
,FlgMoc
,FlgSMA
,FlgProcessing
,FlgErosion
,FlgPNPA
,FlgPercolation
,FlgInMonth
,FlgDirtyRow
,DegDate
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CommonMocTypeAlt_Key
,InMonthMark
,MocStatusMark
,SourceAlt_Key
,BankAssetClass
,Cust_Expo
,MOCReason
,AddlProvisionPer
,FraudDt
,FraudAmount
,DegReason
--,DateOfData
,CustMoveDescription
,TotOsCust
,MOCTYPE
)
select
branchCode
,UCIF_ID
,NULL AS UcifEntityID
,NULL AS CustomerEntityID
,ParentCustomerID
,RefCustomerID
,SourceSystemCustomerID
,CustomerName
,CustSegmentCode
,ConstitutionAlt_Key
,PANNO
,AadharCardNO
,SrcAssetClassAlt_Key
,SysAssetClassAlt_Key
,SplCatg1Alt_Key
,SplCatg2Alt_Key
,SplCatg3Alt_Key
,SplCatg4Alt_Key
,CASE WHEN SMA_Class_Key='NULL'  OR  SMA_Class_Key='' THEN '' ELSE SMA_Class_Key END AS SMA_Class_Key
,CASE WHEN PNPA_Class_Key='NULL'  OR  PNPA_Class_Key='' THEN '' ELSE PNPA_Class_Key END AS PNPA_Class_Key
,CASE WHEN PrvQtrRV='NULL'  OR  PrvQtrRV='' THEN NULL ELSE (CAST(ISNULL(PrvQtrRV,0) AS decimal(18,2))) END AS  PrvQtrRV
,CASE WHEN CurntQtrRv='NULL'  OR  CurntQtrRv='' THEN NULL ELSE (CAST(ISNULL(CurntQtrRv,0) AS decimal(18,2))) END AS CurntQtrRv
,TotProvision
,RBITotProvision
,BankTotProvision
,CASE WHEN SrcNPA_Dt='NULL'  OR  SrcNPA_Dt='' THEN NULL ELSE SrcNPA_Dt END AS SrcNPA_Dt
,CASE WHEN SysNPA_Dt='NULL'  OR  SysNPA_Dt='' THEN NULL ELSE SysNPA_Dt END AS SysNPA_Dt
,CASE WHEN DbtDt='NULL'  OR  DbtDt='' THEN NULL ELSE DbtDt END AS  DbtDt
,NULL AS   DbtDt2
,NULL AS  DbtDt3
,CASE WHEN LossDt='NULL'  OR  LossDt='' THEN NULL ELSE LossDt END AS  LossDt
,CASE WHEN MOC_Dt='NULL'  OR  MOC_Dt='' THEN NULL ELSE CONVERT(Date,MOC_Dt, 103) END AS  MOC_Dt
,CASE WHEN ErosionDt='NULL'  OR  ErosionDt='' THEN NULL ELSE ErosionDt END AS  ErosionDt
,CASE WHEN SMA_Dt='NULL'  OR  SMA_Dt='' THEN NULL ELSE CONVERT(Date,SMA_Dt, 103) END AS  SMA_Dt
,CASE WHEN PNPA_Dt='NULL'  OR  PNPA_Dt='' THEN NULL ELSE PNPA_Dt END AS    PNPA_Dt
--,ProcessingDt AS  ProcessingDt
,Asset_Norm
,FlgDeg
,FlgUpg
,FlgMoc
,'N' FlgSMA
,FlgProcessing
,FlgErosion
,FlgPNPA
,FlgPercolation
,'N' FlgInMonth
,'N' FlgDirtyRow
,NULL AS DegDate
,@TimeKey EffectiveFromTimeKey
,@TimeKey EffectiveToTimeKey
,NULL AS CommonMocTypeAlt_Key
,'N' InMonthMark
,NULL AS MocStatusMark
,1 SourceAlt_Key
,BankAssetClass
,CASE WHEN Cust_Expo='NULL'  OR  Cust_Expo='' THEN NULL ELSE (CAST(ISNULL(Cust_Expo,0) AS decimal(18,2))) END AS  Cust_Expo
,MOCReason
,CASE WHEN AddlProvisionPer='NULL'  OR  AddlProvisionPer='' THEN NULL ELSE (CAST(ISNULL(AddlProvisionPer,0) AS decimal(18,2))) END AS AddlProvisionPer
,CASE WHEN FraudDt='NULL'  OR  FraudDt='' THEN NULL ELSE FraudDt END AS FraudDt
,CASE WHEN FraudAmount='NULL'  OR  FraudAmount='' THEN NULL ELSE (CAST(ISNULL(FraudAmount,0) AS decimal(18,2))) END AS  FraudAmount
,DegReason
--,CASE WHEN DateOfData='NULL'  OR  DateOfData='' THEN NULL ELSE DateOfData END AS DateOfData
,CustMoveDescription
,CASE WHEN TotOsCust='NULL'  OR  TotOsCust='' THEN NULL ELSE (CAST(ISNULL(TotOsCust,0) AS decimal(18,2))) END AS   TotOsCust
,MOCTYPE
 from dbo.TestCaseCustomerCalDummyData 

 
UPDATE PRO.CUSTOMERCAL SET CustomerEntityID=UCIF_ID
UPDATE PRO.CUSTOMERCAL SET SysAssetClassAlt_Key=1, SysNPA_Dt=NULL,FlgDeg='N',DegReason=NULL,CustMoveDescription=NULL

update PRO.CUSTOMERCAL set SysNPA_Dt=SrcNPA_Dt,SysAssetClassAlt_Key=SrcAssetClassAlt_Key,flgupg='N' 
where flgupg='y'


UPDATE  PRO.CUSTOMERCAL  SET  DbtDt=NULL



-------Added  01/12/2020
Update PRO.CUSTOMERCAL set SysAssetClassAlt_Key=SrcAssetClassAlt_Key from pro.CUSTOMERCAL where FlgDeg='N' and SysAssetClassAlt_Key<>1 and SysAssetClassAlt_Key<>2 and srcAssetClassAlt_Key=2
Update PRO.CUSTOMERCAL set SysAssetClassAlt_Key=SrcAssetClassAlt_Key  where CustomerName='Existing NPA: DB(1/2/3)-LOS: CurrQtrSec is less than Balance and erosion is more than 90%-NewLogic'

Update PRO.CUSTOMERCAL  set SysNPA_Dt=null where SysAssetClassAlt_Key=1


UPDATE PRO.CUSTOMERCAL SET PANNO=NULL where PANNO ='NULL'

TRUNCATE TABLE CURDAT.ADVACBASICDETAIL


 DECLARE @EntityKeyMaxId AS bigINT SET @EntityKeyMaxId=(SELECT  ISNULL(Max(Ac_Key),0)
  FROM CURDAT.ADVACBASICDETAIL)

INSERT INTO CURDAT.ADVACBASICDETAIL
(
Ac_Key
,BranchCode
,AccountEntityId
,CustomerEntityId
,SystemACID
,CustomerACID
,GLAlt_Key
,ProductAlt_Key
,GLProductAlt_Key
,FacilityType
,SectorAlt_Key
,SubSectorAlt_Key
,ActivityAlt_Key
,IndustryAlt_Key
,SchemeAlt_Key
,DistrictAlt_Key
,AreaAlt_Key
,VillageAlt_Key
,StateAlt_Key
,CurrencyAlt_Key
,OriginalSanctionAuthAlt_Key
,OriginalLimitRefNo
,OriginalLimit
,OriginalLimitDt
,DtofFirstDisb
,FlagReliefWavier
,UnderLineActivityAlt_Key
,MicroCredit
,ScrCrError
,AdjDt
,AdjReasonAlt_Key
,MarginType
,Pref_InttRate
,CurrentLimitRefNo
,GuaranteeCoverAlt_Key
,AccountName
,AssetClass
,JointAccount
,LastDisbDt
,ScrCrErrorBackup
,AccountOpenDate
,Ac_LADDt
,Ac_DocumentDt
,CurrentLimit
,InttTypeAlt_Key
,InttRateLoadFactor
,Margin
,CurrentLimitDt
,Ac_DueDt
,DrawingPowerAlt_Key
,RefCustomerId
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,D2Ktimestamp
,MocStatus
,MocDate
,MocTypeAlt_Key
,IsLAD
,FincaleBasedIndustryAlt_key
,AcCategoryAlt_Key
,OriginalSanctionAuthLevelAlt_Key
,AcTypeAlt_Key
,ScrCrErrorSeq
,BSRUNID
,AdditionalProv
,AclattestDevelopment
,SourceAlt_Key
,LoanSeries
,LoanRefNo
,SecuritizationCode
,Full_Disb
,OriginalBranchcode
,ProjectCost
,FlgSecured
,segmentcode
,ReferencePeriod
)
SELECT 
@EntityKeyMaxId + ROW_NUMBER () OVER ( ORDER BY AccountEntityId) AS Ac_Key
,BranchCode
,AccountEntityId
,CustomerEntityId
,CustomerAcID AS SystemACID
,CustomerACID
,NULL GLAlt_Key
,ProductAlt_Key
,NULL AS GLProductAlt_Key
,FacilityType
,0 SectorAlt_Key
,0 SubSectorAlt_Key
,0 ActivityAlt_Key
,0 IndustryAlt_Key
,SchemeAlt_Key
,0 DistrictAlt_Key
,0 AreaAlt_Key
,0 VillageAlt_Key
,0 StateAlt_Key
,CurrencyAlt_Key
,NULL OriginalSanctionAuthAlt_Key
,NULL OriginalLimitRefNo
,NULL OriginalLimit
,NULL OriginalLimitDt
,NULL DtofFirstDisb
,NULL FlagReliefWavier
,NULL UnderLineActivityAlt_Key
,NULL MicroCredit
,NULL ScrCrError
,NULL AdjDt
,NULL AdjReasonAlt_Key
,NULL MarginType
,NULL Pref_InttRate
,NULL CurrentLimitRefNo
,NULL GuaranteeCoverAlt_Key
,NULL AccountName
,NULL AS AssetClass
,NULL AS JointAccount
,NULL AS LastDisbDt
,NULL AS ScrCrErrorBackup
,NULL AS AccountOpenDate
,NULL AS Ac_LADDt
,NULL AS Ac_DocumentDt
,NULL AS CurrentLimit
,NULL AS InttTypeAlt_Key
,NULL AS InttRateLoadFactor
,NULL AS Margin
,NULL AS CurrentLimitDt
,NULL AS Ac_DueDt
,NULL AS DrawingPowerAlt_Key
,RefCustomerId
,NULL AS AuthorisationStatus
,EffectiveFromTimeKey
,49999 AS EffectiveToTimeKey
,NULL AS CreatedBy
,NULL AS DateCreated
,NULL AS ModifiedBy
,NULL AS DateModified
,NULL AS ApprovedBy
,NULL AS DateApproved
,GETDATE() AS D2Ktimestamp
,NULL AS MocStatus
,NULL AS MocDate
,NULL AS MocTypeAlt_Key
,NULL AS IsLAD
,NULL AS FincaleBasedIndustryAlt_key
,NULL AS AcCategoryAlt_Key
,NULL AS OriginalSanctionAuthLevelAlt_Key
,NULL AS AcTypeAlt_Key
,NULL AS ScrCrErrorSeq
,NULL AS BSRUNID
,NULL AS AdditionalProv
,NULL AS AclattestDevelopment
,SourceAlt_Key
,NULL AS LoanSeries
,NULL AS LoanRefNo
,NULL AS SecuritizationCode
,NULL AS Full_Disb
,NULL AS OriginalBranchcode
,NULL AS ProjectCost
,NULL AS FlgSecured
,NULL AS segmentcode
,NULL AS ReferencePeriod
FROM PRO.ACCOUNTCAL



-----------------------------End of Customer Cal

Select 'Y' as Flag

Set @Result=1

RETURN @Result



END



GO