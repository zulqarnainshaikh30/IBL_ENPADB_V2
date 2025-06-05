SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


 
CREATE PROCEDURE [dbo].[Rpt-028]
      @TimeKey AS INT,
		@Disburse_Dt	AS	VARCHAR(20),
		@Cost    AS FLOAT
AS

--DECLARE 
--      @TimeKey AS INT=27028,
--	  @Disburse_Dt	AS	VARCHAR(20)=NULL,
--	  @Cost    AS FLOAT=1


--DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)

--DECLARE @ProcessDate DATE=(SELECT DATE FROM SysDayMatrix WHERE Timekey=@TimeKey)

DECLARE @Date AS DATE=(SELECT DATE FROM Automate_Advances WHERE TimeKey=@TimeKey)
DECLARE @ProcessDate DATE=(SELECT DATE FROM Automate_Advances WHERE Timekey=@TimeKey)
---------------------------======================================DPD CalCULATION  Start===========================================

 IF OBJECT_ID('TempDB..#DPD') Is Not Null
Drop Table #DPD


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

 UPDATE #DPD SET DPD_IntService=0 WHERE isnull(DPD_IntService,0)<0
 UPDATE #DPD SET DPD_NoCredit=0 WHERE isnull(DPD_NoCredit,0)<0
 UPDATE #DPD SET DPD_Overdrawn=0 WHERE isnull(DPD_Overdrawn,0)<0
 UPDATE #DPD SET DPD_Overdue=0 WHERE isnull(DPD_Overdue,0)<0
 UPDATE #DPD SET DPD_Renewal=0 WHERE isnull(DPD_Renewal,0)<0
 UPDATE #DPD SET DPD_StockStmt=0 WHERE isnull(DPD_StockStmt,0)<0
 UPDATE #DPD SET DPD_PrincOverdue=0 WHERE isnull(DPD_PrincOverdue,0)<0
 UPDATE #DPD SET DPD_IntOverdueSince=0 WHERE isnull(DPD_IntOverdueSince,0)<0
 UPDATE #DPD SET DPD_OtherOverdueSince=0 WHERE isnull(DPD_OtherOverdueSince,0)<0
 UPDATE #DPD SET DPD_PenalInterestOverdue=0 WHERE isnull(DPD_PenalInterestOverdue,0)<0

UPDATE A SET A.DPD_Max=0  FROM #Dpd  A
UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0)
                                        AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0)
                                                                                AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0)
                                                                                AND  isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0)
                                                                                AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0))
                                                                   THEN isnull(A.DPD_IntService,0)
                                   WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0)
                                                                        AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0)
                                                                        AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0)
                                                                        AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0)
                                                                        AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0))
                                                                   THEN   isnull(A.DPD_NoCredit ,0)
                                                                   WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  
                                                                        AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  
                                                                                AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0)
                                                                                AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0)
                                                                                AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0))
                                                                   THEN  isnull(A.DPD_Overdrawn,0)
                                                                   WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    
                                                                        AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  
                                                                                AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  
                                                                                AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  
                                                                                AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0))
                                                                   THEN isnull(A.DPD_Renewal,0)
                                       WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    
                                                                        AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)
                                                                            AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  
                                                                                AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  
                                                                                AND isnull(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0))  
                                                                   THEN   isnull(A.DPD_Overdue,0)
                                                                   ELSE isnull(A.DPD_StockStmt,0)
                                                END)
                         
FROM  #DPD a

WHERE  (isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0        
       OR isnull(A.DPD_Renewal,0) >0 OR isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)


------------------------------------------------=========================END===========================
-------------------------------------Asset Classification

SELECT DISTINCT
CONVERT(VARCHAR(20),@Date, 103)                  AS  [Process_date] 
,A.UCIF_ID                                       AS UCIC
,A.RefCustomerID                                 AS CustomerID
,A.CustomerName
,B.BranchCode
,BranchName
,B.CustomerAcID
,SourceName
,B.FacilityType
,SchemeType
,B.ProductCode
,ProductName
,ActSegmentCode
,AcBuSegmentDescription
,AcBuRevisedSegmentCode
,DPD_Max
,CONVERT(VARCHAR(20),FinalNpaDt,103)           AS FinalNpaDt
,CONVERT(VARCHAR(20),B.AcOpenDt,103)           AS AccountOpenDate
,ISNULL(B.Balance,0)/@Cost                     AS Balance

