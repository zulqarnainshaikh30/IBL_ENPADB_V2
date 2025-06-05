SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
CREATED BY   :-Baijayanti
CREATED DATE :-12/12/2022
REPORT NAME  :-Industry Specific Provision Report
*/


CREATE PROCEDURE [dbo].[Rpt-053]
      @TimeKey AS INT
AS

--DECLARE 
--      @TimeKey AS INT=26479


SELECT 

 ACH.RefCustomerID                           AS CIF
,ACH.UCIF_ID                                 AS UCIC
,CCH.CustomerName                            AS [Borrower Name]
,ACH.CustomerAcID
,DP.ProductCode                              AS SchemeCode 
,DP.ProductName                              AS [Scheme Description]
,DAM.BSR_ActivityCode                        AS [BSR Activity Code]
,DAM.BSR_ActivityName                        AS [Description]
,DAm.BSR_ActivityGroup                       AS [Group] 
,DAM.BSR_ActivitySubDivision                 AS [Sub Division] 
,ISNULL(Balance,0)                           AS [Balance Outstanding]
,ISNULL(PrincOutStd,0)                       AS [Principal O/S (POS)]
,CONVERT(VARCHAR(20),SDM.[DATE],103)         AS [Provision for Date]
,ISNULL(ProvisionRate,0)                     AS [Provision %]
,ISNULL(TotalProvision,0)                    AS [Provision Amount]


FROM Pro.AccountCal_Hist ACH  

INNER JOIN	Pro.CustomerCal_Hist  CCH     ON ACH.RefCustomerID=CCH.RefCustomerID									    
                                             AND ACH.EffectiveFromTimeKey<=@TimeKey AND ACH.EffectiveToTimeKey>=@TimeKey
											 AND CCH.EffectiveFromTimeKey<=@TimeKey AND CCH.EffectiveToTimeKey>=@TimeKey

INNER JOIN SysDayMatrix SDM               ON SDM.TimeKey=ACH.EffectiveFromTimeKey

INNER JOIN DimIndustrySpecific DIS        ON DIS.CIF=ACH.RefCustomerID
                                             AND  DIS.EffectiveFromTimeKey<=@TimeKey AND DIS.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimBSRActivityMaster DAM       ON DIS.BSRActivityCode=DAM.BSR_ActivityCode
                                             AND  DAM.EffectiveFromTimeKey<=@TimeKey AND DAM.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimProduct DP                   ON DP.ProductAlt_Key=ACH.ProductAlt_Key
                                             AND  DP.EffectiveFromTimeKey<=@TimeKey AND DP.EffectiveToTimeKey>=@TimeKey
 

OPTION(RECOMPILE)


GO