SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AssetClassificationReport]
AS
BEGIN

DECLARE @Date date = 
(select Date from Automate_Advances where Ext_flg = 'Y')

DECLARE @LastQtrDateKey INT = (select LastQtrDateKey from sysdaymatrix where timekey IN (select Timekey from Automate_Advances where Ext_flg = 'Y'))

select convert(nvarchar,@Date , 105) AS  [Process_date] 
,A.UCIF_ID as UCIC
,A.RefCustomerID as CustomerID
,CustomerName
,B.BranchCode
,BranchName
,CustomerAcID
,SourceName
,B.FacilityType
,SchemeType
,B.ProductCode
,ProductName
,ActSegmentCode
,AcBuSegmentDescription
,AcBuRevisedSegmentCode
,DPD_Max
,FinalNpaDt
,Balance
,NetBalance
,DrawingPower
,CurrentLimit
,(CASE WHEN A.SourceAlt_Key = 1 AND SchemeType = 'ODA' 
THEN	(CASE WHEN (ISNULL(b.Balance,0) -(CASE WHEN ISNULL(b.DrawingPower,0)<ISNULL(b.CurrentLimit,0) THEN  ISNULL(b.DrawingPower,0) ELSE ISNULL(b.CurrentLimit,0)  END ))<=0
THEN 0							 ELSE  (CASE WHEN ISNULL(b.DrawingPower,0)<ISNULL(b.CurrentLimit,0) THEN  ISNULL(b.DrawingPower,0) ELSE ISNULL(b.CurrentLimit,0)  END ) END) 
ELSE 0 END) OverDrawn_Amt
,DPD_Overdrawn
,ContiExcessDt
,ReviewDueDt
,DPD_Renewal
,StockStDt
,DPD_StockStmt
,DebitSinceDt
,LastCrDate
,DPD_NoCredit
,CurQtrCredit
,CurQtrInt
,(CASE WHEN (CurQtrInt -CurQtrCredit) < 0 then 0 else(CurQtrInt -CurQtrCredit) END) [InterestNotServiced]
,DPD_IntService
,NULL [CC/OD Interest Service]
,OverdueAmt
,OverDueSinceDt
,DPD_Overdue
,PrincOverdue
,PrincOverdueSinceDt
,DPD_PrincOverdue
,IntOverdue
,IntOverdueSinceDt
,DPD_IntOverdueSince
,OtherOverdue
,OtherOverdueSinceDt
,DPD_OtherOverdueSince
,NULL [Bill/PC Overdue Amount]
,NULL [Overdue Bill/PC ID]
,NULL [Bill/PC Overdue Date]
,NULL [DPD Bill/PC]
,a2.AssetClassName as FinalAssetName
,A.DegReason
,NPANorms
FROM PRO.CUSTOMERCAL A
INNER JOIN PRO.ACCOUNTCAL B
	ON A.CustomerEntityID=B.CustomerEntityID
LEFT JOIN DIMSOURCEDB src
	on b.SourceAlt_Key =src.SourceAlt_Key	
LEFT JOIN DIMPRODUCT PD
	ON PD.EffectiveToTimeKey=49999
	AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
left join DimAssetClass a1
	on a1.EffectiveToTimeKey=49999
	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
left join DimAssetClass a2
	on a2.EffectiveToTimeKey=49999
	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode
LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode
	WHERE RefPeriodOverdue not in (181,366)
and B.FinalAssetClassAlt_Key > 1

END
GO