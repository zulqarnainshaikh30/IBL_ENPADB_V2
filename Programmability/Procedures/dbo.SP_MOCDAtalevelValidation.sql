SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SP_MOCDAtalevelValidation]
AS
------------------------CUSTOMER LEVEL MOC VERIFICATION
Select UCIFEntityid,A.CustomerEntityID,SysAssetClassAlt_Key,AssetClassAlt_Key,A.NPA_Date,B.SysNPA_Dt,
(CASE WHEN C.RefCustomerId is not NULL then 'Y' Else 'N' END)RestrcFlg 
,Asset_Norm
from MOC_ChangeDetails A
Inner join pro.CustomerCal B
on A.CustomerEntityID=B.CustomerEntityID
LEFT JOIN Curdat.AdvAcRestructureDetail C
ON B.RefCustomerID = C.RefCustomerId
AND C.EffectiveToTimeKey = 49999
where A.EffectiveFromTimeKey<=26267 and A.EffectiveToTimeKey>=26267
--and B.EffectiveFromTimeKey<=26288 and B.EffectiveToTimeKey>=26288
and MOCType_Flag='CUST' 
and AssetClassAlt_Key is not null
and C.RefCustomerId is  NULL
--and cast(MOC_Date as date) = '11/30/2021'
--and A.AssetClassAlt_Key!=B.SysAssetClassAlt_Key
 and NPA_Date != SysNPA_Dt
order by UCIFEntityid,A.CustomerEntityID

------------------------ACCOUNT LEVEL MOC VERIFICATION
Select UCIFEntityid,B.CustomerEntityid,B.RefCustomerID,B.AccountEntityID,B.CustomerAcID
FinalAssetClassAlt_Key,AssetClassAlt_Key,A.NPA_Date,B.FinalNpaDt 
,Asset_Norm,(CASE WHEN C.RefCustomerId is not NULL then 'Y' Else 'N' END)RestrcFlg 
from MOC_ChangeDetails A
Inner join pro.ACCOUNTCAL B
on A.CustomerEntityID=B.CustomerEntityID
LEFT JOIN Curdat.AdvAcRestructureDetail C
ON B.RefCustomerID = C.RefCustomerId
AND C.EffectiveToTimeKey = 49999
where A.EffectiveFromTimeKey<=26267 and A.EffectiveToTimeKey>=26267
--and B.EffectiveFromTimeKey<=26267 and B.EffectiveToTimeKey>=26267
and MOCType_Flag='CUST' and AssetClassAlt_Key is not null
and C.AccountEntityId is  NULL
--and cast(MOC_Date as date) = '11/30/2021'
--and A.NPA_Date!=B.FinalNpaDt
order by UCIFEntityid,A.CustomerEntityID

select * from MOC_ChangeDetails where CustomerEntityID in (1389484)
select FLGMOC,SysNPA_Dt,SysAssetClassAlt_Key,* from Pro.CustomerCAL where UCIF_ID = 'ENBD000004524'


------------------MOC IMPACTED ACCOUNTS COUNT
select count(distinct CustomerAcID)accno from Pro.Accountcal where UcifEntityID in (
select UcifEntityID from CustomerBasicDetail  
where CustomerEntityId in (
select distinct CustomerEntityID from MOC_ChangeDetails 
where EffectiveFromTimeKey = 26267  ))
GO