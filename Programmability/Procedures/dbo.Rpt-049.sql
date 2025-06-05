SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Rpt-049]
      @TimeKey AS INT,
	  @Cost    AS FLOAT,
	  @SelectReport AS INT
AS

--DECLARE 
--      @TimeKey AS INT=26373,
--	  @Cost    AS FLOAT=1,
--	  @SelectReport AS INT=1



DECLARE @ProcessDate DATE
SET @ProcessDate=(SELECT DATE FROM Sysdaymatrix WHERE Timekey=@TimeKey)

DECLARE @PrevDay AS INT=@TimeKey-1
DECLARE @LastMonthKey AS INT=(SELECT LastMonthDateKey FROM Sysdaymatrix WHERE Timekey=@TimeKey)
DECLARE @LastFinYearKey AS INT=(SELECT LastFinYearKey FROM Sysdaymatrix WHERE Timekey=@TimeKey)
 
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

WHERE A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey and A.FinalAssetClassAlt_key > 1

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
---------Degrade Report-------------------

SELECT 
DISTINCT
CONVERT(VARCHAR(20),Convert(date,@ProcessDate,105), 103)                  AS  [Process_date]
,SourceName
,B.UCIF_ID                                       AS UCIC
,A.RefCustomerID                                 AS CustomerID
,CustomerName
,B.Branchcode
,BranchName
,B.CustomerAcID
,B.FacilityType
,SchemeType
,B.ProductCode
,ProductName
,DPD_Max
,CONVERT(VARCHAR(20),FinalNpaDt,103)           AS FinalNpaDt
,ISNULL(B.Balance,0)/@Cost                     AS Balance
,ISNULL(B.PrincOutStd,0)/@Cost                 AS PrincOutStd
,CASE WHEN A2.AssetClassName='LOS'
      THEN 'LOSS'
	  ELSE A2.AssetClassName
	  END                                      AS AssetClass
,ISNULL(B.IntOverdue,0)/@Cost                  AS IntOverdue

,ISNULL(FIN.PenalOverdueinterest,0)/@Cost      AS Penal_Interest_Overdue
,ISNULL(B.OtherOverdue,0)/@Cost                AS OtherOverdue
,ISNULL(FIN.UnAppliedIntAmount,0)/@Cost        AS [Interest accrued but not due]
,ISNULL(FIN.PenalUnAppliedIntAmount,0)/@Cost   AS [Penal accrued but not due]

,CASE WHEN ISNULL(RestructureAmt,0)>0
      THEN 'Yes'
	  ELSE 'No'
	  END                                      AS [Restructured - Y/N]
,CASE WHEN B.FinalAssetClassAlt_key = 1 THEN 0 ELSE ISNULL(FIN.UnAppliedIntAmount,0)/@Cost  END      AS [IIS Today]
,CASE WHEN B.FinalAssetClassAlt_key = 1 THEN 0 ELSE ISNULL(FINPD.UnAppliedIntAmount,0)/@Cost   END   AS [IIS Yesterday]
,CASE WHEN B.FinalAssetClassAlt_key = 1 THEN 0 ELSE (ISNULL(FIN.UnAppliedIntAmount,0)-ISNULL(FINPD.UnAppliedIntAmount,0))/@Cost  END      AS [Change in IIS Today]
,CASE WHEN B.FinalAssetClassAlt_key = 1 THEN 0 ELSE ISNULL(FINLM.UnAppliedIntAmount,0)/@Cost  END    AS [IIS Last Month]
,CASE WHEN B.FinalAssetClassAlt_key = 1 THEN 0 ELSE  ISNULL(FINLF.UnAppliedIntAmount,0)/@Cost   END    AS [IIS Last Fiscal Year End]



FROM PRO.CUSTOMERCAL_Hist A
INNER JOIN Pro.AccountCal_Hist B           ON A.CustomerEntityID=B.CustomerEntityID
                                              AND A.EffectiveFromTimeKey<=@TimeKey
									          AND A.EffectiveToTimeKey>=@TimeKey
                                              AND B.EffectiveFromTimeKey<=@TimeKey
									          AND B.EffectiveToTimeKey>=@TimeKey

left join AdvAcRestructureDetail ACRD     ON  B.CustomerACID=ACRD.RefSystemAcId
                                          AND  ACRD.EffectiveFromTimeKey<=@TimeKey AND ACRD.EffectiveToTimeKey>=@TimeKey        
									  

INNER JOIN #DPD PD          	           ON  PD.CustomerAcID=B.CustomerAcID

LEFT JOIN DimAssetClass A2	               ON A2.AssetClassAlt_Key=B.FinalAssetClassAlt_Key
                                              AND A2.EffectiveFromTimeKey <= @Timekey 
											  AND A2.EffectiveToTimeKey >= @Timekey

LEFT JOIN DimSourceDB SRC	               ON B.SourceAlt_Key =SRC.SourceAlt_Key
                                              AND SRC.EffectiveFromTimeKey <= @Timekey 
											  AND SRC.EffectiveToTimeKey >= @Timekey

LEFT JOIN DimProduct DP                    ON  DP.ProductCode=B.ProductCode
                                               AND DP.EffectiveFromTimeKey <= @Timekey 
											   AND DP.EffectiveToTimeKey >= @Timekey

LEFT JOIN DimBranch X                      ON B.BranchCode = X.BranchCode
                                              AND x.EffectiveFromTimeKey <= @Timekey 
									          AND X.EffectiveToTimeKey >= @Timekey

LEFT JOIN AdvAcOtherFinancialDetail FIN    ON B.AccountEntityId = FIN.AccountEntityId
                                               AND FIN.EffectiveFromTimeKey<=@TimeKey
									           AND FIN.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvAcOtherFinancialDetail FINPD   ON FINPD.AccountEntityId = B.AccountEntityId
                                               AND FINPD.EffectiveFromTimeKey<=@PrevDay
									           AND FINPD.EffectiveToTimeKey>=@PrevDay

LEFT JOIN AdvAcOtherFinancialDetail FINLM   ON FINLM.AccountEntityId = B.AccountEntityId
                                               AND FINLM.EffectiveFromTimeKey<=@LastMonthKey
									           AND FINLM.EffectiveToTimeKey>=@LastMonthKey

LEFT JOIN AdvAcOtherFinancialDetail FINLF   ON FINLF.AccountEntityId = B.AccountEntityId
                                               AND FINLF.EffectiveFromTimeKey<=@LastFinYearKey
									           AND FINLF.EffectiveToTimeKey>=@LastFinYearKey


WHERE @SelectReport=1 and B.FinalAssetClassAlt_key > 1

OPTION(RECOMPILE)

DROP TABLE #DPD
GO