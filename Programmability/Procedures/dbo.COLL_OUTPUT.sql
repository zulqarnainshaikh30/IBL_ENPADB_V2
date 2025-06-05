SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[COLL_OUTPUT]
AS
SELECT 
      convert(nvarchar,getdate() , 105) AS  [Generation Date]
	  ,'28-08-2021' Process_Date,
	A.UCIF_ID as UCIC, A.RefCustomerID CustomerID, CustomerName,B.Branchcode,CustomerAcid, b.Facilitytype ,b.ProductCode
	,ProductName
	,Balance,DrawingPower	,CurrentLimit,UnserviedInt UnAppliedIntt, ReviewDueDt,CreditSinceDt,b.ContiExcessDt,StockStDt,DebitSinceDt
	,LastCrDate,PreQtrCredit,PrvQtrInt,CurQtrCredit,CurQtrInt,
	--IntNotServicedDt	
	OverdueAmt	,OverDueSinceDt	
	,FlgSecured,NetBalance,PrincOutStd,CurntQtrRv,ApprRV,UsedRV ,SecuredAmt,UnSecuredAmt,Provsecured	
	,ProvUnsecured
	,TotalProvision
	,case when isnull(NetBalance,0)>0 then (TotalProvision*100)/isnull(NetBalance,0) else 0 end ProvPer
	,RefPeriodOverdue	,RefPeriodOverDrawn	,RefPeriodNoCredit,
	RefPeriodIntService,RefPeriodStkStatement,RefPeriodReview,PrincOverdue,	PrincOverdueSinceDt,	
	IntOverdue,	IntOverdueSinceDt,	OtherOverdue,	OtherOverdueSinceDt,DPD_IntService,	DPD_NoCredit,	
	DPD_Overdrawn	,DPD_Overdue,	DPD_Renewal,	DPD_StockStmt,DPD_PrincOverdue	,DPD_IntOverdueSince	
	,DPD_OtherOverdueSince,DPD_Max	,InitialNpaDt,	FinalNpaDt,InitialAssetClassAlt_Key
	,a1.AssetClassShortNameEnum InitialAssetClass
	,FinalAssetClassAlt_Key ,a2.AssetClassShortNameEnum FialAssetClass
	,b.DegReason,b.FlgDeg, b.FlgUpg,NPA_Reason,FLGSECURED As SecuredFlag
	,a.Asset_Norm
	,b.CD
	,pd.NPANorms,b.WriteOffAmount
	,b.ActSegmentCode,ProductSubGroup
	,SourceName
	,ProductGroup
	,PD.SchemeType
	,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else S.AcBuRevisedSegmentCode end AcBuRevisedSegmentCode
----SELECT ActSegmentCode,* FROM PRO.ACCOUNTCAL

--into #data
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
GO