SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 
 
	CREATE proc [dbo].[Rpt-0001 NPA REPORT]
		@timekey int ,---=26959,
		@Disburse_Dt	AS	varchar(10)
AS

--DECLARE @timekey INT =26959,
--		@Disburse_Dt	AS	varchar(10)='23-10-2023'

 DECLARE	@Disburse_Dt1 DATE=(SELECT Rdate FROM dbo.DateConvert(@Disburse_Dt))
-- DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)
--DECLARE @ProcessDate DATE=(SELECT DATE FROM SysDayMatrix WHERE Timekey=@TimeKey)
 
DECLARE @Date AS DATE=(SELECT DATE FROM Automate_Advances WHERE TimeKey=@TimeKey)
DECLARE @ProcessDate DATE=(SELECT DATE FROM Automate_Advances WHERE Timekey=@TimeKey)


---------------------------======================================DPD CalCULATION  Start===========================================
IF OBJECT_ID('TempDB..#DPD') Is Not Null
 
Drop Table #DPD

SELECT            A.CustomerAcID
 
                 ,A.AccountEntityID
 
                 ,A.IntNotServicedDt
 
                 ,A.LastCrDate
 
                 ,A.ContiExcessDt
 
                 ,A.OverDueSinceDt
 
                 ,A.ReviewDueDt
 
                 ,A.StockStDt
 
                 ,A.DebitSinceDt
 
                 ,A.PrincOverdueSinceDt
 
                 ,A.IntOverdueSinceDt
 
                 ,A.OtherOverdueSinceDt
 
                 ,A.SourceAlt_Key
 
				 ,PenalInterestOverDueSinceDt
 
INTO #DPD
 
FROM pro.AccountCal_Hist A
 
LEFT JOIN  AdvAcOtherFinancialDetail FIN    ON A.AccountEntityId = FIN.AccountEntityId
 
                                               AND FIN.EffectiveFromTimeKey<=@TimeKey
 
									           AND FIN.EffectiveToTimeKey>=@TimeKey
WHERE A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey
OPTION(RECOMPILE)
 
---------------
 
Alter Table #DPD
 
Add        DPD_IntService Int
 
          ,DPD_NoCredit Int
 
          ,DPD_Overdrawn Int
 
          ,DPD_Overdue Int
 
          ,DPD_Renewal Int
 
          ,DPD_StockStmt Int
 
          ,DPD_PrincOverdue Int
 
          ,DPD_IntOverdueSince Int
 
          ,DPD_OtherOverdueSince Int
 
          ,DPD_Max Int
 
		  ,DPD_PenalInterestOverdue INT
-------------------
UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)+1  ELSE 0 END)                          
 
             ,A.DPD_NoCredit = CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>=90)
 
                                                                                        THEN (CASE WHEN  A.LastCrDate IS NOT NULL
 
                                                                                        THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)+0
 
                                                                                        ELSE 0  
 
                                                                                        END)
 
                                                                                        ELSE 0
 
																						END
                         ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END)
 
                         ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END)
 
                         ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)  +1    ELSE 0 END)
 
                         ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL THEN   DateDiff(Day,DATEADD(month,3,A.StockStDt),@ProcessDate)+1 ELSE 0 END)
 
                         ,A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,@ProcessDate)+1  ELSE 0 END)                          
 
                         ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  @ProcessDate)+1       ELSE 0 END)
 
                         ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  @ProcessDate)+1  ELSE 0 END)
 
						 ,A.DPD_PenalInterestOverdue=(CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.PenalInterestOverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END)
 
FROM #DPD A

OPTION(RECOMPILE)
----New Condition Added By Report Team  02/08/2022 for 1 Augesut greter or equal ---
IF @TimeKey>=26511
 
BEGIN
 
UPDATE #DPD SET
 
#DPD.DPD_IntService=0,
 
#DPD.DPD_NoCredit=0,
 
#DPD.DPD_Overdrawn=0,
 
#DPD.DPD_Overdue=0,
 
#DPD.DPD_Renewal=0,
 
#DPD.DPD_StockStmt=0,
 
#DPD.DPD_PrincOverdue=0,
 
#DPD.DPD_IntOverdueSince=0,
 
#DPD.DPD_OtherOverdueSince=0
 
FROM  Pro.ACCOUNTCAL_hist A
 
