SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Rpt-029]
      @TimeKey AS INT,
	  @Cost    AS FLOAT,
	  @SelectReport AS INT
AS

--DECLARE 
--      @TimeKey AS INT=49999,
--	  @Cost    AS FLOAT=1,
--	  @SelectReport AS INT=1

--DECLARE @Date AS DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)
DECLARE @LastQtrDateKey INT = (SELECT LastQtrDateKey FROM sysdaymatrix WHERE timekey=@TimeKey)
DECLARE @PerDayDateKey AS INT=@TimeKey-1

--DECLARE @ProcessDate date
--set @ProcessDate=(select Date from Sysdaymatrix where Timekey=@TimeKey)

DECLARE @Date AS DATE=(SELECT DATE FROM Automate_Advances WHERE TimeKey=@TimeKey)
DECLARE @ProcessDate DATE=(SELECT DATE FROM Automate_Advances WHERE Timekey=@TimeKey)
---------------------------=======================================
IF OBJECT_ID('tempdb..#SecurityValueDetails') IS NOT NULL 
	DROP TABLE #SecurityValueDetails

SELECT
AccountEntityId,
ASVD.ValuationDate,
CASE WHEN SecurityType='P'
     THEN 'Primary'
     WHEN SecurityType='C'
     THEN 'Collateral'
	 END SecurityType
INTO #SecurityValueDetails
FROM AdvSecurityDetail  ASD
INNER JOIN AdvSecurityValueDetail  ASVD      ON  ASD.SecurityEntityID=ASVD.SecurityEntityID              
                                                 AND  ASD.EffectiveFromTimeKey<=@TimeKey AND  ASD.EffectiveToTimeKey>=@TimeKey
												 AND  ASVD.EffectiveFromTimeKey<=@TimeKey AND  ASVD.EffectiveToTimeKey>=@TimeKey 

OPTION(RECOMPILE)
---------------------------======================================DPD CalCULATION  Start===========================================

IF OBJECT_ID('TempDB..#DPD') Is Not Null
DROP TABLE #DPD


SELECT            CustomerAcID
                 ,AccountEntityID
                  ,IntNotServicedDt
                 ,LastCrDate
                 ,ContiExcessDt
                 ,OverDueSinceDt
                 ,ReviewDueDt
                 ,StockStDt
                 ,DebitSinceDt
                 ,PrincOverdueSinceDt
                 ,IntOverdueSinceDt
                 ,OtherOverdueSinceDt
                 ,SourceAlt_Key
INTO #DPD
FROM pro.AccountCal_Hist
WHERE EffectiveFromTimeKey <= @Timekey and EffectiveToTimeKey >= @Timekey

OPTION(RECOMPILE)
---------------
Alter Table #DPD
Add   DPD_IntService Int
      ,DPD_NoCredit Int
          ,DPD_Overdrawn Int
          ,DPD_Overdue Int
          ,DPD_Renewal Int
          ,DPD_StockStmt Int
          ,DPD_PrincOverdue Int
          ,DPD_IntOverdueSince Int
          ,DPD_OtherOverdueSince Int
           ,DPD_Max Int
-------------------

UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)+1  ELSE 0 END)                          
             ,A.DPD_NoCredit = CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>=90)
                                                                                        THEN (CASE WHEN  A.LastCrDate IS NOT NULL
                                                                                        THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)+0
                                                                                        ELSE 0  
                                                                                       
                                                                                        END)
                                                                        ELSE 0 END

                         ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END)
                         ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END)
                         ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)  +1    ELSE 0 END)
                     ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL THEN   DateDiff(Day,DATEADD(month,3,A.StockStDt),@ProcessDate)+1 ELSE 0 END)
                         ,A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,@ProcessDate)+1  ELSE 0 END)                          
             ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  @ProcessDate)+1       ELSE 0 END)
                         ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  @ProcessDate)+1  ELSE 0 END)
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

OPTION(RECOMPILE)
-------------------------------------
IF OBJECT_ID('TempDB..#PREV_DAY') Is Not Null
DROP TABLE #PREV_DAY

