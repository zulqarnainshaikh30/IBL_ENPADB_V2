SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
Report Name			-  TWO Report As On
Create by			-  KALIK DEV
Date				-  10 NOV 2021
*/

create PROCEDURE [dbo].[Rpt-034]
@TimeKey INT,
@Cost FLOAT

AS

BEGIN

--DECLARE 
--@Timekey INT= 26206,
--@Cost FLOAT =1


DECLARE @Date date =(select date from SysDayMatrix where TimeKey=@Timekey)


DECLARE @LastQtrTimekey int = (select LastQtrDateKey from SysDayMatrix  where Timekey in (@Timekey))

DECLARE @LastQtrDate date = (select LastQtrDate from SysDayMatrix  where Timekey in (@Timekey))

DECLARE @CurQtrDate Date = (select CurQtrDate from SysDayMatrix  where Timekey in (@Timekey))

DECLARE @LastMonthTimekey int = (select LastMonthDateKey from SysDayMatrix  where Timekey in (@Timekey))

DECLARE @LastMonthDate date = (select LastMonthDate from SysDayMatrix  where Timekey in (@Timekey))

----------------------------------------
IF OBJECT_ID('TEMPDB..#A') IS NOT NULL
   DROP TABLE #A

SELECT DISTINCT CustomerAcID,FinalNpaDt,SMA_Class 
INTO #A
FROM PRO.AccountCal_Hist with (nolock) 
WHERE CustomerAcID IN (
SELECT DISTINCT B.CustomerAcID 

FROM		ExceptionFinalStatusType Z
LEFT JOIN	PRO.ACCOUNTCAL_Hist B with (nolock)         ON Z.ACID = B.CustomerACID 
														   AND Z.EffectiveFromTimeKey <= @Timekey 
														   AND Z.EffectiveToTimeKey >= @Timekey
	
LEFT JOIN PRO.CustomerCal_Hist A  with (nolock)		    ON A.CustomerEntityID=B.CustomerEntityID 	
														   AND A.EffectiveFromTimeKey=B.EffectiveFromTimeKey 
	
LEFT JOIN DIMSOURCEDB src								ON B.SourceAlt_Key =src.SourceAlt_Key
														    AND src.EffectiveFromTimeKey <= @Timekey 
														    AND src.EffectiveToTimeKey >= @Timekey	
	
LEFT JOIN DIMPRODUCT PD	                                ON  PD.PRODUCTALT_KEY=B.PRODUCTALT_KEY
														    AND PD.EffectiveFromTimeKey <= @Timekey 
														    AND PD.EffectiveToTimeKey >= @Timekey
																
	
LEFT JOIN DimAssetClass A1	                            ON A1.AssetClassAlt_Key=B.InitialAssetClassAlt_Key 	
														   AND A1.EffectiveFromTimeKey <= @Timekey 
														   AND A1.EffectiveToTimeKey >= @Timekey

	
LEFT JOIN DimAssetClass A2
														ON A2.AssetClassAlt_Key=B.FinalAssetClassAlt_Key	
														   AND A2.EffectiveFromTimeKey <= @Timekey 
														   AND A2.EffectiveToTimeKey >= @Timekey
		
	
LEFT JOIN DimAcBuSegment S								ON B.ActSegmentCode=S.AcBuSegmentCode 
														   AND S.EffectiveFromTimeKey <= @Timekey 
														   AND S.EffectiveToTimeKey >= @Timekey
	
LEFT JOIN DimBranch X									ON B.BranchCode = X.BranchCode 
														   AND X.EffectiveFromTimeKey <= @Timekey 
														   AND X.EffectiveToTimeKey >= @Timekey

LEFT JOIN (
			SELECT AcID AS CustomerACID,Amount AS WriteOffAmt,StatusDate AS WriteOffDt 
			FROM ExceptionFinalStatusType WITH (nolock) 
			WHERE CAST(StatusDate AS DATE) <= @LastQtrDate AND EffectiveToTimeKey = 49999
			)Y                                           ON B.CustomerAcID = Y.CustomerACID	



WHERE ISNULL(Y.writeoffAmt,0) != 0  AND FinalNpaDt IS  NULL
      AND A.EffectiveFromTimeKey <= @LastMonthTimekey AND A.EffectiveToTimeKey >= @LastMonthTimekey

)	AND FinalNpaDt IS NOT NULL

