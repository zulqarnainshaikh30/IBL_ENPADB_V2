SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[InterestReversalReport]
as
begin


DECLARE @Date date = 
(select Date from Automate_Advances where Ext_flg = 'Y')

DECLARE @LastQtrDateKey INT = (select LastQtrDateKey from sysdaymatrix where timekey IN (select Timekey from Automate_Advances where Ext_flg = 'Y'))

select  distinct convert(nvarchar,@Date , 105) AS  [Report Date] 
,A.UCIF_ID as UCIC
,A.RefCustomerID as [CIF ID]
,REPLACE(CustomerName,',','') as [Borrower Name]
,B.BranchCode as [Branch Code]
,REPLACE(BranchName,',','') as [Branch Name]
,B.CustomerAcID as [Account No.]
,SourceName as [Source System]
,B.FacilityType as [Facility]
,SchemeType as [Scheme Type]
,B.ProductCode AS [Scheme Code]
,REPLACE(ProductName,',','') as [Scheme Description]
,ActSegmentCode as [Seg Code]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuSegmentDescription end [Segment Description]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuRevisedSegmentCode end [Business Segment]
,DPD_Max as [Account DPD]
,FinalNpaDt as [NPA Date]
,Balance AS [Outstanding]
,ISNULL(PrincOutStd,0) as [Principal Outstanding]
,a2.SrcSysClassCode as [Asset Classification]
,zz.AssetClassCode as	[Soirce System Status]
,ISNULL(IntOverdue,0)		[interest Dues]
--,ISNULL(penal_due,0)	
,'' [Penal Dues]
,ISNULL(OtherOverdue,0)			[Other Dues]
,(ISNULL(int_receivable_adv,0) + ISNULL(Accrued_interest,0)) [interest accured but not due]
,ISNULL(penal_int_receivable,0) [penal accured but not due]
,ISNULL(Balance_INT,0) [Credit Card interest Outstanding]
,ISNULL(Balance_FEES,0) [Credit Card other charges]
,ISNULL(Balance_GST,0) [Credit Card GST/ST Outstanding]
,ISNULL(Interest_DividendDueAmount,0) [Interest/Dividend on Bond/Debentures]
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
LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and S.EffectiveToTimeKey=49999
LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999
LEFT JOIN dbo.AdvAcOtherFinancialDetail Y ON Y.AccountEntityID = B.AccountEntityID and Y.EffectiveToTimeKey = 49999
LEFT JOIN dbo.AdvCreditCardBalanceDetail YZ ON YZ.AccountEntityID = B.AccountEntityID and YZ.EffectiveToTimeKey = 49999
LEFT JOIN InvestmentFinancialDetail Z ON Z.RefInvID = B.CustomerAcID and Z.EffectiveToTimeKey = 49999
LEFT JOIN (select distinct CustomerAcid,AssetClassCode from [ENBD_STGDB].dbo.ACCOUNT_ALL_SOURCE_SYSTEM) ZZ ON B.CustomerAcID = ZZ.CustomerAcID
where  B.FinalAssetClassAlt_Key>1  