SELECT 
A. CustomerEntityID,
B.AccountEntityId,
ASSET.AssetClassName,
ISNULL(NetBalance,0)                                 AS NetBalance,
ISNULL(SecuredAmt,0)                                 AS SecuredAmt,
ISNULL(UnSecuredAmt,0)                               AS UnSecuredAmt,
ISNULL(TotalProvision,0)                             AS TotalProvision,
ISNULL(Provsecured,0)                                AS Provsecured,
ISNULL(ProvUnsecured,0)                              AS ProvUnsecured,
CASE WHEN ISNULL(AssetClassName,'') <>'STANDARD' THEN (ISNULL(NetBalance,0)-ISNULL(totalprovision,0)) END   AS NetNPA
,(ISNULL(NetBalance,0)-ISNULL(totalprovision,0))    AS NetNPA1

INTO #PREV_DAY
FROM PRO.CUSTOMERCAL_hist A
INNER JOIN PRO.ACCOUNTCAL_hist B	          ON A.CustomerEntityID=B.CustomerEntityID

LEFT JOIN DimAssetClass ASSET	              ON ASSET.AssetClassAlt_Key=B.FinalAssetClassAlt_Key
                                                 AND ASSET.EffectiveFromTimeKey<=@PerDayDateKey
									             AND ASSET.EffectiveToTimeKey>=@PerDayDateKey

WHERE B.EffectiveFromTimeKey <= @PerDayDateKey AND B.EffectiveToTimeKey >=@PerDayDateKey
      AND A.EffectiveFromTimeKey <= @PerDayDateKey AND A.EffectiveToTimeKey >=@PerDayDateKey
OPTION(RECOMPILE)
------------------------
IF OBJECT_ID('TempDB..#PREV_QTR') Is Not Null
DROP TABLE #PREV_QTR


SELECT 
A. CustomerEntityID,
B.AccountEntityId,
ASSET.AssetClassName,
ISNULL(NetBalance,0)                                 AS NetBalance,
ISNULL(SecuredAmt,0)                                 AS SecuredAmt,
ISNULL(UnSecuredAmt,0)                               AS UnSecuredAmt,
ISNULL(TotalProvision,0)                             AS TotalProvision,
ISNULL(Provsecured,0)                                AS Provsecured,
ISNULL(ProvUnsecured,0)                              AS ProvUnsecured,
CASE WHEN ISNULL(AssetClassName,'') <>'STANDARD' THEN (ISNULL(NetBalance,0)-ISNULL(totalprovision,0)) END   AS NetNPA
,(ISNULL(NetBalance,0)-ISNULL(totalprovision,0))    AS NetNPA1

INTO #PREV_QTR
FROM PRO.CUSTOMERCAL_hist A
INNER JOIN PRO.ACCOUNTCAL_hist B	          ON A.CustomerEntityID=B.CustomerEntityID

LEFT JOIN DimAssetClass ASSET	              ON ASSET.AssetClassAlt_Key=B.FinalAssetClassAlt_Key
                                                 AND ASSET.EffectiveFromTimeKey<=@LastQtrDateKey
									             AND ASSET.EffectiveToTimeKey>=@LastQtrDateKey

WHERE B.EffectiveFromTimeKey <= @LastQtrDateKey AND B.EffectiveToTimeKey >=@LastQtrDateKey
      AND A.EffectiveFromTimeKey <= @LastQtrDateKey AND A.EffectiveToTimeKey >=@LastQtrDateKey

OPTION(RECOMPILE)

----------------------------------
IF OBJECT_ID('TempDB..#MOC_Provision') Is Not Null
DROP TABLE #MOC_Provision

SELECT 
ACH.AccountEntityId,
CASE WHEN ISNULL(ACH.TotalProvision,0)>ISNULL(MAC.TotalProvision,0)
     THEN ISNULL(ACH.TotalProvision,0)-ISNULL(MAC.TotalProvision,0)
	 ELSE ISNULL(MAC.TotalProvision,0)-ISNULL(ACH.TotalProvision,0)
	 END                                 AS ShortfallinProvision
INTO #MOC_Provision
FROM PRO.AccountCal_Hist ACH
LEFT JOIN PreMoc.AccountCal MAC                  ON ACH.CustomerAcID=MAC.CustomerAcID
                                                    AND MAC.EffectiveFromTimeKey <= @TimeKey AND MAC.EffectiveToTimeKey >=@TimeKey
													AND MAC.FlgMOC='Y'

WHERE ACH.EffectiveFromTimeKey <= @TimeKey AND ACH.EffectiveToTimeKey >=@TimeKey AND ACH.FlgMOC='Y'

OPTION(RECOMPILE)

-----------------------------------Provision

