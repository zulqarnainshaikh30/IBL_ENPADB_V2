SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
CREATE BY		:	Baijayanti
CREATE DATE	    :	18-08-2022
DISCRIPTION		:   Security Erosion Report
*/

 CREATE PROC [dbo].[Rpt-014]  
  @TimeKey AS INT,
	@Valuation_Dt	AS	VARCHAR(10)
,@Security_type	AS	VARCHAR(10),
  @Cost    AS FLOAT
AS 

--DECLARE 
-- @TimeKey AS INT=27028
--,@Valuation_Dt	AS	VARCHAR(20)=NULL
--,@Security_type	AS	VARCHAR(20)=NULL
--,@Cost    AS FLOAT=1


SET NOCOUNT ON ;  

DECLARE @PerQtrKey INT=(SELECT TimeKey-1 FROM SysDayMatrix WHERE TimeKey=@TimeKey)
DECLARE @CurDate DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)

----------------------------------Security Data-------------------------
---------------------------=======================================
IF OBJECT_ID('tempdb..#SecurityValueDetails') IS NOT NULL 
	DROP TABLE #SecurityValueDetails

SELECT
AccountEntityId,
ASVD.ValuationDate,
ASVD.ValuationExpiryDate
,SecurityType
INTO #SecurityValueDetails
FROM AdvSecurityDetail  ASD
INNER JOIN AdvSecurityValueDetail  ASVD      ON  ASD.SecurityEntityID=ASVD.SecurityEntityID              
                                                 AND  ASD.EffectiveFromTimeKey<=@TimeKey AND  ASD.EffectiveToTimeKey>=@TimeKey
												 AND  ASVD.EffectiveFromTimeKey<=@TimeKey AND  ASVD.EffectiveToTimeKey>=@TimeKey 

OPTION(RECOMPILE)
-------------------------Per------------------------

IF(OBJECT_ID('tempdb..#DATA_PER') IS NOT NULL)
DROP TABLE #DATA_PER

SELECT
DISTINCT
ACH.RefCustomerID,
ACH.UCIF_ID,
CustomerAcID,
DAC.AssetClassName, 
ISNULL(ApprRV,0)             AS ApprRV,
ISNULL(Balance,0)            AS Balance,
ISNULL(SecuredAmt,0)         AS SecuredAmt
INTO #DATA_PER
FROM Pro.AccountCal_Hist ACH 
INNER JOIN Pro.CustomerCal_Hist CCH        ON ACH.RefCustomerID=CCH.RefCustomerID
                                              AND ACH.EffectiveFromTimeKey<=@PerQtrKey 
										      AND ACH.EffectiveToTimeKey>=@PerQtrKey
										      AND CCH.EffectiveFromTimeKey<=@PerQtrKey 
										      AND CCH.EffectiveToTimeKey>=@PerQtrKey

INNER JOIN DimAssetClass DAC              ON ACH.FinalAssetClassAlt_Key=DAC.AssetClassAlt_Key
                                             AND DAC.EffectiveFromTimeKey<=@PerQtrKey 
											 AND DAC.EffectiveToTimeKey>=@PerQtrKey

OPTION(RECOMPILE)

---------------------------------------------Final Selection---------------------------


SELECT 
DISTINCT
CONVERT(VARCHAR(20),@CurDate,103)                                               AS ReportDate,
ACH.UCIF_ID,
ACH.RefCustomerID,
CCH.CustomerName,
ACH.CustomerACID,
SecurityType,
CASE WHEN DATA.AssetClassName='LOS'
     THEN 'LOSS'
	 ELSE DATA.AssetClassName
	 END                                                                        AS [Prv Asset Class],