,CASE WHEN ISNULL(BAL.SignBalance,0)>0 AND B.FinalAssetClassAlt_Key=1
      THEN ISNULL(BAL.SignBalance,0)   
      ELSE 0
	  END AS CREDITBAL

,ISNULL(NetBalance,0)/@Cost                  AS NetBalance
,ISNULL(PrincOutStd,0)/@Cost                 AS PrincOutStd
,ISNULL(DrawingPower,0)/@Cost                AS DrawingPower
,ISNULL(B.CurrentLimit,0)/@Cost                AS CurrentLimit
,(CASE WHEN (ISNULL(B.Balance,0) -(ISNULL(DrawingPower,0)+ISNULL(B.CurrentLimit,0))) < 0 
       THEN 0 
	   ELSE (ISNULL(B.Balance,0) -(ISNULL(DrawingPower,0)+ISNULL(B.CurrentLimit,0))) 
	   END)/@Cost                                                                        AS OverDrawn_Amt
,DPD_Overdrawn
,CONVERT(VARCHAR(20),B.ContiExcessDt,103)      AS ContiExcessDt
,CONVERT(VARCHAR(20),B.ReviewDueDt,103)        AS ReviewDueDt
,DPD_Renewal
,CONVERT(VARCHAR(20),B.StockStDt,103)          AS StockStDt
,DPD_StockStmt
,CONVERT(VARCHAR(20),B.DebitSinceDt,103)       AS DebitSinceDt
,CONVERT(VARCHAR(20),B.LastCrDate,103)         AS LastCrDate
,DPD_NoCredit
,ISNULL(CurQtrCredit,0)/@Cost                AS CurQtrCredit
,ISNULL(CurQtrInt,0)/@Cost                   AS CurQtrInt
,(CASE WHEN (ISNULL(CurQtrInt,0) -ISNULL(CurQtrCredit,0)) < 0 
       THEN 0 
	   ELSE (ISNULL(CurQtrInt,0) -ISNULL(CurQtrCredit,0)) 
	   END)/@Cost                                     AS [InterestNotServiced]
,DPD_IntService
,0                                                    AS [CC/OD Interest Service]
,ISNULL(OverdueAmt,0)/@Cost                           AS OverdueAmt
,CONVERT(VARCHAR(20),B.OverDueSinceDt,103)            AS OverDueSinceDt
,DPD_Overdue
,ISNULL(PrincOverdue,0)/@Cost                         AS PrincOverdue
,CONVERT(VARCHAR(20),B.PrincOverdueSinceDt,103)       AS PrincOverdueSinceDt
,DPD_PrincOverdue
,ISNULL(IntOverdue,0)/@Cost                           AS IntOverdue
,CONVERT(VARCHAR(20),B.IntOverdueSinceDt,103)         AS IntOverdueSinceDt
,DPD_IntOverdueSince
,ISNULL(OtherOverdue,0)/@Cost                         AS OtherOverdue
,CONVERT(VARCHAR(20),B.OtherOverdueSinceDt,103)       AS OtherOverdueSinceDt
,DPD_OtherOverdueSince
,0                                                    AS [Bill/PC Overdue Amount]
,''                                                   AS [Overdue Bill/PC ID]
,''                                                   AS [Bill/PC Overdue Date]
,''                                                   AS [DPD Bill/PC]
----,A2.AssetClassName                                    AS FinalAssetName
--,CASE WHEN A2.AssetClassAlt_Key=1    THEN 'STANDARD'
--      WHEN A2.AssetClassAlt_Key<>1   THEN 'NPA'
--	  END  FinalAssetName
,case 
when FinalAssetClassAlt_Key=1 and SMA_Class='STD' then 'A0'
when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_0' then 'S0'
when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_1' then 'S1'
when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_2' then 'S2'
when FinalAssetClassAlt_Key=1 and SMA_Class='SMA_3' then 'S3'
when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) <=91 then 'B0'
when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) between 91 and 183 then 'B1'
when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) between 183 and 274 then 'B2'
when FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) >=273 then 'B3'
when finalassetclassalt_key=3 then 'C1'
when finalassetclassalt_key=4 then 'C2'
when FinalAssetClassAlt_Key=5 then 'C3'
when FinalAssetClassAlt_Key=6 then 'D0'
end  FinalAssetName