SELECT 
CONVERT(VARCHAR(20),@ProcessDate, 103)                  AS [Process_date]
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

----------- Pradeep on 26/04/2024 due to Assset class should be displayed as per bank master-----------

,CONVERT(VARCHAR(20),FinalNpaDt,103)                                 AS FinalNpaDt
--,CASE WHEN A2.AssetClassName ='LOS'
--      THEN 'LOSS'
--	  ELSE A2.AssetClassName 
--	  END                                                            AS FinalAssetName

	 , CASE 

WHEN FinalAssetClassAlt_Key=1 and SMA_Class='STD' then 'A0'

WHEN FinalAssetClassAlt_Key=1 and SMA_Class='SMA_0' then 'S0'

WHEN FinalAssetClassAlt_Key=1 and SMA_Class='SMA_1' then 'S1'

WHEN FinalAssetClassAlt_Key=1 and SMA_Class='SMA_2' then 'S2'

WHEN FinalAssetClassAlt_Key=1 and SMA_Class='SMA_3' then 'S3'

WHEN FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) <=91 then 'B0'

WHEN FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) between 91 and 183 then 'B1'

WHEN FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) between 183 and 274 then 'B2'

WHEN FinalAssetClassAlt_Key=2 and DATEDIFF(day,FinalNpaDt,@Date) >=273 then 'B3'

WHEN finalassetclassalt_key=3 then 'C1'

WHEN finalassetclassalt_key=4 then 'C2'

WHEN FinalAssetClassAlt_Key=5 then 'C3'

WHEN FinalAssetClassAlt_Key=6 then 'D0'

END AS FinalAssetName

,NPANorms	
,ISNULL(B.Balance,0)/@Cost                                           AS Balance							                             
,ISNULL(B.NetBalance,0)/@Cost                                        AS NetBalance
,ISNULL(A.CurntQtrRv,0)/@Cost                                        AS SecurityValue
,ISNULL(ApprRV,0)/@Cost                                              AS ApprRV
,ISNULL(B.SecuredAmt,0)/@Cost                                        AS SecuredAmt
,ISNULL(B.UnSecuredAmt,0)/@Cost                                      AS UnSecuredAmt
,ISNULL(B.TotalProvision,0)/@Cost                                    AS TotalProvision
,ISNULL(B.Provsecured,0)/@Cost                                       AS Provsecured
,ISNULL(B.ProvUnsecured,0)/@Cost                                     AS ProvUnsecured
,ISNULL(PrincOutStd,0)/@Cost                                         AS PrincOutStd
,ISNULL(UsedRV,0)/@Cost                                              AS SecurityRV
,CASE WHEN A2.AssetClassName  <>'STANDARD'
      THEN (ISNULL(B.NetBalance,0)-ISNULL(B.TotalProvision,0))/@Cost 
	  ELSE 0 
	  END           AS [Net NPA]
,ROUND(ISNULL(CASE WHEN ROUND((ISNULL(B.Provsecured,0)/NULLIF(B.SecuredAmt,0))*100,1) < 0.5 AND
                        ROUND((ISNULL(B.Provsecured,0)/NULLIF(B.SecuredAmt,0))*100,1) > 0
                   THEN 0.4 
			       ELSE ROUND((ISNULL(B.Provsecured,0)/NULLIF(B.SecuredAmt,0))*100,2)  END,0),2)               AS [ProvisionSecured%]

,ROUND(ISNULL(CASE WHEN ROUND((ISNULL(B.ProvUnsecured,0)/NULLIF(B.UnSecuredAmt,0))*100,1) < 0.5 AND
                        ROUND((ISNULL(B.ProvUnsecured,0)/NULLIF(B.UnSecuredAmt,0))*100,1) > 0
                   THEN 0.4 
			       ELSE ROUND((ISNULL(B.ProvUnsecured,0)/NULLIF(B.UnSecuredAmt,0))*100,2)  END,0),2)          AS [ProvisionUnSecured%]

,ROUND(ISNULL(CASE WHEN ROUND((ISNULL(B.TotalProvision,0)/NULLIF(B.NetBalance,0))*100,1) < 0.5 AND
                        ROUND((ISNULL(B.TotalProvision,0)/NULLIF(B.NetBalance,0))*100,1) > 0
                   THEN 0.4 
			       ELSE ROUND((ISNULL(B.TotalProvision,0)/NULLIF(B.NetBalance,0))*100,2)  END,0),2)           AS [ProvisionTotal%]

