SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


----------------------AssetClassification  ALL NPA  Report----------------------

CREATE PROC [dbo].[Rpt-039]
	@TimeKey  INT,
	@SelectReport AS INT
	AS 


--DECLARE  @TimeKey AS INT=26471,
--         @SelectReport AS INT=1

DECLARE @ProcessDate DATE=(SELECT DATE FROM Sysdaymatrix WHERE Timekey=@TimeKey)


---------------------------======================================DPD CalCULATION  Start===========================================

IF OBJECT_ID('TempDB..#DPD') IS NOT NULL
DROP TABLE #DPD


SELECT            A.CustomerAcID
                 ,A.AccountEntityID
                 ,A.IntNotServicedDt
                 ,A.LastCrDate
                 ,A.ContiExcessDt
                 ,A.OverDueSinceDt
                 ,A.ReviewDueDt
                 ,A.StockStDt
                 ,A.DebitSinceDt
                 ,A.PrincOverdueSinceDt
                 ,A.IntOverdueSinceDt
                 ,A.OtherOverdueSinceDt
                 ,A.SourceAlt_Key
				 ,PenalInterestOverDueSinceDt
INTO #DPD
FROM pro.AccountCal_Hist A
LEFT JOIN  AdvAcOtherFinancialDetail FIN    ON A.AccountEntityId = FIN.AccountEntityId
                                               AND FIN.EffectiveFromTimeKey<=@TimeKey
									           AND FIN.EffectiveToTimeKey>=@TimeKey

WHERE A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey

OPTION(RECOMPILE)
---------------
Alter Table #DPD
Add        DPD_IntService Int
          ,DPD_NoCredit Int
          ,DPD_Overdrawn Int
          ,DPD_Overdue Int
          ,DPD_Renewal Int
          ,DPD_StockStmt Int
          ,DPD_PrincOverdue Int
          ,DPD_IntOverdueSince Int
          ,DPD_OtherOverdueSince Int
          ,DPD_Max Int
		  ,DPD_PenalInterestOverdue INT

-------------------

UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)+1  ELSE 0 END)                          
             ,A.DPD_NoCredit = CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>=90)
                                                                                        THEN (CASE WHEN  A.LastCrDate IS NOT NULL
                                                                                        THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)+0
                                                                                        ELSE 0  
                                                                                        END)
                                                                                        ELSE 0 
																						END

                         ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END)
                         ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END)
                         ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)  +1    ELSE 0 END)
                         ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL THEN   DateDiff(Day,DATEADD(month,3,A.StockStDt),@ProcessDate)+1 ELSE 0 END)
                         ,A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,@ProcessDate)+1  ELSE 0 END)                          
                         ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  @ProcessDate)+1       ELSE 0 END)
                         ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  @ProcessDate)+1  ELSE 0 END)
						 ,A.DPD_PenalInterestOverdue=(CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.PenalInterestOverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END)
FROM #DPD A


OPTION(RECOMPILE)

----New Condition Added By Report Team  02/08/2022 for 1 Augesut greter or equal ---

IF @TimeKey>=26511
BEGIN
UPDATE #DPD SET 
#DPD.DPD_IntService=0,
#DPD.DPD_NoCredit=0,
#DPD.DPD_Overdrawn=0,
#DPD.DPD_Overdue=0,
#DPD.DPD_Renewal=0,
#DPD.DPD_StockStmt=0,
#DPD.DPD_PrincOverdue=0,
#DPD.DPD_IntOverdueSince=0,
#DPD.DPD_OtherOverdueSince=0
FROM  Pro.ACCOUNTCAL_hist A
INNER JOIN AdvAcBalanceDetail C      ON A.AccountEntityId=C.AccountEntityId
INNER JOIN #DPD  DPD                 ON DPD.AccountEntityID=A.AccountEntityID
INNER JOIN DimProduct B              ON A.ProductCode=B.ProductCode 


WHERE ISNULL(A.Balance,0)=0 AND ISNULL(C.SignBalance,0)>=0
      AND B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey 
      AND C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey
      AND A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey
      AND A.DebitSinceDt IS NULL

OPTION(RECOMPILE)

