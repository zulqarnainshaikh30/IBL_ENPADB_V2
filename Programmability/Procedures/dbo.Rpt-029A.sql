SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
 CREATE BY   :- Baijayanti
 CREATE DATE :- 09/08/2022
 DESCRIPTION :- Calypso For Provision Report

 */ 
 
CREATE PROCEDURE [dbo].[Rpt-029A]	
    @TimeKey AS INT,
	@Cost AS FLOAT,
	@SelectReport AS INT
	
AS

--DECLARE
--    @Timekey AS INT=26372,
--	@SelectReport AS INT=2,
--	@Cost AS FLOAT=1
	

------------------------

DECLARE @LastQtrDateKey INT = (SELECT LastQtrDateKey FROM sysdaymatrix WHERE timekey=@TimeKey)
DECLARE @PerDayDateKey AS INT=@TimeKey-1

---------------------------Prev QTR--------------------------------------------
IF OBJECT_ID('TempDB..#PREV_QTR') Is Not Null
DROP TABLE #PREV_QTR

SELECT * INTO #PREV_QTR FROM(
SELECT 
IID.UcifId                                                                 AS UCIC_ID,
IID.IssuerID                                                               AS IssuerID,
IBD.InvID                                                                  AS InvestmentID,
(CASE WHEN DA.AssetClassName = 'LOS' THEN 'LOSS' ELSE DA.AssetClassName END) AssetClassName,
ISNULL(IFD.BookValueINR,0)                                                 AS NetBalance,
ISNULL(TotalProvison,0)                                                    AS TotalProvision,
CASE WHEN ISNULL(AssetClassName,'') <>'STANDARD' THEN (ISNULL(IFD.BookValueINR,0)-ISNULL(IFD.TotalProvison,0)) END   AS NetNPA

FROM dbo.InvestmentBasicDetail IBD
INNER JOIN DBO.InvestmentFinancialdetail     IFD			ON  IFD.InvEntityId=IBD.InvEntityId 
															    AND IFD.EffectiveFromTimeKey<=@LastQtrDateKey 
                                                                AND IFD.EffectiveToTimeKey>=@LastQtrDateKey
																AND IBD.EffectiveFromTimeKey<=@LastQtrDateKey 
                                                                AND IBD.EffectiveToTimeKey>=@LastQtrDateKey
																
INNER JOIN DBO.InvestmentIssuerDetail   IID				    ON  IID.IssuerEntityId=IBD.IssuerEntityId 
															    AND IID.EffectiveFromTimeKey<=@LastQtrDateKey 
                                                                AND IID.EffectiveToTimeKey>=@LastQtrDateKey

INNER JOIN DimAssetClass DA                                 ON DA.AssetClassAlt_Key=IFD.FinalAssetClassAlt_Key
                                                                AND DA.EffectiveFromTimeKey<=@LastQtrDateKey 
                                                                AND DA.EffectiveToTimeKey>=@LastQtrDateKey

UNION ALL

SELECT
UCIC_ID                                                                  AS UCIC_ID,
CustomerID                                                               AS IssuerID,
DerivativeRefNo                                                          AS InvestmentID,
(CASE WHEN DA.AssetClassName = 'LOS' THEN 'LOSS' ELSE DA.AssetClassName END)AssetClassName , 
CASE WHEN FinalAssetClassAlt_key =1 OR ISNULL(MTMIncomeAmt,0)   < 0 THEN 0 ELSE ISNULL(MTMIncomeAmt,0)     END                                AS NetBalance,
ISNULL(TotalProvison,0)                                    AS TotalProvision,
CASE WHEN ISNULL(AssetClassName,'') <>'STANDARD' THEN (ISNULL(MTMIncomeAmt,0)-ISNULL(TotalProvison,0)) END   AS NetNPA

FROM CURDAT.DerivativeDetail Derivative

INNER JOIN DimAssetClass DA                        ON DA.AssetClassAlt_Key=Derivative.FinalAssetClassAlt_Key
                                                      AND DA.EffectiveFromTimeKey<=@LastQtrDateKey 
                                                      AND DA.EffectiveToTimeKey>=@LastQtrDateKey

WHERE Derivative.EffectiveFromTimeKey<=@LastQtrDateKey  AND Derivative.EffectiveToTimeKey>=@LastQtrDateKey

)DA

OPTION(RECOMPILE)
-----------------------------------------------------
IF OBJECT_ID('TempDB..#PREV_DAY') Is Not Null
DROP TABLE #PREV_DAY

SELECT * INTO #PREV_DAY FROM(
SELECT 
IID.UcifId                                                                 AS UCIC_ID,
IID.IssuerID                                                               AS IssuerID,
IBD.InvID                                                                  AS InvestmentID,
(CASE WHEN DA.AssetClassName = 'LOS' THEN 'LOSS' ELSE DA.AssetClassName END) AssetClassName,
ISNULL(IFD.BookValueINR,0)                                                 AS NetBalance,
ISNULL(TotalProvison,0)                                                    AS TotalProvision,
CASE WHEN ISNULL(AssetClassName,'') <>'STANDARD' THEN (ISNULL(IFD.BookValueINR,0)-ISNULL(IFD.TotalProvison,0)) END   AS NetNPA