,ROUND(ISNULL(CASE WHEN ROUND(((ISNULL(B.TotalProvision,0)-(ISNULL(B.Provsecured,0)+ISNULL(B.ProvUnsecured,0)))/NULLIF(B.NetBalance,0))*100,1) < 0.5 AND
                        ROUND(((ISNULL(B.TotalProvision,0)-(ISNULL(B.Provsecured,0)+ISNULL(B.ProvUnsecured,0)))/NULLIF(B.NetBalance,0))*100,1) > 0
                   THEN 0.4 
			       ELSE ROUND(((ISNULL(B.TotalProvision,0)-(ISNULL(B.Provsecured,0)+ISNULL(B.ProvUnsecured,0)))/NULLIF(B.NetBalance,0))*100,2)  
				   END,0),2)          AS AddProvisionPer

,ISNULL(Y.NetBalance,0)/@Cost                                        AS [Prev. Qtr. Balance Outstanding]
,ISNULL(Y.SecuredAmt,0)/@Cost	                                     AS [Prev. Qtr. Secured Outstanding]
,ISNULL(Y.UnSecuredAmt,0)/@Cost	                                     AS [Prev. Qtr. Unsecured Outstanding]
,ISNULL(Y.TotalProvision,0)/@Cost	                                 AS [Prev. Qtr.Provision Total]
,ISNULL(Y.Provsecured,0)/@Cost	                                     AS [Prev. Qtr.Provision Secured]
,ISNULL(Y.ProvUnsecured,0)/@Cost	                                 AS [Prev. Qtr. Provision Unsecured]
,ISNULL(Y.NetNPA,0)/@Cost	                                         AS [Prev. Qtr. Net NPA]
----------------------------
 
,CASE WHEN Y1.AssetClassName='STANDARD' AND ISNULL(A2.AssetClassName,'') <>'STANDARD'
      THEN ISNULL(B.NetBalance,0)
	  WHEN ISNULL(Y1.AssetClassName,'')<>'STANDARD' AND ISNULL(A2.AssetClassName,'') <>'STANDARD'  
      THEN (CASE WHEN (ISNULL(B.NetBalance,0) - ISNULL(Y1.netBalance,0)) < 0 
                 THEN 0 
	             ELSE ABS(ISNULL(B.NetBalance,0) - ISNULL(Y1.netBalance,0)) 
	             END)   
      WHEN Y1.AccountEntityId IS NULL AND ISNULL(A2.AssetClassName,'') <>'STANDARD'
	  THEN ISNULL(B.NetBalance,0)
	  ELSE 0 
	  END/@Cost                                           AS NPAIncrease

,CASE WHEN ISNULL(Y1.AssetClassName,'') <>'STANDARD' AND A2.AssetClassName ='STANDARD'   
      THEN ISNULL(Y1.netBalance,0)
	  WHEN ISNULL(Y1.AssetClassName,'')<>'STANDARD' AND ISNULL(A2.AssetClassName,'') <>'STANDARD'
	  THEN (CASE WHEN (ISNULL(Y1.netBalance,0)-ISNULL(B.NetBalance,0))< 0 
                 THEN 0 
	             ELSE (ISNULL(Y1.netBalance,0)-ISNULL(B.NetBalance,0))
	             END)   	  
	  WHEN ISNULL(Y1.AssetClassName,'')<>'STANDARD' AND B.AccountEntityId IS NULL 
	  THEN ISNULL(Y1.netBalance,0)
	  ELSE 0 
	  END/@Cost                                                  AS NPADecrease


,CASE WHEN Y1.AssetClassName='STANDARD' AND A2.AssetClassName ='STANDARD'   
      THEN (CASE WHEN (ISNULL(B.TotalProvision,0) - ISNULL(Y1.TotalProvision,0)) < 0 
                 THEN 0 
	             ELSE ABS(ISNULL(B.TotalProvision,0) - ISNULL(Y1.TotalProvision,0)) 
	             END)
	   WHEN ISNULL(Y1.AssetClassName,'')<>'STANDARD' AND A2.AssetClassName ='STANDARD'   
	   THEN ISNULL(B.TotalProvision,0) 	              
	   WHEN Y1.AccountEntityId IS NULL AND A2.AssetClassName ='STANDARD'   
	   THEN ISNULL(B.TotalProvision,0)  
	   ELSE 0 
	   END/@Cost                                                   AS STD_ProvisionIncrease