OPTION(RECOMPILE)

--------------------------------------------------------
DROP TABLE IF EXISTS   #DPD 

SELECT 
CustomerACID,AccountEntityid,B.SourceSystemCustomerID,B.IntNotServicedDt,
LastCrDate,ContiExcessDt,OverDueSinceDt,ReviewDueDt,StockStDt,
PrincOverdueSinceDt,IntOverdueSinceDt,OtherOverdueSinceDt
,RefPeriodIntService
,RefPeriodNoCredit
,RefPeriodOverDrawn
,RefPeriodOverdue
,RefPeriodReview
,RefPeriodStkStatement
,b.EffectiveFromTimeKey
INTO #DPD 
FROM PRO.AccountCal_Hist B WITH (NOLOCK)

INNER JOIN SYSDAYMATRIX SD											ON B.EffectiveFromTimeKey=SD.TimeKey

INNER JOIN PRO.CustomerCal_Hist A									ON  A.CustomerEntityID=B.CustomerEntityID
																	    AND A.EffectiveFromTimeKey =SD.TimeKey
WHERE InitialAssetClassAlt_Key = 1 AND FinalAssetClassAlt_Key > 1
      AND A.EffectiveFromTimeKey <= @LastMonthTimekey AND A.EffectiveToTimeKey >= @LastMonthTimekey

OPTION(RECOMPILE)

-----------------------------------
ALTER TABLE #DPD
ADD DPD_IntService INT,DPD_NoCredit INT,DPD_Overdrawn INT,DPD_Overdue INT,DPD_Renewal INT,DPD_StockStmt INT,DPD_PrincOverdue INT,DPD_IntOverdueSince INT,DPD_OtherOverdueSince INT,DPD_MAX INT


/*---------- CALCULATED ALL DPD---------------------------------------------------------*/

UPDATE A 
SET		 A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@Date)  ELSE 0 END)			   
             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL  THEN DATEDIFF(DAY,A.LastCrDate,  @Date)       ELSE 0 END)
			 ,A.DPD_Overdrawn=  (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @Date)     ELSE 0 END)
			 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @Date)   ELSE 0 END) 
			 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @Date)      ELSE 0 END)
			 ,A.DPD_StockStmt=  (CASE WHEN  A.StockStDt IS NOT NULL		THEN   DATEDIFF(DAY,A.StockStDt,@Date)       ELSE 0 END)
			 ,A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,@Date)  ELSE 0 END)	 
             ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  @Date)   ELSE 0 END)
			 ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  @Date)  ELSE 0 END)
FROM			#DPD A 

OPTION(RECOMPILE)

/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/

 UPDATE #DPD SET DPD_IntService=0 WHERE ISNULL(DPD_IntService,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_NoCredit=0 WHERE ISNULL(DPD_NoCredit,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_Overdrawn=0 WHERE ISNULL(DPD_Overdrawn,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_Overdue=0 WHERE ISNULL(DPD_Overdue,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_Renewal=0 WHERE ISNULL(DPD_Renewal,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_StockStmt=0 WHERE ISNULL(DPD_StockStmt,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_PrincOverdue=0 WHERE ISNULL(DPD_PrincOverdue,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_IntOverdueSince=0 WHERE ISNULL(DPD_IntOverdueSince,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_OtherOverdueSince=0 WHERE ISNULL(DPD_OtherOverdueSince,0)<0

 OPTION(RECOMPILE)

