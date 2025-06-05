SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 
 
	CREATE proc [dbo].[Rpt-0002 Interest Reversal]
	@timekey int
	AS

--DECLARE @timekey INT =27028
 
 
 
--DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)
--DECLARE @ProcessDate DATE=(SELECT DATE FROM SysDayMatrix WHERE Timekey=@TimeKey)

DECLARE @Date AS DATE=(SELECT DATE FROM Automate_Advances WHERE TimeKey=@TimeKey)
DECLARE @ProcessDate DATE=(SELECT DATE FROM Automate_Advances WHERE Timekey=@TimeKey)

Declare	@LastMonthKey AS INT =( SELECT LastMonthDateKey from SYSDAYMATRIX   WHERE TimeKey=@Timekey)

----------------==========For Last Month Data===============-----------------------
IF OBJECT_ID('TempDB..#AccountCal_Hist_data') Is Not Null
 
Drop Table #AccountCal_Hist_data

SELECT AccountEntityID,IntOverdue,PrincOverdue into #AccountCal_Hist_data from  pro.AccountCal_Hist

WHERE EffectiveFromTimeKey<=@LastMonthKey and EffectiveToTimeKey>=@LastMonthKey


---------------------------=============================final data===========================================

 
select DISTINCT



CONVERT(VARCHAR(20),@ProcessDate,103)						AS	ProcessDate,
B.CustomerAcID												AS Customer_ACID
,DS.SourceName												AS  Source_Name
,A.CustomerName												AS	CustomerName
,A.RefCustomerID											AS	Customer_ID
,B.CUstomerAcid
,B.ProductCode												AS	Scheme_Type
,B.BranchCode												AS	SOL_ID
--,B.IntOverdue													AS	IntOverdue

--,(B.IntOverdue + (SELECT CASE WHEN (CurQtrInt-CurQtrCredit)  > 0 THEN  (CurQtrInt-CurQtrCredit) else 0 END AS INTE ) )   AS IntOverdue 

,CASE WHEN FACILITYTYPE='TL' THEN  (B.IntOverdue) ELSE (SELECT CASE WHEN (CurQtrInt-CurQtrCredit)  > 0 THEN  (CurQtrInt-CurQtrCredit) else 0 END AS INTE ) END  AS IntOverdue 

,C.UnAppliedIntAmount										AS	UnAppliedIntAmount

--,B.IntOverdue+UnAppliedIntAmount							AS	Int_Receiveble

--,(B.IntOverdue + (SELECT CASE WHEN (CurQtrInt-CurQtrCredit)  > 0 THEN  (CurQtrInt-CurQtrCredit) else 0 END AS INTE )+C.UnAppliedIntAmount ) Int_Receiveble

,CASE WHEN FACILITYTYPE='TL' THEN  (B.IntOverdue) ELSE ((SELECT CASE WHEN (CurQtrInt-CurQtrCredit)  > 0 THEN  (CurQtrInt-CurQtrCredit) else 0 END AS INTE )+C.UnAppliedIntAmount ) END Int_Receiveble

----,convert(varchar(20), B.InitialNpaDt,103)				AS	InitialNpaDt
--,B.IntOverdue-AC_HIST.IntOverdue							AS	Amount_of_Overdue

--,CASE WHEN (B.IntOverdue + (SELECT CASE WHEN (CurQtrInt-CurQtrCredit)  > 0 THEN  (CurQtrInt-CurQtrCredit) else 0 END AS INTE )-L_BAL.Overdueinterest ) > 0 THEN (B.IntOverdue + (SELECT CASE WHEN (CurQtrInt-CurQtrCredit)  > 0 THEN  (CurQtrInt-CurQtrCredit) else 0 END AS INTE )-L_BAL.Overdueinterest )		ELSE 0 END												AS Amount_of_Overdue


