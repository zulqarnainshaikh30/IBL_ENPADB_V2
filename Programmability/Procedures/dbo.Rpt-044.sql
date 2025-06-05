SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
CREATED BY   :-Baijayanti
CREATED DATE :-12/08/2022
REPORT NAME  :-Buyout Report As On
*/


CREATE PROCEDURE [dbo].[Rpt-044]
      @TimeKey AS INT
AS

--DECLARE 
--      @TimeKey AS INT=26936

	  
DECLARE @Date AS DATE=(SELECT DATE FROM Automate_Advances WHERE TimeKey=@TimeKey) 
SELECT DISTINCT
 --CIFId
--,ENBDAcNo											 AS AUNo
BuyoutPartyLoanNo
,CustomerName
,CONVERT(VARCHAR(20),NPADate,103)					 AS FinalNpaDt

--,AssetClass											 AS AssetClass
,CASE 
--WHEN PACC.FinalAssetClassAlt_Key=1 and PACC.SMA_Class='STD' then 'A0'
WHEN FinalAssetClassAlt_Key=1 and AssetClass ='STD'then 'A0'
WHEN FinalAssetClassAlt_Key=1 and AssetClass='SMA-0' then 'S0'
WHEN FinalAssetClassAlt_Key=1 and AssetClass='SMA-1' then 'S1'
WHEN FinalAssetClassAlt_Key=1 and AssetClass='SMA-2' then 'S2'
WHEN FinalAssetClassAlt_Key=1 and AssetClass='SMA-3' then 'S3'
WHEN FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) <=91 then 'B0'
WHEN FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) between 91 and 183 then 'B1'
WHEN FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) between 183 and 274 then 'B2'
WHEN FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) >=273 then 'B3'
WHEN finalassetclassalt_key=3 then 'C1'
WHEN finalassetclassalt_key=4 then 'C2'
WHEN FinalAssetClassAlt_Key=5 then 'C3'
WHEN FinalAssetClassAlt_Key=6 then 'D0'
END AS AssetClass
,DPD												 AS DPD
--,DP.ProductCode
--,DP.ProductName
--,ISNULL(Balance,0)                            AS Balance
,ISNULL(NetBalance,0)                         AS NetBalance
,ISNULL(TotalProvision,0)                     AS TotalProvision
,ISNULL((ISNULL(TotalProvision,0)/NULLIF(NetBalance,0))*100,0)             AS FinalProvPercentage
,ISNULL(InterestReceivable,0)                      AS InterestReceivable
,ISNULL(PrincipalOutstanding,0)                    AS PrincipalOutstanding
,PoolName                                          AS PoolName
,Category                                          AS Category
,Charges                                           AS Charges
,ISNULL(AccuredInterest,0)				           AS AccuredInterest
,ISNULL(InterestOverdue,0)						   AS InterestOverdue
--,[Action]
--,CONVERT(VARCHAR(20),OverDueSinceDt,103)       AS OverDueDate

FROM  BuyoutDetails_Final  BOFD
--INNER JOIN Pro.AccountCal_Hist ACH                                  ON ACH.CustomerAcID=BOFD.ENBDAcNo
--										                               AND  ACH.EffectiveFromTimeKey<=@TimeKey AND ACH.EffectiveToTimeKey>=@TimeKey
										                            
--INNER JOIN Pro.CustomerCal_Hist CCH                                 ON ACH.RefCustomerID=CCH.RefCustomerID
--										                               AND  CCH.EffectiveFromTimeKey<=@TimeKey AND CCH.EffectiveToTimeKey>=@TimeKey
										                            
--LEFT JOIN AdvAcOtherFinancialDetail ACOFD                           ON ACH.AccountEntityID=ACOFD.AccountEntityID
--										                               AND  ACOFD.EffectiveFromTimeKey<=@TimeKey AND ACOFD.EffectiveToTimeKey>=@TimeKey                       
										                            
--LEFT JOIN DimProduct DP                                             ON ACH.ProductAlt_Key=DP.ProductAlt_Key
--										                               AND  DP.EffectiveFromTimeKey<=@TimeKey AND DP.EffectiveToTimeKey>=@TimeKey

WHERE   BOFD.EffectiveFromTimeKey<=@TimeKey AND BOFD.EffectiveToTimeKey>=@TimeKey

ORDER BY FinalNpaDt DESC
OPTION(RECOMPILE)
GO