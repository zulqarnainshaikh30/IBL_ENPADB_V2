SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


create proc [dbo].[ADHOC_MOC_Report] --'01/01/2021','15/04/2023'
(
@FromDate Varchar(10),
 @ToDate Varchar(10)
)
AS

BEGIN

--Declare @FromDate Varchar(10)= '01/01/2021'
--Declare @ToDate Varchar(10)= '15/04/2023'

set @FromDate= Convert(DATE,@FromDate,105)
set @ToDate= Convert(DATE,@ToDate,105)

IF OBJECT_ID('TEMPDB..#TEMP1') IS NOT NULL
		DROP TABLE #TEMP1

--select Timekey,date,ROW_NUMBER() over (order by Timekey) rn INTO #TEMP1 from Automate_Advances
--where date >=@FromDate and date <=@ToDate
--order by 1
select      Timekey,date,ROW_NUMBER() over (order by Timekey) rn INTO #TEMP1 
from        Automate_Advances a
inner join  AdhocACL_ChangeDetails b
on          a.Timekey=b.EffectiveFromTimeKey
where cast(b.DateCreated as date) >=@FromDate and cast(b.DateCreated as date) <=@ToDate
order by 1

IF OBJECT_ID('TEMPDB..#temp') IS NOT NULL
		DROP TABLE #temp

Create table #temp
(
--SrNo int,
Moc_Status varchar(20),
CurrentProcessingDate Varchar(20),
SourceName Varchar(100),
CustomerAcID Varchar(40),--5
CustomerID Varchar(40),
CustomerName Varchar(100),
UCIF_ID Varchar(40),
FacilityType Varchar(100),
PANNo varchar(100),--10
AadharCardNo Varchar(20),
InitialNpaDt Varchar(20),
InitialAssetClassAlt_Key int,
InitalAssetClassName varchar(20),
FirstDtOfDisb varchar(20),--15
ProductAlt_Key int,
ProductName varchar(100),
Balance     decimal(16,2) ,
PrincOutStd decimal(16,2) ,
PrincOverdue decimal(16,2) , --20
IntOverdue  decimal(16,2) ,
DrawingPower decimal(16,2), 
CurrentLimit decimal(16,2), 
ContiExcessDt varchar(20), 
StockStDt  	varchar(20) ,--25
DebitSinceDt varchar(20), 
LastCrDate   varchar(20),
CurQtrCredit decimal(16,2), 
CurQtrInt  decimal(16,2)	 ,
InttServiced decimal(16,2),--30
IntNotServicedDt varchar(20),
OverDueSinceDt   varchar(20),
ReviewDueDt  	varchar(20) ,
SecurityValue  decimal(16,2)	 ,
DFVAmt  	decimal(16,2)	 ,--35
GovtGtyAmt  decimal(16,2)	 ,
WriteOffAmount  decimal(16,2) ,
UnAdjSubSidy  	 varchar(20),
Asset_Norm     varchar(20)  ,
AddlProvision   decimal(16,2)   ,--40
PrincOverDueSinceDt varchar(20), 
IntOverDueSinceDt  varchar(20),
OtherOverDueSinceDt varchar(20), 
UnserviedInt  	decimal(16,2)   ,
AdvanceRecovery  decimal(16,2)  ,--45
RePossession decimal(16,2),
RepossessionDate decimal(16,2),
 RCPending     varchar(100)   ,
 PaymentPending  varchar(100) ,
 WheelCase  	varchar(20)  ,--50
 RFA  		varchar(20)	  ,
 IsNonCooperative varchar(20), 
 Sarfaesi  		varchar(20)  ,
 SarfaesiDate  varchar(20),
 InherentWeakness varchar(20) ,--55
 InherentWeaknessDate varchar(20),
 FlgFITL				varchar(20)	,
 FlgRestructure  		varchar(20)	,
 RestructureDate  		varchar(20)	,
 FlgUnusualBounce  		varchar(20)	,--60
  UnusualBounceDate  	varchar(20)	,
 FlgUnClearedEffect  	varchar(20)	,
  UnClearedEffectDate   varchar(20)    ,                
-------OutPut-----  		,
 CoverGovGur  			decimal(16,2)	,
 DegReason           varchar(100)       ,  --65
  NetBalance  	decimal(16,2)			,
  ApprRV  		decimal(16,2)			,
  SecuredAmt  	decimal(16,2)			,
 UnSecuredAmt  	decimal(16,2)			,
 ProvDFV  		decimal(16,2)			,--70
 Provsecured  	decimal(16,2)			,
 ProvUnsecured  decimal(16,2)			,
 ProvCoverGovGur  decimal(16,2)			,
 TotalProvision  	decimal(16,2)		,
 BankTotalProvision  decimal(16,2)		,--75
 RBITotalProvision  	decimal(16,2)	,
 FinalNpaDt  		varchar(20)		,
 DoubtfulDt  	varchar(20)			,
 UpgDate  			varchar(20)		,
 FinalAssetClassAlt_Key  int	,--80
  FinalAssetClassName  	varchar(20)	,
 NPA_Reason  		varchar(100)		,
 FlgDeg  				varchar(20)	,
 FlgUpg  				varchar(20)	,
 FinalProvisiONPer  	decimal(16,2)	,--85
 FlgSMA  		varchar(20)			,
  SMA_Dt  	varchar(20)				,
 SMA_Class  		varchar(20)		,
 SMA_Reason  			varchar(100)	,
 FlgPNPA  			varchar(20)		,--90
  PNPA_DATE  		varchar(20)		,
 PNPA_Reason  		varchar(100)		,
  CustSMAStatus  		varchar(100)	,
 MOC_Dt  	varchar(20)				,
 FlgFraud  		varchar(20)			,--95
 FraudDate  varchar(20)				,
  MakerID  		varchar(20)			,
  MakerDate  	varchar(20)			,
 CheckerID  		varchar(20)		,
 CheckerDate  	varchar(20)			,--100
  ReviewerID   		varchar(20)		,
  ReviewerDate  varchar(20)			,
 MOCReason  	varchar(100)			,
  AcBuSegmentCode  		varchar(40)	,
 AcBuSegmentDescription  varchar(100)--105
)




