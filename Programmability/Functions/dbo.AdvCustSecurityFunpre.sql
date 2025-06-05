SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



 

CREATE FUNCTION [dbo].[AdvCustSecurityFunpre] (@TimeKey Int)

RETURNS TABLE

AS

RETURN

 

---------------**********************************************************************************************************

---------------*************** PLS ALSO CHANGE IN AdvCustSecurityFun_BrWise IF ANY CHANGE IN THIS FUNCTION

---------------**********************************************************************************************************

 

SELECT CustomerEntityId,

                     SUM(Total_PriSec) AS Total_PriSec,

                     SUM(CRM_PriSec) AS CRM_PriSec,

                     SUM(NONCRM_PriSec) AS NONCRM_PriSec,

                     SUM(Total_CollSec) AS Total_CollSec,

                     SUM(CRM_CollSec) AS CRM_CollSec,

                     SUM(NONCRM_CollSec) AS NONCRM_CollSec,

                     SUM(TotNFSecurity) AS TotNFSecurity

              FROM (

 

                                  SELECT    CBD.CustomerEntityId

                                                ,CASE WHEN Advsec.Securitytype = 'P'

                                                       THEN ISNULL(CurrentValue,0) ELSE 0 END AS Total_PriSec

                                                ,CASE WHEN Advsec.Securitytype = 'P' AND  SecM.SrcSecurityCode IN ('CASHM01','DEPOS01','GOLJW01')     

                                                              THEN ISNULL(CurrentValue,0) ELSE 0 END AS CRM_PriSec 

                                                ,CASE WHEN Advsec.Securitytype = 'P' AND  SecM.SrcSecurityCode not IN ('CASHM01','DEPOS01','GOLJW01') 

                                                              THEN ISNULL(CurrentValue,0) ELSE 0 END AS NONCRM_PriSec 

                                                ,CASE WHEN Advsec.Securitytype = 'C'

                                                       THEN ISNULL(CurrentValue,0) ELSE 0 END AS Total_CollSec

                                                ,CASE WHEN Advsec.Securitytype = 'C' AND  SecM.SrcSecurityCode IN ('CASHM01','DEPOS01','GOLJW01')

                                                              THEN ISNULL(CurrentValue,0) ELSE 0 END AS CRM_CollSec 

                                                ,CASE WHEN Advsec.Securitytype = 'C' AND SecM.SrcSecurityCode not IN ('CASHM01','DEPOS01','GOLJW01')

                                                              THEN ISNULL(CurrentValue,0) ELSE 0 END AS NONCRM_CollSec

                                                ,0 AS TotNFSecurity

                                  FROM dbo.CustomerBasicDetail CBD

                                        

                                                INNER  JOIN CURDAT.AdvSecurityDetail Advsec on Advsec.CustomerEntityID = CBD.CustomerEntityID

                                         INNER JOIN AdvSecurityValueDetail Sec ON (SEC.EffectiveFromTimeKey < = @TimeKey AND SEC.EffectiveToTimeKey >= @TimeKey)

                                                                                                             

                                                                                                              AND Advsec.SecurityEntityID=Sec.SecurityEntityID

                                                                                                              AND Advsec.EffectiveFromTimeKey < = @Timekey

                                                                     AND Advsec.EffectiveToTimeKey > = @Timekey

                                         INNER JOIN DimCollateralSubType SecM On  (SecM.EffectiveFromTimeKey < = @TimeKey AND SecM.EffectiveToTimeKey >= @TimeKey)

                                                                                         AND SecM.CollateralSubTypeAltKey = Advsec.SecurityAlt_Key

                                         AND CBD.EffectiveFromTimeKey < = @Timekey

                                                                     AND CBD.EffectiveToTimeKey > = @Timekey

 ---As per bank mail dated 03/09/2022 Modification Done By Triloki Khanna 06/09/2022 --
 and (isnull(ValuationExpiryDate,'1900-01-01')>=case when SecM.SrcSecurityCode in('EQUIP01','FURF01','MACH01','MTGFA01','VEH01') then (SELECT Date FROM utks_MISDB.[dbo].Automate_Advances WHERE EXT_FLG='Y') else '1900-01-01' end )
                          

                           ) SEC

             

                           GROUP BY CustomerEntityId
GO