,CASE WHEN (CASE WHEN FACILITYTYPE='TL' THEN  B.IntOverdue ELSE (SELECT CASE WHEN (CurQtrInt-CurQtrCredit)  > 0 THEN  (CurQtrInt-CurQtrCredit) else 0 END AS INTE )END -L_BAL.Overdueinterest ) > 0 

	THEN (CASE WHEN FACILITYTYPE='TL' THEN  B.IntOverdue ELSE  (SELECT CASE WHEN (CurQtrInt-CurQtrCredit)  > 0 THEN  (CurQtrInt-CurQtrCredit) else 0 END AS INTE ) END -L_BAL.Overdueinterest )	

	ELSE 0 END												AS Amount_of_Overdue


--,B.PrincOverdue-AC_HIST.PrincOverdue						AS	 PrincOverdue
,B.PrincOverdue-isnull(L_BAL.OverduePrincipal,0)						AS	 PrincOverdue


 FROM pro.CustomerCal_Hist A  
 

inner join pro.AccountCal_Hist B  
												on A.CustomerEntityID = B.CustomerEntityID
												and A.EffectiveFromTimeKey<=@TIMEKEY and A.EffectiveToTimeKey>=@TIMEKEY
												and B.EffectiveFromTimeKey<=@TIMEKEY and B.EffectiveToTimeKey>=@TIMEKEY
 
inner join AdvAcBalanceDetail C					ON c.AccountEntityId = B.AccountEntityID
												and C.EffectiveFromTimeKey<=@TIMEKEY and C.EffectiveToTimeKey>=@TIMEKEY

LEFT JOIN AdvAcBalanceDetail L_BAL				ON L_BAL.AccountEntityId = B.AccountEntityID
												and L_BAL.EffectiveFromTimeKey<=@LastMonthKey and L_BAL.EffectiveToTimeKey>=@LastMonthKey
--inner join AdvAcOtherFinancialDetail D
--												ON D.AccountEntityId = C.AccountEntityId
--												and D.EffectiveFromTimeKey<=@TIMEKEY and D.EffectiveToTimeKey>=@TIMEKEY
left join DIMSOURCEDB	DS
												ON ds.SourceAlt_Key = b.SourceAlt_Key
												and ds.EffectiveFromTimeKey<=@timekey and ds.EffectiveToTimeKey>=@timekey
--left join DimAssetClass DASSET
--												ON DASSET.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
--												and DASSET.EffectiveFromTimeKey<=@timekey and DASSET.EffectiveToTimeKey>=@timekey


--left join DimAssetClass DASSET1					ON DASSET1.AssetClassAlt_Key = b.PrvAssetClassAlt_Key
--												and DASSET1.EffectiveFromTimeKey<=@timekey and DASSET1.EffectiveToTimeKey>=@timekey

--LEFT JOIN DimProduct	DP						ON DP.ProductAlt_Key = b.ProductAlt_Key
--												and DP.EffectiveFromTimeKey<=@timekey and DP.EffectiveToTimeKey>=@timekey

--LEFT JOIN DimScheme		DC						ON DC.SchemeAlt_Key = b.SchemeAlt_Key
--												and DC.EffectiveFromTimeKey<=@timekey and DC.EffectiveToTimeKey>=@timekey


 LEFT JOIN #AccountCal_Hist_data		AC_HIST		ON AC_HIST.AccountEntityId = B.AccountEntityID
													
 
 WHERE 
 B.FinalAssetClassAlt_Key>1
 AND
(
C.UnAppliedIntAmount> 0 OR
B.IntOverdue >0 OR
B.PrincOverdue > 0 OR
((B.IntOverdue + (SELECT CASE WHEN (CurQtrInt-CurQtrCredit)  > 0 THEN  (CurQtrInt-CurQtrCredit) else 0 END AS INTE ) ) 
-L_BAL.Overdueinterest ) > 0 OR
B.PrincOverdue-L_BAL.OverduePrincipal	 > 0
)
 --AND B.CustomerACID=1354790000006047
ORDER BY A.RefCustomerID

OPTION(RECOMPILE)
GO