FROM dbo.InvestmentBasicDetail IBD
INNER JOIN DBO.InvestmentFinancialdetail     IFD			ON  IFD.InvEntityId=IBD.InvEntityId 
															    AND IFD.EffectiveFromTimeKey<=@PerDayDateKey 
                                                                AND IFD.EffectiveToTimeKey>=@PerDayDateKey
																AND IBD.EffectiveFromTimeKey<=@PerDayDateKey 
                                                                AND IBD.EffectiveToTimeKey>=@PerDayDateKey
																
INNER JOIN DBO.InvestmentIssuerDetail   IID				    ON  IID.IssuerEntityId=IBD.IssuerEntityId 
															    AND IID.EffectiveFromTimeKey<=@PerDayDateKey 
                                                                AND IID.EffectiveToTimeKey>=@PerDayDateKey

INNER JOIN DimAssetClass DA                                 ON DA.AssetClassAlt_Key=IFD.FinalAssetClassAlt_Key
                                                                AND DA.EffectiveFromTimeKey<=@PerDayDateKey 
                                                                AND DA.EffectiveToTimeKey>=@PerDayDateKey

UNION ALL

SELECT
UCIC_ID                                                                  AS UCIC_ID,
CustomerID                                                               AS IssuerID,
DerivativeRefNo                                                          AS InvestmentID,
(CASE WHEN DA.AssetClassName = 'LOS' THEN 'LOSS' ELSE DA.AssetClassName END) AssetClassName,
CASE WHEN ISNULL(MTMIncomeAmt,0)      <0 THEN 0 ELSE ISNULL(MTMIncomeAmt,0) END                                 AS NetBalance,
ISNULL(TotalProvison,0)                                    AS TotalProvision,
CASE WHEN ISNULL(AssetClassName,'') <>'STANDARD' THEN (ISNULL(MTMIncomeAmt,0)-ISNULL(TotalProvison,0)) END   AS NetNPA

FROM CURDAT.DerivativeDetail Derivative

INNER JOIN DimAssetClass DA                        ON DA.AssetClassAlt_Key=Derivative.FinalAssetClassAlt_Key
                                                      AND DA.EffectiveFromTimeKey<=@PerDayDateKey 
                                                      AND DA.EffectiveToTimeKey>=@PerDayDateKey

WHERE Derivative.EffectiveFromTimeKey<=@PerDayDateKey  AND Derivative.EffectiveToTimeKey>=@PerDayDateKey

)DA

OPTION(RECOMPILE)

--------------------------------------------------
IF OBJECT_ID('TempDB..#MOC_Provision_Fin') Is Not Null
DROP TABLE #MOC_Provision_Fin

SELECT 
IFD.InvEntityId,
CASE WHEN ISNULL(IFD.TotalProvison,0)>ISNULL(MIFD.TotalProvison,0)
     THEN ISNULL(IFD.TotalProvison,0)-ISNULL(MIFD.TotalProvison,0)
	 ELSE ISNULL(MIFD.TotalProvison,0)-ISNULL(IFD.TotalProvison,0)
	 END                                 AS ShortfallinProvision
INTO #MOC_Provision_Fin
FROM InvestmentFinancialDetail IFD
LEFT JOIN PreMoc.InvestmentFinancialDetail MIFD                  ON IFD.InvEntityId=MIFD.InvEntityId
                                                                    AND MIFD.EffectiveFromTimeKey <= @TimeKey AND MIFD.EffectiveToTimeKey >=@TimeKey
																	AND MIFD.FlgMOC='Y'

WHERE IFD.EffectiveFromTimeKey <= @TimeKey AND IFD.EffectiveToTimeKey >=@TimeKey AND IFD.FlgMOC='Y'

OPTION(RECOMPILE)

-----------------------------------------
IF OBJECT_ID('TempDB..#MOC_Provision_Der') Is Not Null
DROP TABLE #MOC_Provision_Der

SELECT 
DD.DerivativeRefNo,
CASE WHEN ISNULL(DD.TotalProvison,0)>ISNULL(MDD.TotalProvison,0)
     THEN ISNULL(DD.TotalProvison,0)-ISNULL(MDD.TotalProvison,0)
	 ELSE ISNULL(MDD.TotalProvison,0)-ISNULL(DD.TotalProvison,0)
	 END                                 AS ShortfallinProvision
INTO #MOC_Provision_Der
FROM Curdat.DerivativeDetail DD
LEFT JOIN PreMoc.DerivativeDetail MDD                  ON DD.DerivativeRefNo=MDD.DerivativeRefNo
                                                            AND MDD.EffectiveFromTimeKey <= @TimeKey AND MDD.EffectiveToTimeKey >=@TimeKey
															AND MDD.FlgMOC='Y'

WHERE DD.EffectiveFromTimeKey <= @TimeKey AND DD.EffectiveToTimeKey >=@TimeKey AND DD.FlgMOC='Y'

