SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

/*
CREATED BY   :-Baijayanti
CREATED DATE :-30/08/2022
REPORT NAME  :-For Finacle RFA Fraud Report
*/


CREATE PROCEDURE [dbo].[Rpt-050]
      @TimeKey AS INT,
	  @SelectReport AS INT
AS

--DECLARE 
--      @TimeKey AS INT=26479,
--	  @SelectReport AS INT=1

DECLARE @CurDate AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)

SELECT 
DISTINCT
 ACH.UCIF_ID                                                     AS CIF
,CCH.RefCustomerID                                               AS CustomerID
,CCH.CustomerName                                                AS CustomerName
,FD.RefCustomerACID                                              AS AccountID
,''                                                              AS Industry
,ISNULL(FlgRestructure,'N')                                      AS [Restructured - Y/N]
,ISNULL(CurrentLimit,0)                                          AS [SANCTION_LIMIT_LCY]
,ISNULL(Balance,0)                                               AS [Total Outstandings in LCY]
,CONVERT(VARCHAR(20),rfa_datereportingbybank,103)                AS [Date of Classification as Red Flag Account]
,CONVERT(VARCHAR(20),DateofRemovalofRFAClassification,103)       AS [Date of Re-classification from Red Flag Account Status]
,(CASE WHEN CONVERT(VARCHAR(20),DateofRemovalofRFAClassification,103) is  NULL THEN 
CASE WHEN DATEDIFF(DD,DATEADD(mm,6,rfa_datereportingbybank),@CurDate) < 0 THEN 0 ELSE DATEDIFF(DD,DATEADD(mm,6,rfa_datereportingbybank),@CurDate) END ELSE ''  END) 
AS [Days Delay (over six months from classification) in reclassification of RFA]
,CONVERT(VARCHAR(20),FraudOccuranceDate,103)                     AS [Date of Classification as Fraud]
,ISNULL(CASE WHEN DAC.AssetClassName='LOS'
             THEN 'LOSS'
			 ELSE DAC.AssetClassName
			 END,CASE WHEN DAC1.AssetClassName='LOS'
             THEN 'LOSS'
			 ELSE DAC1.AssetClassName
			 END)                  AS [Asset Classification]
,CONVERT(VARCHAR(20),ACD.NPADt,103)                              AS [NPA Date]


 FROM Fraud_details FD
INNER JOIN Pro.AccountCal_Hist  ACH          ON  ACH.CustomerACID=FD.RefCustomerACID
                                                 AND  ACH.EffectiveFromTimeKey<=@TimeKey AND ACH.EffectiveToTimeKey>=@TimeKey

INNER JOIN Pro.CustomerCal_Hist  CCH         ON  CCH.RefCustomerID=ACH.RefCustomerID
                                                 AND  CCH.EffectiveFromTimeKey<=@TimeKey AND CCH.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvCustNPADetail  ACD              ON  ACD.RefCustomerID=ACH.RefCustomerID
                                                 AND  ACD.EffectiveFromTimeKey<=@TimeKey AND ACD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimAssetClass DAC                  ON DAC.AssetClassAlt_Key=ACD.Cust_AssetClassAlt_Key
                                                AND  DAC.EffectiveFromTimeKey<=@TimeKey AND DAC.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimAssetClass DAC1                 ON DAC1.AssetClassAlt_Key=ACH.FinalAssetClassAlt_Key
                                                AND  DAC1.EffectiveFromTimeKey<=@TimeKey AND DAC1.EffectiveToTimeKey>=@TimeKey

WHERE FD.EffectiveFromTimeKey<=@TimeKey AND FD.EffectiveToTimeKey>=@TimeKey AND @SelectReport=1


OPTION(RECOMPILE)
GO