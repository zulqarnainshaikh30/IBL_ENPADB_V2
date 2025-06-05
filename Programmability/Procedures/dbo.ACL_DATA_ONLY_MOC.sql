SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ACL_DATA_ONLY_MOC]
AS

Declare @Date date ='2021-09-30' --(select Date from Automate_Advances where Ext_flg = 'Y')

Declare @Timekey int =26206-- (select Timekey from Automate_Advances where Ext_flg = 'Y')

-----------------------------------------ACL PROCESSING---------------

SELECT 
      convert(nvarchar,GETDATE() , 105) AS  [Generation Date]
	  ,  convert(nvarchar,@Date, 105) Process_Date,
	A.UCIF_ID as UCIC, A.RefCustomerID CustomerID, CustomerName,B.Branchcode,CustomerAcid, b.Facilitytype ,b.ProductCode
	,ProductName
	,Balance,DrawingPower	,CurrentLimit,UnserviedInt UnAppliedIntt, ReviewDueDt,CreditSinceDt,b.ContiExcessDt,StockStDt,DebitSinceDt
	,LastCrDate,PreQtrCredit,PrvQtrInt,CurQtrCredit,CurQtrInt,
	--IntNotServicedDt	
	OverdueAmt	,OverDueSinceDt	
	,SecurityValue,NetBalance,PrincOutStd	,ApprRV,SecuredAmt,UnSecuredAmt,Provsecured	
	,ProvUnsecured
	,TotalProvision,RefPeriodOverdue	,RefPeriodOverDrawn	,RefPeriodNoCredit,
	RefPeriodIntService,RefPeriodStkStatement,RefPeriodReview,PrincOverdue,	PrincOverdueSinceDt,	
	IntOverdue,	IntOverdueSinceDt,	OtherOverdue,	OtherOverdueSinceDt
	,DPD_IntService,	DPD_NoCredit,	
	DPD_Overdrawn	,DPD_Overdue,	DPD_Renewal,	
	DPD_StockStmt,DPD_PrincOverdue	,DPD_IntOverdueSince	
	,DPD_OtherOverdueSince,DPD_Max	
	,InitialNpaDt,	FinalNpaDt,InitialAssetClassAlt_Key
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
	,ISNULL(A.FlgMoc	 ,b.FlgMoc)		FlgMoc
	,ISNULL(A.MOCReason	 ,b.MOCReason)	MOCReason
	,ISNULL(A.MOC_Dt	 ,b.MOC_Dt)		MOC_Dt
	,ISNULL(A.MOCTYPE    ,b.MOCTYPE)	MOCTYPE
into ACL_DATA_ONLY_MOC_30092021
FROM PRO.CUSTOMERCAL A
	INNER JOIN PRO.ACCOUNTCAL B
		ON A.CustomerEntityID=B.CustomerEntityID
		and a.EffectiveFromTimeKey=26206
		and b.EffectiveToTimeKey=26206
    LEFT JOIN DIMSOURCEDB src
		on b.SourceAlt_Key =src.SourceAlt_Key
		 AND SRC.EffectiveFromTimeKey<=@Timekey  AND SRC.EffectiveToTimeKey>=@Timekey

	LEFT JOIN DIMPRODUCT PD
		ON  PD.EffectiveFromTimeKey<=@TimekeY AND  PD.EffectiveToTimeKey>=@Timekey
		AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
	left join DimAssetClass a1
		on a1.EffectiveToTimeKey=49999
		and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
		 AND A1.EffectiveFromTimeKey<=@Timekey  AND A1.EffectiveToTimeKey>=@Timekey

	left join DimAssetClass a2
		on a2.EffectiveToTimeKey=49999
		and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
		 AND A2.EffectiveFromTimeKey<=@Timekey  AND A2.EffectiveToTimeKey>=@Timekey

	LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode
		 AND S.EffectiveFromTimeKey<=@Timekey  AND S.EffectiveToTimeKey>=@Timekey

--WHERE B.FinalAssetClassAlt_Key>1

	--AND isnull(b.WriteOffAmount,0)=0	--	 where B.FlgUpg='U'

GO