END
------------------------------

 UPDATE #DPD SET DPD_IntService=0 WHERE ISNULL(DPD_IntService,0)<0
 UPDATE #DPD SET DPD_NoCredit=0 WHERE ISNULL(DPD_NoCredit,0)<0
 UPDATE #DPD SET DPD_Overdrawn=0 WHERE ISNULL(DPD_Overdrawn,0)<0
 UPDATE #DPD SET DPD_Overdue=0 WHERE ISNULL(DPD_Overdue,0)<0
 UPDATE #DPD SET DPD_Renewal=0 WHERE ISNULL(DPD_Renewal,0)<0
 UPDATE #DPD SET DPD_StockStmt=0 WHERE ISNULL(DPD_StockStmt,0)<0
 UPDATE #DPD SET DPD_PrincOverdue=0 WHERE ISNULL(DPD_PrincOverdue,0)<0
 UPDATE #DPD SET DPD_IntOverdueSince=0 WHERE ISNULL(DPD_IntOverdueSince,0)<0
 UPDATE #DPD SET DPD_OtherOverdueSince=0 WHERE ISNULL(DPD_OtherOverdueSince,0)<0
 UPDATE #DPD SET DPD_PenalInterestOverdue=0 WHERE ISNULL(DPD_PenalInterestOverdue,0)<0

UPDATE A SET A.DPD_Max=0  FROM #Dpd  A
UPDATE   A SET A.DPD_Max= (CASE    WHEN (ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_NoCredit,0)
                                        AND ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_Overdrawn,0)
                                                                                AND    ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_Overdue,0)
                                                                                AND  ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_Renewal,0)
                                                                                AND ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_StockStmt,0))
                                                                   THEN ISNULL(A.DPD_IntService,0)
                                   WHEN (ISNULL(A.DPD_NoCredit,0)>=ISNULL(A.DPD_IntService,0)
                                                                        AND ISNULL(A.DPD_NoCredit,0)>=  ISNULL(A.DPD_Overdrawn,0)
                                                                        AND    ISNULL(A.DPD_NoCredit,0)>=ISNULL(A.DPD_Overdue,0)
                                                                        AND    ISNULL(A.DPD_NoCredit,0)>=  ISNULL(A.DPD_Renewal,0)
                                                                        AND ISNULL(A.DPD_NoCredit,0)>=ISNULL(A.DPD_StockStmt,0))
                                                                   THEN   ISNULL(A.DPD_NoCredit ,0)
                                                                   WHEN (ISNULL(A.DPD_Overdrawn,0)>=ISNULL(A.DPD_NoCredit,0)  
                                                                        AND ISNULL(A.DPD_Overdrawn,0)>= ISNULL(A.DPD_IntService,0)  
                                                                                AND  ISNULL(A.DPD_Overdrawn,0)>=ISNULL(A.DPD_Overdue,0)
                                                                                AND   ISNULL(A.DPD_Overdrawn,0)>= ISNULL(A.DPD_Renewal,0)
                                                                                AND ISNULL(A.DPD_Overdrawn,0)>=ISNULL(A.DPD_StockStmt,0))
                                                                   THEN  ISNULL(A.DPD_Overdrawn,0)
                                                                   WHEN (ISNULL(A.DPD_Renewal,0)>=ISNULL(A.DPD_NoCredit,0)    
                                                                        AND ISNULL(A.DPD_Renewal,0)>=   ISNULL(A.DPD_IntService,0)  
                                                                                AND  ISNULL(A.DPD_Renewal,0)>=ISNULL(A.DPD_Overdrawn,0)  
                                                                                AND  ISNULL(A.DPD_Renewal,0)>=   ISNULL(A.DPD_Overdue,0)  
                                                                                AND ISNULL(A.DPD_Renewal,0) >=ISNULL(A.DPD_StockStmt ,0))
                                                                   THEN ISNULL(A.DPD_Renewal,0)
                                       WHEN (ISNULL(A.DPD_Overdue,0)>=ISNULL(A.DPD_NoCredit,0)    
                                                                        AND ISNULL(A.DPD_Overdue,0)>=   ISNULL(A.DPD_IntService,0)
                                                                            AND  ISNULL(A.DPD_Overdue,0)>=ISNULL(A.DPD_Overdrawn,0)  
                                                                                AND  ISNULL(A.DPD_Overdue,0)>=   ISNULL(A.DPD_Renewal,0)  
                                                                                AND ISNULL(A.DPD_Overdue ,0)>=ISNULL(A.DPD_StockStmt ,0))  
                                                                   THEN   ISNULL(A.DPD_Overdue,0)
                                                                   ELSE ISNULL(A.DPD_StockStmt,0)
                                                END)
                         