INNER JOIN AdvAcBalanceDetail C      ON A.AccountEntityId=C.AccountEntityId
 
INNER JOIN #DPD  DPD                 ON DPD.AccountEntityID=A.AccountEntityID
 
INNER JOIN DimProduct B              ON A.ProductCode=B.ProductCode

WHERE ISNULL(A.Balance,0)=0 AND ISNULL(C.SignBalance,0)>=0
 
      AND B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey
 
      AND C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey
 
      AND A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey
 
      AND A.DebitSinceDt IS NULL
OPTION(RECOMPILE)
END
 
------------------------------
UPDATE #DPD SET DPD_IntService=0 WHERE isnull(DPD_IntService,0)<0
 
UPDATE #DPD SET DPD_NoCredit=0 WHERE isnull(DPD_NoCredit,0)<0
 
UPDATE #DPD SET DPD_Overdrawn=0 WHERE isnull(DPD_Overdrawn,0)<0
 
UPDATE #DPD SET DPD_Overdue=0 WHERE isnull(DPD_Overdue,0)<0
 
UPDATE #DPD SET DPD_Renewal=0 WHERE isnull(DPD_Renewal,0)<0
 
UPDATE #DPD SET DPD_StockStmt=0 WHERE isnull(DPD_StockStmt,0)<0
 
UPDATE #DPD SET DPD_PrincOverdue=0 WHERE isnull(DPD_PrincOverdue,0)<0
 
UPDATE #DPD SET DPD_IntOverdueSince=0 WHERE isnull(DPD_IntOverdueSince,0)<0
 
UPDATE #DPD SET DPD_OtherOverdueSince=0 WHERE isnull(DPD_OtherOverdueSince,0)<0
 
UPDATE #DPD SET DPD_PenalInterestOverdue=0 WHERE isnull(DPD_PenalInterestOverdue,0)<0
UPDATE A SET A.DPD_Max=0  FROM #Dpd  A
 
UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0)
 
                                        AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0)
 
                                                                                AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0)
 
                                                                                AND  isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0)
 
                                                                                AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0))
 
                                                                   THEN isnull(A.DPD_IntService,0)
 
                                   WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0)
 
                                                                        AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0)
 
                                                                        AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0)
 
                                                                        AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0)
 
                                                                        AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0))
 
                                                                   THEN   isnull(A.DPD_NoCredit ,0)
 
                                                                   WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  
 
                                                                        AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  
 
                                                                                AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0)
 
                                                                                AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0)
 
                                                                                AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0))
 
                                                                   THEN  isnull(A.DPD_Overdrawn,0)
 
                                                                   WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    
 
                                                                        AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  
 
                                                                                AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  
 
                                                                                AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  
 
                                                                                AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0))
 
                                                                   THEN isnull(A.DPD_Renewal,0)
 
                                       WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    
 
                                                                        AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)
 
                                                                            AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  
 
                                                                                AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  
 
                                                                                AND isnull(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0))  
 
                                                                   THEN   isnull(A.DPD_Overdue,0)
 
                                                                   ELSE isnull(A.DPD_StockStmt,0)
 
                                                END)
 
FROM  #DPD a
WHERE  (isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0        
 
       OR isnull(A.DPD_Renewal,0) >0 OR isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)

 
 
select DISTINCT