OPTION(RECOMPILE)
-------------------------------------------------
SELECT
DISTINCT
'Calypso'                                                                  AS SourceSystem,
DB.BranchName,
IID.UcifId                                                                 AS UCIC_ID,
IID.IssuerID                                                               AS IssuerID,
IID.IssuerName                                                             AS IssuerName,
IBD.InvID                                                                  AS 'InvestmentID/Derv No.',
IBD.InvestmentNature                                                       AS InvestmentNature,
CONVERT(VARCHAR(15),IBD.MaturityDt,103)                                    AS MaturityDt,
CASE WHEN IBD.ReStructureDate IS NOT NULL 
     THEN 'Yes'
     ELSE 'No'
	 END                                                                   AS Restructured_Y_N,
CONVERT(VARCHAR(15),IBD.ReStructureDate,103)                               AS ReStructureDate,
IFD.HoldingNature                                                          AS HoldingNature,	
--------CHANGED ON 18-04-2022--------------												                       
ISNULL(IFD.BookValueINR,0)/@Cost                                           AS BookValue,
ISNULL(IFD.MTMValueINR,0)/@Cost                                            AS MTMValue,														                       
ISNULL(IFD.TotalProvison,0)/@Cost                                          AS TotalProvison,
IFD.DPD                                                                    AS DPD,
ISNULL(IFD.Interest_DividendDueAmount,0)/@Cost                             AS OVERDUE_AMOUNT,
0                                                                          AS PartialRedumptionDueAmount,
CONVERT(VARCHAR(15),IFD.PartialRedumptionDueDate,103)                      AS PartialRedumptionDueDate,

(CASE WHEN DA.AssetClassName = 'LOS' THEN 'LOSS' ELSE DA.AssetClassName END)                                                         AS NPIAssetClass,
''                                                AS CouponOverDueSinceDt,
'Investment'                                      AS Flag,
InstrName                                         AS InstrumentName,
''                                                AS OverDueSinceDt,
ISNULL(OVERDUE_AMOUNT,0)/@Cost                    AS DueAmtReceivable,

CONVERT(VARCHAR(20),IFD.NPIDt,103)                AS NPADate,
CASE WHEN DA.AssetClassAlt_Key=1 
     THEN ISNULL(DPSTD.ProvisionSecured,0)  
	 ELSE ISNULL(DPS.ProvisionSecured,0) 
	 END                                          AS ProvisionPerSecured,
CASE WHEN DA.AssetClassAlt_Key=1 
     THEN ISNULL(DPSTD.ProvisionUnSecured,0) 
	 ELSE ISNULL(DPS.ProvisionUnSecured,0)  
	 END                                          AS ProvisionPerUnSecured,
ISNULL(IFD.BookValueINR,0)/@Cost                  AS BalanceOutstanding, 
0                                                 AS PrincipalOutstanding,
ISNULL(IFD.BookValueINR,0)/@Cost                  AS NetBalance,
0                                                 AS SecurityValue,
0                                                 AS SecurityValueappropriated,
''                                                AS SecurityType,
''                                                AS ValuationDate,
0                                                 AS SecuredOutstanding,
0                                                 AS UnsecuredOutstanding,
0                                                 AS SecurityUsedRV,
CASE WHEN IFD.FinalAssetClassAlt_Key = 1 THEN 0 ELSE ISNULL(IFD.Interest_DividendDueAmount,0)/@Cost  END  AS InterestInSuspenseAmount,
0                                                 AS Totalincomesuspended,
CASE WHEN ISNULL(DA.AssetClassName,'')  <>'STANDARD'
     THEN (ISNULL(IFD.BookValueINR,0)-ISNULL(IFD.TotalProvison,0))/@Cost 
	 ELSE 0 
	 END                                          AS NetNPA,
ISNULL(PQTR.NetBalance,0)/@Cost                   AS PrevQtrBalanceOutstanding,
0                                                 AS PrevQtrSecuredOutstanding,
0                                                 AS PrevQtrUnsecuredOutstanding,
ISNULL(PQTR.TotalProvision,0)/@Cost               AS PrevQtrTotalProvision,
0                                                 AS PrevQtrProvisionSecured,
0                                                 AS PrevQtrProvisionUnsecured,
ISNULL(PQTR.NetBalance,0)/@Cost                   AS PrevQtrNetNPA,
CASE WHEN PDAY.AssetClassName='STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
      THEN ISNULL(IFD.BookValueINR,0)
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'  
      THEN (CASE WHEN (ISNULL(IFD.BookValueINR,0) - ISNULL(PDAY.netBalance,0)) < 0 
                 THEN 0 
	             ELSE ABS(ISNULL(IFD.BookValueINR,0) - ISNULL(PDAY.netBalance,0)) 
	             END)   
      WHEN PDAY.InvestmentID IS NULL AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
	  THEN ISNULL(IFD.BookValueINR,0)
	  ELSE 0 
	  END/@Cost                                                 AS NPAIncrease,
CASE WHEN ISNULL(PDAY.AssetClassName,'') <>'STANDARD' AND DA.AssetClassName ='STANDARD'   
      THEN ISNULL(PDAY.netBalance,0)
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
	  THEN (CASE WHEN (ISNULL(PDAY.netBalance,0)-ISNULL(IFD.BookValueINR,0))< 0 
                 THEN 0 
	             ELSE (ISNULL(PDAY.netBalance,0)-ISNULL(IFD.BookValueINR,0))
	             END)   	  
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND IBD.InvID IS NULL 
	  THEN ISNULL(PDAY.netBalance,0)
	  ELSE 0 
	  END/@Cost                                                 AS NPADecrease,