FROM  #DPD a

WHERE  (ISNULL(A.DPD_IntService,0)>0   OR ISNULL(A.DPD_Overdrawn,0)>0   OR  ISNULL(A.DPD_Overdue,0)>0        
       OR ISNULL(A.DPD_Renewal,0) >0 OR ISNULL(A.DPD_StockStmt,0)>0 OR ISNULL(DPD_NoCredit,0)>0)


------------------------------------------------=========================END===========================


SELECT 
DISTINCT
CONVERT(VARCHAR(10),@ProcessDate,103)                                       AS CurrentProcessingDate
---------RefColumns---------
,H.SourceName
,A.UCIF_ID
,A.RefCustomerID as CustomerID
,F.CustomerName
,A.BranchCode
,DB.BranchName
,A.CustomerAcID
,CONVERT(VARCHAR(20),A.AcOpenDt,103)                                       AS AccountOpenDate
,A.FacilityType
,D.SchemeType
,A.ProductCode
,D.ProductName
,DPD_Max
,ISNULL(A.Balance,0)                                                       AS Balance
,ISNULL(A.PrincOutStd,0)                                                   AS PrincOutStd                                                   
,ISNULL(A.DrawingPower,0)                                                  AS DrawingPower
,ISNULL(A.CurrentLimit,0)                                                  AS CurrentLimit
,DPD_Overdrawn                                                             AS DPD_Overdrawn
,CONVERT(VARCHAR(20),A.ContiExcessDt,103)                                  AS DP_Overdrawn_date
,CONVERT(VARCHAR(20),A.ReviewDueDt,103)                                    AS Limit_Expiry_Date
,DPD_Renewal                                                               AS DPD_limit_Expiry
,CONVERT(VARCHAR(20),A.StockStDt,103)                                      AS StockStDt
,DPD_StockStmt                                                             AS DPD_StockStmt
,CONVERT(VARCHAR(20),A.DebitSinceDt,103)                                   AS DebitSinceDt
,CONVERT(VARCHAR(20),A.LastCrDate,103)                                     AS LastCrDate
,DPD_NoCredit                                                              AS DPD_NoCredit
,ISNULL(CurQtrCredit,0)                                                    AS CurQtrCredit
,ISNULL(CurQtrInt,0)                                                       AS CurQtrInt
,ISNULL(PrincOverdue,0)                                                    AS PrincOverdue
,CONVERT(VARCHAR(20),A.PrincOverdueSinceDt,103)                            AS PrincOverdueSinceDt
,DPD_PrincOverdue                                                          AS DPD_PrincOverdue
,ISNULL(IntOverdue,0)                                                      AS IntOverdue
,CONVERT(VARCHAR(20),A.IntOverdueSinceDt,103)                              AS IntOverdueSinceDt
,DPD_IntOverdueSince                                                       AS DPD_IntOverdueSince
,ISNULL(FIN.PenalOverdueinterest,0)                                        AS Penal_Interest_Overdue
,CONVERT(VARCHAR(20),FIN.PenalInterestOverDueSinceDt,103)                  AS Penal_Interest_Overdue_Date
,ISNULL(DPD_PenalInterestOverdue,0)                                        AS DPD_Penal_Interest_Overdue
,ISNULL(OtherOverdue,0)                                                    AS OtherOverdue
,CONVERT(VARCHAR(20),A.OtherOverdueSinceDt,103)                            AS OtherOverdueSinceDt
,DPD_OtherOverdueSince                                                     AS DPD_OtherOverdueSince
,ISNULL(OverdueAmt,0)                                                      AS OverdueAmt
,CONVERT(VARCHAR(20),A.OverDueSinceDt,103)                                 AS OverDueSinceDt
,DPD_Overdue                                                               AS DPD_Overdue
--,A.FlgRestructure
,FlgFraud                                                                  AS RFA_Fraud_Flag
,CONVERT(VARCHAR(20),FraudDate,103)                                        AS RFA_Fraud_Date
,CASE WHEN C.AssetClassAlt_Key=1
      THEN (CASE WHEN A.SMA_Class='STD' THEN 'STANDARD'
	            WHEN A.SMA_Class='SMA_0' THEN 'SMA 0'
				WHEN A.SMA_Class='SMA_1' THEN 'SMA 1'
				WHEN A.SMA_Class='SMA_2' THEN 'SMA 2' 
				END)
	  WHEN C.SrcSysClassName='SUBST'
	  THEN 'SUBSTD'
	  ELSE C.SrcSysClassName 
	  END                                                                  AS SubAssetClass 
