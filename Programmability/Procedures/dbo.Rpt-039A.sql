SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
 CREATE BY   :- Baijayanti
 CREATE DATE :- 08/08/2022
 DESCRIPTION :- Calypso For ALL NPA Report

 */ 

 
CREATE PROCEDURE [dbo].[Rpt-039A]	
    @TimeKey AS INT,
	@SelectReport AS INT
	
AS

--DECLARE
--    @Timekey AS INT=26479,
--	@SelectReport AS INT=2
	


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
     THEN 'Y'
     ELSE 'N'
	 END                                                                   AS Restructured_Y_N,
CONVERT(VARCHAR(15),IBD.ReStructureDate,103)                               AS ReStructureDate,
IFD.HoldingNature                                                          AS HoldingNature,	
--------CHANGED ON 18-04-2022--------------												                       
ISNULL(IFD.BookValueINR,0)                                                 AS BookValue,
ISNULL(IFD.MTMValueINR,0)                                                  AS MTMValue,														                       
IFD.GL_Code                                                                AS GL_Code,
IFD.GL_Description                                                         AS GL_Description,
CONVERT(VARCHAR(15),AFD.AC_nextreviewduedt ,103)                           AS LimitExpiryDate,
IFD.DPD                                                                    AS DPD,
ISNULL(IFD.Interest_DividendDueAmount,0)                                   AS OVERDUE_AMOUNT,
0                                                                          AS PartialRedumptionDueAmount,
CONVERT(VARCHAR(15),IFD.PartialRedumptionDueDate,103)                      AS PartialRedumptionDueDate,
IFD.FLGDEG                                                                 AS FLGDEG,
IFD.DEGREASON                                                              AS DEGREASON,
IFD.FLGUPG                                                                 AS FLGUPG,

''                                                AS CouponOverDueSinceDt,
'Investment'                                      AS Flag,
InstrName                                         AS InstrumentName,
''                                                AS OverDueSinceDt,
ISNULL(OVERDUE_AMOUNT,0)                          AS DueAmtReceivable,

C.SrcSysClassName                                 AS SubAssetClass,

CONVERT(VARCHAR(20),CASE WHEN DA.AssetClassShortNameEnum='SUB'
                         THEN NPIDt
						 END,103)                                                  AS SubSTD,
	  
CONVERT(VARCHAR(20),CASE WHEN DA.AssetClassShortNameEnum='DB1'
                         THEN DATEADD(YYYY,1,NPIDt)
						 END,103)                                                 AS DBTDate1,
CONVERT(VARCHAR(20),CASE WHEN DA.AssetClassShortNameEnum='DB2'
                         THEN DATEADD(YYYY,2,NPIDt)
						 END,103)								                  AS DBTDate2,
CONVERT(VARCHAR(20),CASE WHEN DA.AssetClassShortNameEnum='DB3'
                         THEN DATEADD(YYYY,4,NPIDt)
						 END,103)								                  AS DBTDate3,

CONVERT(VARCHAR(20),CASE WHEN DA.AssetClassShortNameEnum='LOS'
                         THEN SDM.[DATE]
						 END,103)								                  AS LossDate,
ISNULL(ProvisionSecured,0)                        AS ProvisionPerSecured,
ISNULL(ProvisionUnSecured,0)                      AS ProvisionPerUnSecured,

ISNULL(IFD.TotalProvison,0)*100/NULLIF(IFD.BookvalueINr,0) 	  AS FinalPerProvision,

CASE WHEN FD.RFA_DateReportingByBank IS NOT NULL
     THEN 'Yes' 
	 ELSE 'No' 
	 END									   AS RFAFraudFlag,

CONVERT(VARCHAR(15),FD.RFA_DateReportingByBank,103)        AS RFAFraudDate,

0												  AS DFVAmt,
0												  AS GovtGtyAmt,						
0												  AS CoverGovGur,
0												  AS UnAdjSubSidy,
0												  AS SecuredAmt,
0												  AS UnSecuredAmt,
0												  AS ApprRV,
0												  AS ProvDFV,
0		                                          AS AddlProvision,
0												  AS WriteOffAmount,