/*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/

UPDATE A SET DPD_NoCredit=0 FROM #DPD A 

OPTION(RECOMPILE)

/* CALCULATE MAX DPD */

	 IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
	    DROP TABLE #TEMPTABLE

	 SELECT A.CustomerAcID
			,CASE WHEN  ISNULL(A.DPD_IntService,0)>=ISNULL(A.RefPeriodIntService,0)		THEN A.DPD_IntService  ELSE 0   END DPD_IntService,   
			 CASE WHEN  ISNULL(A.DPD_NoCredit,0)>=ISNULL(A.RefPeriodNoCredit,0)			THEN A.DPD_NoCredit    ELSE 0   END DPD_NoCredit,  
			 CASE WHEN  ISNULL(A.DPD_Overdrawn,0)>=ISNULL(A.RefPeriodOverDrawn	,0)	    THEN A.DPD_Overdrawn   ELSE 0   END DPD_Overdrawn,  
			 CASE WHEN  ISNULL(A.DPD_Overdue,0)>=ISNULL(A.RefPeriodOverdue	,0)		    THEN A.DPD_Overdue     ELSE 0   END DPD_Overdue , 
			 CASE WHEN  ISNULL(A.DPD_Renewal,0)>=ISNULL(A.RefPeriodReview	,0)			THEN A.DPD_Renewal     ELSE 0   END  DPD_Renewal ,
			 CASE WHEN  ISNULL(A.DPD_StockStmt,0)>=ISNULL(A.RefPeriodStkStatement,0)       THEN A.DPD_StockStmt   ELSE 0   END DPD_StockStmt  			
			 INTO #TEMPTABLE
			 FROM #DPD A 
			 INNER JOIN Pro.CustomerCal_hist B ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
			 WHERE ( 
			          ISNULL(DPD_IntService,0)>=ISNULL(RefPeriodIntService,0)
                   OR ISNULL(DPD_NoCredit,0)>=ISNULL(RefPeriodNoCredit,0)
				   OR ISNULL(DPD_Overdrawn,0)>=ISNULL(RefPeriodOverDrawn,0)
				   OR ISNULL(DPD_Overdue,0)>=ISNULL(RefPeriodOverdue,0)
				   OR ISNULL(DPD_Renewal,0)>=ISNULL(RefPeriodReview,0)
                   OR ISNULL(DPD_StockStmt,0)>=ISNULL(RefPeriodStkStatement,0)
			      ) AND (ISNULL(B.FlgProcessing,'N')='N' 
	
			      )
			    
			OPTION(RECOMPILE)

	/*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/

		UPDATE A SET A.DPD_Max=0
		 FROM #DPD A 
		
		OPTION(RECOMPILE)


		/*----------------FIND MAX DPD---------------------------------------*/

		UPDATE   A SET A.DPD_Max= (CASE    WHEN (ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_NoCredit,0) AND ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_Overdrawn,0) AND    ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_Overdue,0) AND  ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_Renewal,0) AND ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_StockStmt,0) 
		AND ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_PrincOverdue,0) 
		AND ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_IntOverDueSince,0) 
		AND ISNULL(A.DPD_IntService,0)>=ISNULL(A.DPD_OtherOverDueSince,0)) 
		THEN ISNULL(A.DPD_IntService,0)
										   WHEN (ISNULL(A.DPD_NoCredit,0)>=ISNULL(A.DPD_IntService,0) 
										   AND ISNULL(A.DPD_NoCredit,0)>=  ISNULL(A.DPD_Overdrawn,0) 
										   AND    ISNULL(A.DPD_NoCredit,0)>=ISNULL(A.DPD_Overdue,0) 
										   AND    ISNULL(A.DPD_NoCredit,0)>=  ISNULL(A.DPD_Renewal,0) 
										   AND ISNULL(A.DPD_NoCredit,0)>=ISNULL(A.DPD_StockStmt,0)
										   AND ISNULL(A.DPD_NoCredit,0)>=ISNULL(A.DPD_PrincOverdue,0) 
											AND ISNULL(A.DPD_NoCredit,0)>=ISNULL(A.DPD_IntOverDueSince,0) 
											AND ISNULL(A.DPD_NoCredit,0)>=ISNULL(A.DPD_OtherOverDueSince,0)) 
										    THEN   ISNULL(A.DPD_NoCredit ,0)
										   WHEN (ISNULL(A.DPD_Overdrawn,0)>=ISNULL(A.DPD_NoCredit,0)  AND ISNULL(A.DPD_Overdrawn,0)>= ISNULL(A.DPD_IntService,0)  AND  ISNULL(A.DPD_Overdrawn,0)>=ISNULL(A.DPD_Overdue,0) AND   ISNULL(A.DPD_Overdrawn,0)>= ISNULL(A.DPD_Renewal,0) AND ISNULL(A.DPD_Overdrawn,0)>=ISNULL(A.DPD_StockStmt,0)
										   AND ISNULL(A.DPD_Overdrawn,0)>=ISNULL(A.DPD_PrincOverdue,0) 
											AND ISNULL(A.DPD_Overdrawn,0)>=ISNULL(A.DPD_IntOverDueSince,0) 
											AND ISNULL(A.DPD_Overdrawn,0)>=ISNULL(A.DPD_OtherOverDueSince,0)) THEN  ISNULL(A.DPD_Overdrawn,0)
										   WHEN (ISNULL(A.DPD_Renewal,0)>=ISNULL(A.DPD_NoCredit,0)    AND ISNULL(A.DPD_Renewal,0)>=   ISNULL(A.DPD_IntService,0)  AND  ISNULL(A.DPD_Renewal,0)>=ISNULL(A.DPD_Overdrawn,0)  AND  ISNULL(A.DPD_Renewal,0)>=   ISNULL(A.DPD_Overdue,0)  AND ISNULL(A.DPD_Renewal,0) >=ISNULL(A.DPD_StockStmt ,0)
										   AND ISNULL(A.DPD_Renewal,0)>=ISNULL(A.DPD_PrincOverdue,0) 
											AND ISNULL(A.DPD_Renewal,0)>=ISNULL(A.DPD_IntOverDueSince,0) 
											AND ISNULL(A.DPD_Renewal,0)>=ISNULL(A.DPD_OtherOverDueSince,0)) THEN ISNULL(A.DPD_Renewal,0)
										   WHEN (ISNULL(A.DPD_Overdue,0)>=ISNULL(A.DPD_NoCredit,0)    AND ISNULL(A.DPD_Overdue,0)>=   ISNULL(A.DPD_IntService,0)  AND  ISNULL(A.DPD_Overdue,0)>=ISNULL(A.DPD_Overdrawn,0)  AND  ISNULL(A.DPD_Overdue,0)>=   ISNULL(A.DPD_Renewal,0)  AND ISNULL(A.DPD_Overdue ,0)>=ISNULL(A.DPD_StockStmt ,0)
										   AND ISNULL(A.DPD_Overdue,0)>=ISNULL(A.DPD_PrincOverdue,0) 
											AND ISNULL(A.DPD_Overdue,0)>=ISNULL(A.DPD_IntOverDueSince,0) 
											AND ISNULL(A.DPD_Overdue,0)>=ISNULL(A.DPD_OtherOverDueSince,0))  THEN   ISNULL(A.DPD_Overdue,0)
										   WHEN (ISNULL(A.DPD_StockStmt,0)>=ISNULL(A.DPD_NoCredit,0)    
										   AND ISNULL(A.DPD_StockStmt,0)>=   ISNULL(A.DPD_IntService,0)  
										   AND  ISNULL(A.DPD_StockStmt,0)>=ISNULL(A.DPD_Overdrawn,0)  
										   AND  ISNULL(A.DPD_StockStmt,0)>=   ISNULL(A.DPD_Renewal,0)  
										   AND ISNULL(A.DPD_StockStmt ,0)>=ISNULL(A.DPD_Overdue ,0)
										   AND ISNULL(A.DPD_StockStmt,0)>=ISNULL(A.DPD_PrincOverdue,0) 
											AND ISNULL(A.DPD_StockStmt,0)>=ISNULL(A.DPD_IntOverDueSince,0) 
											AND ISNULL(A.DPD_StockStmt,0)>=ISNULL(A.DPD_OtherOverDueSince,0))  THEN   ISNULL(A.DPD_StockStmt,0)
										   WHEN (ISNULL(A.DPD_PrincOverdue,0)>=ISNULL(A.DPD_NoCredit,0)    
										   AND ISNULL(A.DPD_PrincOverdue,0)>=   ISNULL(A.DPD_IntService,0)  
										   AND  ISNULL(A.DPD_PrincOverdue,0)>=ISNULL(A.DPD_Overdrawn,0)  
										   AND  ISNULL(A.DPD_PrincOverdue,0)>=   ISNULL(A.DPD_Renewal,0)  
										   AND ISNULL(A.DPD_PrincOverdue ,0)>=ISNULL(A.DPD_StockStmt ,0)
										   AND ISNULL(A.DPD_PrincOverdue,0)>=ISNULL(A.DPD_Overdue,0) 
											AND ISNULL(A.DPD_PrincOverdue,0)>=ISNULL(A.DPD_IntOverDueSince,0) 
											AND ISNULL(A.DPD_PrincOverdue,0)>=ISNULL(A.DPD_OtherOverDueSince,0))  THEN   ISNULL(DPD_PrincOverdue,0)
										   WHEN (ISNULL(A.DPD_IntOverDueSince,0)>=ISNULL(A.DPD_NoCredit,0)    
										   AND ISNULL(A.DPD_IntOverDueSince,0)>=   ISNULL(A.DPD_IntService,0)  
										   AND  ISNULL(A.DPD_IntOverDueSince,0)>=ISNULL(A.DPD_Overdrawn,0)  
										   AND  ISNULL(A.DPD_IntOverDueSince,0)>=   ISNULL(A.DPD_Renewal,0)  
										   AND ISNULL(A.DPD_IntOverDueSince ,0)>=ISNULL(A.DPD_StockStmt ,0)
										   AND ISNULL(A.DPD_IntOverDueSince,0)>=ISNULL(A.DPD_Overdue,0) 
											AND ISNULL(A.DPD_IntOverDueSince,0)>=ISNULL(A.DPD_PrincOverdue,0) 
											AND ISNULL(A.DPD_IntOverDueSince,0)>=ISNULL(A.DPD_OtherOverDueSince,0))  THEN   ISNULL(A.DPD_IntOverDueSince,0)
										   ELSE ISNULL(A.DPD_OtherOverDueSince,0) END) 
			 
		FROM  #DPD A 
		INNER JOIN PRO.CustomerCal_Hist C        ON C.SourceSystemCustomerID=A.SourceSystemCustomerID
		WHERE  (ISNULL(C.FlgProcessing,'N')='N') 
		       AND 	(ISNULL(A.DPD_IntService,0)>0   OR ISNULL(A.DPD_Overdrawn,0)>0   OR  ISNULL(A.DPD_Overdue,0)>0	 OR ISNULL(A.DPD_Renewal,0) >0 OR ISNULL(A.DPD_StockStmt,0)>0 OR ISNULL(DPD_NoCredit,0)>0)

		OPTION(RECOMPILE)

