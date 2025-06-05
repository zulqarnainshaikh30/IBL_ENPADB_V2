SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
 CREATE BY   :- Baijayanti
 CREATE DATE :- 19/09/2022
 DESCRIPTION :- Calypso For Interest Reversal Report

 */ 

 
CREATE PROCEDURE [dbo].[Rpt-049A]	
    @TimeKey AS INT,
	@Cost AS FLOAT,
	@SelectReport AS INT
	
AS

--DECLARE
--    @Timekey AS INT=26479,
--	@SelectReport AS INT=2,
--	@Cost AS FLOAT=1
	

DECLARE @CurDate AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@Timekey)
DECLARE @PrevDay AS INT=@TimeKey-1
DECLARE @LastMonthKey AS INT=(SELECT LastMonthDateKey FROM Sysdaymatrix WHERE Timekey=@TimeKey)
DECLARE @LastFinYearKey AS INT=(SELECT LastFinYearKey FROM Sysdaymatrix WHERE Timekey=@TimeKey)


SELECT
DISTINCT
CONVERT(VARCHAR(20),@CurDate,103)                                          AS ReportDate,
'Calypso'                                                                  AS SourceSystem,
DB.BranchName,
IID.UcifId                                                                 AS UCIC_ID,
IID.IssuerID                                                               AS IssuerID,
IID.IssuerName                                                             AS IssuerName,
''                                                                         AS ProductCode,
IBD.InvID                                                                  AS 'InvestmentID/Derv No.',
IFD.DPD                                                                    AS DPD,
--------CHANGED ON 18-04-2022--------------												                       
ISNULL(IFD.BookValueINR,0)/@Cost                                           AS BookValue,
ISNULL(IFD.MTMValueINR,0)/@Cost                                            AS MTMValue,	
ISNULL(IFD.Interest_DividendDueAmount,0)/@Cost                             AS OVERDUE_AMOUNT,
0                                                                          AS Totalincome,
CASE WHEN IBD.ReStructureDate IS NOT NULL 
     THEN 'Yes'
     ELSE 'No'
	 END                                                                   AS Restructured_Y_N,
CONVERT(VARCHAR(15),IBD.ReStructureDate,103)                               AS ReStructureDate,
CASE WHEN FD.RFA_DateReportingByBank IS NOT NULL 
     THEN 'Yes' 
	 ELSE 'No' 
	 END                                                                   AS RFA_FraudFlag,
CONVERT(VARCHAR(15),FD.RFA_DateReportingByBank,103)                        AS RFA_FraudDate,
CASE WHEN DA.AssetClassName='LOS'
     THEN 'LOSS'
	 ELSE DA.AssetClassName
	 END                                                                   AS NPIAssetClass,

CONVERT(VARCHAR(20),IFD.NPIDt,103)                                         AS NPADate,
(CASE WHEN IFD.FinalAssetClassAlt_Key =1 then 0 else ISNULL(IFD.Interest_DividendDueAmount,0)/@Cost  END)                     AS [IIS Today],
(CASE WHEN IFDPD.FinalAssetClassAlt_Key = 1 THEN 0 ELSE ISNULL(IFDPD.Interest_DividendDueAmount,0)/@Cost    END)                        AS [IIS Yesterday],
((CASE WHEN IFD.FinalAssetClassALt_key =1 then 0 else ISNULL(IFD.Interest_DividendDueAmount,0) END)-
(CASE WHEN IFDPD.FinalAssetClassAlt_key = 1 THen 0 ELSE ISNULL(IFDPD.Interest_DividendDueAmount,0) END)/@Cost)                            AS [Change in IIS Today],
(CASE WHEN IFDLM.FinalAssetClassAlt_key = 1 THEN 0 ELSE ISNULL(IFDLM.Interest_DividendDueAmount,0)/@Cost    END)                        AS [IIS Last Month],
(CASE WHEN IFDLF.FinalAssetClassAlt_key = 1 THEN 0 ELSE ISNULL(IFDLF.Interest_DividendDueAmount,0)/@Cost   END)                         AS [IIS Last Fiscal Year End],
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

LEFT JOIN InvestmentFinancialdetail IFDPD                   ON IFDPD.InvEntityId = IFD.InvEntityId
                                                               AND IFDPD.EffectiveFromTimeKey<=@PrevDay
									                           AND IFDPD.EffectiveToTimeKey>=@PrevDay
											                
LEFT JOIN InvestmentFinancialdetail IFDLM                   ON IFDLM.InvEntityId = IFD.InvEntityId
                                                               AND IFDLM.EffectiveFromTimeKey<=@LastMonthKey
									                           AND IFDLM.EffectiveToTimeKey>=@LastMonthKey
											                
LEFT JOIN InvestmentFinancialdetail IFDLF                   ON IFDLF.InvEntityId = IFD.InvEntityId
                                                               AND IFDLF.EffectiveFromTimeKey<=@LastFinYearKey
									                           AND IFDLF.EffectiveToTimeKey>=@LastFinYearKey

