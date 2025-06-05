SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
CREATED BY   :-Baijayanti
CREATED DATE :-12/08/2022
REPORT NAME  :-IBPC Report As On
*/


CREATE PROCEDURE [dbo].[Rpt-045]
      @TimeKey AS INT
AS

--DECLARE 
--      @TimeKey AS INT=26479


SELECT 

 DS.SourceName
,CustomerID
,CustomerName
,AccountID
,ISNULL(AccountBalance,0)         AS AccountBalance
,ISNULL(InterestReceivable,0)     AS InterestReceivable
,ISNULL(POS,0)                    AS POS
,PoolID
,PoolName
,PoolType
,CONVERT(VARCHAR(20),IBPCMarkingDate,103)               AS IBPCMarkingDate
,CONVERT(VARCHAR(20),MaturityDate,103)					AS MaturityDate
,CASE WHEN FlagAlt_Key='Y'	
      THEN 'Yes'
	  WHEN FlagAlt_Key='N'
	  THEN 'No'
	  END				                                AS IBPCFlag
,ISNULL(ExposureAmount,0)                               AS ExposureAmount
,CONVERT(VARCHAR(20),FinalNpaDt,103)                    AS NPADate
,AssetClassName                                         AS AssetClass
,ISNULL(TotalProvision,0)                               AS ProvisionAmount
,ISNULL(NetBalance,0)                                   AS NetBalanceProv
,ISNULL((ISNULL(TotalProvision,0)/NULLIF(NetBalance,0))*100,0)                                             AS ProvisionPer

FROM IBPCFinalPoolDetail IBPCD

INNER JOIN Pro.AccountCal_Hist ACH        ON ACH.CustomerAcID=IBPCD.AccountID
                                          AND  IBPCD.EffectiveFromTimeKey<=@TimeKey AND IBPCD.EffectiveToTimeKey>=@TimeKey
										  AND  ACH.EffectiveFromTimeKey<=@TimeKey AND ACH.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimSourceDB DS                 ON DS.SourceAlt_Key=IBPCD.SourceAlt_Key
                                          AND  IBPCD.EffectiveFromTimeKey<=@TimeKey AND IBPCD.EffectiveToTimeKey>=@TimeKey
                                          AND  DS.EffectiveFromTimeKey<=@TimeKey AND DS.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimAssetClass DAC              ON DAC.AssetClassAlt_Key=ACH.FinalAssetClassAlt_Key
                                          AND  DAC.EffectiveFromTimeKey<=@TimeKey AND DAC.EffectiveToTimeKey>=@TimeKey

OPTION(RECOMPILE)
GO