ISNULL(IFD.Interest_DividendDueAmount,0)		  AS InterestInSuspenseAmount,
0												  AS Totalincomesuspended,
ISNULL(IFD.BookValueINR,0)						  AS NetBalance

,CASE WHEN IBPCD.AccountID IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsIBPC
,CASE WHEN SFD.AccountID IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsSecuritised
,CASE WHEN FD.RFA_ReportingByBank IS NOT NULL
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

INNER JOIN SysDayMatrix SDM                                 ON IFD.EffectiveFromTimeKey=SDM.TimeKey

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

LEFT JOIN AdvAcFinancialDetail		AFD						ON  IBD.InvEntityId=AFD.AccountEntityId 
															    AND AFD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND AFD.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimAssetClass DA                                 ON DA.AssetClassAlt_Key=IFD.FinalAssetClassAlt_Key
                                                                AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DA.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimBranch DB                                       ON DB.BranchCode=IBD.BranchCode
                                                                AND DB.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DB.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimProvision_Seg DPS                               ON DPS.ProvisionAlt_Key=IFD.ProvisionAlt_Key
                                                                AND DPS.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DPS.EffectiveToTimeKey>=@TimeKey

LEFT JOIN		(SELECT DISTINCT SourceAlt_Key,AssetClassAlt_Key,(CASE WHEN AssetClassAlt_Key = 1 THEN 'STANDARD' ELSE SrcSysClassName END)SrcSysClassName ,
				 EffectiveFromTimeKey,EffectiveToTimeKey
				 FROM DimAssetClassMapping) C ON C.AssetClassAlt_Key=IFD.FinalAssetClassAlt_Key
                                                 AND C.EffectiveFromTimeKey<=@TimeKey
									             AND C.EffectiveToTimeKey>=@TimeKey

WHERE  @SelectReport=2 AND ISNULL(IFD.FinalAssetClassAlt_Key,0)<>1


UNION ALL

SELECT
DISTINCT
Derivative.SourceSystem                                                             AS SourceSystem,
DB.BranchName,
Derivative.UCIC_ID,
Derivative.CustomerID                                                               AS IssuerID,
Derivative.CustomerName                                                             AS IssuerName,
DerivativeRefNo                                                          AS 'InvestmentID/Derv No.',
''                                                                       AS InvestmentNature,
CONVERT(VARCHAR(15),Duedate,103)                                         AS MaturityDt,
''                                                                       AS Restructured_Y_N,
''                                                                       AS ReStructureDate,
''                                                                       AS HoldingNature,													                       
(CASE WHEN ISNULL(OsAmt,0)<0
      THEN ISNULL(OsAmt,0)*-1
      ELSE ISNULL(OsAmt,0)END)                                           AS BookValue,
ISNULL(MTMIncomeAmt,0)                                                   AS MTMValue,													                       
''                                                                       AS GL_Code,
''                                                                       AS GL_Description,
''                                                                       AS LimitExpiryDate,
DPD                                                                      AS DPD,
ISNULL(OverdueCouponAmt,0)                                               AS OVERDUE_AMOUNT,
0                                                                        AS PartialRedumptionDueAmount,
''                                                                       AS PartialRedumptionDueDate,
FLGDEG                                                                   AS FLGDEG,
DEGREASON                                                                AS DEGREASON,
FLGUPG                                                                   AS FLGUPG,
CONVERT(VARCHAR(15),CouponOverDueSinceDt,103)                            AS CouponOverDueSinceDt,
'Derivative'                                                             AS Flag,
Derivative.InstrumentName                                                AS InstrumentName,
CONVERT(VARCHAR(20),Derivative.OverDueSinceDt,103)                       AS OverDueSinceDt,
ISNULL(Derivative.DueAmtReceivable,0)                                    AS DueAmtReceivable,
C.SrcSysClassName                                                        AS SubAssetClass,
CONVERT(VARCHAR(20),CASE WHEN DA.AssetClassShortNameEnum='SUB'
                         THEN SDM.[DATE]
						 END,103)                                        AS SubSTD,	  
