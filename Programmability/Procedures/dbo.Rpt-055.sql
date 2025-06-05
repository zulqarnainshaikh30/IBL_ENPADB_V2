SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




/*
 CREATE BY   :- KALIK DEV 
 CREATE DATE :- 28/10/2021
 DESCRIPTION :- Credit Card Asset Classification Processing

 */
  
 
CREATE PROCEDURE [dbo].[Rpt-055]	
    @TimeKey AS INT,
	@Cost AS FLOAT,
	@AssetClass AS VARCHAR(10)
	------@SelectPar AS VARCHAR(100)
	
AS

--DECLARE
--@Timekey AS INT=26959,
--@Cost AS FLOAT=1,
--@AssetClass AS VARCHAR(10)='<ALL>'
----@SelectPar AS VARCHAR(100)='4'


 DECLARE @DATEOFDATA DATE =(SELECT date FROM SysDayMatrix WHERE TimeKey=@Timekey)
-- print @DATEOFDATA
  
 
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

 
 
 --------------------*************Final data


SELECT

PACC.CustomerAcID						                 AS	 CustomerAcID ,
PACC.RefCustomerID						                 AS	 RefCustomerID,
PACC.SourceSystemCustomerID				                 AS	 SourceSystemCustomerID,
PACC.BranchCode							                 AS	 BranchCode,
PACC.FacilityType						                 AS	 FacilityType,
CONVERT(VARCHAR(15),PACC.AcOpenDt,103)					 AS	 AcOpenDt,
CONVERT(VARCHAR(15),PACC.FirstDtOfDisb,103)				 AS	 FirstDtOfDisb,
ISNULL(PACC.Balance,0)/@Cost			                 AS	 Balance,
case when aabd.SignBalance<0  then SignBalance else 0 end  AS CreditBalance,

ISNULL(PACC.DrawingPower,0)/@Cost		                 AS	 DrawingPower,
ISNULL(PACC.CurrentLimit,0)/@Cost		                 AS	 CurrentLimit,
CONVERT(VARCHAR(15),PACC.CurrentLimitDt,103)			 AS	 CurrentLimitDt,
ISNULL(PACC.OverdueAmt,0)/@Cost			                 AS	 OverdueAmt,
ISNULL(PACC.NetBalance,0)/@Cost			                 AS	 NetBalance,
ISNULL(PACC.ApprRV,0)/@Cost				                 AS	 ApprRV,
ISNULL(PACC.SecuredAmt,0)/@Cost			                 AS	 SecuredAmt,
ISNULL(PACC.UnSecuredAmt,0)/@Cost		                 AS	 UnSecuredAmt,
ISNULL(PACC.Provsecured	,0)/@Cost		                 AS	 Provsecured,
ISNULL(PACC.ProvUnsecured,0)/@Cost		                 AS	 ProvUnsecured,
ISNULL(PACC.TotalProvision,0)/@Cost		                 AS	 TotalProvision,
ISNULL(PACC.BankProvsecured,0)/@Cost	                 AS	 BankProvsecured,
ISNULL(PACC.BankProvUnsecured,0)/@Cost	                 AS	 BankProvUnsecured,
ISNULL(PACC.BankTotalProvision,0)/@Cost	                 AS	 BankTotalProvision,
DPD.DPD_Max,
CONVERT(VARCHAR(15),PACC.FinalNpaDt,103)				 AS	 FinalNpaDt,
CONVERT(VARCHAR(15),PACC.SMA_Dt,103)					 AS	 SMA_Dt,
CONVERT(VARCHAR(15),PACC.UpgDate,103)					 AS	 UpgDate,
PACC.SMA_Class							                 AS	 SMA_Class,
PACC.SMA_Reason							                 AS	 SMA_Reason,
PACC.FlgDeg								                 AS	 FlgDeg,
PACC.FlgDirtyRow						                 AS	 FlgDirtyRow,
PACC.FlgSMA								                 AS	 FlgSMA,
PACC.FlgUpg								                 AS	 FlgUpg,
ISNULL(PACC.Liability,0)/@Cost							 AS	 Liability,
PACC.CD									                 AS	 CD,
CONVERT(VARCHAR(15),PACC.OverDueSinceDt,103)			 AS	 OverDueSinceDt,
PACC.DegReason											 AS  DegReason,
DSDB.SourceName                                          AS  SOURCENAME,
CONVERT(VARCHAR(15),@DATE,103)							 AS DATEOFDATA,
   ADVREL.PAN                                                  AS PAN,
 PACC.PrincOverdue                                            AS [Principal Overdue Amt],	
CONVERT(VARCHAR(15),PACC.PrincOverdueSinceDt,103)        AS [Principal Over Due Since Dt],
 PACC.IntOverdue                                             AS [Interest Overdue Amt]	,
CONVERT(VARCHAR(15),PACC.IntOverdueSinceDt,103)          AS [Interest Over Due Since Dt],
PACC.OtherOverdue                                             AS [Oth. Charges Overdue Amt],
CONVERT(VARCHAR(15),PACC.OtherOverdueSinceDt,103)	     AS [Oth. Changes Over Due Since Dt],