CASE WHEN PDAY.AssetClassName='STANDARD' AND DA.AssetClassName ='STANDARD'   
      THEN (CASE WHEN (ISNULL(IFD.TotalProvison,0) - ISNULL(PDAY.TotalProvision,0)) < 0 
                 THEN 0 
	             ELSE ABS(ISNULL(IFD.TotalProvison,0) - ISNULL(PDAY.TotalProvision,0)) 
	             END)
	   WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND DA.AssetClassName ='STANDARD'   
	   THEN ISNULL(IFD.TotalProvison,0) 	              
	   WHEN PDAY.InvestmentID IS NULL AND DA.AssetClassName ='STANDARD'   
	   THEN ISNULL(IFD.TotalProvison,0)  
	   ELSE 0 
	   END/@Cost                                                 AS STDProvisionIncrease,
CASE WHEN PDAY.AssetClassName ='STANDARD'  AND DA.AssetClassName ='STANDARD'  
      THEN (CASE WHEN (ISNULL(PDAY.TotalProvision,0)-ISNULL(IFD.TotalProvison,0))< 0 
                 THEN 0 
	             ELSE (ISNULL(PDAY.TotalProvision,0)-ISNULL(IFD.TotalProvison,0)) 
	             END)  
	  WHEN PDAY.AssetClassName ='STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'  
	  THEN ISNULL(PDAY.TotalProvision,0)
	  ELSE 0 
	  END/@Cost                                                 AS STDProvisionDecrease,

CASE WHEN PDAY.AssetClassName='STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'   
      THEN ISNULL(IFD.TotalProvison,0)
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'   
	  THEN (CASE WHEN (ISNULL(IFD.TotalProvison,0) - ISNULL(PDAY.TotalProvision,0)) < 0 
                 THEN 0 
	             ELSE ABS(ISNULL(IFD.TotalProvison,0) - ISNULL(PDAY.TotalProvision,0)) 
	             END) 	              
	  WHEN PDAY.InvestmentID IS NULL AND ISNULL(DA.AssetClassName,'') <>'STANDARD'   
	  THEN ISNULL(IFD.TotalProvison,0)  
	  ELSE 0 
	  END/@Cost                                                 AS NPAProvisionIncrease,
CASE WHEN ISNULL(PDAY.AssetClassName,'') <>'STANDARD'  AND ISNULL(DA.AssetClassName,'') <>'STANDARD'  
      THEN (CASE WHEN (ISNULL(PDAY.TotalProvision,0)-ISNULL(IFD.TotalProvison,0))< 0 
                 THEN 0 
	             ELSE (ISNULL(PDAY.TotalProvision,0)-ISNULL(IFD.TotalProvison,0))
	             END)  
	  WHEN ISNULL(PDAY.AssetClassName,'') <>'STANDARD' AND DA.AssetClassName='STANDARD'  
	  THEN ISNULL(PDAY.TotalProvision,0)
	  ELSE 0 
	  END/@Cost                                                 AS NPAProvisionDecrease,

CASE WHEN PDAY.AssetClassName='STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
      THEN (ISNULL(IFD.BookValueINR,0)-ISNULL(IFD.TotalProvison,0))
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'  
      THEN (CASE WHEN ((ISNULL(IFD.BookValueINR,0)-ISNULL(IFD.TotalProvison,0)) - ISNULL(PDAY.NetNPA,0)) < 0 
                 THEN 0 
	             ELSE ABS((ISNULL(IFD.BookValueINR,0)-ISNULL(IFD.TotalProvison,0)) - ISNULL(PDAY.NetNPA,0)) 
	             END)   
      WHEN PDAY.InvestmentID IS NULL AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
	  THEN (ISNULL(IFD.BookValueINR,0)-ISNULL(IFD.TotalProvison,0))
	  ELSE 0 
	  END/@Cost                                                 AS NetNPAIncrease,
CASE WHEN ISNULL(PDAY.AssetClassName,'') <>'STANDARD' AND DA.AssetClassName ='STANDARD'   
      THEN ISNULL(PDAY.NetNPA,0)
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
	  THEN (CASE WHEN (ISNULL(PDAY.NetNPA,0)-(ISNULL(IFD.BookValueINR,0)-ISNULL(IFD.TotalProvison,0)))< 0 
                 THEN 0 
	             ELSE (ISNULL(PDAY.NetNPA,0)-(ISNULL(IFD.BookValueINR,0)-ISNULL(IFD.TotalProvison,0)))
	             END)   
	  
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND IBD.InvID IS NULL
	  THEN ISNULL(PDAY.NetNPA,0)
	  ELSE 0 
	  END/@Cost                                                 AS NetNPADecrease,
ISNULL(IFD.TotalProvison,0)/@Cost                 AS ActualProvision,
ISNULL(ShortfallinProvision,0)/@Cost              AS ShortfallinProvisionHeld ,
0                                                 AS ProvisionSecured,
0                                                 AS ProvisionUnsecured,

