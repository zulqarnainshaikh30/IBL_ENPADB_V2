SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*

CREATE BY           : Baijayanti
CREATE DATE         : 16-08-2022
DISCRIPTION         : NPA Movement Report

*/
--exec [dbo].[Rpt-015]  '27/11/2022','27/11/2023'

CREATE PROC [dbo].[Rpt-015] 
  @FromDate   AS VARCHAR(15)
 ,@ToDate     AS VARCHAR(15)
AS
 

--DECLARE
--  @FromDate   AS VARCHAR(15)='01/10/2022'
-- ,@ToDate     AS VARCHAR(15)='31/10/2022'


SET NOCOUNT ON ; 

 

DECLARE @From1  DATE=(SELECT Rdate FROM dbo.DateConvert(@FromDate))
DECLARE @To1    DATE=(SELECT Rdate FROM dbo.DateConvert(@ToDate))

DECLARE @TimeKey  AS INT=(SELECT TimeKey FROM SysDayMatrix WHERE DATE=@To1)


DECLARE @FromTimeKey INT=(SELECT TimeKey FROM Sysdaymatrix WHERE [DATE]=@From1)
DECLARE @ToTimeKey INT=(SELECT TimeKey FROM Sysdaymatrix WHERE [DATE]=@To1)

---------------------------------------------Final Selection---------------------------


SELECT

CONVERT(VARCHAR(20),NPAProcessingDate,103)                          AS Created_Date,
Movement_Flag,
NPAM.CustomerAcid,
DACI.AssetClassGroup                                                AS I_AssetClassGroup,
CONVERT(VARCHAR(20),ACFD.FinalNpaDt,103)                                     AS NPADt
,(CASE WHEN FlgErosion = 'Y' and ACFD.FinalAssetClassAlt_Key =3 THEN CONVERT(VARCHAR(20),DATEADD(YYYY,1,F.DbtDt),103) 
		WHEN (FlgFraud = 'Y' OR ISNULL(WriteoffAmount,0) > 0) THEN CASE WHEN ACFD.InitialAssetClassAlt_Key < 3  THEN '' ELSE CONVERT(VARCHAR(20),DATEADD(YYYY,1,F.DbtDt),103) END 
		WHEN (FlgErosion = 'N' AND FlgFraud = 'N' AND ISNULL(WriteoffAmount,0) = 0) and ACFD.Asset_Norm <> 'ALWYS_NPA' and ACFD.FinalAssetClassAlt_key >= 3 THEN CONVERT(VARCHAR(20),DATEADD(YYYY,1,ACFD.FinalNpaDt),103)  
		ELSE  ''
 END) AS DB1dt
,(CASE	WHEN ACFD.FinalAssetClassAlt_key >= 4 THEN CASE	WHEN (FlgErosion = 'Y' OR FlgFraud = 'Y' OR ISNULL(WriteoffAmount,0) > 0) OR ACFD.Asset_Norm <> 'ALWYS_NPA'
													THEN ''  
													ELSE CONVERT(VARCHAR(20),DATEADD(YYYY,2,ACFD.FinalNpaDt),103) END	ELSE '' END)			   AS DB2dt

,(CASE	WHEN ACFD.FinalAssetClassAlt_key >= 5 THEN CASE	WHEN (FlgErosion = 'Y' OR FlgFraud = 'Y' OR ISNULL(WriteoffAmount,0) > 0)  OR ACFD.Asset_Norm <> 'ALWYS_NPA'
													THEN ''  
													ELSE CONVERT(VARCHAR(20),DATEADD(YYYY,4,ACFD.FinalNpaDt),103) END	ELSE '' END)					   AS DB3dt