CONVERT(VARCHAR(20),CASE WHEN DA.AssetClassShortNameEnum='DB1'
                         THEN DATEADD(YYYY,1,NPIDt)
						 END,103)                                        AS DBTDate1,
CONVERT(VARCHAR(20),CASE WHEN DA.AssetClassShortNameEnum='DB2'
                         THEN DATEADD(YYYY,2,NPIDt)
						 END,103)								         AS DBTDate2,
CONVERT(VARCHAR(20),CASE WHEN DA.AssetClassShortNameEnum='DB3'
                         THEN DATEADD(YYYY,4,NPIDt)
						 END,103)								         AS DBTDate3,	

CONVERT(VARCHAR(20),CASE WHEN DA.AssetClassShortNameEnum='LOS'
                         THEN SDM.[DATE]
						 END,103)								         AS LossDate,
ISNULL(ProvisionSecured,0)                                               AS ProvisionPerSecured,
ISNULL(ProvisionUnSecured,0)                                             AS ProvisionPerUnSecured,
ISNULL(Derivative.TotalProvison,0) *100/NULLIF(Derivative.MTMIncomeAmt,0)  	  	 AS FinalPerProvision,

CASE WHEN FD.RFA_DateReportingByBank IS NOT NULL
     THEN 'Yes' 
	 ELSE 'No' 
	 END																 AS RFAFraudFlag,
CONVERT(VARCHAR(15),FD.RFA_DateReportingByBank,103)						 AS RFAFraudDate,
0																		 AS DFVAmt,
0																		 AS GovtGtyAmt,
0																		 AS	CoverGovGur,
0																		 AS UnAdjSubSidy,
0																		 AS SecuredAmt,
0																		 AS UnSecuredAmt,
0																		 AS ApprRV,
0																		 AS ProvDFV,
0								                                         AS AddlProvision,
0																		 AS WriteOffAmount,
ISNULL(Derivative.MTMIncomeAmt,0)										 AS InterestInSuspenseAmount,
0																		 AS Totalincomesuspended,
ISNULL(MTMIncomeAmt,0)													 AS NetBalance

,CASE WHEN IBPCD.AccountID IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsIBPC
,CASE WHEN SFD.AccountID IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsSecuritised
,CASE WHEN FD.RFA_ReportingByBank IS NOT NULL
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

INNER JOIN DimAssetClass DA                        ON DA.AssetClassAlt_Key=Derivative.FinalAssetClassAlt_Key
                                                      AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                      AND DA.EffectiveToTimeKey>=@TimeKey

INNER JOIN SysDayMatrix SDM                       ON Derivative.EffectiveFromTimeKey=SDM.TimeKey

LEFT JOIN DimBranch DB                            ON DB.BranchCode=Derivative.BranchCode
                                                       AND DB.EffectiveFromTimeKey<=@TimeKey 
                                                       AND DB.EffectiveToTimeKey>=@TimeKey

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

LEFT JOIN DimProvision_Seg DPS                      ON DPS.ProvisionAlt_Key=Derivative.ProvisionAlt_Key
                                                       AND DPS.EffectiveFromTimeKey<=@TimeKey 
                                                       AND DPS.EffectiveToTimeKey>=@TimeKey
												  
LEFT JOIN		(SELECT DISTINCT SourceAlt_Key,AssetClassAlt_Key,(CASE WHEN AssetClassAlt_Key = 1 THEN 'STANDARD' ELSE SrcSysClassName END)SrcSysClassName ,
				 EffectiveFromTimeKey,EffectiveToTimeKey
				 FROM DimAssetClassMapping) C ON C.AssetClassAlt_Key=Derivative.FinalAssetClassAlt_Key
                                                 AND C.EffectiveFromTimeKey<=@TimeKey
									             AND C.EffectiveToTimeKey>=@TimeKey

WHERE  @SelectReport=2 AND Derivative.EffectiveFromTimeKey<=@TimeKey AND Derivative.EffectiveToTimeKey>=@TimeKey
       AND ISNULL(Derivative.FinalAssetClassAlt_Key,0)<>1
	
	
	
	ORDER BY UCIC_ID															

OPTION(RECOMPILE)

																


   
GO