SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[PUI_Output]
aS
--select * from  PUI_DATA_30112021
SELECT 
	 b.UCIF_ID UCIC
	,C.CustomerId,C.CustomerName,B.CustomerAcID,B.ProductCode
	,aCl1.AssetClassShortName PrevAssetClass
	,aCl2.AssetClassShortName CurrentAssetClass
	,pc.ProjectCategoryDescription ProjectCategory
	,psc.ProjectCategorySubTypeDescription [Project Sub Category]
	,ow.ParameterName Projectownersip
	,auth.ParameterName ProjectAuthority
	,A.OriginalDCCO
	,A.OriginalProjectCost
	,a.CostOverRunPer
	,a.CostOverrun
	,A.OriginalDebt
	,A.Debt_EquityRatio
	,A.ChangeinProjectScope
	,A.FreshOriginalDCCO
	,A.RevisedDCCO
	,A.InitialExtension
	,A.BeyonControlofPromoters
	,A.CourtCaseArbitration
	,a.ChangeinProjectScope
	,A.CIOReferenceDate
	,A.CIODCCO
	,A.TakeOutFinance
	,AcL3.AssetClassShortName AssetClassSellerBook
	,A.NPADateSellerBook
	,A.Restructuring

	,A.DelayReasonOther
	,A.FLG_UPG
	,A.FLG_DEG
	,A.DEFAULT_REASON
	,A.ProjCategory
	,A.NPA_DATE
	,A.PUI_ProvPer
	,A.RestructureDate
	,A.ActualDCCO
	,A.ActualDCCO_Date
	,A.UpgradeDate
	,A.SecuredProvision  PUI_SecuredProvision	
	,a.UnSecuredProvision PUI_UnSecuredProvision	
	,A.FLG_DEG PUI_FlgDeg	
	,A.FLG_UPG PUI_FlgUpg	
	,SecuredAmt	
	,UnSecuredAmt	
	,BankTotalProvision	
	,RBITotalProvision	
	,isnull(A.SecuredProvision,0)+isnull(a.UnSecuredProvision,0) PUI_Provision	
	,TotalProvision
	,pps.RM_CreditOfficer
FROM PRO.PUI_CAL A
	INNER JOIN pro.ACCOUNTCAL b
		ON a.AccountEntityID=B.AccountEntityID

	inner join AdvAcPUIDetailMain pp
		on pp.EffectiveToTimeKey=49999
		and pp.AccountEntityId =a.AccountEntityId
	inner join AdvAcPUIDetailSub pps
		on pps.EffectiveToTimeKey=49999
		and pps.AccountEntityId =a.AccountEntityId

	INNER jOIN CustomerBasicDetail c
		ON c.CustomerEntityId =B.CustomerEntityID
	iNneR jOiN DimAssetClass Acl1
		ON aCl1.EffectiveToTimeKey =49999
		anD aCl1.AssetClassAlt_Key =b.InitialAssetClassAlt_Key
	INNER JOIN DimAssetClass Acl2
		ON aCl2.EffectiveToTimeKey =49999
		anD aCl2.AssetClassAlt_Key =b.FinalAssetClassAlt_Key
	LEfT JOIN DimAssetClass Acl3
		ON aCl3.EffectiveToTimeKey =49999
		anD aCl3.AssetClassAlt_Key =a.AssetClassSellerBookAlt_key
	--INNeR jOIN ENBD_PUI_DATA aa
	--	ON b.CustomerAcID=aa.[Account ID]
	left join ProjectCategory pc
		on pc.EffectiveToTimeKey=49999
		and pc.ProjectCategoryAltKey=pp.ProjectCategoryAlt_Key
	left join ProjectCategorySubType  psc
		on psc.EffectiveToTimeKey=49999
		and psc.ProjectCategorySubTypeAltKey=pp.ProjectSubCategoryAlt_key
	LEFT JOIN DimParameter OW
		ON OW.EffectiveToTimeKey=49999
		and ow.ParameterAlt_Key=pp.ProjectOwnerShipAlt_Key
		AND OW.DimParameterName ='ProjectOwnership'	
	LEFT JOIN DimParameter auth
		ON OW.EffectiveToTimeKey=49999
		and ow.ParameterAlt_Key=pp.ProjectAuthorityAlt_key
		AND OW.DimParameterName ='ProjectAuthority'	

--order by b.FinalAssetClassAlt_Key


GO