,CASE WHEN ACFD.FinalAssetClassAlt_Key = 6 THEN CONVERT(VARCHAR(20),ISNULL(ACND.LosDt,ACND.NPADt),103)    ELSE '' END                                  AS LossDt,
ISNULL(InitialNPABalance,0)                                         AS InitialNPABalance,
ISNULL(InitialUnservicedInterest,0)                                 AS InitialUnservicedInterest,
ISNULL(InitialGNPABalance,0)                                        AS InitialGNPABalance,
ISNULL(InitialProvision,0)                                          AS InitialProvision,
ISNULL(InitialNNPABalance,0)                                        AS InitialNNPABalance,
ISNULL(ExistingNPA_Addition,0)                                      AS ExistingNPA_Addition,
ISNULL(FreshNPA_Addition,0)                                         AS FreshNPA_Addition,
ISNULL(ReductionDuetoUpgradeAmount,0)                               AS ReductionDuetoUpgradeAmount,
ISNULL(ReductionDuetoRecovery_ExistingNPA,0)                        AS ReductionDuetoRecovery_ExistingNPA,
ISNULL(ReductionDuetoWrite_OffAmount,0)                             AS ReductionDuetoWrite_OffAmount,
ISNULL(ReductionDuetoRecovery_Arcs,0)                               AS ReductionDuetoRecovery_Arcs,
DACF.AssetClassGroup                                                AS F_AssetClassGroup,
MovementNature,
ISNULL(FinalNPABalance,0)                                           AS FinalNPABalance,
ISNULL(FinalUnservicedInterest,0)                                   AS FinalUnservicedInterest,
ISNULL(FinalGNPABalance,0)                                          AS FinalGNPABalance,
MovementStatus,
ISNULL(FinalProvision,0)                                            AS FinalProvision,
ISNULL(FinalNNPABalance,0)                                          AS FinalNNPABalance,
ISNULL(TotalAddition_GNPA,0)                                        AS TotalAddition_GNPA,
ISNULL(TotalReduction_GNPA,0)                                       AS TotalReduction_GNPA,
ISNULL(TotalAddition_Provision,0)                                   AS TotalAddition_Provision,
ISNULL(TotalReduction_Provision,0)                                  AS TotalReduction_Provision,
ISNULL(TotalAddition_UnservicedInterest,0)                          AS TotalAddition_UnservicedInterest,
ISNULL(TotalReduction_UnservicedInterest,0)                         AS TotalReduction_UnservicedInterest

FROM NPAMovement NPAM
INNER JOIN DimAssetClass DACI              ON NPAM.InitialAssetClassAlt_Key=DACI.AssetClassAlt_Key
                                              AND DACI.EffectiveFromTimeKey<=@ToTimeKey AND DACI.EffectiveToTimeKey>=@FromTimeKey

INNER JOIN DimAssetClass DACF              ON NPAM.FinalAssetClassAlt_Key=DACF.AssetClassAlt_Key
                                              AND DACF.EffectiveFromTimeKey<=@ToTimeKey AND DACF.EffectiveToTimeKey>=@FromTimeKey

LEFT JOIN PRO.accountcal_hist ACFD        ON ACFD.CustomerACID=NPAM.CustomerACID
                                              AND ACFD.EffectiveFromTimeKey<=@ToTimeKey AND ACFD.EffectiveToTimeKey>=@FromTimeKey

LEFT JOIN Pro.CustomerCal_Hist F                 ON F.CustomerEntityId=ACFD.CustomerEntityId 
                                                     AND F.EffectiveFromTimeKey<=@ToTimeKey  
												     AND F.EffectiveToTimeKey>=@FromTimeKey

 LEFT JOIN AdvCustNPADetail ACND                   ON ACND.CustomerEntityId=ACFD.CustomerEntityId 
  AND ACND.EffectiveFromTimeKey<=@ToTimeKey  
 AND ACND.EffectiveToTimeKey>=@FromTimeKey
												


WHERE NPAProcessingDate BETWEEN @From1 AND @To1 and ACFD.InitialAssetClassAlt_Key <> ACFD.FinalAssetClassAlt_Key




OPTION(RECOMPILE)
GO