--------------------------------------------------------------

IF OBJECT_ID('TEMPDB..#TWOReport') IS NOT NULL
   DROP TABLE #TWOReport


SELECT  
DISTINCT 
CONVERT(VARCHAR(20),@Date , 103)                      AS [Report date] 
,A.UCIF_ID                                            AS UCIC
,A.RefCustomerID                                      AS [CIF ID]
,REPLACE(A.CustomerName,',','')                       AS [Customer Name]
,B.BranchCode                                         AS [Branch Code]
,REPLACE(BranchName,',','')                           AS [Branch Name]
,B.CustomerAcID                                       AS [Account No.]
,SchemeType                                           AS [Scheme Type]
,B.ProductCode                                        AS [Scheme Code]
,ProductName                                          AS [Scheme Description]
,ActSegmentCode                                       AS [Account Segment Code]
,CASE WHEN SourceName='Ganaseva'   THEN 'FI'
	  WHEN SourceName='VisionPlus' THEN 'Credit Card'
	  ELSE AcBuSegmentDescription 
	  END                                             AS [Account Segment Description]
,B.FacilityType                                       AS [Facility]
,ProductGroup                                         AS [Nature of Facility]
,ISNULL(Y.WriteOffAmt,0)/@Cost                        AS [Opening Balance]
,(CASE WHEN ISNULL(Y.WriteOffAmt,0) = 0 
       THEN  ISNULL(B.PrincOutStd,0)  
	   ELSE 0 
	   END)/@Cost                                     AS [Addition]