ROUND(ISNULL(CASE WHEN ROUND((ISNULL(IFD.TotalProvison,0)/NULLIF(IFD.BookValueINR,0))*100,1) < 0.5 AND
                        ROUND((ISNULL(IFD.TotalProvison,0)/NULLIF(IFD.BookValueINR,0))*100,1) > 0
                   THEN 0.4 
			       ELSE ROUND((ISNULL(IFD.TotalProvison,0)/NULLIF(IFD.BookValueINR,0))*100,2)  END,0),2)        AS [Total Provision %]

,DEGREASON AS NPAReason

,CASE WHEN IBPCD.AccountID IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsIBPC
,CASE WHEN SFD.AccountID IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsSecuritised
,CASE WHEN FD.RFA_DateReportingByBank IS NOT NULL OR FD.RFA_OtherBankDate is not NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS RFA
,CASE WHEN PUID.AccountID IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS PUI
,CASE WHEN FD.FraudOccuranceDate IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS FlgFraud              
,CASE WHEN ARD.RefSystemAcId IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS FlgRestructure      
,CASE WHEN AARC.AccountId IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS ARCFlg

,CASE WHEN RPD.CustomerId IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS RPFlg

FROM dbo.InvestmentBasicDetail IBD
INNER JOIN DBO.InvestmentFinancialdetail     IFD			ON  IFD.InvEntityId=IBD.InvEntityId 
															    AND IFD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IFD.EffectiveToTimeKey>=@TimeKey
																AND IBD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IBD.EffectiveToTimeKey>=@TimeKey
																
INNER JOIN DBO.InvestmentIssuerDetail   IID				    ON  IID.IssuerEntityId=IBD.IssuerEntityId 
															    AND IID.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IID.EffectiveToTimeKey>=@TimeKey

LEFT JOIN #PREV_QTR PQTR                                    ON  IID.UcifId=PQTR.UCIC_ID 
                                                                AND IID.IssuerID=PQTR.IssuerID
                                                                AND IBD.InvID=PQTR.InvestmentID

LEFT JOIN #PREV_DAY PDAY                                    ON  IID.UcifId=PDAY.UCIC_ID 
                                                                AND IID.IssuerID=PDAY.IssuerID
                                                                AND IBD.InvID=PDAY.InvestmentID

LEFT JOIN SaletoARCFinalACFlagging  AARC                    ON  AARC.AccountID=IBD.InvID
                                                                AND AARC.EffectiveFromTimeKey<=@TimeKey 
                                                                AND AARC.EffectiveToTimeKey>=@TimeKey

LEFT JOIN RP_Portfolio_Details  RPD                         ON  RPD.CustomerID=IID.IssuerID
                                                                AND RPD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND RPD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN Fraud_Details  FD                                 ON  FD.RefCustomerACID=IBD.InvID
                                                                AND FD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND FD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN SecuritizedFinalACDetail  SFD                     ON  SFD.AccountID=IBD.InvID
                                                                AND SFD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND SFD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN IBPCFinalPoolDetail  IBPCD                        ON  IBPCD.AccountID=IBD.InvID
                                                                AND IBPCD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IBPCD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvAcPUIDetailMain  PUID                          ON  PUID.AccountID=IBD.InvID
                                                                AND PUID.EffectiveFromTimeKey<=@TimeKey 
                                                                AND PUID.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvAcRestructureDetail  ARD                       ON  ARD.RefSystemAcId=IBD.InvID
                                                                AND ARD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND ARD.EffectiveToTimeKey>=@TimeKey
																      
LEFT JOIN #MOC_Provision_Fin MOCP                           ON  IFD.InvEntityId=MOCP.InvEntityId 

INNER JOIN DimAssetClass DA                                 ON DA.AssetClassAlt_Key=IFD.FinalAssetClassAlt_Key
                                                                AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DA.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimBranch DB                                       ON DB.BranchCode=IBD.BranchCode
                                                                AND DB.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DB.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimProvision_Seg DPS                               ON DPS.ProvisionAlt_Key=IFD.ProvisionAlt_Key
                                                                AND DPS.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DPS.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimProvision_SegStd DPSTD                          ON DPSTD.ProvisionAlt_Key=IFD.ProvisionAlt_Key
                                                                AND DPSTD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DPSTD.EffectiveToTimeKey>=@TimeKey

WHERE  @SelectReport=2 

UNION ALL

SELECT
DISTINCT
Derivative.SourceSystem                                                             AS SourceSystem,
DB.BranchName,
Derivative.UCIC_ID,
Derivative.CustomerID                                                               AS IssuerID,
Derivative.CustomerName                                                             AS IssuerName,
Derivative.DerivativeRefNo                                               AS 'InvestmentID/Derv No.',
''                                                                       AS InvestmentNature,
CONVERT(VARCHAR(15),Duedate,103)                                         AS MaturityDt,
''                                                                       AS Restructured_Y_N,
''                                                                       AS ReStructureDate,
''                                                                       AS HoldingNature,													                       
(CASE WHEN ISNULL(OsAmt,0)<0
      THEN ISNULL(OsAmt,0)*-1
      ELSE ISNULL(OsAmt,0)
	  END)/@Cost                                                         AS BookValue,
