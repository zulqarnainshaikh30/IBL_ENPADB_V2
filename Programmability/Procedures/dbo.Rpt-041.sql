SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
 CREATE BY   :- KALIK DEV 
 CREATE DATE :- 26/10/2021
 DESCRIPTION :-  Investment Asset Classification Processing

 */ 

 
CREATE PROCEDURE [dbo].[Rpt-041]	
    @TimeKey AS INT,
	@Cost AS FLOAT,
	@AssetClass AS VARCHAR(10)
	
AS

--DECLARE
--    @Timekey AS INT=26959,
--	@Cost AS FLOAT=1,
--	@AssetClass AS VARCHAR(10)='<ALL>'

	
DECLARE @Date AS DATE=(SELECT DATE FROM Automate_Advances WHERE TimeKey=@TimeKey)

----select 	@Date


SELECT
DISTINCT
IID.UcifId                                                                 AS UCIC_ID,
CONVERT( VARCHAR(20),@Date,103)   									AS	DateOfData,
IID.IssuerID                                                               AS IssuerID,
IID.IssuerName                                                             AS IssuerName,
IBD.InvID                                                                  AS 'InvestmentID/Derv No.',
IBD.InvestmentNature                                                       AS InvestmentNature,
CONVERT(VARCHAR(15),IBD.MaturityDt,103)                                    AS MaturityDt,
CONVERT(VARCHAR(15),IBD.ReStructureDate,103)                               AS ReStructureDate,
IFD.HoldingNature                                                          AS HoldingNature,	
--------CHANGED ON 18-04-2022--------------												                       
--ISNULL(IFD.BookValue,0)/@Cost                                              AS BookValue,
--ISNULL(IFD.MTMValue,0)/@Cost                                               AS MTMValue,
ISNULL(IFD.BookValueINR,0)/@Cost                                           AS BookValue,
ISNULL(IFD.MTMValueINR,0)/@Cost                                            AS MTMValue,														                       
CONVERT(VARCHAR(15),IFD.NPIDt,103)                                         AS NPIDt,
ISNULL(IFD.TotalProvison,0)/@Cost                                          AS TotalProvison,
IFD.GL_Code                                                                AS GL_Code,
IFD.GL_Description                                                         AS GL_Description,
CONVERT(VARCHAR(15),AFD.AC_nextreviewduedt ,103)                           AS LimitExpiryDate,
IFD.DPD                                                                    AS DPD,
ISNULL(IFD.Interest_DividendDueAmount,0)/@Cost                             AS OVERDUE_AMOUNT,

CONVERT(VARCHAR(15),IFD.PartialRedumptionDueDate,103)                      AS PartialRedumptionDueDate,
0                                                                          AS PartialRedumptionDueAmount,
IFD.FLGDEG                                                                 AS FLGDEG,
IFD.FLGUPG                                                                 AS FLGUPG,
ISNULL(IFD.DEGREASON ,'')                                                  AS NPAReason,

CASE WHEN DA.AssetClassName='LOS'
     THEN 'LOSS'
	 ELSE DA.AssetClassName
	 END                                                          AS NPIAssetClass,

   ----''                                   AS CouponOverDueSinceDt,
CONVERT(VARCHAR(15),Interest_DividendDueDate,103)                           AS CouponOverDueSinceDt,
Interest_DividendDueAmount,
IFD.SMA_Class                           AS SMA_Status,
'Investment'                            AS Flag,
InstrName                               AS InstrumentName,
''                                      AS OverDueSinceDt,
ISNULL(OVERDUE_AMOUNT,0)                AS DueAmtReceivable,

CASE WHEN FD.RFA_DateReportingByBank IS NOT NULL 
     THEN 'Yes' 
	 ELSE 'No' 
	 END						        AS RFAFraudFlag,

CONVERT(VARCHAR(15),FD.RFA_DateReportingByBank,103)        AS RFAFraudDate,


--CASE WHEN C.AssetClassAlt_Key=1
--      THEN (CASE WHEN IFD.SMA_Class='STD' THEN 'STANDARD'
--	             WHEN IFD.SMA_Class='SMA_0' THEN 'SMA 0'
--				 WHEN IFD.SMA_Class='SMA_1' THEN 'SMA 1'
--				 WHEN IFD.SMA_Class='SMA_2' THEN 'SMA 2' 
--				 END)
--	  ELSE C.SrcSysClassName 
--	  END                                         AS SubAssetClass,