,(CASE WHEN ISNULL(Y.WriteOffAmt,0) > 0 
       THEN (CASE WHEN ISNULL(B.PrincOutStd,0) - ISNULL(Y.WriteOffAmt,0) < 0 
				  THEN 0 
				  ELSE ISNULL(B.PrincOutStd,0) - ISNULL(Y.WriteOffAmt,0) 	
				  END)						
		ELSE 0 
		END)/@Cost                                    AS [Increase In Balance]
,0                                                    AS [Cash Recovery]		
,0                                                    AS [Recovery from NPA Sale]
,0                                                    AS [Write-off]
,ISNULL(B.PrincOutStd,0)/@Cost                        AS [Closing Balance POS as on 19/10/2021]	
,(CASE WHEN ISNULL(Y.WriteOffAmt,0) - ISNULL(B.PrincOutStd,0) < 0 
       THEN 0 
	   ELSE ISNULL(Y.WriteOffAmt,0) - ISNULL(B.PrincOutStd,0) 
	   END)/@Cost                                     AS [Reduction in Balance]
,@CurQtrDate                                          AS [Reporting_Period]
,ISNULL(DPD_Max,0)                                    AS [DPD as on 19/10/2021]
,FinalNpaDt                                           AS [NPA Date as on 19/10/2021]
,A2.AssetClassName                                    AS [Asset Classification]
,CONVERT(VARCHAR(20),Z.StatusDate ,103)               AS [Date of Technical Write-off]
,SourceName                                           AS [Host System]
,CASE WHEN SourceName='Ganaseva' 
      THEN 'FI'
      WHEN SourceName='VisionPlus' 
	  THEN 'Credit Card'
      ELSE AcBuRevisedSegmentCode 
	  END                                             AS [Business Segment]
		