ISNULL(MTMIncomeAmt,0)/@Cost                                             AS MTMValue,													                       
ISNULL(TotalProvison,0)/@Cost                                            AS TotalProvison,
DPD                                                                      AS DPD,
ISNULL(OverdueCouponAmt,0)/@Cost                                         AS OVERDUE_AMOUNT,
0                                                                        AS PartialRedumptionDueAmount,
''                                                                       AS PartialRedumptionDueDate,
(CASE WHEN DA.AssetClassName = 'LOS' THEN 'LOSS' ELSE DA.AssetClassName END)                                                       AS NPIAssetClass,
CONVERT(VARCHAR(15),CouponOverDueSinceDt,103)                            AS CouponOverDueSinceDt,
'Derivative'                                                             AS Flag,
Derivative.InstrumentName                                                AS InstrumentName,
CONVERT(VARCHAR(20),Derivative.OverDueSinceDt,103)                       AS OverDueSinceDt,
ISNULL(Derivative.DueAmtReceivable,0)/@Cost                              AS DueAmtReceivable,
CONVERT(VARCHAR(20),Derivative.NPIDt,103)                                AS NPADate,
CASE WHEN DA.AssetClassAlt_Key=1 
     THEN ISNULL(DPSTD.ProvisionSecured,0)  
	 ELSE ISNULL(DPS.ProvisionSecured,0) 
	 END                                          AS ProvisionPerSecured,
CASE WHEN DA.AssetClassAlt_Key=1 
     THEN ISNULL(DPSTD.ProvisionUnSecured,0) 
	 ELSE ISNULL(DPS.ProvisionUnSecured,0)  
	 END                                          AS ProvisionPerUnSecured,
ISNULL(MTMIncomeAmt,0)/@Cost                      AS BalanceOutstanding, 
ISNULL(Derivative.POS,0)/@Cost                               AS PrincipalOutstanding,
Case when ISNULL(MTMIncomeAmt,0)/@Cost < 0 THEN 0 ELSE ISNULL(MTMIncomeAmt,0)/@Cost    END                   AS NetBalance,
0                                                 AS SecurityValue,
0                                                 AS SecurityValueappropriated,
''                                                AS SecurityType,
''                                                AS ValuationDate,
0                                                 AS SecuredOutstanding,
0                                                 AS UnsecuredOutstanding,
0                                                 AS SecurityUsedRV,
CASE WHEN (FinalAssetClassAlt_key =1 OR ISNULL(Derivative.MTMIncomeAmt,0)/@Cost  < 0) THEN 0 ELSE ISNULL(Derivative.MTMIncomeAmt,0)/@Cost    END       AS InterestInSuspenseAmount,
0                                                 AS Totalincomesuspended,
CASE WHEN ISNULL(DA.AssetClassName,'')  <>'STANDARD'
     THEN (ISNULL(MTMIncomeAmt,0)-ISNULL(TotalProvison,0))/@Cost 
	 ELSE 0 
	 END                                          AS NetNPA,
ISNULL(PQTR.NetBalance,0)/@Cost                   AS PrevQtrBalanceOutstanding,
0                                                 AS PrevQtrSecuredOutstanding,
0                                                 AS PrevQtrUnsecuredOutstanding,
ISNULL(PQTR.TotalProvision,0)/@Cost               AS PrevQtrTotalProvision,
0                                                 AS PrevQtrProvisionSecured,
0                                                 AS PrevQtrProvisionUnsecured,
ISNULL(PQTR.NetBalance,0)/@Cost                   AS PrevQtrNetNPA,
CASE WHEN PDAY.AssetClassName='STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
      THEN ISNULL(Derivative.MTMIncomeAmt,0)
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'  
      THEN (CASE WHEN (ISNULL(Derivative.MTMIncomeAmt,0) - ISNULL(PDAY.netBalance,0)) < 0 
                 THEN 0 
	             ELSE ABS(ISNULL(Derivative.MTMIncomeAmt,0) - ISNULL(PDAY.netBalance,0)) 
	             END)   
      WHEN PDAY.InvestmentID IS NULL AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
	  THEN ISNULL(Derivative.MTMIncomeAmt,0)
	  ELSE 0 
	  END/@Cost                                                 AS NPAIncrease,
CASE WHEN ISNULL(PDAY.AssetClassName,'') <>'STANDARD' AND DA.AssetClassName ='STANDARD'   
      THEN ISNULL(PDAY.netBalance,0)
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
	  THEN (CASE WHEN (ISNULL(PDAY.netBalance,0)-ISNULL(Derivative.MTMIncomeAmt,0))< 0 
                 THEN 0 
	             ELSE (ISNULL(PDAY.netBalance,0)-ISNULL(Derivative.MTMIncomeAmt,0))
	             END)   	  
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND Derivative.DerivativeRefNo IS NULL 
	  THEN ISNULL(PDAY.netBalance,0)
	  ELSE 0 
	  END/@Cost                                                 AS NPADecrease,