,A.NPA_Reason
,ISNULL(A.DFVAmt,0)                                                        AS DFVAmt
,ISNULL(A.GovtGtyAmt,0)                                                    AS GovtGtyAmt
,ISNULL(A.UnAdjSubSidy,0)                                                  AS UnAdjSubSidy
,ISNULL(A.CoverGovGur,0)                                                   AS CoverGovGur
,ISNULL(A.SecuredAmt,0)                                                    AS SecuredAmt
,ISNULL(A.UnSecuredAmt,0)                                                  AS UnSecuredAmt
,ISNULL(A.ApprRV,0)                                                        AS ApprRV
,(ISNULL(ProvSecured,0)/NULLIF(SecuredAmt,0))*100	                       AS ProvPerSecured
,(ISNULL(ProvUnSecured,0)/NULLIF(UnSecuredAmt,0))*100                      AS ProvPerUnSecured
,ISNULL(A.ProvDFV,0)                                                       AS ProvDFV
,ISNULL(AddlProvision,0)                                                   AS AddlProvision
,(ISNULL(TotalProvision,0)/NULLIF(NetBalance,0))*100                       AS FinalProvisionPer
,ISNULL(A.WriteOffAmount,0)                                                AS WriteOffAmount
,ISNULL(A.NetBalance,0)                                                    AS NetBalance
,A.FlgDeg
,A.FlgUpg
,CONVERT(VARCHAR(20),A.FinalNpaDt,103)                                     AS SubSTD
,(CASE WHEN FlgErosion = 'Y' and FInalAssetclassAlt_key =3 THEN CONVERT(VARCHAR(20),DATEADD(YYYY,1,F.DbtDt),103) 
		WHEN (FlgFraud = 'Y' OR ISNULL(WriteoffAmount,0) > 0) THEN CASE WHEN InitialAssetClassAlt_Key < 3  THEN '' ELSE CONVERT(VARCHAR(20),DATEADD(YYYY,1,F.DbtDt),103) END 
		WHEN (FlgErosion = 'N' AND FlgFraud = 'N' AND ISNULL(WriteoffAmount,0) = 0) and FinalAssetClassAlt_key >= 3 THEN CONVERT(VARCHAR(20),DATEADD(YYYY,1,A.FinalNpaDt),103)  
		ELSE  ''
 END) AS DB1
,(CASE	WHEN FinalAssetClassAlt_key >= 4 THEN CASE	WHEN (FlgErosion = 'Y' OR FlgFraud = 'Y' OR ISNULL(WriteoffAmount,0) > 0) 
													THEN ''  
													ELSE CONVERT(VARCHAR(20),DATEADD(YYYY,2,A.FinalNpaDt),103) END	ELSE '' END)			   AS DB2

,(CASE	WHEN FinalAssetClassAlt_key >= 5 THEN CASE	WHEN (FlgErosion = 'Y' OR FlgFraud = 'Y' OR ISNULL(WriteoffAmount,0) > 0) 
													THEN ''  
													ELSE CONVERT(VARCHAR(20),DATEADD(YYYY,4,A.FinalNpaDt),103) END	ELSE '' END)					   AS DB3