,CASE WHEN Y1.AssetClassName='STANDARD' AND ISNULL(A2.AssetClassName,'') <>'STANDARD'   
      THEN ISNULL(B.TotalProvision,0)
	  WHEN ISNULL(Y1.AssetClassName,'')<>'STANDARD' AND ISNULL(A2.AssetClassName,'') <>'STANDARD'   
	  THEN (CASE WHEN (ISNULL(B.TotalProvision,0) - ISNULL(Y1.TotalProvision,0)) < 0 
                 THEN 0 
	             ELSE ABS(ISNULL(B.TotalProvision,0) - ISNULL(Y1.TotalProvision,0)) 
	             END) 	              
	  WHEN Y1.AccountEntityId IS NULL AND ISNULL(A2.AssetClassName,'') <>'STANDARD'   
	  THEN ISNULL(B.TotalProvision,0)  
	  ELSE 0 
	  END/@Cost                                                   AS NPA_ProvisionIncrease


,CASE WHEN Y1.AssetClassName ='STANDARD'  AND A2.AssetClassName ='STANDARD'  
      THEN (CASE WHEN (ISNULL(Y1.TotalProvision,0)-ISNULL(B.TotalProvision,0))< 0 
                 THEN 0 
	             ELSE (ISNULL(Y1.TotalProvision,0)-ISNULL(B.TotalProvision,0)) 
	             END)  
	  WHEN Y1.AssetClassName ='STANDARD' AND ISNULL(A2.AssetClassName,'') <>'STANDARD'  
	  THEN ISNULL(Y1.TotalProvision,0)
	  ELSE 0 
	  END/@Cost                                                    AS STD_ProvisionDecrease

,CASE WHEN ISNULL(Y1.AssetClassName,'') <>'STANDARD'  AND ISNULL(A2.AssetClassName,'') <>'STANDARD'  
      THEN (CASE WHEN (ISNULL(Y1.TotalProvision,0)-ISNULL(B.TotalProvision,0))< 0 
                 THEN 0 
	             ELSE (ISNULL(Y1.TotalProvision,0)-ISNULL(B.TotalProvision,0))
	             END)  
	  WHEN ISNULL(Y1.AssetClassName,'') <>'STANDARD' AND A2.AssetClassName='STANDARD'  
	  THEN ISNULL(Y1.TotalProvision,0)
	  ELSE 0 
	  END/@Cost                                                    AS NPA_ProvisionDecrease


,CASE WHEN Y1.AssetClassName='STANDARD' AND ISNULL(A2.AssetClassName,'') <>'STANDARD'
      THEN (ISNULL(B.NetBalance,0)-ISNULL(B.TotalProvision,0))
	  WHEN ISNULL(Y1.AssetClassName,'')<>'STANDARD' AND ISNULL(A2.AssetClassName,'') <>'STANDARD'  
      THEN (CASE WHEN ((ISNULL(B.NetBalance,0)-ISNULL(B.TotalProvision,0)) - ISNULL(Y1.NetNPA,0)) < 0 
                 THEN 0 
	             ELSE ABS((ISNULL(B.NetBalance,0)-ISNULL(B.TotalProvision,0)) - ISNULL(Y1.NetNPA,0)) 
	             END)   
      WHEN Y1.AccountEntityId IS NULL AND ISNULL(A2.AssetClassName,'') <>'STANDARD'
	  THEN (ISNULL(B.NetBalance,0)-ISNULL(B.TotalProvision,0))
	  ELSE 0 
	  END/@Cost                                           AS NetNPAIncrease

,CASE WHEN ISNULL(Y1.AssetClassName,'') <>'STANDARD' AND A2.AssetClassName ='STANDARD'   
      THEN ISNULL(Y1.NetNPA,0)
	  WHEN ISNULL(Y1.AssetClassName,'')<>'STANDARD' AND ISNULL(A2.AssetClassName,'') <>'STANDARD'
	  THEN (CASE WHEN (ISNULL(Y1.NetNPA,0)-(ISNULL(B.NetBalance,0)-ISNULL(B.TotalProvision,0)))< 0 
                 THEN 0 
	             ELSE (ISNULL(Y1.NetNPA,0)-(ISNULL(B.NetBalance,0)-ISNULL(B.TotalProvision,0)))
	             END)   
	  
	  WHEN ISNULL(Y1.AssetClassName,'')<>'STANDARD' AND B.AccountEntityId IS NULL 
	  THEN ISNULL(Y1.NetNPA,0)
	  ELSE 0 
	  END/@Cost                                          AS NetNPAnDecrease