LEFT JOIN	 Fraud_Details		FD							ON  IID.IssuerID=FD.RefCustomerID
															    AND FD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND FD.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimAssetClass DA                                 ON DA.AssetClassAlt_Key=IFD.FinalAssetClassAlt_Key
                                                                AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DA.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimBranch DB                                       ON DB.BranchCode=IBD.BranchCode
                                                                AND DB.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DB.EffectiveToTimeKey>=@TimeKey

WHERE  @SelectReport=2 and IFD.FinalAssetClassAlt_key > 1


UNION ALL

SELECT
DISTINCT
CONVERT(VARCHAR(20),@CurDate,103)                                        AS ReportDate,
Derivative.SourceSystem                                                  AS SourceSystem,
DB.BranchName,
Derivative.UCIC_ID,
Derivative.CustomerID                                                    AS IssuerID,
Derivative.CustomerName                                                  AS IssuerName,
''                                                                       AS ProductCode,
Derivative.DerivativeRefNo                                               AS 'InvestmentID/Derv No.',
Derivative.DPD                                                           AS DPD,
(CASE WHEN ISNULL(Derivative.OsAmt,0)<0
      THEN ISNULL(Derivative.OsAmt,0)*-1
      ELSE ISNULL(Derivative.OsAmt,0)
	  END)/@Cost                                                         AS BookValue,
ISNULL(Derivative.MTMIncomeAmt,0)/@Cost                                  AS MTMValue,
ISNULL(Derivative.OverdueCouponAmt,0)/@Cost                              AS OVERDUE_AMOUNT,
0                                                                        AS Totalincome,
''                                                                       AS Restructured_Y_N,
''                                                                       AS ReStructureDate,
CASE WHEN FD.RFA_DateReportingByBank IS NOT NULL
     THEN 'Yes' 
	 ELSE 'No' 
	 END						                                         AS RFAFraudFlag,

CONVERT(VARCHAR(15),FD.RFA_DateReportingByBank,103)                      AS RFAFraudDate,												                       													                       
CASE WHEN DA.AssetClassName='LOS'
     THEN 'LOSS'
	 ELSE DA.AssetClassName
	 END                                                                 AS NPIAssetClass,
CONVERT(VARCHAR(20),Derivative.NPIDt,103)                                AS NPADate,
ISNULL(Derivative.MTMIncomeAmt,0)/@Cost                                  AS [IIS Today],
ISNULL(DerPD.MTMIncomeAmt,0)/@Cost                                       AS [IIS Yesterday],
(ISNULL(Derivative.MTMIncomeAmt,0)-ISNULL(DerPD.MTMIncomeAmt,0))/@Cost   AS [Change in IIS Today],
ISNULL(DerLM.MTMIncomeAmt,0)/@Cost                                       AS [IIS Last Month],
ISNULL(DerLF.MTMIncomeAmt,0)/@Cost                                       AS [IIS Last Fiscal Year End],
'Derivative'                                                             AS Flag

FROM CURDAT.DerivativeDetail Derivative

INNER JOIN DimAssetClass DA                        ON DA.AssetClassAlt_Key=Derivative.FinalAssetClassAlt_Key
                                                      AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                      AND DA.EffectiveToTimeKey>=@TimeKey

LEFT JOIN CURDAT.DerivativeDetail DerPD            ON DerPD.DerivativeRefNo = Derivative.DerivativeRefNo
                                                      AND DerPD.EffectiveFromTimeKey<=@PrevDay
									                  AND DerPD.EffectiveToTimeKey>=@PrevDay
											       
LEFT JOIN CURDAT.DerivativeDetail DerLM            ON DerLM.DerivativeRefNo = Derivative.DerivativeRefNo
                                                      AND DerLM.EffectiveFromTimeKey<=@LastMonthKey
									                  AND DerLM.EffectiveToTimeKey>=@LastMonthKey
											       
LEFT JOIN CURDAT.DerivativeDetail DerLF            ON DerLF.DerivativeRefNo = Derivative.DerivativeRefNo
                                                      AND DerLF.EffectiveFromTimeKey<=@LastFinYearKey
									                  AND DerLF.EffectiveToTimeKey>=@LastFinYearKey
												   
LEFT JOIN Fraud_Details		FD					   ON  Derivative.CustomerID=FD.RefCustomerID 
													  AND FD.EffectiveFromTimeKey<=@TimeKey 
                                                      AND FD.EffectiveToTimeKey>=@TimeKey


LEFT JOIN DimBranch DB                             ON DB.BranchCode=Derivative.BranchCode
                                                       AND DB.EffectiveFromTimeKey<=@TimeKey 
                                                       AND DB.EffectiveToTimeKey>=@TimeKey

WHERE  @SelectReport=2 AND Derivative.EffectiveFromTimeKey<=@TimeKey AND Derivative.EffectiveToTimeKey>=@TimeKey
       and Derivative.FinalAssetClassAlt_key > 1
	
	
	
ORDER BY UCIC_ID															

OPTION(RECOMPILE)

																


   
GO