CASE WHEN PDAY.AssetClassName='STANDARD' AND DA.AssetClassName ='STANDARD'   
      THEN (CASE WHEN (ISNULL(Derivative.TotalProvison,0) - ISNULL(PDAY.TotalProvision,0)) < 0 
                 THEN 0 
	             ELSE ABS(ISNULL(Derivative.TotalProvison,0) - ISNULL(PDAY.TotalProvision,0)) 
	             END)
	   WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND DA.AssetClassName ='STANDARD'   
	   THEN ISNULL(Derivative.TotalProvison,0) 	              
	   WHEN PDAY.InvestmentID IS NULL AND DA.AssetClassName ='STANDARD'   
	   THEN ISNULL(Derivative.TotalProvison,0)  
	   ELSE 0 
	   END/@Cost                                                 AS STDProvisionIncrease,
CASE WHEN PDAY.AssetClassName ='STANDARD'  AND DA.AssetClassName ='STANDARD'  
      THEN (CASE WHEN (ISNULL(PDAY.TotalProvision,0)-ISNULL(Derivative.TotalProvison,0))< 0 
                 THEN 0 
	             ELSE (ISNULL(PDAY.TotalProvision,0)-ISNULL(Derivative.TotalProvison,0)) 
	             END)  
	  WHEN PDAY.AssetClassName ='STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'  
	  THEN ISNULL(PDAY.TotalProvision,0)
	  ELSE 0 
	  END/@Cost                                                 AS STDProvisionDecrease,

CASE WHEN PDAY.AssetClassName='STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'   
      THEN ISNULL(Derivative.TotalProvison,0)
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'   
	  THEN (CASE WHEN (ISNULL(Derivative.TotalProvison,0) - ISNULL(PDAY.TotalProvision,0)) < 0 
                 THEN 0 
	             ELSE ABS(ISNULL(Derivative.TotalProvison,0) - ISNULL(PDAY.TotalProvision,0)) 
	             END) 	              
	  WHEN PDAY.InvestmentID IS NULL AND ISNULL(DA.AssetClassName,'') <>'STANDARD'   
	  THEN ISNULL(Derivative.TotalProvison,0)  
	  ELSE 0 
	  END/@Cost                                                 AS NPAProvisionIncrease,
CASE WHEN ISNULL(PDAY.AssetClassName,'') <>'STANDARD'  AND ISNULL(DA.AssetClassName,'') <>'STANDARD'  
      THEN (CASE WHEN (ISNULL(PDAY.TotalProvision,0)-ISNULL(Derivative.TotalProvison,0))< 0 
                 THEN 0 
	             ELSE (ISNULL(PDAY.TotalProvision,0)-ISNULL(Derivative.TotalProvison,0))
	             END)  
	  WHEN ISNULL(PDAY.AssetClassName,'') <>'STANDARD' AND DA.AssetClassName='STANDARD'  
	  THEN ISNULL(PDAY.TotalProvision,0)
	  ELSE 0 
	  END/@Cost                                                 AS NPAProvisionDecrease,

CASE WHEN PDAY.AssetClassName='STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
      THEN (ISNULL(MTMIncomeAmt,0)-ISNULL(Derivative.TotalProvison,0))
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'  
      THEN (CASE WHEN ((ISNULL(MTMIncomeAmt,0)-ISNULL(Derivative.TotalProvison,0)) - ISNULL(PDAY.NetNPA,0)) < 0 
                 THEN 0 
	             ELSE ABS((ISNULL(MTMIncomeAmt,0)-ISNULL(Derivative.TotalProvison,0)) - ISNULL(PDAY.NetNPA,0)) 
	             END)   
      WHEN PDAY.InvestmentID IS NULL AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
	  THEN (ISNULL(MTMIncomeAmt,0)-ISNULL(Derivative.TotalProvison,0))
	  ELSE 0 
	  END/@Cost                                                 AS NetNPAIncrease,
CASE WHEN ISNULL(PDAY.AssetClassName,'') <>'STANDARD' AND DA.AssetClassName ='STANDARD'   
      THEN ISNULL(PDAY.NetNPA,0)
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND ISNULL(DA.AssetClassName,'') <>'STANDARD'
	  THEN (CASE WHEN (ISNULL(PDAY.NetNPA,0)-(ISNULL(MTMIncomeAmt,0)-ISNULL(Derivative.TotalProvison,0)))< 0 
                 THEN 0 
	             ELSE (ISNULL(PDAY.NetNPA,0)-(ISNULL(MTMIncomeAmt,0)-ISNULL(Derivative.TotalProvison,0)))
	             END)   
	  
	  WHEN ISNULL(PDAY.AssetClassName,'')<>'STANDARD' AND Derivative.DerivativeRefNo IS NULL
	  THEN ISNULL(PDAY.NetNPA,0)
	  ELSE 0 
	  END/@Cost                                                 AS NetNPADecrease,