--,REPLACE(isnull(B.NPA_Reason,b.DegReason),',','') as DegReason
,ISNULL(B.DegReason,'')                             AS DegReason
,ISNULL(B.NPA_Reason,'')                            AS NPA_Reason
,NPANorms
--------
----,C.AssetClassMappingAlt_Key SubAssetCode
,CASE WHEN C.AssetClassAlt_Key=1
      THEN (CASE WHEN B.SMA_Class='STD' THEN 'STANDARD'
	            WHEN B.SMA_Class='SMA_0' THEN 'SMA 0'
				WHEN B.SMA_Class='SMA_1' THEN 'SMA 1'
				WHEN B.SMA_Class='SMA_2' THEN 'SMA 2' END)
	  ELSE C.SrcSysClassName 
	  END  SubAssetClass

,CASE WHEN C.AssetClassAlt_Key=1
      THEN (CASE WHEN B.SMA_Class='STD' THEN ''
	            WHEN B.SMA_Class IN('SMA_0','SMA_1','SMA_2') THEN CONVERT(varchar(20),B.SMA_Dt,103)
				 END)
	  ELSE ''----- CONVERT(varchar(20),B.FinalNpaDt,103) 
	  END  SubAssetDate

----,(ISNULL(BAL.SignBalance,0)*-1)CREDITBAL

