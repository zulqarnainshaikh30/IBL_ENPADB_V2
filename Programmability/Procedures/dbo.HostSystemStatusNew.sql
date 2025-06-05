SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--EXEC HostSystemStatusNew 1

CREATE PROCEDURE [dbo].[HostSystemStatusNew]
@Assetclass int
AS
BEGIN


Declare @Date date = (select Date from Automate_advances where Ext_flg = 'Y')
Declare @TimeKey int = (select timekey from Automate_advances where Ext_flg = 'Y')

IF @Assetclass = 1 
BEGIN
SELECT distinct 
	A.UCIF_ID as [UCIC Code], 
	A.RefCustomerID CustomerID, 
	A.CustomerName,
	CustomerAcid AccountNo
	,SourceName as [Host System Name]
	,SignBalance OSBalance
	,convert(nvarchar,@Date, 105) [Report Date]
	,B.ActSegmentCode
	,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else S.AcBuRevisedSegmentCode end  [Account Level Business Segment],
		AcBuSegmentDescription [Business Seg Desc]
	,b.ProductCode as [Base Account Scheme Code]
	,SMA_Class as [CrisMac System Status]
	,tbl.Main_Classification [Host System Status]
	,tbl.Remarks [Remarks]
	,tbl.Closed_Date [Closed Date]
	,(CASE WHEN SignBalance > 0 then 'Dr'  ELSE 'Cr' END) [Cr/Dr]	
		FROM PRO.CustomerCal_Hist A with (nolock) 
	INNER JOIN PRO.ACCOUNTCAL_Hist B with (nolock) 
		ON A.CustomerEntityID=B.CustomerEntityID 
		INNER JOIN AdvAcBalanceDetail D with (nolock)
		ON B.AccountEntityID = D.AccountEntityId
		and D.EffectiveToTimeKey = 49999
		INNER JOIN ReverseFeedData C with (nolock) 
		ON B.CustomerAcID = C.AccountID 		
	INNER JOIN ENPA_Host_System_status_tbl  tbl 
	ON C.AccountID = tbl.Account_No 
	and cast(c.DateofData as date) = cast(tbl.Report_Date as date)
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
	WHERE  A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @TimeKey
	and B.EffectiveFromTimeKey <= @Timekey 
	and B.EffectiveToTimeKey >= @TimeKey and Cast(Report_Date as date) = @Date
		and C.AssetClass > 1 and B.SourceAlt_Key != 6
	END
	ELSE
	BEGIN
	SELECT distinct 
	A.UCIF_ID as [UCIC Code], 
	A.RefCustomerID CustomerID, 
	A.CustomerName,
	CustomerAcid AccountNo
	,SourceName as [Host System Name]
	,SignBalance OSBalance
	,convert(nvarchar,@Date, 105) [Report Date]
	,B.ActSegmentCode
	,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else S.AcBuRevisedSegmentCode end  [Account Level Business Segment],
		AcBuSegmentDescription [Business Seg Desc]
	,b.ProductCode as [Base Account Scheme Code]
	,SMA_Class as [CrisMac System Status]
	,tbl.Main_Classification [Host System Status]
	,tbl.Remarks [Remarks]
	,tbl.Closed_Date [Closed Date]
	,(CASE WHEN SignBalance > 0 then 'Dr'  ELSE 'Cr' END) [Cr/Dr]	
FROM PRO.CustomerCal_Hist A with (nolock) 
	INNER JOIN PRO.ACCOUNTCAL_Hist B with (nolock) 
		ON A.CustomerEntityID=B.CustomerEntityID 
		INNER JOIN AdvAcBalanceDetail D with (nolock)
		ON B.AccountEntityID = D.AccountEntityId
		and D.EffectiveToTimeKey = 49999
		INNER JOIN ReverseFeedData C with (nolock) 
		ON B.CustomerAcID = C.AccountID 		
	INNER JOIN ENPA_Host_System_status_tbl  tbl 
	ON C.AccountID = tbl.Account_No 
	and cast(c.DateofData as date) = cast(tbl.Report_Date as date)
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
	WHERE  A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @TimeKey
	and B.EffectiveFromTimeKey <= @Timekey 
	and B.EffectiveToTimeKey >= @TimeKey 
	and Cast(Report_Date as date) = @Date
		and C.AssetClass = 1 and B.SourceAlt_Key != 6
	END
	END
GO