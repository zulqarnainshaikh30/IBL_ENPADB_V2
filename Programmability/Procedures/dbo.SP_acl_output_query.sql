SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SP_acl_output_query]
AS
BEGIN
drop table if exists #data
Declare @date date = (select Date from Automate_Advances where Ext_Flg = 'Y')
SELECT 


      convert(nvarchar,getdate() , 105) AS  [Generation Date]
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
	,S.AcBuRevisedSegmentCode
----SELECT ActSegmentCode,* FROM PRO.ACCOUNTCAL
into ACL_NPA_DATA_04072021_UPDATED
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
--	 where B.FinalAssetClassAlt_Key>1
--	 where B.FlgUpg='U'


	SELECT * FROM SYS.tables ORDER BY create_date DESC
		--where a1.AssetClassShortNameEnum<>a2.AssetClassShortNameEnum
--where CustomerAcID='409000600193'
--			select CustomerAcID, * from #data where (CurQtrInt is not null or CurQtrCredit is not null) and FacilityType='tl'

--			select StockStDt,FacilityType from pro.ACCOUNTCAL where StockStDt is not null

--select * from AdvAcBasicDetail where CustomerAcID='Z015AWM_01313902'
--select * from AdvAcBasicDetail where CustomerAcID='Z015AWM_01313902'

	--	select distinct AcSegmentCode from ENBD_STGDB.dbo.ACCOUNT_ALL_SOURCE_SYSTEM 
	--	except		
	--	select AcBuSegmentCode from DimAcBuSegment 

	--select CurQtrCredit,CurQtrInt from ENBD_STGDB.dbo.ACCOUNT_ALL_SOURCE_SYSTEM where CustomerAcID='609000123661'



	--select * from SYSDAYMNDATRIX where date='2021-06-23'

	END
GO