,ISNULL(FIN.PenalOverdueinterest,0)/@Cost                                AS PENAL_INTEREST
,CONVERT(VARCHAR(20),FIN.PenalInterestOverDueSinceDt,103)                AS PenalInterestOverDueDate
,ISNULL(DPD_PenalInterestOverdue,0)                                      AS DPD_PenalInterestOverdue
,CASE WHEN B.FacilityType='NF' THEN ACBD1.Limit_Suffix ELSE ACBD.Limit_Suffix END   AS Limit_Suffix
,CBD.Internal_Rating
,FirstDtOfDisb
,CASE WHEN ISNULL(B.IsIBPC,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsIBPC
,CASE WHEN ISNULL(B.IsSecuritised,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS IsSecuritised
,CASE WHEN ISNULL(B.RFA,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS RFA
,CASE WHEN ISNULL(B.PUI,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS PUI
,CASE WHEN ISNULL(B.FlgFraud,'N')='Y'
      THEN 'Yes'
	  ELSE 'No'
	  END                                          AS FlgFraud              
,CASE WHEN ISNULL(B.FlgRestructure,'N')='Y'
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


FROM PRO.CUSTOMERCAL_Hist A
INNER JOIN pro.AccountCal_Hist B                   ON A.CustomerEntityID=B.CustomerEntityID                                      
                                                   AND B.EffectiveFromTimeKey<=@TimeKey
									               AND B.EffectiveToTimeKey>=@TimeKey									  
									               
INNER JOIN #DPD PD          	                   ON  PD.CustomerAcID=B.CustomerAcID
									               
LEFT JOIN AdvAcBalanceDetail BAL                   ON BAL.AccountEntityId=B.AccountEntityId
                                                   AND BAL.EffectiveFromTimeKey<=@TimeKey
									               AND BAL.EffectiveToTimeKey>=@TimeKey
									               
LEFT JOIN AdvAcBasicDetail ACBD                    ON ACBD.AccountEntityId=B.AccountEntityId
                                                   AND ACBD.EffectiveFromTimeKey<=@TimeKey
									               AND ACBD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvNFAcBasicDetail ACBD1                 ON ACBD1.AccountEntityId=B.AccountEntityId
                                                   AND ACBD1.EffectiveFromTimeKey<=@TimeKey
									               AND ACBD1.EffectiveToTimeKey>=@TimeKey
									               
LEFT JOIN CustomerBasicDetail CBD                  ON CBD.CustomerEntityID=B.CustomerEntityID
                                                   AND CBD.EffectiveFromTimeKey<=@TimeKey
									               AND CBD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN SaletoARCFinalACFlagging SARC            ON SARC.AccountId=B.CustomerAcID
                                                   AND SARC.EffectiveFromTimeKey<=@TimeKey
									               AND SARC.EffectiveToTimeKey>=@TimeKey

LEFT JOIN RP_Portfolio_Details  RPD                ON RPD.CustomerId=B.RefCustomerID
                                                   AND RPD.EffectiveFromTimeKey<=@TimeKey
									               AND RPD.EffectiveToTimeKey>=@TimeKey      

LEFT JOIN		DimProduct D                       ON B.ProductAlt_Key=D.ProductAlt_Key 
                                                   AND D.EffectiveFromTimeKey<=@TimeKey
									               AND D.EffectiveToTimeKey>=@TimeKey

									 

LEFT JOIN		(select Distinct SourceAlt_Key,AssetClassAlt_Key,(CASE WHEN AssetClassAlt_Key = 1 THEN 'STANDARD' ELSE SrcSysClassName END)SrcSysClassName ,----AssetClassMappingAlt_Key,
				 EffectiveFromTimeKey,EffectiveToTimeKey
				 from DimAssetClassMapping) C ON C.AssetClassAlt_Key=B.FinalAssetClassAlt_Key
				                              ----and   C.AssetClassMappingAlt_Key=B.FinalAssetClassAlt_Key
                                              And	C.SourceAlt_Key=D.SourceAlt_Key
                                        AND C.EffectiveFromTimeKey<=@TimeKey
									   AND C.EffectiveToTimeKey>=@TimeKey
LEFT JOIN		(select Distinct SourceAlt_Key,AssetClassAlt_Key,(CASE WHEN AssetClassAlt_Key = 1 THEN 'STANDARD' ELSE SrcSysClassName END)SrcSysClassName ,
					EffectiveFromTimeKey,EffectiveToTimeKey
					from DimAssetClassMapping) E ON		E.AssetClassAlt_Key=B.InitialAssetClassAlt_Key 
                                                 And	C.SourceAlt_Key=D.SourceAlt_Key
                                       AND E.EffectiveFromTimeKey<=@TimeKey
									   AND E.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DIMSOURCEDB src	        ON B.SourceAlt_Key =src.SourceAlt_Key
                                       AND src.EffectiveFromTimeKey<=@TimeKey
									   AND src.EffectiveToTimeKey>=@TimeKey
	


LEFT JOIN DimAssetClass A2	        ON A2.AssetClassAlt_Key=B.FinalAssetClassAlt_Key
                                       AND A2.EffectiveFromTimeKey<=@TimeKey
									   AND A2.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimAcBuSegment S          ON B.ActSegmentCode=S.AcBuSegmentCode
                                       AND S.EffectiveFromTimeKey<=@TimeKey
									   AND S.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimBranch X               ON B.BranchCode = X.BranchCode
                                       AND X.EffectiveFromTimeKey<=@TimeKey
									   AND X.EffectiveToTimeKey>=@TimeKey


LEFT JOIN AdvAcOtherFinancialDetail FIN    ON B.AccountEntityId = FIN.AccountEntityId
                                               AND FIN.EffectiveFromTimeKey<=@TimeKey
									           AND FIN.EffectiveToTimeKey>=@TimeKey


WHERE ISNULL(RefPeriodOverdue,0) NOT IN (181,366)  AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
AND (B.FirstDtOfDisb =(SELECT Rdate FROM dbo.DateConvert(@Disburse_Dt)) OR @Disburse_Dt IS NULL)

ORDER BY A.RefCustomerID
OPTION(RECOMPILE)

DROP TABLE #DPD
GO