CASE 
--WHEN IFD.FinalAssetClassAlt_Key=1 and IFD.SMA_Class='STD' then 'A0'
WHEN IFD.FinalAssetClassAlt_Key=1 and IFD.SMA_Class is null then 'A0'
WHEN IFD.FinalAssetClassAlt_Key=1 and IFD.SMA_Class='SMA_0' then 'S0'
WHEN IFD.FinalAssetClassAlt_Key=1 and IFD.SMA_Class='SMA_1' then 'S1'
WHEN IFD.FinalAssetClassAlt_Key=1 and IFD.SMA_Class='SMA_2' then 'S2'
WHEN IFD.FinalAssetClassAlt_Key=1 and IFD.SMA_Class='SMA_3' then 'S3'
WHEN IFD.FinalAssetClassAlt_Key=2 and DATEDIFF(day,NPIDt,@Date) <=91 then 'B0'
WHEN IFD.FinalAssetClassAlt_Key=2 and DATEDIFF(day,NPIDt,@Date) between 91 and 183 then 'B1'
WHEN IFD.FinalAssetClassAlt_Key=2 and DATEDIFF(day,NPIDt,@Date) between 183 and 274 then 'B2'
WHEN IFD.FinalAssetClassAlt_Key=2 and DATEDIFF(day,NPIDt,@Date) >=273 then 'B3'
WHEN IFD.finalassetclassalt_key=3 then 'C1'
WHEN IFD.finalassetclassalt_key=4 then 'C2'
WHEN IFD.FinalAssetClassAlt_Key=5 then 'C3'
WHEN IFD.FinalAssetClassAlt_Key=6 then 'D0'
END AS SubAssetClass,

CONVERT(VARCHAR(20),IFD.SMA_Dt,103)               AS SMA_Date0,	  
CONVERT(VARCHAR(20),CASE WHEN IFD.SMA_Class IN ('SMA_1','SMA_2')
                         THEN DATEADD(DD,30,IFD.SMA_Dt) 
						 END,103)                                                                           AS SMA_Date1,	  
CONVERT(VARCHAR(20), CASE WHEN IFD.SMA_Class='SMA_2' THEN DATEADD(DD,60,IFD.SMA_Dt) END,103)                AS SMA_Date2,
	  
IFD.SMA_Reason

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

LEFT JOIN DimAssetClass DA                                   ON DA.AssetClassAlt_Key=IFD.FinalAssetClassAlt_Key
                                                                AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DA.EffectiveToTimeKey>=@TimeKey

LEFT JOIN		(SELECT DISTINCT SourceAlt_Key,AssetClassAlt_Key,(CASE WHEN AssetClassAlt_Key = 1 THEN 'STANDARD' ELSE SrcSysClassName END)SrcSysClassName ,
				 EffectiveFromTimeKey,EffectiveToTimeKey
				 FROM DimAssetClassMapping) C ON C.AssetClassAlt_Key=IFD.FinalAssetClassAlt_Key
                                                 AND C.EffectiveFromTimeKey<=@TimeKey
									             AND C.EffectiveToTimeKey>=@TimeKey

		---------------------ADDED FOR FINELNPA DATE TO MATCH ASSET CLASS WITH BANK MASTER------------------------

LEFT JOIN pro.accountcal_hist A	                          ON IFD.FinalAssetClassAlt_Key=A.FinalAssetClassAlt_Key
                                                         AND A.EffectiveFromTimeKey<=@TimeKey
									                     AND A.EffectiveToTimeKey>=@TimeKey


WHERE  ((@AssetClass='STANDARD' AND DA.AssetClassName='STANDARD')
	     OR (@AssetClass='NPA' AND ISNULL(DA.AssetClassName,'')<>'STANDARD')
		 OR (@AssetClass='<ALL>'))

		 -----------  commented on 17052024 because bank not maintain DerivativeDetail table ----------------

--UNION ALL

--SELECT
--DISTINCT
--Derivative.UCIC_ID,
--Derivative.CustomerID                                                               AS IssuerID,
--Derivative.CustomerName                                                             AS IssuerName,
--DerivativeRefNo                                                          AS 'InvestmentID/Derv No.',
--''                                                                       AS InvestmentNature,
--CONVERT(VARCHAR(15),Duedate,103)                                         AS MaturityDt,
--''                                                                       AS ReStructureDate,
--''                                                                       AS HoldingNature,													                       
--(CASE WHEN OsAmt<0
--      THEN OsAmt*-1
--      ELSE ISNULL(OsAmt,0)END)/@Cost                                     AS BookValue,
--ISNULL(MTMIncomeAmt,0)/@Cost                                             AS MTMValue,													                       
--CONVERT(VARCHAR(15),NPIDt,103)                                           AS NPIDt,
--ISNULL(TotalProvison,0)/@Cost                                            AS TotalProvison,
--''                                                                       AS GL_Code,
--''                                                                       AS GL_Description,
--''                                                                       AS LimitExpiryDate,
--DPD                                                                      AS DPD,
--ISNULL(OverdueCouponAmt,0)/@Cost                                         AS OVERDUE_AMOUNT,

--''                                                                       AS PartialRedumptionDueDate,
--0                                                                        AS PartialRedumptionDueAmount,
--FLGDEG                                                                   AS FLGDEG,
--FLGUPG                                                                   AS FLGUPG,
--DEGREASON                                                                AS NPAReason,
--CASE WHEN DA.AssetClassName='LOS'
--     THEN 'LOSS'
--	 ELSE DA.AssetClassName
--	 END                                                        AS NPIAssetClass,
--CONVERT(VARCHAR(15),CouponOverDueSinceDt,103)                           AS CouponOverDueSinceDt,
--''                                                                      AS SMA_Status,
--'Derivative'                                                            AS Flag,
--Derivative.InstrumentName                                               AS InstrumentName,
--CONVERT(VARCHAR(20),Derivative.OverDueSinceDt,103)                      AS OverDueSinceDt,
--ISNULL(Derivative.DueAmtReceivable,0)                                   AS DueAmtReceivable,
--CASE WHEN FD.RFA_DateReportingByBank IS NOT NULL 
--     THEN 'Yes' 
--	 ELSE 'No' 
--	 END						                           AS RFAFraudFlag,