,B.FlgRestructure                                        AS Restructure
,(CASE WHEN B.FinalAssetclassAlt_key = 1 THEN 0 ELSE ISNULL(FIN.UnAppliedIntAmount,0)/@Cost  END)                  AS InterestInSuspenseAmount
,0                                                       AS Totalincomesuspended
,ISNULL(B.TotalProvision,0)/@Cost                        AS ActualProvision
,ISNULL(MOCP.ShortfallinProvision,0)/@Cost               AS ShortfallinProvision
,CONVERT(VARCHAR(20),ValuationDate,103)                  AS ValuationDate
,SecurityType
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

FROM PRO.CUSTOMERCAL_hist A
INNER JOIN PRO.ACCOUNTCAL_hist B                      ON A.CustomerEntityID=B.CustomerEntityID
                                                         AND A.EffectiveFromTimeKey<=@TimeKey
									                     AND A.EffectiveToTimeKey>=@TimeKey
                                                         AND B.EffectiveFromTimeKey<=@TimeKey
									                     AND B.EffectiveToTimeKey>=@TimeKey
									                  
INNER JOIN #DPD DPD                                   ON DPD.CustomerAcID=B.CustomerAcID
									                  
LEFT JOIN #SecurityValueDetails SVD                   ON SVD.AccountEntityId=B.AccountEntityID
									                  
LEFT JOIN #PREV_QTR   Y        	  	                  ON B.AccountEntityId = Y.AccountEntityId
									                  
LEFT JOIN #PREV_DAY   Y1        	                  ON B.AccountEntityId = Y1.AccountEntityId

LEFT JOIN AdvAcOtherFinancialDetail FIN               ON B.AccountEntityId = FIN.AccountEntityId
                                                          AND FIN.EffectiveFromTimeKey<=@TimeKey
									                      AND FIN.EffectiveToTimeKey>=@TimeKey

LEFT JOIN #MOC_Provision MOCP                         ON B.AccountEntityId = MOCP.AccountEntityId

LEFT JOIN SaletoARCFinalACFlagging SARC               ON SARC.AccountId=B.CustomerAcID
                                                         AND SARC.EffectiveFromTimeKey<=@TimeKey
									                     AND SARC.EffectiveToTimeKey>=@TimeKey

LEFT JOIN RP_Portfolio_Details  RPD                   ON RPD.CustomerId=B.RefCustomerID
                                                         AND RPD.EffectiveFromTimeKey<=@TimeKey
									                     AND RPD.EffectiveToTimeKey>=@TimeKey 
									   
LEFT JOIN DIMSOURCEDB src	                          ON B.SourceAlt_Key =src.SourceAlt_Key
                                                         AND src.EffectiveFromTimeKey<=@TimeKey
									                     AND src.EffectiveToTimeKey>=@TimeKey
									                  
									                  
LEFT JOIN DIMPRODUCT PD          	                  ON PD.PRODUCTALT_KEY=B.PRODUCTALT_KEY
                                                          AND PD.EffectiveFromTimeKey<=@TimeKey
									                      AND PD.EffectiveToTimeKey>=@TimeKey
									                  
									                  
LEFT JOIN DimAssetClass A2	                          ON A2.AssetClassAlt_Key=B.FinalAssetClassAlt_Key
                                                         AND A2.EffectiveFromTimeKey<=@TimeKey
									                     AND A2.EffectiveToTimeKey>=@TimeKey
									                  
LEFT JOIN DimAcBuSegment S                            ON B.ActSegmentCode=S.AcBuSegmentCode
                                                         AND S.EffectiveFromTimeKey<=@TimeKey
									                     AND S.EffectiveToTimeKey>=@TimeKey
									                  
LEFT JOIN DimBranch X                                 ON B.BranchCode = X.BranchCode
                                                         AND X.EffectiveFromTimeKey<=@TimeKey
									                     AND X.EffectiveToTimeKey>=@TimeKey
									   


WHERE src.SourceAlt_Key in (1,2,4) AND @SelectReport =1

ORDER BY A.RefCustomerID  

OPTION(RECOMPILE)

DROP TABLE #DPD,#SecurityValueDetails,#PREV_QTR,#PREV_DAY,#MOC_Provision

GO