--DA.AssetClassName                                        AS  FINALASSETCLASS,
CASE 
WHEN PACC.FinalAssetClassAlt_Key=1 and PACC.SMA_Class='STD' then 'A0'
--WHEN PACC.FinalAssetClassAlt_Key=1 and PACC.SMA_Class is null then 'A0'
WHEN PACC.FinalAssetClassAlt_Key=1 and PACC.SMA_Class='SMA_0' then 'S0'
WHEN PACC.FinalAssetClassAlt_Key=1 and PACC.SMA_Class='SMA_1' then 'S1'
WHEN PACC.FinalAssetClassAlt_Key=1 and PACC.SMA_Class='SMA_2' then 'S2'
WHEN PACC.FinalAssetClassAlt_Key=1 and PACC.SMA_Class='SMA_3' then 'S3'
WHEN PACC.FinalAssetClassAlt_Key=2 and DATEDIFF(day,PACC.FinalNpaDt,@Date) <=91 then 'B0'
WHEN PACC.FinalAssetClassAlt_Key=2 and DATEDIFF(day,PACC.FinalNpaDt,@Date) between 91 and 183 then 'B1'
WHEN PACC.FinalAssetClassAlt_Key=2 and DATEDIFF(day,PACC.FinalNpaDt,@Date) between 183 and 274 then 'B2'
WHEN PACC.FinalAssetClassAlt_Key=2 and DATEDIFF(day,PACC.FinalNpaDt,@Date) >=273 then 'B3'
WHEN PACC.finalassetclassalt_key=3 then 'C1'
WHEN PACC.finalassetclassalt_key=4 then 'C2'
WHEN PACC.FinalAssetClassAlt_Key=5 then 'C3'
WHEN PACC.FinalAssetClassAlt_Key=6 then 'D0'
END AS  FINALASSETCLASS, 
''                                                       AS GSTBALANCE,
BS.FlgSecured                                            AS SECURED,
PACC.ProductCode                                         AS SCHEME,
PACC.NPA_Reason											 as NPAREASON

 
FROM Pro.Accountcal_Hist PACC
left JOIN DIMSOURCEDB   DSDB                     ON PACC.SourceAlt_Key=DSDB.SourceAlt_Key
                                                     AND DSDB.EffectiveFromTimeKey<=@TimeKey
                                                     AND DSDB.EffectiveToTimeKey>=@TimeKey
													 AND PACC.EffectiveFromTimeKey<=@TimeKey
                                                     AND PACC.EffectiveToTimeKey>=@TimeKey

--LEFT JOIN Pro.DPD_DATA  D                              ON D.CustomerACID =PACC.CustomerACID 
--                                                          AND D.EffectiveFromTimeKey<=@TimeKey
--											              AND D.EffectiveToTimeKey>=@TimeKey


LEFT JOIN AdvCustRelationship ADVREL                    ON ADVREL.CustomerEntityId=PACC.CustomerEntityID
                                                          AND ADVREL.EffectiveFromTimeKey<=@TimeKey
											              AND ADVREL.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimAssetClass DA                             ON DA.AssetClassAlt_Key=PACC.FinalAssetClassAlt_Key
                                                          AND DA.EffectiveFromTimeKey<=@TimeKey
											              AND DA.EffectiveToTimeKey>=@TimeKey
LEFT JOIN AdvAcBasicDetail BS                           ON BS.AccountEntityId=PACC.AccountEntityID
                                                          AND BS.EffectiveFromTimeKey<=@TimeKey
											              AND BS.EffectiveToTimeKey>=@TimeKey

LEFT JOIN AdvAcBalanceDetail AABD					   ON PACC.AccountEntityId =AABD.AccountEntityId
														   AND AABD.EffectiveFromTimeKey<=@TimeKey
										                   AND AABD.EffectiveToTimeKey>=@TimeKey

LEFT JOIN Pro.AccountCal  E                              ON E.CustomerACID =PACC.CustomerACID 
                                                          AND E.EffectiveFromTimeKey<=@TimeKey
											              AND E.EffectiveToTimeKey>=@TimeKey

LEFT JOIN #DPD DPD										ON PACC.AccountEntityId =DPD.AccountEntityId


--WHERE PACC.FacilityType='CC' 
      ---- AND ISNULL(DSDB.SourceAlt_Key,0) NOT IN(1,5)
	  WHERE ISNULL(DSDB.SourceAlt_Key,0) =4
	  --AND DSDB.SourceAlt_Key IN(SELECT * FROM dbo.Split(@SelectPar,','))
	  AND((PACC.Finalassetclassalt_key=1 AND @AssetClass ='STANDARD')
	      OR (ISNULL(PACC.Finalassetclassalt_key,0)<>1 AND @AssetClass ='NPA')
		  OR  @AssetClass ='<ALL>')


OPTION(RECOMPILE)
GO