--CONVERT(VARCHAR(15),FD.RFA_DateReportingByBank,103)        AS RFAFraudDate,

--''        AS SubAssetClass,
--''        AS SMA_Date0,	  
--''        AS SMA_Date1,	 
--''	      AS SMA_Date2 , 
--''        AS SMA_Reason

--,CASE WHEN IBPCD.AccountID IS NOT NULL
--      THEN 'Yes'
--	  ELSE 'No'
--	  END                                          AS IsIBPC
--,CASE WHEN SFD.AccountID IS NOT NULL
--      THEN 'Yes'
--	  ELSE 'No'
--	  END                                          AS IsSecuritised
--,CASE WHEN FD.RFA_ReportingByBank IS NOT NULL
--      THEN 'Yes'
--	  ELSE 'No'
--	  END                                          AS RFA
--,CASE WHEN PUID.AccountID IS NOT NULL
--      THEN 'Yes'
--	  ELSE 'No'
--	  END                                          AS PUI
--,CASE WHEN FD.FraudOccuranceDate IS NOT NULL
--      THEN 'Yes'
--	  ELSE 'No'
--	  END                                          AS FlgFraud              
--,CASE WHEN ARD.RefSystemAcId IS NOT NULL
--      THEN 'Yes'
--	  ELSE 'No'
--	  END                                          AS FlgRestructure      
--,CASE WHEN AARC.AccountId IS NOT NULL
--      THEN 'Yes'
--	  ELSE 'No'
--	  END                                          AS ARCFlg

--,CASE WHEN RPD.CustomerId IS NOT NULL
--      THEN 'Yes'
--	  ELSE 'No'
--	  END                                          AS RPFlg


--FROM CURDAT.DerivativeDetail Derivative

--INNER JOIN DimAssetClass DA                       ON DA.AssetClassAlt_Key=Derivative.FinalAssetClassAlt_Key
--                                                     AND DA.EffectiveFromTimeKey<=@TimeKey 
--                                                     AND DA.EffectiveToTimeKey>=@TimeKey

--LEFT JOIN SaletoARCFinalACFlagging  AARC            ON  AARC.AccountID=Derivative.DerivativeRefNo
--                                                        AND AARC.EffectiveFromTimeKey<=@TimeKey 
--                                                        AND AARC.EffectiveToTimeKey>=@TimeKey

--LEFT JOIN RP_Portfolio_Details  RPD                 ON  RPD.CustomerID=Derivative.CustomerID
--                                                        AND RPD.EffectiveFromTimeKey<=@TimeKey 
--                                                        AND RPD.EffectiveToTimeKey>=@TimeKey

--LEFT JOIN Fraud_Details  FD                         ON  FD.RefCustomerACID=Derivative.DerivativeRefNo
--                                                        AND FD.EffectiveFromTimeKey<=@TimeKey 
--                                                        AND FD.EffectiveToTimeKey>=@TimeKey

--LEFT JOIN SecuritizedFinalACDetail  SFD             ON  SFD.AccountID=Derivative.DerivativeRefNo
--                                                        AND SFD.EffectiveFromTimeKey<=@TimeKey 
--                                                        AND SFD.EffectiveToTimeKey>=@TimeKey

--LEFT JOIN IBPCFinalPoolDetail  IBPCD                ON  IBPCD.AccountID=Derivative.DerivativeRefNo
--                                                        AND IBPCD.EffectiveFromTimeKey<=@TimeKey 
--                                                        AND IBPCD.EffectiveToTimeKey>=@TimeKey

--LEFT JOIN AdvAcPUIDetailMain  PUID                  ON  PUID.AccountID=Derivative.DerivativeRefNo
--                                                        AND PUID.EffectiveFromTimeKey<=@TimeKey 
--                                                        AND PUID.EffectiveToTimeKey>=@TimeKey

--LEFT JOIN AdvAcRestructureDetail  ARD               ON  ARD.RefSystemAcId=Derivative.DerivativeRefNo
--                                                        AND ARD.EffectiveFromTimeKey<=@TimeKey 
--                                                        AND ARD.EffectiveToTimeKey>=@TimeKey


												  

--WHERE  ((@AssetClass='STANDARD' AND DA.AssetClassName='STANDARD')
--	     OR (@AssetClass='NPA' AND ISNULL(DA.AssetClassName,'')<>'STANDARD')
--		 OR (@AssetClass='<ALL>')) AND Derivative.EffectiveFromTimeKey<=@TimeKey AND Derivative.EffectiveToTimeKey>=@TimeKey
	
	
	
	ORDER BY UCIC_ID															

OPTION(RECOMPILE)

														


   
GO