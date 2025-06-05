SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE FUNCTION [dbo].[AdvAcSecurityFun] (@Timekey Int  ,@BranchCode Varchar(8)) 
RETURNS TABLE 
AS 
RETURN  
SELECT   
AccountEntityId,BranchCode , 
  SUM(ISNULL(Total_PriSec,0))   Total_PriSec
, SUM(ISNULL(Total_CollSec,0))   Total_CollSec
, SUM(ISNULL(CRM_PriSec,0))   CRM_PriSec
, SUM(ISNULL(CRM_CollSec,0))    CRM_CollSec  
, SUM(ISNULL(NONCRM_PriSec,0))   NONCRM_PriSec   
, SUM(ISNULL(NONCRM_CollSec,0))   NONCRM_CollSec   
FROM 
( 
SELECT 
ABD.AccountEntityId,ABD.BranchCode 
,(CASE WHEN Advsec.Securitytype = 'P' THEN 'Total_PriSec' else 'Total_CollSec' end)  TotalSecurity

,(CASE WHEN Advsec.Securitytype = 'P' THEN 'CRM_PriSec' else 'CRM_CollSec' end) CRMSecurity

,(CASE WHEN Advsec.Securitytype = 'P' THEN 'NONCRM_PriSec' else 'NONCRM_CollSec' end) NonCRMSecurity

,ISNULL(CurrentValue,0) as TotalSec

,CASE WHEN SecM.SrcSecurityCode IN ('CASHM01','DEPOS01','GOLJW01') THEN (ISNULL(CurrentValue,0)) END AS Sec_CRM

,CASE WHEN SecM.SrcSecurityCode not IN ('CASHM01','DEPOS01','GOLJW01')  THEN (ISNULL(CurrentValue,0)) END AS Sec_NONCRM

FROM 
dbo.AdvAcBasicDetail ABD INNER  JOIN CURDAT.AdvSecurityDetail Advsec 
on 
Advsec.AccountEntityId=ABD.AccountEntityId INNER JOIN curdat.AdvSecurityValueDetail Sec 
ON  
ABD.EffectiveFromTimeKey < = @Timekey  
AND ABD.EffectiveToTimeKey >= @Timekey 
AND Sec.EffectiveFromTimeKey < = @Timekey
AND Sec.EffectiveToTimeKey > = @Timekey
AND Advsec.SecurityEntityID=Sec.SecurityEntityID
AND ( Advsec.EffectiveFromTimeKey < = @TimeKey AND Advsec.EffectiveToTimeKey   >= @TimeKey)
INNER JOIN DimCollateralSubType SecM 
ON  
SecM.EffectiveFromTimeKey < = @Timekey
AND SecM.EffectiveToTimeKey >= @Timekey
AND SecM.CollateralSubTypeAltKey = Advsec.SecurityAlt_Key
WHERE 
ABD.BranchCode = (CASE WHEN ISNULL(@BranchCode,'')='0' THEN ABD.BranchCode ELSE @BranchCode END )
---As per bank mail dated 03/09/2022 Modification Done By Triloki Khanna 06/09/2022 --
and (isnull(ValuationExpiryDate,'1900-01-01')>=case when SecM.SrcSecurityCode in('EQUIP01','FURF01','MACH01','MTGFA01','VEH01') then (SELECT Date FROM utks_MISDB.[dbo].Automate_Advances WHERE EXT_FLG='Y') else '1900-01-01' end )
) Src  
PIVOT (SUM(TotalSec) FOR TotalSecurity IN (Total_PriSec,Total_CollSec)) TotSec 
PIVOT (SUM(Sec_CRM) FOR CRMSecurity IN (CRM_PriSec,CRM_CollSec)) CRMSec 
PIVOT (SUM(Sec_NONCRM) FOR NonCRMSecurity IN (NONCRM_PriSec,NONCRM_CollSec))  NonCRMSec 
GROUP BY AccountEntityId,BranchCode 

GO