--UNION
--select  convert(nvarchar,@Date , 105) AS  [Report Date] 
--,A.UCIF_ID as UCIC
--,A.RefCustomerID as [CIF ID]
--,REPLACE(CustomerName,',','') as [Borrower Name]
--,B.BranchCode as [Branch Code]
--,REPLACE(BranchName,',','') as [Branch Name]
--,B.CustomerAcID as [Account No.]
--,SourceName as [Source System]
--,B.FacilityType as [Facility]
--,SchemeType as [Scheme Type]
--,B.ProductCode AS [Scheme Code]
--,REPLACE(ProductName,',','') as [Scheme Description]
--,ActSegmentCode as [Seg Code]
--,CASE WHEN SourceName='Ganaseva' THEN 'FI'
--		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
--		else AcBuSegmentDescription end [Segment Description]
--,CASE WHEN SourceName='Ganaseva' THEN 'FI'
--		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
--		else AcBuRevisedSegmentCode end [Business Segment]
--,DPD_Max as [Account DPD]
--,FinalNpaDt as [NPA Date]
--,Balance AS [Outstanding]
--,ISNULL(PrincOutStd,0) as [Principal Outstanding]
--,zz.AssetClassCode as [Asset Classification]
--,a2.SrcSysClassCode as	[Soirce System Status]
--,ISNULL(IntOverdue,0)		[interest Dues]
----,ISNULL(penal_due,0)	
--,'' [Penal Dues]
--,ISNULL(OtherOverdue,0)			[Other Dues]
--,(ISNULL(int_receivable_adv,0) + ISNULL(Accrued_interest,0)) [interest accured but not due]
--,ISNULL(penal_int_receivable,0) [penal accured but not due]
--,ISNULL(Balance_INT,0) [Credit Card interest Outstanding]
--,ISNULL(Balance_FEES,0) [Credit Card other charges]
--,ISNULL(Balance_GST,0) [Credit Card GST/ST Outstanding]
--,ISNULL(Interest_DividendDueAmount,0) [Interest/Dividend on Bond/Debentures]
--FROM PRO.CUSTOMERCAL A with (nolock)
--INNER JOIN PRO.ACCOUNTCAL B with (nolock)
--	ON A.CustomerEntityID=B.CustomerEntityID
--LEFT JOIN DIMSOURCEDB src
--	on b.SourceAlt_Key =src.SourceAlt_Key	
--LEFT JOIN DIMPRODUCT PD
--	ON PD.EffectiveToTimeKey=49999
--	AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
--left join DimAssetClass a1
--	on a1.EffectiveToTimeKey=49999
--	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
--left join DimAssetClass a2
--	on a2.EffectiveToTimeKey=49999
--	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
--LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and S.EffectiveToTimeKey=49999
--LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999
--LEFT JOIN dbo.AdvAcOtherFinancialDetail Y ON Y.AccountEntityID = B.AccountEntityID and Y.EffectiveToTimeKey = 49999
--INNER JOIN dbo.AdvCreditCardBalanceDetail YZ ON YZ.AccountEntityID = B.AccountEntityID and YZ.EffectiveToTimeKey = 49999
--LEFT JOIN InvestmentFinancialDetail Z ON Z.RefInvID = B.CustomerAcID and Z.EffectiveToTimeKey = 49999
--LEFT JOIN (select distinct CustomerAcid,AssetClassCode from [ENBD_STGDB].dbo.ACCOUNT_ALL_SOURCE_SYSTEM) ZZ ON B.CustomerAcID = ZZ.CustomerAcID
--where  B.FinalAssetClassAlt_Key>1  
--and (ISNULL(Balance_INT,0) > 0 OR 
--ISNULL(Balance_FEES,0) > 0 OR
--ISNULL(Balance_GST,0) > 0)
--UNION
--select  convert(nvarchar,@Date , 105) AS  [Report Date] 
--,A.UCIF_ID as UCIC
--,A.RefCustomerID as [CIF ID]
--,REPLACE(CustomerName,',','') as [Borrower Name]
--,B.BranchCode as [Branch Code]
--,REPLACE(BranchName,',','') as [Branch Name]
--,B.CustomerAcID as [Account No.]
--,SourceName as [Source System]
--,B.FacilityType as [Facility]
--,SchemeType as [Scheme Type]
--,B.ProductCode AS [Scheme Code]
--,REPLACE(ProductName,',','') as [Scheme Description]
--,ActSegmentCode as [Seg Code]
--,CASE WHEN SourceName='Ganaseva' THEN 'FI'
--		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
--		else AcBuSegmentDescription end [Segment Description]
--,CASE WHEN SourceName='Ganaseva' THEN 'FI'
--		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
--		else AcBuRevisedSegmentCode end [Business Segment]
--,DPD_Max as [Account DPD]
--,FinalNpaDt as [NPA Date]
--,Balance AS [Outstanding]
--,ISNULL(PrincOutStd,0) as [Principal Outstanding]
--,zz.AssetClassCode as [Asset Classification]
--,a2.SrcSysClassCode as	[Soirce System Status]
--,ISNULL(IntOverdue,0)		[interest Dues]
----,ISNULL(penal_due,0)	
--,'' [Penal Dues]
--,ISNULL(OtherOverdue,0)			[Other Dues]
--,(ISNULL(int_receivable_adv,0) + ISNULL(Accrued_interest,0)) [interest accured but not due]
--,ISNULL(penal_int_receivable,0) [penal accured but not due]
--,ISNULL(Balance_INT,0) [Credit Card interest Outstanding]
--,ISNULL(Balance_FEES,0) [Credit Card other charges]
--,ISNULL(Balance_GST,0) [Credit Card GST/ST Outstanding]
--,ISNULL(Interest_DividendDueAmount,0) [Interest/Dividend on Bond/Debentures]
--FROM PRO.CUSTOMERCAL A with (nolock)
--INNER JOIN PRO.ACCOUNTCAL B with (nolock)
--	ON A.CustomerEntityID=B.CustomerEntityID
--LEFT JOIN DIMSOURCEDB src
--	on b.SourceAlt_Key =src.SourceAlt_Key	
--LEFT JOIN DIMPRODUCT PD
--	ON PD.EffectiveToTimeKey=49999
--	AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
--left join DimAssetClass a1
--	on a1.EffectiveToTimeKey=49999
--	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
--left join DimAssetClass a2
--	on a2.EffectiveToTimeKey=49999
--	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
--LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and S.EffectiveToTimeKey=49999
--LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999
--LEFT JOIN dbo.AdvAcOtherFinancialDetail Y ON Y.AccountEntityID = B.AccountEntityID and Y.EffectiveToTimeKey = 49999
--LEFT JOIN dbo.AdvCreditCardBalanceDetail YZ ON YZ.AccountEntityID = B.AccountEntityID and YZ.EffectiveToTimeKey = 49999
--INNER JOIN InvestmentFinancialDetail Z ON Z.RefInvID = B.CustomerAcID and Z.EffectiveToTimeKey = 49999
--LEFT JOIN (select distinct CustomerAcid,AssetClassCode from [ENBD_STGDB].dbo.ACCOUNT_ALL_SOURCE_SYSTEM) ZZ ON B.CustomerAcID = ZZ.CustomerAcID
--where  B.FinalAssetClassAlt_Key>1  
--and ISNULL(Interest_DividendDueAmount,0) > 0 


end
GO