Declare @timekey int

Declare @counter int
set @counter=1

while (@counter <=(select max(rn) from #TEMP1))

BEGIN 

declare @Process_Date date=(select date from #TEMP1 where rn=@counter)
set @timekey =(select timekey from #TEMP1 where rn=@counter)

--------------------------------------------------------------------------------------------------

--Declare @TimeKey int=26477

--set @TimeKey=@TimeKey+1


IF(OBJECT_ID('TEMPDB..#DimAcBuSegment')IS NOT NULL)  
   DROP TABLE #DimAcBuSegment  
  
SELECT   
DENSE_RANK()OVER(PARTITION BY AcBuRevisedSegmentCode ORDER BY AcBuSegmentCode) RN,  
AcBuSegmentCode,  
AcBuRevisedSegmentCode,  
AcBuSegmentDescription   
INTO #DimAcBuSegment  
FROM DimAcBuSegment  
WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey  
  
OPTION(RECOMPILE)  


INSERT INTO #temp
select 
  --ROW_NUMBER()OVER(ORDER BY A.UcifEntityId)                        AS SrNo 
 'Post Moc' Moc_Status   
 ,CONVERT(VARCHAR(20),G.DATE,103)                                  AS CurrentProcessingDate  
 --,ROW_NUMBER()OVER(ORDER BY A.UcifEntityId)                        AS SrNo  
 ---------RefColumns---------  
 ,H.SourceName  
 ,A.CustomerAcID  --5
 ,A.RefCustomerID                                                  AS CustomerID  
 ,B.CustomerName  
 ,A.UCIF_ID  
 ,A.FacilityType  
 ,ISNULL(B.PANNo,'')                                               AS PANNo  --10
 ,B.AadharCardNo  
 ,CONVERT(VARCHAR(20),A.InitialNpaDt,103)                          AS InitialNpaDt  
 ,A.InitialAssetClassAlt_Key  
 --,DA.AssetClassName                                                 AS InitalAssetClassName  
 ,DA.AssetClassSubGroup                                          AS InitalAssetClassName  ---added by Prashant---02052024---  
 ----Edit--------  
 ,CONVERT(VARCHAR(20),A.FirstDtOfDisb,103)                         AS FirstDtOfDisb --15 
 ,A.ProductAlt_Key  
 ,DP.ProductName  
 ,ISNULL(A.Balance,0)                                              AS Balance  
 ,ISNULL(A.PrincOutStd,0)                                          AS PrincOutStd  
 ,ISNULL(A.PrincOverdue,0)                                         AS PrincOverdue  --20
 ,ISNULL(A.IntOverdue,0)                                           AS IntOverdue  
 ,ISNULL(A.DrawingPower,0)                                         AS DrawingPower  
 ,ISNULL(A.CurrentLimit,0)                                         AS CurrentLimit  
 ,CONVERT(VARCHAR(20),A.ContiExcessDt,103)                         AS ContiExcessDt  
 ,CONVERT(VARCHAR(20),A.StockStDt,103)                             AS StockStDt  --25
 ,CONVERT(VARCHAR(20),A.DebitSinceDt,103)                          AS DebitSinceDt  
 ,CONVERT(VARCHAR(20),A.LastCrDate,103)                            AS LastCrDate  
 ,ISNULL(A.CurQtrCredit,0)                                         AS CurQtrCredit  
 ,ISNULL(A.CurQtrInt,0)                                            AS CurQtrInt  
 ,A.InttServiced  --30
 ,CONVERT(VARCHAR(20),A.IntNotServicedDt,103)                      AS IntNotServicedDt  
 ,CONVERT(VARCHAR(20),A.OverDueSinceDt,103)                        AS OverDueSinceDt  
 ,CONVERT(VARCHAR(20),A.ReviewDueDt,103)                           AS ReviewDueDt  
 ,ISNULL(B.CurntQtrRv,0)                                           AS SecurityValue  
 ,ISNULL(A.DFVAmt,0)                                               AS DFVAmt --35 
 ,ISNULL(A.GovtGtyAmt,0)                                           AS GovtGtyAmt  
 ,ISNULL(A.WriteOffAmount,0)                                       AS WriteOffAmount  
 ,ISNULL(A.UnAdjSubSidy,0)                                         AS UnAdjSubSidy  
 ,A.Asset_Norm                    
 ,ISNULL(A.AddlProvision,0)                                        AS AddlProvision --40 
 ,CONVERT(VARCHAR(20),A.PrincOverDueSinceDt,103)                   AS PrincOverDueSinceDt  
 ,CONVERT(VARCHAR(20),A.IntOverDueSinceDt,103)                     AS IntOverDueSinceDt  
 ,CONVERT(VARCHAR(20),A.OtherOverDueSinceDt,103)                   AS OtherOverDueSinceDt  
 ,ISNULL(A.UnserviedInt,0)                                         AS UnserviedInt  
 ,ISNULL(A.AdvanceRecovery,0)                                      AS AdvanceRecovery  --45
 ,A.RePossession  
 ,CONVERT(VARCHAR(20),A.RepossessionDate,103)                      AS RepossessionDate  
 ,A.RCPending  
 ,A.PaymentPending  
 ,A.WheelCase  --50
 ,A.RFA  
 ,A.IsNonCooperative  
 ,A.Sarfaesi  
 ,CONVERT(VARCHAR(20),A.SarfaesiDate,103)                          AS SarfaesiDate  
 ,A.WeakAccount                                                    AS InherentWeakness --55 
 ,CONVERT(VARCHAR(20),A.WeakAccountDate,103)                       AS InherentWeaknessDate  
 ,A.FlgFITL  
 ,A.FlgRestructure  
 ,CONVERT(VARCHAR(20),A.RestructureDate,103)                       AS RestructureDate  
 ,A.FlgUnusualBounce  --60
 ,CONVERT(VARCHAR(20),A.UnusualBounceDate,103)                     AS UnusualBounceDate  
 ,A.FlgUnClearedEffect  
 ,CONVERT(VARCHAR(20),A.UnClearedEffectDate,103)                   AS UnClearedEffectDate                       
-------OutPut-----  
 ,ISNULL(A.CoverGovGur,0)                                          AS CoverGovGur  
 ,A.DegReason                    --65
 ,ISNULL(A.NetBalance,0)                                           AS NetBalance  
 ,ISNULL(A.ApprRV,0)                                               AS ApprRV  
 ,ISNULL(A.SecuredAmt,0)                                           AS SecuredAmt  
 ,ISNULL(A.UnSecuredAmt,0)                                         AS UnSecuredAmt  
 ,ISNULL(A.ProvDFV,0)                                              AS ProvDFV  --70
 ,ISNULL(A.Provsecured,0)                                          AS Provsecured  
 ,ISNULL(A.ProvUnsecured,0)                                        AS ProvUnsecured  
 ,ISNULL(A.ProvCoverGovGur,0)                                      AS ProvCoverGovGur  
 ,ISNULL(A.TotalProvision,0)                                       AS TotalProvision  
 ,ISNULL(A.BankTotalProvision,0)                                   AS BankTotalProvision  --75
 ,ISNULL(A.RBITotalProvision,0)                                    AS RBITotalProvision  
 ,CONVERT(VARCHAR(20),A.FinalNpaDt,103)                            AS FinalNpaDt  
 ,CONVERT(VARCHAR(20),B.DbtDt,103)                                 AS DoubtfulDt  
 ,CONVERT(VARCHAR(20),A.UpgDate,103)                               AS UpgDate  
 ,A.FinalAssetClassAlt_Key  --80
 --,DA1.AssetClassName                                                 AS FinalAssetClassName  
  ,DA1.AssetClassSubGroup                                             AS FinalAssetClassName  ---added by Prashant---02052024---
 ,A.NPA_Reason  
 ,A.FlgDeg  
 ,A.FlgUpg  
 ,A.FinalProvisiONPer  --85
 ,A.FlgSMA  
 ,CONVERT(VARCHAR(20),A.SMA_Dt,103)                                AS SMA_Dt  
 ,A.SMA_Class  
 ,A.SMA_Reason  
 ,A.FlgPNPA  --90
 ,CONVERT(VARCHAR(20),A.PNPA_DATE,103)                             AS PNPA_DATE  
 ,A.PNPA_Reason  
 ,B.CustMoveDescription                                            AS CustSMAStatus  
 --,CONVERT(VARCHAR(20),A.MOC_Dt,103)                                AS MOC_Dt  
 ,CONVERT(VARCHAR(20),G.DATE,103)                                                            AS MOC_Dt  
 ,A.FlgFraud  --95
 ,CONVERT(VARCHAR(20),A.FraudDate,103)                             AS FraudDate  
 ,AC.CreatedBy                              AS MakerID  
 --,AC.DateCreated                         AS MakerDate 
 ,(CONVERT(VARCHAR(10),AC.DateCreated,105) +' '+ CONVERT(VARCHAR,AC.DateCreated,108)) AS MakerDate
 ,AC.FirstLevelApprovedBy        AS CheckerID  
 --,AC.FirstLevelDateApproved     AS CheckerDate  --100
 ,(CONVERT(VARCHAR(10),AC.FirstLevelDateApproved,105) +' '+ CONVERT(VARCHAR,AC.FirstLevelDateApproved,108)) AS CheckerDate
 ,AC.ApprovedBy                           AS ReviewerID   
 --,AC.DateApproved                   AS ReviewerDate  
 ,(CONVERT(VARCHAR(10),AC.DateApproved,105) +' '+ CONVERT(VARCHAR,AC.DateApproved,108)) AS ReviewerDate
 ,DR.ParameterName                                AS MOCReason  
 --,DABS.AcBuRevisedSegmentCode                                      AS AcBuSegmentCode  
 --,DABS.AcBuSegmentDescription  --105
  ,CASE WHEN SourceName='FIS' THEN 'FI'
		  --WHEN SourceName='VisionPlus' THEN 'Credit Card'
		  		  WHEN SourceName='VisionPlus' and a.ProductCode in ('777','780') THEN 'Retail'
		  WHEN SourceName='VisionPlus' and a.ProductCode not in ('777','780') THEN 'Credit Card'
		else DABS.AcBuRevisedSegmentCode end                       AS AcBuSegmentCode 
 --,DABS.AcBuSegmentDescription  
 ,CASE WHEN SourceName='FIS' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else DABS.AcBuSegmentDescription end                        AS AcBuSegmentDescription
 --into #temp
 from pro.ACCOUNTCAL_hist a with(nolock)
 INNER JOIN  PRO.CustomerCal_Hist B ON A.CustomerEntityID=B.CustomerEntityID
                                   AND B.EffectiveFromTimeKey <=@TimeKey and B.EffectiveToTimeKey >=@TimeKey
 INNER JOIN  AdhocACL_ChangeDetails AC ON  AC.CustomerEntityId=B.CustomerEntityID
                               AND AC.EffectiveFromTimeKey <=@TimeKey and AC.EffectiveToTimeKey >=@TimeKey
LEFT JOIN SysDayMatrix G                     ON AC.EffectiveFromTimekey=G.TimeKey 
left join  DIMSOURCEDB H ON   A.SourceAlt_Key=H.SourceAlt_Key


LEFT JOIN    DimAssetClass DA ON   DA.AssetClassAlt_Key=A.InitialAssetClassAlt_Key AND DA.EffectiveToTimeKey=49999
LEFT JOIN    DimAssetClass DA1 ON   DA1.AssetClassAlt_Key=A.FinalAssetClassAlt_Key AND DA1.EffectiveToTimeKey=49999
LEFT JOIN     DimProduct DP ON  DP.ProductAlt_Key=A.ProductAlt_Key AND DP.EffectiveToTimeKey=49999
LEFT JOIN #DimAcBuSegment   DABS              ON A.ActSegmentCode=DABS.AcBuSegmentCode  
                                                 --AND DABS.RN=1  
LEFT JOIN DimParameter DR on DR.ParameterAlt_Key=AC.Reason AND  DR.DimParameterName='DimMoRreason' AND DR.EffectiveToTimeKey=49999
where A.EffectiveFromTimeKey <=@TimeKey and A.EffectiveToTimeKey >=@TimeKey
order by 2


set @counter=@counter+1

END

-------------- REMOVING STARTING AND ENDING COMMAS IN REASONS COLUMNS BY SATWAJI AS ON 15/04/2023 -------------------------
select --SrNo,
	Moc_Status,CurrentProcessingDate,SourceName,CustomerAcID,CustomerID,CustomerName,UCIF_ID,FacilityType,PANNo,AadharCardNo,InitialNpaDt,InitialAssetClassAlt_Key,
	InitalAssetClassName,FirstDtOfDisb,ProductAlt_Key,ProductName,Balance,PrincOutStd,PrincOverdue,IntOverdue,DrawingPower,CurrentLimit,ContiExcessDt,StockStDt,DebitSinceDt,
	LastCrDate,CurQtrCredit,CurQtrInt,InttServiced,IntNotServicedDt,OverDueSinceDt,ReviewDueDt,SecurityValue,DFVAmt,GovtGtyAmt,WriteOffAmount,UnAdjSubSidy,Asset_Norm,
	AddlProvision,PrincOverDueSinceDt,IntOverDueSinceDt,OtherOverDueSinceDt,UnserviedInt,AdvanceRecovery,RePossession,RepossessionDate,RCPending,PaymentPending,WheelCase,
	RFA,IsNonCooperative,Sarfaesi,SarfaesiDate,InherentWeakness,InherentWeaknessDate,FlgFITL,FlgRestructure,RestructureDate,FlgUnusualBounce,UnusualBounceDate,
	FlgUnClearedEffect,UnClearedEffectDate,CoverGovGur
	,CASE WHEN LEFT(DegReason,1)=', ' THEN TRIM(RIGHT(REPLACE(DegReason,',',' & '),LEN(DegReason)-1))
					WHEN RIGHT(DegReason,1)=', ' THEN TRIM(LEFT(REPLACE(DegReason,',',' & '),LEN(DegReason)-1))
				ELSE REPLACE(DegReason,',',' & ') END AS DegReason
	--,DegReason
	,NetBalance,ApprRV,SecuredAmt,UnSecuredAmt,ProvDFV,Provsecured,ProvUnsecured,ProvCoverGovGur,TotalProvision,BankTotalProvision,RBITotalProvision,FinalNpaDt,DoubtfulDt
	,UpgDate,FinalAssetClassAlt_Key,FinalAssetClassName
	,CASE WHEN LEFT(NPA_Reason,1)=', ' THEN TRIM(RIGHT(REPLACE(NPA_Reason,',',' & '),LEN(NPA_Reason)-1))
				WHEN RIGHT(NPA_Reason,1)=', ' THEN TRIM(LEFT(REPLACE(NPA_Reason,',',' & '),LEN(NPA_Reason)-1))
			ELSE REPLACE(NPA_Reason,',',' & ') END AS NPA_Reason
	--NPA_Reason
	,FlgDeg,FlgUpg,FinalProvisiONPer,FlgSMA,SMA_Dt,SMA_Class
	,CASE WHEN LEFT(SMA_Reason,1)=', ' THEN TRIM(RIGHT(REPLACE(SMA_Reason,',',' & '),LEN(SMA_Reason)-1))
			WHEN RIGHT(SMA_Reason,1)=', ' THEN TRIM(LEFT(REPLACE(SMA_Reason,',',' & '),LEN(SMA_Reason)-1))
		ELSE REPLACE(TRIM(SMA_Reason),',',' & ') END AS SMA_Reason
	--SMA_Reason
	,FlgPNPA,PNPA_DATE
	,CASE WHEN LEFT(PNPA_Reason,1)=', ' THEN TRIM(RIGHT(REPLACE(PNPA_Reason,',',' & '),LEN(PNPA_Reason)-1))
			WHEN RIGHT(PNPA_Reason,1)=', ' THEN TRIM(LEFT(REPLACE(PNPA_Reason,',',' & '),LEN(PNPA_Reason)-1))
		ELSE REPLACE(TRIM(PNPA_Reason),',',' & ') END AS PNPA_Reason
	--PNPA_Reason
	,CustSMAStatus,MOC_Dt,FlgFraud,FraudDate,MakerID,MakerDate
	,CheckerID,CheckerDate,ReviewerID,ReviewerDate
	,CASE WHEN LEFT(MOCReason,1)=', ' THEN TRIM(RIGHT(REPLACE(MOCReason,',',' & '),LEN(MOCReason)-1))
			WHEN RIGHT(MOCReason,1)=', ' THEN TRIM(LEFT(REPLACE(MOCReason,',',' & '),LEN(MOCReason)-1))
		ELSE REPLACE(TRIM(MOCReason),',',' & ') END AS MOCReason
	--MOCReason
	,AcBuSegmentCode,AcBuSegmentDescription
FROM #temp
ORDER BY UCIF_ID,CustomerID,CustomerAcID

END
GO