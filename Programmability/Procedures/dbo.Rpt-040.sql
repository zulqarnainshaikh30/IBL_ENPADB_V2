SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE Procedure [dbo].[Rpt-040]
@TimeKey  INT,
@Cost AS FLOAT
AS


--DECLARE  @TimeKey AS INT=26959,
--         @Cost AS FLOAT=1

--DECLARE @ProcessDate DATE
--SET @ProcessDate=(SELECT DATE FROM Sysdaymatrix WHERE Timekey=@TimeKey)

DECLARE @Date AS DATE=(SELECT DATE FROM Automate_Advances WHERE TimeKey=@TimeKey)
DECLARE @ProcessDate DATE=(SELECT DATE FROM Automate_Advances WHERE Timekey=@TimeKey)

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
CONVERT(VARCHAR(10),@ProcessDate,103)   AS CurrentProcessingDate
---------RefColumns---------
,H.SourceName
,A.UCIF_ID
,A.RefCustomerID                        AS CustomerID
,F.CustomerName
,A.BranchCode
,DB.BranchName
,A.CustomerAcID
,CONVERT(VARCHAR(20),A.AcopenDt,103)                             AS AcopenDt
,A.FacilityType
,SchemeType
,A.ProductCode
,D.ProductName
,DPD1.DPD_Max
,ISNULL(Balance,0)/@Cost                                                   AS Balance
,ISNULL(PrincOutStd,0)/@Cost                                               AS PrincOutStd
,ISNULL(DrawingPower,0)/@Cost                                              AS DrawingPower
,ISNULL(CurrentLimit,0)/@Cost                                              AS CurrentLimit
,CONVERT(VARCHAR(20),FirstDtOfDisb,103) 									AS	FirstDtOfDisb
,DPD_Overdrawn                                                             AS DPD_Overdrawn
,CONVERT(VARCHAR(20),A.ContiExcessDt,103)                                  AS DP_Overdrawn_date
,CONVERT(VARCHAR(20),A.ReviewDueDt,103)                                    AS Limit_Expiry_Date
,DPD_Renewal                                                               AS DPD_limit_Expiry
,CONVERT(VARCHAR(20),A.StockStDt,103)                                      AS StockStDt
,DPD_StockStmt                                                             AS DPD_StockStmt
,CONVERT(VARCHAR(20),A.DebitSinceDt,103)                                   AS DebitSinceDt
,CONVERT(VARCHAR(20),A.LastCrDate,103)                                     AS LastCrDate
,DPD_NoCredit                                                              AS DPD_NoCredit
,ISNULL(CurQtrCredit,0)/@Cost                                              AS CurQtrCredit
,ISNULL(CurQtrInt,0)/@Cost                                                 AS CurQtrInt
,ISNULL(PrincOverdue,0)/@Cost                                              AS PrincOverdue
,CONVERT(VARCHAR(20),A.PrincOverdueSinceDt,103)                            AS PrincOverdueSinceDt
,DPD_PrincOverdue                                                          AS DPD_PrincOverdue
,ISNULL(IntOverdue,0)/@Cost                                                AS IntOverdue
,CONVERT(VARCHAR(20),A.IntOverdueSinceDt,103)                              AS IntOverdueSinceDt
,DPD_IntOverdueSince                                                       AS DPD_IntOverdueSince
,ISNULL(FIN.PenalOverdueinterest,0)/@Cost                                  AS Penal_Interest_Overdue
,CONVERT(VARCHAR(20),FIN.PenalInterestOverDueSinceDt,103)                  AS Penal_Interest_Overdue_Date
,ISNULL(DPD_PenalInterestOverdue,0)                                        AS DPD_Penal_Interest_Overdue
,ISNULL(OtherOverdue,0)/@Cost                                              AS OtherOverdue
,CONVERT(VARCHAR(20),A.OtherOverdueSinceDt,103)                            AS OtherOverdueSinceDt
,DPD_OtherOverdueSince                                                     AS DPD_OtherOverdueSince
,ISNULL(OverdueAmt,0)/@Cost                                                AS OverdueAmt
,CONVERT(VARCHAR(20),A.OverDueSinceDt,103)                                 AS OverDueSinceDt
,DPD_Overdue                                                               AS DPD_Overdue
,a.Asset_Norm																	as	Asset_Norm
,SMA_Class                                                                 AS SMA_Class
,CONVERT(VARCHAR(20),A.SMA_Dt,103)                                         AS SMA_Date0
--,CONVERT(VARCHAR(20),CASE WHEN SMA_Class='SMA_1'
--                          THEN G.[DATE]
--						  END,103)                     AS SMA_Date1 
,CONVERT(VARCHAR(20),CASE WHEN SMA_Class in ('SMA_1','SMA_2')
                         THEN DATEADD(dd,30,A.SMA_Dt) END,103)						AS SMA_Date1 
--,CONVERT(VARCHAR(20),CASE WHEN SMA_Class='SMA_2'
--                          THEN G.[DATE]
--						  END,103)                     AS SMA_Date2
						 , CONVERT(VARCHAR(20), CASE WHEN SMA_Class='SMA_2' THEN DATEADD(dd,60,A.SMA_Dt) END,103)						AS SMA_Date2 
,A.SMA_Reason

------------ Added on 05/03/2024--------------
,A.FlgSMA


FROM Pro.AccountCal_Hist A
INNER JOIN Pro.CustomerCal_HIST F                 ON F.CustomerEntityId=A.CustomerEntityId 
                                                     AND F.EffectiveFromTimeKey <= @Timekey AND F.EffectiveToTimeKey >= @Timekey
												     AND A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey

INNER JOIN  DimBranch DB                          ON DB.BranchCode=A.BranchCode 
                                                     AND DB.EffectiveFromTimeKey <= @Timekey AND DB.EffectiveToTimeKey >= @Timekey

LEFT JOIN	DimProduct D                          ON A.ProductAlt_Key=D.ProductAlt_Key 
                                                     AND D.EffectiveFromTimeKey <= @Timekey AND D.EffectiveToTimeKey >= @Timekey

INNER JOIN SysDayMatrix G                         ON A.EffectiveFromTimekey=G.TimeKey

INNER JOIN DIMSOURCEDB H                          ON H.SourceAlt_Key=A.SourceAlt_Key   
                                                     AND H.EffectiveFromTimeKey <= @Timekey AND H.EffectiveToTimeKey >= @Timekey

INNER JOIN #DPD DPD1                              ON DPD1.CustomerAcID=A.CustomerAcID


LEFT JOIN AdvAcOtherFinancialDetail FIN           ON A.AccountEntityId = FIN.AccountEntityId
                                                     AND FIN.EffectiveFromTimeKey<=@TimeKey AND FIN.EffectiveToTimeKey>=@TimeKey

 
WHERE A.finalAssetClassAlt_key=1 AND A.FlgSMA='Y'


ORDER BY A.RefCustomerID




 DROP TABLE #DPD

GO