,CASE WHEN FinalAssetClassAlt_Key = 6 THEN CONVERT(VARCHAR(20),ISNULL(ACND.LosDt,ACND.NPADt),103)    ELSE '' END                                  AS LossDt
,CASE WHEN FinalAssetClassAlt_key = 1 THEN 0 ELSE ISNULL(FIN.UnAppliedIntAmount,0)		END	   AS InterestInSuspenseAmount
,0												                      AS Totalincomesuspended
,CASE WHEN ISNULL(A.IsIBPC,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsIBPC
,CASE WHEN ISNULL(A.IsSecuritised,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsSecuritised
,CASE WHEN ISNULL(A.RFA,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS RFA
,CASE WHEN ISNULL(A.PUI,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS PUI
,CASE WHEN ISNULL(A.FlgFraud,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS FlgFraud              
,CASE WHEN ISNULL(A.FlgRestructure,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS FlgRestructure      
,CASE WHEN SARC.AccountId IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS ARCFlg

,CASE WHEN RPD.CustomerId IS NOT NULL
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS RPFlg

FROM Pro.AccountCal_Hist A

INNER JOIN Pro.CustomerCal_Hist F                 ON F.CustomerEntityId=A.CustomerEntityId 
                                                     AND F.EffectiveFromTimeKey<=@TimeKey  
												     AND F.EffectiveToTimeKey>=@TimeKey
													 AND A.EffectiveFromTimeKey<=@TimeKey  
													 AND A.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvCustNPADetail ACND                   ON ACND.CustomerEntityId=A.CustomerEntityId 
                                                     AND ACND.EffectiveFromTimeKey<=@TimeKey  
												     AND ACND.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvAcOtherFinancialDetail FIN           ON A.AccountEntityId = FIN.AccountEntityId
                                                      AND FIN.EffectiveFromTimeKey<=@TimeKey
									                  AND FIN.EffectiveToTimeKey>=@TimeKey

INNER JOIN #DPD DPD                               ON DPD.AccountEntityID=A.AccountEntityID

LEFT JOIN SaletoARCFinalACFlagging SARC           ON SARC.AccountId=A.CustomerAcID
                                                     AND SARC.EffectiveFromTimeKey<=@TimeKey
									                 AND SARC.EffectiveToTimeKey>=@TimeKey

LEFT JOIN RP_Portfolio_Details  RPD               ON RPD.CustomerId=A.RefCustomerID
                                                      AND RPD.EffectiveFromTimeKey<=@TimeKey
									                  AND RPD.EffectiveToTimeKey>=@TimeKey 

LEFT JOIN DimAssetClass  DAC                      ON DAC.AssetClassAlt_Key=A.FinalAssetClassAlt_Key 
                                                     AND DAC.EffectiveFromTimeKey<=@TimeKey  
													 AND DAC.EffectiveToTimeKey>=@TimeKey

INNER JOIN DIMSOURCEDB H                          ON H.SourceAlt_Key=A.SourceAlt_Key   
                                                     AND H.EffectiveFromTimeKey<=@TimeKey  
													 AND H.EffectiveToTimeKey>=@TimeKey


LEFT JOIN	DimProduct D                          ON A.ProductAlt_Key=D.ProductAlt_Key 
                                                     AND D.EffectiveFromTimeKey<=@TimeKey  
													 AND D.EffectiveToTimeKey>=@TimeKey

LEFT JOIN	DimBranch DB                          ON A.BranchCode=DB.BranchCode 
                                                     AND DB.EffectiveFromTimeKey<=@TimeKey  
													 AND DB.EffectiveToTimeKey>=@TimeKey

LEFT JOIN	(SELECT DISTINCT SourceAlt_Key
                            ,AssetClassAlt_Key
							,(CASE WHEN AssetClassAlt_Key = 1 THEN 'STD' 
							       ELSE SrcSysClassCode 
							  END)SrcSysClassName 
							,AssetClassName
							,EffectiveFromTimeKey
							,EffectiveToTimeKey
							,AssetClassShortName
			  FROM DimAssetClassMapping) C         ON C.AssetClassAlt_Key=A.FinalAssetClassAlt_Key 
                                                      AND C.SourceAlt_Key=D.SourceAlt_Key
                                                      AND C.EffectiveFromTimeKey<=@TimeKey  
													  AND C.EffectiveToTimeKey>=@TimeKey


WHERE A.FinalAssetClassAlt_Key>1  AND H.SourceAlt_Key=1 AND @SelectReport =1



OPTION(RECOMPILE)

DROP TABLE #DPD


GO