INTO #TWOReport
FROM ExceptionFinalStatusType Z

LEFT JOIN	PRO.ACCOUNTCAL_Hist B with (nolock)								ON Z.ACID = B.CustomerACID 
																			   AND Z.EffectiveFromTimeKey <= @Timekey
																			   AND Z.EffectiveToTimeKey >= @Timekey

LEFT JOIN PRO.CustomerCal_Hist A  with (nolock)
																			ON A.CustomerEntityID=B.CustomerEntityID 
																			   AND A.EffectiveFromTimeKey=B.EffectiveFromTimeKey

LEFT JOIN DIMSOURCEDB src                                                   ON B.SourceAlt_Key =src.SourceAlt_Key
																			   AND src.EffectiveFromTimeKey <= @Timekey 
																		       AND src.EffectiveToTimeKey >= @Timekey																				

LEFT JOIN DIMPRODUCT PD                                                     ON PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
																			   AND PD.EffectiveFromTimeKey <= @Timekey 
																		       AND PD.EffectiveToTimeKey >= @Timekey

LEFT JOIN DimAssetClass A1                                                  ON  A1.AssetClassAlt_Key=B.InitialAssetClassAlt_Key
																			    AND A1.EffectiveFromTimeKey <= @Timekey 
																		        AND A1.EffectiveToTimeKey >= @Timekey

