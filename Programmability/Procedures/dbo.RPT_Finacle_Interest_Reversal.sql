SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[RPT_Finacle_Interest_Reversal] 
@timekey int
AS

 --DECLARE @TIMEKEY INT = 49999
 select 
PA.UCIF_ID        as UCIC ,
PA.RefCustomerID  as Customer_ID,
PC.CustomerName   as Borrower_Name,
PA.BranchCode     as Branch_Code,
D.BranchName      as Branch_Name,
PA.CustomerAcID   as Account_No,
PA.FacilityType   as Facility,
dp.ProductCode    as Scheme_Code,
dp.ProductName    as Scheme_Description,
case when DA.AssetClassName = 'Los' then 'LOSS' end as  AssetClassName,
PA.FinalNpaDt     as NPA_Date,
case when  ISNULL(RestructureAmt,0)>0   THEN 'Yes'  ELSE 'No' end 'Restructured Y/N',
 PA.Balance        as Balance_Outstanding,
PA.PrincOutStd    as 'Principal O/S (POS)',
PA.IntOverdue     as Interest_Dues,
AfD.PenalOverdueinterest as Penal_Dues,
PA.OtherOverdue   as  Other_Dues,
AfD.UnAppliedIntAmount as Interest_accrued_but_not_due,
AfD.PenalUnAppliedIntAmount as Penal_accrued_but_not_due,
CASE WHEN FinalAssetClassAlt_key = 1 THEN 0 ELSE ISNULL(UnAppliedIntAmount,0)end IIS_Today,
CASE WHEN FinalAssetClassAlt_key = 1 THEN 0 ELSE ISNULL(UnAppliedIntAmount,0) end IIS_Yesterday,
CASE WHEN FinalAssetClassAlt_key = 1 THEN 0 ELSE (ISNULL(UnAppliedIntAmount,0)-ISNULL(UnAppliedIntAmount,0))end Change_in_IIS_Today,

CASE WHEN FinalAssetClassAlt_key = 1 THEN 0 ELSE ISNULL(UnAppliedIntAmount,0)end IIS_Last_Month, 
CASE WHEN FinalAssetClassAlt_key = 1 THEN 0 ELSE ISNULL(UnAppliedIntAmount,0)end IIS_Last_Fiscal_Year_End --

	   	     from Pro.AccountCal_Hist PA
 left join Pro.CustomerCal_Hist PC       on PA.BranchCode=PC.BranchCode and PA.EffectiveFromTimeKey>=@TIMEKEY and pa.EffectiveToTimeKey<=@TIMEKEY
 left join DimBranch D                   on D.BranchCode=PA.BranchCode and D.EffectiveFromTimeKey>=@TIMEKEY and D.EffectiveToTimeKey<=@TIMEKEY
 left join DimProduct dp                 on dp.ProductAlt_Key=PA.ProductAlt_Key and dp.EffectiveFromTimeKey>=@TIMEKEY and dp.EffectiveToTimeKey<=@TIMEKEY
 left join DimAssetClass DA              on DA.AssetClass_Key=PA.FinalAssetClassAlt_Key and DA.EffectiveFromTimeKey>=@TIMEKEY and DA.EffectiveToTimeKey<=@TIMEKEY 
 left join AdvAcRestructureDetail AR     on AR.AccountEntityID=PA.AccountEntityId and AR.EffectiveFromTimeKey>=@TIMEKEY and AR.EffectiveToTimeKey<=@TIMEKEY 
 left join AdvAcOtherFinancialDetail AfD on AfD.EntityKey= PA.ENTITYKEY and AfD.EffectiveFromTimeKey>=@TIMEKEY and AfD.EffectiveToTimeKey<=@TIMEKEY 

 where FinalAssetClassAlt_key > 1

 ----(Yesterday TimeKey Parameter Data)
 ----(Current TimeKey Data -Yesterday TimeKey Data)
 ----(Last Month TimeKey Parameter Data)
 --(Last Fin Year TimeKey Parameter Data)
 
GO