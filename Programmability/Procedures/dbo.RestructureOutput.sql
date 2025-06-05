SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE proc [dbo].[RestructureOutput]
as
 

declarE @dATE dATE = (SELECT DATE FROM Automate_Advances WHERE eXT_FLG = 'y')
delete from RestrOutput where cast(createddate  as date) = CAST((SELECT DATE FROM Automate_Advances WHERE eXT_FLG = 'y') AS DATE)

INSERT INTO RestrOutput
select
a.RefCustomerID	 CustomerID
,a.CustomerAcID	
,rt.ParameterName TypeOfRestructure	
,cc.ParameterName Covid_Category	
,b.RestructureDt
,pr.AssetClassShortName Pre_Restr_AssetClass	
,b.PreRestructureNPA_Prov
,c.PreRestructureNPA_Date	
----,ins.AssetClassShortName Previous_AssetClass
--,InitialNpaDt
,AcL.AssetClassShortName Current_AssetClass	
,a.FinalNpaDt CurrentNPA_Date	
,a.DPD_Max 
,B.DPD_Breach_Date	
,B.ZeroDPD_Date	 ExtendedExpirePeriod_StartDAte
,Res_POS_to_CurrentPOS_Per	
,B.POS_10PerPaidDate
,b.RestructureStage
,Ai.AssetClassShortName AssetClass_On_Iinvocation	
,B.ProvPerOnRestrucure
,NetBalance	
,b.RestructurePOS	
,B.CurrentPOS	
,BALANCE	
,C.PrincRepayStartDate	
,c.InttRepayStartDate	
,SP_ExpiryDate	
,B.SP_ExpiryExtendedDate	
,b.AddlProvPer RestrProvPer	
,ProvReleasePer	
,AppliedNormalProvPer	
,FinalProvPer	
,b.PreDegProvPer	
,b.UpgradeDate	
,b.SurvPeriodEndDate	
,DegDurSP_PeriodProvPer	
,RestructureProvision	
,b.SecuredProvision  RESTR_SecuredProvision	
,B.UnSecuredProvision RESTR_UnSecuredProvision	
,b.FlgDeg RESTR_FlgDeg	
,b.FlgUpg RESTR_FlgUpg	
,SecuredAmt	
,UnSecuredAmt	
,BankTotalProvision	
,RBITotalProvision		
,TotalProvision

--,cast(case when isnull(cc.Parametershortnameenum,'')='MSME_OLD'
--	then ISNULL(TotalProvision,0)*100/(case when isnull(CurrentPos,0)=0 then 1 else isnull(CurrentPos,0) end)
--	  else   ISNULL(TotalProvision,0)*100/(case when isnull(NetBalance,0)=0 then 1 else isnull(NetBalance,0) end )
--   end  as decimal(5,2))  AppliedProvPer
,case when (isnull(AppliedNormalProvPer,0)+	isnull(FinalProvPer,0))>100
		then 100
		else (isnull(AppliedNormalProvPer,0)+	isnull(FinalProvPer,0))
		end AppliedProvPer
,cast(@dATE as date)CreatedDate
,Asset_Norm
,left(NPA_Reason,200) NPA_Reason
,left(a.DegReason,200) DegReason
,a.UCIF_ID UCIC
,A.AcOpenDt
,RF.ParameterName RestructureFacility
,B.FlgMorat
,B.DPD_MAXFIN
,B.DPD_MAXNONFIN
,a.DPD_Overdrawn
,a.FacilityType
---SELECT A.FinalAssetClassAlt_Key,A.InitialAssetClassAlt_Key,ACL.AssetClassShortName
from pro.ACCOUNTCAL  A
	INNER JOIN pro.AdvAcRestructureCal b
		On a.AccountEntityID =b.AccountEntityId
	----	AND A.AccountEntityID =2254734
	inner join DimProduct  pp
		on pp.ProductAlt_Key =a.ProductAlt_Key
		and pp.EffectiveToTimeKey =49999
	inner JoiN AdvAcRestructureDetail c
			on c.AccountEntityId=a.AccountEntityID
	leFt join DimParameter RF
		on RF.EffectiveToTimeKey =49999
		and RF.ParameterAlt_Key =c.RestructureFacilityTypeAlt_Key 
		and rF.DimParameterName ='RestructureFacility'
	leFt join DimParameter rT
		on rT.EffectiveToTimeKey =49999
		and Rt.ParameterAlt_Key =c.RestructureTypeAlt_Key 
		and rt.DimParameterName ='TypeofRestructuring'
	leFt join DimParameter cc
		on cc.EffectiveToTimeKey =49999
		and cc.ParameterAlt_Key =c.COVID_OTR_CatgAlt_Key 
		and cc.DimParameterName ='Covid - OTR Category'
	left join DimAssetClass AI
		on ai.EffectiveToTimeKey =49999
		and ai.AssetClassAlt_Key =c.AssetClassAlt_KeyOnInvocation
	left join DimAssetClass pr
		on pr.EffectiveToTimeKey =49999
		and pr.AssetClassAlt_Key =c.PreRestructureAssetClassAlt_Key
	left join DimAssetClass acl
		on acL.EffectiveToTimeKey =49999
		and acl.AssetClassAlt_Key =a.FinalAssetClassAlt_Key

	left join DimAssetClass Ins
		on Ins.EffectiveToTimeKey =49999
		and Ins.AssetClassAlt_Key =a.InitialAssetClassAlt_Key
	----inner join ENBD_RESTR_dATA ss
	----	ON ss.RefSystemAcId=a.CustomerACID

	
ORDER BY 3,4


select 
UCIC
,CustomerID
,CustomerAcID
,FacilityType
,AcOpenDt
,RestructureFacility
,TypeOfRestructure
,Covid_Category
,FlgMorat
,RestructureDt
,Pre_Restr_AssetClass
,PreRestructureNPA_Prov
,PreRestructureNPA_Date
,Current_AssetClass
,CurrentNPA_Date
,DPD_Max
,DPD_MAXFIN
,DPD_MAXNONFIN
,DPD_Overdrawn
,DPD_Breach_Date
,ZeroDPD_Date
,Res_POS_to_CurrentPOS_Per
,RestructureStage
,AssetClass_On_Iinvocation
,ProvPerOnRestrucure
,NetBalance
,RestructurePOS
,CurrentPOS
,BALANCE
,PrincRepayStartDate
,InttRepayStartDate
,SP_ExpiryDate
,SP_ExpiryExtendedDate
,PreDegProvPer
,UpgradeDate
-----,SurvPeriodEndDate
,DegDurSP_PeriodProvPer

,RESTR_FlgDeg
,RESTR_FlgUpg
,NPA_Reason
,DegReason
,SecuredAmt
,UnSecuredAmt
,RestrProvPer
,ProvReleasePer
,AppliedNormalProvPer
,FinalProvPer RestrFinalProvPer
,RestructureProvision
,RESTR_SecuredProvision
,RESTR_UnSecuredProvision
,BankTotalProvision
,RBITotalProvision
,TotalProvision
,AppliedProvPer
,CreatedDate
,Asset_Norm
from RestrOutput where cast(createddate  as date) = cast(@dATE as date)

GO