SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
CREATED BY  :-Baijayanti
CREATED DATE :-12/08/2022
REPORT NAME  :-Securitization Report As On
*/


CREATE PROCEDURE [dbo].[Rpt-042]
      @TimeKey AS INT
AS

--DECLARE 
--      @TimeKey AS INT=26372


SELECT 

DS.SourceName
,CustomerID
,CustomerName
,AccountID
,ISNULL(AccountBalance,0)                       AS AccountBalance
,ISNULL(InterestReceivable,0)                   AS InterestReceivable
,ISNULL(POS,0)                                  AS POS
,PoolID
,PoolName
,PoolType
,ISNULL(ExposureAmount,0)                       AS ExposureAmount
,CONVERT(VARCHAR(20),SecMarkingDate,103)        AS SecMarkingDate
,CONVERT(VARCHAR(20),ScrInDate,103)             AS ScrInDate
,CONVERT(VARCHAR(20),MaturityDate,103)          AS MaturityDate
,CASE WHEN FlagAlt_Key='Y'
      THEN 'Yes'
	  WHEN FlagAlt_Key='N'
	  THEN 'No'
	  END                                       AS ScrFlg
,ISNULL(InterestAccruedinRs,0)                  AS InterestAccruedinRs
,CONVERT(VARCHAR(20),FinalNpaDt,103)            AS NPADate
,AssetClassName                                 AS AssetClass
,ISNULL(TotalProvision,0)                       AS ProvisionAmount
,ISNULL(NetBalance,0)                           AS NetBalanceProv
,ISNULL((ISNULL(TotalProvision,0)/NULLIF(NetBalance,0))*100,0)                                             AS ProvisionPer
,0                           AS Assigned_Per
,0                            AS Remaining_Per

FROM SecuritizedFinalACDetail SFACD
INNER JOIN Pro.AccountCal_Hist ACH        ON ACH.CustomerAcID=SFACD.AccountID
                                          AND  SFACD.EffectiveFromTimeKey<=@TimeKey AND SFACD.EffectiveToTimeKey>=@TimeKey
										  AND  ACH.EffectiveFromTimeKey<=@TimeKey AND ACH.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimSourceDB DS                 ON DS.SourceAlt_Key=SFACD.SourceAlt_Key
                                          AND  DS.EffectiveFromTimeKey<=@TimeKey AND DS.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimAssetClass DAC              ON DAC.AssetClassAlt_Key=ACH.FinalAssetClassAlt_Key
                                          AND  DAC.EffectiveFromTimeKey<=@TimeKey AND DAC.EffectiveToTimeKey>=@TimeKey



OPTION(RECOMPILE)
GO