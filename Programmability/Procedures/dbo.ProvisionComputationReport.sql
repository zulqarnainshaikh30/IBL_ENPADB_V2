SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ProvisionComputationReport]
AS
BEGIN


DECLARE @Date date = 
(select Date from Automate_Advances where Ext_flg = 'Y')

DECLARE @LastQtrDateKey INT = (select LastQtrDateKey from sysdaymatrix where timekey IN (select Timekey from Automate_Advances where Ext_flg = 'Y'))


select   convert(nvarchar,@Date , 105) AS  [Report Date] 
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
,CASE WHEN B.SecApp ='S' THEN 'SECURED' ELSE 'UNSECURED'  END [Secured/Unsecured]
,ActSegmentCode as [Seg Code]
,(CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuSegmentDescription end) as [Segment Description]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuRevisedSegmentCode end  as [Business Segment]
,DPD_Max as [Account DPD]
,CD [Cycle Past due]
,FinalNpaDt [NPA Date]
,A2.AssetClassName as [Asset Classification]
,REFPERIODOVERDUE [NPA Norms]  --NPANorms as [NPA Norms] 
,B.NetBalance [Balance Outstanding]
,CurntQtrRv [Customer Security Value]
-----,SecurityValue as [Account Security Value]   -- TO BE REMOVED
,ApprRV as [Security Value Appropriated]
,B.SecuredAmt as [Secured Outstanding]
,B.UnSecuredAmt as [Unsecured Outstanding]
,B.TotalProvision as [Provision Total]
,B.Provsecured as [Provision Secured]
,B.ProvUnsecured as [Provision Unsecured]
,ISNULL((B.NetBalance-B.TotalProvision),0)[Net NPA]
,cast((ISNULL((B.Provsecured/NULLIF(B.SecuredAmt,0))*100,0)) as decimal(5,2)) [ProvisionSecured%]
,cast((ISNULL((B.ProvUnsecured/NULLIF(B.UnSecuredAmt,0))*100,0))  as decimal(5,2)) [ProvisionUnSecured%]
,cast((ISNULL((B.TotalProvision/NULLIF(B.NetBalance,0))*100,0))  as decimal(5,2)) [ProvisionTotal%]
,ISNULL(y.NetBalance,0) [Prev. Qtr. Balance Outstanding]
,ISNULL(y.SecuredAmt,0)	[Prev. Qtr. Secured Outstanding],
ISNULL(y.UnSecuredAmt,0)	[Prev. Qtr. Unsecured Outstanding],
ISNULL(y.TotalProvision,0)	[Prev. Qtr.Provision Total],
ISNULL(y.Provsecured,0)	[Prev. Qtr.Provision Secured]
,ISNULL(y.ProvUnsecured,0)	[Prev. Qtr. Provision Unsecured]
,ISNULL(y.NetNPA,0)	[Prev. Qtr. Net NPA]
,CASE WHEN ISNULL((ISNULL(B.NetBalance,0) - ISNULL(Y.netBalance,0)),0) < 0 
			then 0 
		ELSE ISNULL((ISNULL(B.NetBalance,0) - ISNULL(Y.netBalance,0)),0) 
	END NPAIncrease
,CASE WHEN ISNULL((B.NetBalance - ISNULL(Y.netBalance,0)),0) >= 0 then 0 
ELSE ISNULL((B.NetBalance - ISNULL(Y.netBalance,0)),0) END NPADecrease
,CASE WHEN ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) < 0 then 0 
ELSE ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) END ProvisionIncrease
,CASE WHEN ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) >= 0 then 0 
ELSE ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) END ProvisionDecrease
,CASE WHEN ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - y.NetNPA),0) < 0 then 0 
ELSE ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - ISNULL(y.NetNPA,0)),0) END NetNPAIncrease
,CASE WHEN ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - ISNULL(y.NetNPA,0)),0) >= 0 then 0 ELSE ISNULL(((B.NetBalance-B.TotalProvision) - ISNULL(y.NetNPA,0)),0) END NetNPAnDecrease

FROM PRO.CUSTOMERCAL A with (nolock)
INNER JOIN PRO.ACCOUNTCAL B with (nolock)
	ON A.CustomerEntityID=B.CustomerEntityID	
	AND ISNULL(B.WriteOffAmount,0)=0
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
LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and S.EffectiveToTimeKey=49999
LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999
LEFT JOIN (
select A. CustomerEntityID,B.AccountEntityID,NetBalance,SecuredAmt,UnSecuredAmt,TotalProvision,Provsecured,ProvUnsecured,(NetBalance-totalprovision)NetNPA
FROM PRO.CustomerCal_Hist A with (nolock)
INNER JOIN PRO.AccountCal_Hist B with (nolock)
	ON A.CustomerEntityID=B.CustomerEntityID --AND a.EffectiveFromTimeKey = b.EffectiveFromTimeKey
	WHERE B.EffectiveFromTimeKey <= @LastQtrDateKey AND b.EffectiveToTimeKey >=  @LastQtrDateKey and
	B.FinalAssetClassAlt_Key>1 and A.EffectiveFromTimeKey <= @LastQtrDateKey AND A.EffectiveToTimeKey >=  @LastQtrDateKey )Y 
	ON B.AccountEntityID = Y.AccountEntityID
WHERE B.FinalAssetClassAlt_Key>1 

END
GO