LEFT JOIN DimAssetClass A2                                                  ON A2.AssetClassAlt_Key=B.FinalAssetClassAlt_Key
																			   AND A2.EffectiveFromTimeKey <= @Timekey 
																			   AND A2.EffectiveToTimeKey >= @Timekey


LEFT JOIN DimAcBuSegment S													ON B.ActSegmentCode=S.AcBuSegmentCode 
																			   AND S.EffectiveFromTimeKey <= @Timekey 
																			   AND S.EffectiveToTimeKey >= @Timekey


LEFT JOIN DimBranch X														ON B.BranchCode = X.BranchCode 
																			   AND X.EffectiveFromTimeKey <= @Timekey 
																			   AND X.EffectiveToTimeKey >= @Timekey


LEFT JOIN (
				SELECT ACID as CustomerAcID,Amount as WriteOffAmt,StatusDate as WriteOffDt 
				FROM ExceptionFinalStatusType with (nolock) 
				WHERE CAST(StatusDate AS DATE) <= @LastQtrDate AND EffectiveToTimeKey	 = 49999
			)Y 	                                                            ON B.CustomerAcID = Y.CustomerAcID
	
LEFT JOIN #DPD  DPD															ON DPD.AccountEntityID=B.AccountEntityID 
																			   AND DPD.EffectiveFromTimeKey = B.EffectiveFromTimeKey

WHERE ISNULL(Y.writeoffAmt,0) != 0 
      AND A.EffectiveFromTimeKey <= @LastMonthTimekey and A.EffectiveToTimeKey >= @LastMonthTimekey 

OPTION(RECOMPILE)

UPDATE A SET A.[NPA Date as on 19/10/2021] = B.FinalNpaDt,
A.[Asset Classification]= (CASE WHEN B.SMA_Class = 'SUB' 
                                THEN 'SUB-STANDARD' 
								WHEN B.SMA_Class = 'DB1' 
								THEN 'DOUBTFUL I' 
								WHEN B.SMA_Class = 'DB2' 
								THEN 'DOUBTFUL II'
								WHEN B.SMA_Class = 'DB3' 
								THEN 'DOUBTFUL III' 
								ELSE B.SMA_Class 
								END)
FROM #TWOReport A 
INNER JOIN #A B                ON A.[Account No.] = B.CustomerACID

OPTION(RECOMPILE)

UPDATE A SET A.[NPA Date as on 19/10/2021] = CONVERT(DATE,B.[NPA date1],103) ,A.[Asset Classification] = B.[Assets Class ]
FROM #TWOReport A 
INNER JOIN TWO_653 B                ON A.[Account No.] = B.[Account No#]

WHERE A.[NPA Date as on 19/10/2021] IS NULL
	
OPTION(RECOMPILE)	

UPDATE #TWOReport SET [Asset Classification] = (CASE WHEN [Asset Classification] = 'SUB' 
                                                     THEN 'SUB-STANDARD' 
													 WHEN [Asset Classification] = 'DB1' 
													 THEN 'DOUBTFUL I' 
													 WHEN [Asset Classification] = 'DB2' 
													 THEN 'DOUBTFUL II' 
													 WHEN [Asset Classification] = 'DB3' 
													 THEN 'DOUBTFUL III' 
													 ELSE [Asset Classification] 
													 END)


OPTION(RECOMPILE)

SELECT * FROM #TWOReport

OPTION(RECOMPILE)

END

DROP TABLE #A,#DPD,#TEMPTABLE,#TWOReport


GO