DB.BranchCode												AS BranchCode
,DB.BranchName												AS BranchName
,CONVERT(VARCHAR(20),@ProcessDate,103)						AS	ProcessDate
,B.CustomerAcID                                             AS Customer_ACID
,DS.SourceName												AS  Source_Name
,A.CustomerName												AS	CustomerName
,A.RefCustomerID											AS	Customer_ID
,B.UCIF_ID													AS	UCIF_ID
,B.FacilityType												AS	FacilityType
,Bs.SchemeType 											    AS	Scheme_Type
,A.PANNO													AS	PANNO
,convert(varchar(20), B.InitialNpaDt,103)					AS InitialNpaDt
,DASSET.AssetClassSubGroup								    AS Initial_Sub_AssetClass
,convert(varchar(20), B.AcOpenDt	,103)					AS  Account_Open_Date
,convert(varchar(20), B.FirstDtOfDisb,103)					AS	FirstDtOfDisb
,DP.ProductName												AS	PRODUCT_NAME
,cast(B.Balance	as decimal (30,2))							AS	Balance
,cast(B.PrincOutStd	as decimal (30,2))						AS  Principal_OS_POS
,cast(B.PrincOverdue as decimal (30,2))						AS  Principal_Overdue_Amount
,cast(C.Overdueinterest as decimal(30,2))					AS	Int_Overdue_Amount
,B.DrawingPower												AS	DrawingPower
,B.CurrentLimit												AS	CurrentLimit
,convert(varchar(20),B.ContiExcessDt,103)                   AS	ContiExcessDt
,convert(varchar(20),B.StockStDt,103)				     	AS	Stock_St_Dt
,convert(varchar(20),B.LastCrDate,103)						AS	LastCrDate
--,cast(B.PreQtrCredit as decimal (30,2))						AS Previous90daysCredit
,cast(B.CurQtrCredit as decimal (30,2))						AS Previous90daysCredit
--,cast(PrvQtrInt	as decimal (30,2))							AS  Previous90_days_Interest
,cast(CurQtrInt	as decimal (30,2))							AS  Previous90_days_Interest
--,cast(B.InttServiced as decimal (30,2))						AS  Intt_Not_Serviced_Amount
,cast(B.unserviedint as decimal (30,2))						AS  Intt_Not_Serviced_Amount
,CONVERT(varchar(20),B.OverDueSinceDt,103)	                AS  Over_Due_Since_Dt
,CONVERT(varchar(20),B.ReviewDueDt,103)						AS	ReviewDueDt
,cast(B.SecurityValue as decimal (30,2))					AS	SecurityValue
,cast(B.DFVAmt as decimal (30,2))							AS	DFVAmt
,cast(B.GovtGtyAmt	as decimal (30,2))						AS	GovtGtyAmt
,cast(B.WriteOffAmount as decimal (30,2))					AS	WriteOffAmount
,B.UnAdjSubSidy												AS	UnAdjSubSidy
,B.Asset_Norm												AS	Asset_Norm
,AddlProvision												AS	Addl_Provision
,CONVERT(varchar(20),B.PrincOverdueSinceDt,103)	            AS	PrincOverdueSinceDt
,CONVERT(varchar(20),B.IntOverdueSinceDt,103)	            AS	IntOverdueSinceDt
,CONVERT(varchar(20),B.OtherOverdueSinceDt,103)	            AS	Other_Overdue_Since_Date
,B.CoverGovGur												AS	Govt_Gurantee_Cover
,B.DegReason												AS	DegReason
,cast(NetBalance as decimal (30,2))							AS	Net_Balance
,B.ApprRV													AS	ApprRV
,cast(B.SecuredAmt as decimal (30,2))						AS	SecuredAmt
,cast(UnSecuredAmt as decimal (30,2))						AS Unsecured_Amt
,B.ProvDFV											AS	ProvDFV
--,DASSET1.AssetClassGroup							AS REV_ASST_MAIN_CLS
,DASSET.AssetClassName							AS REV_ASST_MAIN_CLS      ----Previously AssetClassGroup changed on date 15/02/2024
--,DASSET1.AssetClassSubGroup							AS REV_ASST_SUB_CLS
,case 
when b.FinalAssetClassAlt_Key=1 and SMA_Class='STD' then 'A0'
when b.FinalAssetClassAlt_Key=1 and SMA_Class='SMA_0' then 'S0'
when b.FinalAssetClassAlt_Key=1 and SMA_Class='SMA_1' then 'S1'
when b.FinalAssetClassAlt_Key=1 and SMA_Class='SMA_2' then 'S2'
when b.FinalAssetClassAlt_Key=1 and SMA_Class='SMA_3' then 'S3'
when b.FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@ProcessDate) <=91 then 'B0'
when b.FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@ProcessDate) between 91 and 183 then 'B1'
when b.FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@ProcessDate) between 183 and 274 then 'B2'
when b.FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@ProcessDate) >=273 then 'B3'
when b.finalassetclassalt_key=3 then 'C1'
when b.finalassetclassalt_key=4 then 'C2'
when b.FinalAssetClassAlt_Key=5 then 'C3'
when b.FinalAssetClassAlt_Key=6 then 'D0'
end                                                 AS REV_ASST_SUB_CLS	
--,DASSET1.AssetClassSubGroup							AS REV_ASST_SUB_CLS
,B.Provsecured									AS Provision_secured-------------need to ckeck mapping previously ProvPersecured
,DPD.DPD_IntService									AS DPD_Int_Service
,ProvUnsecured										AS Prov_Unsecured
,DPD_NoCredit										AS DPD_No_Credit
,DPD_Overdrawn										AS DPD_Overdrawn
,DPD_Overdue										AS DPD_Overdue
,DPD_Renewal										AS DPD_Renewal
,DPD_StockStmt										AS DPD_Stock_Stmt
,DPD_Max											AS DPD_Max
,B.NPA_Reason										AS NPA_Reason
,B.FlgDeg											AS Flg_Deg
,B.FlgUpg											AS Flg_Upg
,B.TotalProvision								AS Final_Provision
,B.FlgSMA											AS Flg_SMA
,CONVERT(varchar(20),B.SMA_Dt,103)					AS SMA_Dt
,SMA_Class											AS SMA_Class
,SMA_Reason											AS SMA_Reason
,SMA_Class											AS Cust_SMAStatus

 FROM pro.CustomerCal_Hist A  