ISNULL(Derivative.TotalProvison,0)/@Cost          AS ActualProvision,
ISNULL(ShortfallinProvision,0)/@Cost              AS ShortfallinProvisionHeld,
0                                                 AS ProvisionSecured,
0                                                 AS ProvisionUnsecured,
ROUND(CASE WHEN ROUND((ISNULL(Derivative.TotalProvison,0)/NULLIF(Derivative.MTMIncomeAmt,0))*100,1) < 0.5 and 
ROUND((ISNULL(Derivative.TotalProvison,0)/NULLIF(Derivative.MTMIncomeAmt,0))*100,1) > 0
	 then 0.4 
	 ELSE ROUND((ISNULL(Derivative.TotalProvison,0)/NULLIF(CASE WHEN ISNULL(Derivative.MTMIncomeAmt,0) = 0 
																THEN 
																		CASE	WHEN ISNULL(Derivative.POS,0) <= 0 
																				THEN 0 
																				ELSE ISNULL(Derivative.POS,0) 
																				END 
																WHEN ISNULL(Derivative.MTMIncomeAmt,0) < 0 
																THEN 0 
																ELSE ISNULL(Derivative.MTMIncomeAmt,0) END ,0))*100,2)  
	END ,2)
                                                 AS [Total Provision %]

,DEGREASON AS NPAReason

,CASE WHEN IBPCD.AccountID IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsIBPC
,CASE WHEN SFD.AccountID IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsSecuritised
,CASE WHEN FD.RFA_DateReportingByBank IS NOT NULL OR FD.RFA_OtherBankDate is not NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS RFA
,CASE WHEN PUID.AccountID IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS PUI
,CASE WHEN FD.FraudOccuranceDate IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS FlgFraud              
,CASE WHEN ARD.RefSystemAcId IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS FlgRestructure      
,CASE WHEN AARC.AccountId IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS ARCFlg

,CASE WHEN RPD.CustomerId IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS RPFlg

FROM CURDAT.DerivativeDetail Derivative

INNER JOIN DimAssetClass DA                         ON DA.AssetClassAlt_Key=Derivative.FinalAssetClassAlt_Key
                                                       AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                       AND DA.EffectiveToTimeKey>=@TimeKey

LEFT JOIN #PREV_QTR PQTR                            ON  Derivative.UCIC_ID=PQTR.UCIC_ID 
                                                        AND Derivative.CustomerID=PQTR.IssuerID
                                                        AND Derivative.DerivativeRefNo=PQTR.InvestmentID

LEFT JOIN #PREV_DAY PDAY                            ON  Derivative.UCIC_ID=PDAY.UCIC_ID 
                                                        AND Derivative.CustomerID=PDAY.IssuerID
                                                        AND Derivative.DerivativeRefNo=PDAY.InvestmentID

LEFT JOIN #MOC_Provision_Der MOCP                   ON  Derivative.DerivativeRefNo=MOCP.DerivativeRefNo 

LEFT JOIN SaletoARCFinalACFlagging  AARC            ON  AARC.AccountID=Derivative.DerivativeRefNo
                                                        AND AARC.EffectiveFromTimeKey<=@TimeKey 
                                                        AND AARC.EffectiveToTimeKey>=@TimeKey

LEFT JOIN RP_Portfolio_Details  RPD                 ON  RPD.CustomerID=Derivative.CustomerID
                                                        AND RPD.EffectiveFromTimeKey<=@TimeKey 
                                                        AND RPD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN Fraud_Details  FD                         ON  FD.RefCustomerACID=Derivative.DerivativeRefNo
                                                        AND FD.EffectiveFromTimeKey<=@TimeKey 
                                                        AND FD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN SecuritizedFinalACDetail  SFD             ON  SFD.AccountID=Derivative.DerivativeRefNo
                                                        AND SFD.EffectiveFromTimeKey<=@TimeKey 
                                                        AND SFD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN IBPCFinalPoolDetail  IBPCD                ON  IBPCD.AccountID=Derivative.DerivativeRefNo
                                                        AND IBPCD.EffectiveFromTimeKey<=@TimeKey 
                                                        AND IBPCD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvAcPUIDetailMain  PUID                  ON  PUID.AccountID=Derivative.DerivativeRefNo
                                                        AND PUID.EffectiveFromTimeKey<=@TimeKey 
                                                        AND PUID.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvAcRestructureDetail  ARD               ON  ARD.RefSystemAcId=Derivative.DerivativeRefNo
                                                        AND ARD.EffectiveFromTimeKey<=@TimeKey 
                                                        AND ARD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimBranch DB                              ON DB.BranchCode=Derivative.BranchCode
                                                       AND DB.EffectiveFromTimeKey<=@TimeKey 
                                                       AND DB.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimProvision_Seg DPS                      ON DPS.ProvisionAlt_Key=Derivative.ProvisionAlt_Key
                                                       AND DPS.EffectiveFromTimeKey<=@TimeKey 
                                                       AND DPS.EffectiveToTimeKey>=@TimeKey
												  
LEFT JOIN DimProvision_SegStd DPSTD                 ON DPSTD.ProvisionAlt_Key=Derivative.ProvisionAlt_Key
                                                       AND DPSTD.EffectiveFromTimeKey<=@TimeKey 
                                                       AND DPSTD.EffectiveToTimeKey>=@TimeKey

WHERE  @SelectReport=2 AND Derivative.EffectiveFromTimeKey<=@TimeKey AND Derivative.EffectiveToTimeKey>=@TimeKey
       
	
	
	
ORDER BY UCIC_ID															

OPTION(RECOMPILE)

DROP TABLE  #PREV_QTR,#PREV_DAY,#MOC_Provision_Der,#MOC_Provision_Fin																


   
GO