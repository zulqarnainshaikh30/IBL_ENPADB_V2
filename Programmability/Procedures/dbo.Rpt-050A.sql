SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
 CREATE BY   :- Baijayanti
 CREATE DATE :- 28/09/2022
 DESCRIPTION :- Calypso For RFA Fraud Report

 */ 

CREATE PROCEDURE [dbo].[Rpt-050A]	
    @TimeKey AS INT,
	@SelectReport AS INT
	
AS

--DECLARE
--    @Timekey AS INT=26479,
--	@SelectReport AS INT=2
	

DECLARE @CurDate AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)

SELECT
DISTINCT
IID.UcifId                                                                 AS UCIC_ID,
IID.IssuerID                                                               AS IssuerID,
IID.IssuerName                                                             AS IssuerName,
IBD.InvID                                                                  AS 'InvestmentID/Derv No.',											                       														                       
ISNULL(IFD.BookValueINR,0)                                                 AS [Total Outstandings in LCY],
ISNULL(IFD.MTMValueINR,0)                                                  AS [MTM Values of Treasury products],
0                                                                          AS [Investment in LCY],
CONVERT(VARCHAR(20),RFA_DateReportingByBank,103)                              AS [Date of Classification as Red Flag Account],
CONVERT(VARCHAR(20),DateofRemovalofRFAClassification,103)                  AS [Date of Re-classification from Red Flag Account Status],
(CASE WHEN CONVERT(VARCHAR(20),DateofRemovalofRFAClassification,103) is  NULL THEN 
CASE WHEN DATEDIFF(DD,DATEADD(mm,6,rfa_datereportingbybank),@CurDate) < 0 THEN 0 ELSE DATEDIFF(DD,DATEADD(mm,6,rfa_datereportingbybank),@CurDate) END ELSE ''  END)                                   AS [Days Delay (over six months from classification) in reclassification of RFA],
CONVERT(VARCHAR(20),FraudOccuranceDate,103)                                AS [Date of Classification as Fraud],
CASE WHEN DA.AssetClassName='LOS'
     THEN 'LOSS'
	 ELSE DA.AssetClassName
	 END                                                                   AS NPIAssetClass,
CONVERT(VARCHAR(20),IFD.NPIDt,103)                                         AS [NPA Date],
'Investment'                                                               AS Flag


FROM dbo.InvestmentBasicDetail IBD

INNER JOIN DBO.InvestmentFinancialdetail     IFD			ON  IFD.InvEntityId=IBD.InvEntityId 
															    AND IFD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IFD.EffectiveToTimeKey>=@TimeKey
																AND IBD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IBD.EffectiveToTimeKey>=@TimeKey
																
INNER JOIN DBO.InvestmentIssuerDetail   IID				    ON  IID.IssuerEntityId=IBD.IssuerEntityId 
															    AND IID.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IID.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimAssetClass DA                                 ON DA.AssetClassAlt_Key=IFD.FinalAssetClassAlt_Key
                                                                AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DA.EffectiveToTimeKey>=@TimeKey


INNER JOIN	 Fraud_Details		FD							ON  IBD.InvID=FD.RefCustomerACID 
															    AND FD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND FD.EffectiveToTimeKey>=@TimeKey

WHERE  @SelectReport=2 


UNION ALL

SELECT
DISTINCT
UCIC_ID,
CustomerID                                                                 AS IssuerID,
CustomerName                                                               AS IssuerName,
DerivativeRefNo                                                            AS 'InvestmentID/Derv No.',
ISNULL(MTMIncomeAmt,0)                                                     AS [Total Outstandings in LCY],
ISNULL(MTMIncomeAmt,0)                                                     AS [MTM Values of Treasury products],
0                                                                          AS [Investment in LCY],
CONVERT(VARCHAR(20),RFA_DateReportingByBank,103)                             AS [Date of Classification as Red Flag Account],
CONVERT(VARCHAR(20),DateofRemovalofRFAClassification,103)                  AS [Date of Re-classification from Red Flag Account Status],
(CASE WHEN CONVERT(VARCHAR(20),DateofRemovalofRFAClassification,103) is  NULL THEN 
CASE WHEN DATEDIFF(DD,DATEADD(mm,6,rfa_datereportingbybank),@CurDate) < 0 THEN 0 ELSE DATEDIFF(DD,DATEADD(mm,6,rfa_datereportingbybank),@CurDate) END ELSE ''  END)           AS [Days Delay (over six months from classification) in reclassification of RFA],
CONVERT(VARCHAR(20),FraudOccuranceDate,103)                                AS [Date of Classification as Fraud],
CASE WHEN DA.AssetClassName='LOS'
     THEN 'LOSS'
	 ELSE DA.AssetClassName
	 END                                                                   AS NPIAssetClass,
CONVERT(VARCHAR(20),Derivative.NPIDt,103)                                  AS NPADate,													                       													                       
'Derivative'                                                               AS Flag

FROM CURDAT.DerivativeDetail Derivative
INNER JOIN DimAssetClass DA                        ON DA.AssetClassAlt_Key=Derivative.FinalAssetClassAlt_Key
                                                      AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                      AND DA.EffectiveToTimeKey>=@TimeKey

INNER JOIN Fraud_Details		FD				   ON  Derivative.DerivativeRefNo=FD.RefCustomerACID 
													  AND FD.EffectiveFromTimeKey<=@TimeKey 
                                                      AND FD.EffectiveToTimeKey>=@TimeKey

WHERE  @SelectReport=2 AND Derivative.EffectiveFromTimeKey<=@TimeKey AND Derivative.EffectiveToTimeKey>=@TimeKey
	
ORDER BY UCIC_ID															

OPTION(RECOMPILE)

																


   
GO