inner join pro.AccountCal_Hist B  
												on A.CustomerEntityID = B.CustomerEntityID
												and A.EffectiveFromTimeKey<=@TIMEKEY and A.EffectiveToTimeKey>=@TIMEKEY
												and B.EffectiveFromTimeKey<=@TIMEKEY and B.EffectiveToTimeKey>=@TIMEKEY
 
Left join AdvAcBalanceDetail C
												ON c.AccountEntityId = B.AccountEntityID
												and C.EffectiveFromTimeKey<=@TIMEKEY and C.EffectiveToTimeKey>=@TIMEKEY
 
Left join AdvAcOtherFinancialDetail D
												ON D.AccountEntityId = C.AccountEntityId
												and D.EffectiveFromTimeKey<=@TIMEKEY and D.EffectiveToTimeKey>=@TIMEKEY
left join DIMSOURCEDB	DS
												ON ds.SourceAlt_Key = b.SourceAlt_Key
												and ds.EffectiveFromTimeKey<=@timekey and ds.EffectiveToTimeKey>=@timekey
left join DimAssetClass DASSET
												--ON DASSET.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
												ON DASSET.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
												and DASSET.EffectiveFromTimeKey<=@timekey and DASSET.EffectiveToTimeKey>=@timekey


left join DimAssetClass DASSET1					ON DASSET1.AssetClassAlt_Key = b.PrvAssetClassAlt_Key
												and DASSET1.EffectiveFromTimeKey<=@timekey and DASSET1.EffectiveToTimeKey>=@timekey

LEFT JOIN DimProduct	DP						ON DP.ProductAlt_Key = b.ProductAlt_Key
												and DP.EffectiveFromTimeKey<=@timekey and DP.EffectiveToTimeKey>=@timekey

LEFT JOIN DimScheme		DC						ON DC.SchemeAlt_Key = b.SchemeAlt_Key
												and DC.EffectiveFromTimeKey<=@timekey and DC.EffectiveToTimeKey>=@timekey


LEFT join #DPD dpd								ON dpd.AccountEntityID = b.AccountEntityID

Left join    DimProduct Bs                       On b.SchemeAlt_key=bs.Product_key   and   bs.EffectiveFromTimeKey<=@timekey and bs.EffectiveToTimeKey>=@timekey       -----------------------Newly added by kapil on 28/02/2024

LEFT JOIN DimBranch DB							ON B.BranchCode=DB.Branchcode
												and DB.EffectiveFromTimeKey<=@timekey and DB.EffectiveToTimeKey>=@timekey

 WHERE 
 B.FinalAssetClassAlt_Key<>1

 ------- added by pradeep on 10052024 where @Disburse_Dt can be null -------------
 AND (B.FirstDtOfDisb =@Disburse_Dt1 or @Disburse_Dt1 is null )

 --and B.FirstDtOfDisb =@Disburse_Dt

 --AND B.CustomerACID=1354790000006033
 
ORDER BY A.RefCustomerID

OPTION(RECOMPILE)

DROP TABLE #DPD


--select * from #DPD WHERE CustomerACID=1408110000000105


GO