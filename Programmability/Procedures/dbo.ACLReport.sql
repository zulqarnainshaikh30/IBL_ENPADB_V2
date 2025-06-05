SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ACLReport]
AS
BEGIn

DECLARE @Date date = 
(select Date from Automate_Advances where Ext_flg = 'Y')

DECLARE @LastQtrDateKey INT = (select LastQtrDateKey from sysdaymatrix where timekey IN (select Timekey from Automate_Advances where Ext_flg = 'Y'))

select  convert(nvarchar,@Date , 105) AS  [Report date] 
,A.UCIF_ID as UCIC
,A.RefCustomerID as [CIF ID]
,REPLACE(CustomerName,',','') as [Borrower Name]
,B.BranchCode as [Branch Code]
,REPLACE(BranchName,',','') as  [Branch Name]
,CustomerAcID as [Account No.]
,SourceName as [Source System]
,B.FacilityType as [Facility]
,SchemeType as [Scheme Type]
,B.ProductCode as [Scheme Code]
,ProductName as [Scheme Description]
,ActSegmentCode as [Seg Code]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuSegmentDescription end as [Segment Description]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuRevisedSegmentCode end as [Business Segment]
,DPD_Max as [Account DPD]
,FinalNpaDt as [NPA Date]
,Balance as [Outstanding]
,NetBalance as [Principal Outstanding]
,DrawingPower as [Drawing Power]
,CurrentLimit as [Sanction Limit]
,CASE WHEN SourceName = 'Finacle' AND SchemeType ='ODA' THEN (
		CASE WHEN (ISNULL(b.Balance,0) - (	CASE WHEN ISNULL(b.DrawingPower,0)<ISNULL(b.CurrentLimit,0) 
											THEN			ISNULL(b.DrawingPower,0) 
											ELSE ISNULL(b.CurrentLimit,0)  
											END 
										)
				  )<=0
		THEN	0	 
		ELSE  
		ISNULL(b.Balance,0) - (	CASE WHEN ISNULL(b.DrawingPower,0)<ISNULL(b.CurrentLimit,0) 
											THEN			ISNULL(b.DrawingPower,0) 
											ELSE ISNULL(b.CurrentLimit,0)  
											END 
										)
END) ELSE 0 END
 [OverDrawn Amount]
,DPD_Overdrawn 
,ContiExcessDt as [Limit/DP Overdrawn Date]
,ReviewDueDt as [Limit Expiry Date]
,DPD_Renewal as [DPD_Limit Expiry]
,StockStDt as [Stock Statement valuation date]
,DPD_StockStmt as [DPD_Stock Statement expiry]
,DebitSinceDt as [Debit Balance Since Date]
,LastCrDate as [Last Credit Date]
,DPD_NoCredit as [DPD_No Credit]
,CurQtrCredit as [Current quarter credit]
,CurQtrInt as [Current quarter interest]
,(CASE WHEN (CurQtrInt -CurQtrCredit) < 0 then 0 else(CurQtrInt -CurQtrCredit) END)
[Interest Not Serviced]
,DPD_IntService as [DPD_out of order]
,IntNotServicedDt [CC/OD Interest Service]
,OverdueAmt [Overdue Amount]
,OverDueSinceDt [Overdue Date]
,DPD_Overdue
,PrincOverdue [Principal Overdue]
,PrincOverdueSinceDt [Principal Overdue Date]
,DPD_PrincOverdue [DPD_Principal Overdue]
,IntOverdue as [Interest Overdue]
,IntOverdueSinceDt as [Interest Overdue Date]
,DPD_IntOverdueSince as [DPD_Interest Overdue]
,OtherOverdue as [Other OverDue]
,OtherOverdueSinceDt as [Other OverDue Date]
,DPD_OtherOverdueSince as  [DPD_Other Overdue]
,(CASE WHEN SchemeType = 'FBA' then OverdueAmt else 0 END) [Bill/PC Overdue Amount]
,'' [Overdue Bill/PC ID]
,(CASE WHEN SchemeType = 'FBA' then OverDueSinceDt else '' END) [Bill/PC Overdue Date]
,(CASE WHEN SchemeType = 'FBA' then DPD_Overdue else 0 END) [DPD Bill/PC]
,a2.AssetClassName as [Asset Classification]
,REPLACE(isnull(A.DegReason,b.NPA_Reason),',','') as [Degrade Reason]
,b.REFPERIODOVERDUE as [NPA Norms]

FROM PRO.CUSTOMERCAL A with (nolock)
INNER JOIN PRO.ACCOUNTCAL B with (nolock)
	ON A.CustomerEntityID=B.CustomerEntityID
	and isnull(b.WriteOffAmount,0)=0
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
and S.EffectiveToTimeKey = 49999
LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey = 49999
	WHERE  B.FinalAssetClassAlt_Key > 1  


END 

GO