CONVERT(VARCHAR(20),ValuationDate ,103)                                         AS [Last Date of Valuation],
CONVERT(VARCHAR(20),ValuationExpiryDate,103)                                    AS [Valuation Expiry Date],
ISNULL(PrvQtrRV,0)/@Cost                                                        AS [Security Value as of yesterday],
ISNULL(DATA.ApprRV,0)/@Cost                                                     AS [Appr (Appropriated) RV (?) as of yesterday],
ISNULL(DATA.Balance,0)/@Cost                                                    AS [Balance Outstanding as of yesterday],
ISNULL(DATA.SecuredAmt,0)/@Cost                                                 AS [Secured balance Outstanding as of yesterday],
--CASE WHEN DAC.AssetClassName='LOS'
--     THEN 'LOSS'
--	 ELSE DAC.AssetClassName
--	 END                                                                        AS [Current Asset Class],
 
case 

when FinalAssetClassAlt_Key=1 and SMA_Class='STD' then 'A0'

when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_0' then 'S0'

when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_1' then 'S1'

when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_2' then 'S2'

when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_3' then 'S3'

when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@CurDate) <=91 then 'B0'

when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@CurDate) between 91 and 183 then 'B1'

when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@CurDate) between 183 and 274 then 'B2'

when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@CurDate) >=273 then 'B3'

when finalassetclassalt_key=3 then 'C1'

when finalassetclassalt_key=4 then 'C2'

when FinalAssetClassAlt_Key=5 then 'C3'

when FinalAssetClassAlt_Key=6 then 'D0'

end  AS [Current Asset Class],

ISNULL(CurntQtrRv,0)/@Cost                                                      AS [Current Security Value],
ISNULL(ACH.ApprRV,0)/@Cost                                                      AS [Current Appr RV], 
ISNULL(ACH.Balance,0)/@Cost                                                     AS [Current Balance Outstanding],
ISNULL(ACH.SecuredAmt,0)/@Cost                                                  AS [Current  Secured balance Outstanding] ,
CAST((((ISNULL(PrvQtrRV,0)- ISNULL(CurntQtrRv,0))/NULLIF(PrvQtrRV,0))*100)  AS DECIMAL(10,2))        AS [Security Erosion (%)],
CAST(ISNULL(((ISNULL(CurntQtrRv,0)/NULLIF(ACH.Balance,0))*100),0)  AS DECIMAL(10,2))			AS [Security Erosion OutStanding]

FROM Pro.AccountCal_Hist ACH 
INNER JOIN Pro.CustomerCal_Hist CCH        ON ACH.RefCustomerID=CCH.RefCustomerID
                                              AND ACH.EffectiveFromTimeKey<=@TimeKey 
										      AND ACH.EffectiveToTimeKey>=@TimeKey
										      AND CCH.EffectiveFromTimeKey<=@TimeKey 
										      AND CCH.EffectiveToTimeKey>=@TimeKey


LEFT JOIN #DATA_PER  DATA                  ON ACH.RefCustomerID=DATA.RefCustomerID
                                              AND ACH.UCIF_ID=DATA.UCIF_ID
											  AND ACH.CustomerACID=DATA.CustomerACID

LEFT JOIN #SecurityValueDetails  SVD       ON ACH.AccountEntityID=SVD.AccountEntityID


INNER JOIN DimAssetClass DAC               ON ACH.FinalAssetClassAlt_Key=DAC.AssetClassAlt_Key
                                              AND DAC.EffectiveFromTimeKey<=@TimeKey 
											  AND DAC.EffectiveToTimeKey>=@TimeKey
 

WHERE FlgErosion='Y'
--AND ACH.FirstDtOfDisb =(SELECT Rdate FROM dbo.DateConvert(@Valuation_Dt)) 
 AND (ACH.FirstDtOfDisb =(SELECT Rdate FROM dbo.DateConvert(@Valuation_Dt)) or @Valuation_Dt is null )
AND	(SecurityType=@Security_type OR @Security_type IS NULL)

OPTION(RECOMPILE)

--DROP TABLE #DATA_PER,#SecurityValueDetails
----SELECT * FROM #SecurityValueDetails 


 
GO