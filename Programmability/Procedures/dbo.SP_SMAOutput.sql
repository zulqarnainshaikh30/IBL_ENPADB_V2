SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE prOCEDURE [dbo].[SP_SMAOutput]
AS
BEGIN

--DECLARE @TIMEKEY INT='26267'
--(select timekey from Automate_Advances where Ext_flg = 'y')
DECLARE @TIMEKEY INT=(select timekey from Automate_Advances where Ext_flg = 'y')

DECLARE @PROCESSDATE DATE
SET @PROCESSDATE=(SELECT DATE FROM SYSDAYMATRIX WHERE TIMEKEY=@TIMEKEY)---972953

---------------------------======================================DPD Calculation Start===========================================

 --Drop table if exists   #DPD 

 	IF OBJECT_ID('TEMPDB..#DPD') IS NOT NULL
	DROP TABLE  #DPD

select AccountEntityID,UcifEntityID,CustomerEntityID,CustomerAcID,
RefCustomerID,SourceSystemCustomerID,UCIF_ID,IntNotServicedDt,LastCrDate,ContiExcessDt,OverDueSinceDt,ReviewDueDt,StockStDt,
RefPeriodIntService,RefPeriodNoCredit,RefPeriodOverDrawn,RefPeriodOverdue,RefPeriodReview,RefPeriodStkStatement,SourceAlt_Key,DebitSinceDt,Asset_Norm
 INTO #DPD 
 from  PRO.AccountCal_Hist where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey

ALTER Table #DPD
ADD DPD_IntService int,DPD_NoCredit int,DPD_Overdrawn int,DPD_Overdue int,DPD_Renewal int,DPD_StockStmt int,DPD_MAX INT,DPD_UCIF_ID INT


----/*---------- CALCULATED ALL DPD---------------------------------------------------------*/

--UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)  ELSE 0 END)			   
--             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)
--			 ,A.DPD_Overdrawn=  (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END)
--			 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)   ELSE 0 END) 
--			 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)      ELSE 0 END)
--			 ,A.DPD_StockStmt=  (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate)       ELSE 0 END)
--FROM #DPD A 
if @TIMEKEY >26267
begin
UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)+1  ELSE 0 END)			   
---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)
             ,A.DPD_NoCredit = CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>90)
											THEN (CASE WHEN  A.LastCrDate IS NOT NULL THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)+1 ELSE 0 END)
									ELSE 0 END

			 ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END) 
			 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END) 
			 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)  +1    ELSE 0 END)
			 ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate) +1     ELSE 0 END)
FROM #DPD A 

end
else
begin

UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)  ELSE 0 END)			   
---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)
             ,A.DPD_NoCredit = CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>90)
											THEN (CASE WHEN  A.LastCrDate IS NOT NULL THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)  ELSE 0 END)
									ELSE 0 END

			 ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END) 
			 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)  ELSE 0 END) 
			 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)      ELSE 0 END)
			 ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate)     ELSE 0 END)
FROM #DPD A 

end



----/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/

 UPDATE #DPD SET DPD_IntService=0 WHERE isnull(DPD_IntService,0)<0
 UPDATE #DPD SET DPD_NoCredit=0 WHERE isnull(DPD_NoCredit,0)<0
 UPDATE #DPD SET DPD_Overdrawn=0 WHERE isnull(DPD_Overdrawn,0)<0
 UPDATE #DPD SET DPD_Overdue=0 WHERE isnull(DPD_Overdue,0)<0
 UPDATE #DPD SET DPD_Renewal=0 WHERE isnull(DPD_Renewal,0)<0
 UPDATE #DPD SET DPD_StockStmt=0 WHERE isnull(DPD_StockStmt,0)<0
 
 UPDATE A SET DPD_Overdrawn=0 FROM #DPD A where ISNULL(DPD_Overdrawn,0)<=30


----	/*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/

		UPDATE A SET A.DPD_Max=0
		 FROM #DPD A 
		  
		  update a set DPD_Overdrawn=0,DPD_Overdue=0,DPD_IntService=0,DPD_NoCredit=0,DPD_Renewal=0
		  FROM #DPD A where Asset_Norm='ALWYS_STD'

----		/*----------------FIND MAX DPD---------------------------------------*/
		UPDATE   A SET A.DPD_Max= (CASE WHEN isnull(A.DPD_Overdrawn,0)>isnull(A.DPD_Overdue,0)
											THEN isnull(A.DPD_Overdrawn,0)
										ELSE isnull(A.DPD_Overdue,0)
									END)
			 
		FROM  #DPD a 
		WHERE  (isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0)
		


		--UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND  isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0)) THEN isnull(A.DPD_IntService,0)
		--								   WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0) AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)) THEN   isnull(A.DPD_NoCredit ,0)
		--								   WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)) THEN  isnull(A.DPD_Overdrawn,0)
		--								   WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)) THEN isnull(A.DPD_Renewal,0)
		--								   WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0))  THEN   isnull(A.DPD_Overdue,0)
		--								   ELSE isnull(A.DPD_StockStmt,0) END) 
			 
		--FROM  #DPD a 
		--WHERE  
		--(isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0	 OR isnull(A.DPD_Renewal,0) >0 OR
		--isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)
		

	DROP TABLE IF EXISTS #DPD_UCIF_ID
	SELECT UCIF_ID,MAX(DPD_MAX) DPD_UCIF_ID 
		INTO #DPD_UCIF_ID
	FROM #DPD 
	GROUP BY UCIF_ID

	UPDATE A 
		SET A.DPD_UCIF_ID=B.DPD_UCIF_ID
	FROM #DPD A
		INNER JOIN #DPD_UCIF_ID B
			ON A.UCIF_ID =B.UCIF_ID

	

Select 

Convert(Varchar(10),@PROCESSDATE,103)CurrentProcessingDate
,ROW_NUMBER()Over(Order by A.UcifEntityId) SrNo
---------RefColumns---------
,R.BranchCode
,R.BranchName
,R.BranchStateName
,H.SourceName
,A.RefCustomerID as CustomerID
,A.SourceSystemCustomerID as SourceSystemCustomerID
,A.UCIF_ID
,A.CustomerAcID
,F.PANNO
,F.CustomerName
,F.CustSegmentCode
,A.FacilityType
----Edit--------
,A.ProductCode
,C.ProductName
,A.ActSegmentCode
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else S.AcBuRevisedSegmentCode end AcBuRevisedSegmentCode
,SchemeType
,ISNULL(A.Balance,0) AS Balance
,ISNULL(A.PrincOutStd,0) AS PrincOutStd
,ISNULL(A.PrincOverdue,0) AS PrincOverdue
,ISNULL(A.IntOverdue,0) AS IntOverdue
,ISNULL(A.OtherOverdue,0) AS OtherOverdue
,ISNULL(A.OverdueAmt,0) AS OverdueAmt
,ISNULL(A.CurrentLimit,0) AS CurrentLimit
,Convert(Varchar(10),A.ContiExcessDt,103)ContiExcessDt
,Convert(Varchar(10),A.StockStDt,103)StockStDt
,Convert(Varchar(10),A.LastCrDate,103)LastCrDate
,Convert(Varchar(10),A.IntNotServicedDt,103)IntNotServicedDt
,Convert(Varchar(10),A.OverDueSinceDt,103)OverDueSinceDt
,Convert(Varchar(10),A.ReviewDueDt,103)ReviewDueDt

-------OutPut-----
,DPD.DPD_StockStmt
,DPD.DPD_NoCredit
,DPD.DPD_IntService
,DPD.DPD_Overdrawn
,DPD.DPD_Overdue
,DPD.DPD_Renewal
,DPD.DPD_Max SMA_DPD
,A.FlgSMA AS AccountFlgSMA
,A.SMA_Dt AS AccountSMA_Dt
,A.SMA_Class AS AccountSMA_AssetClass
,A.SMA_Reason AS SMA_Reason
,dpd.DPD_UCIF_ID
,F.FlgSMA AS UCICFlgSMA
,F.SMA_Dt AS UCICSMA_Dt
--,Case When A.Asset_Norm='ALWYS_STD' then A.SMA_Class Else F.CustMoveDescription End as UCICSMA_AssetStatus
 ,F.CustMoveDescription  AS UCICSMA_AssetStatus
,Case When A.FlgSMA='Y' then NULL Else I.MovementFromDate End as MovementFromDate
,Case When A.FlgSMA='Y' then NULL Else I.MovementFromStatus End as MovementFromStatus
,Case When A.FlgSMA='Y' then NULL Else I.MovementToStatus End as MovementToStatus
,A.Asset_Norm
From Pro.AccountCal_hist A
	INNER JOIN DimProduct C ON C.ProductAlt_Key=A.ProductAlt_Key 
		AND A.EFFECTIVEFROMTIMEKEY<=@TIMEKEY   AND A.EFFECTIVETOTIMEKEY>=@TIMEKEY
		AND C.EffectiveFromTimeKey<=@TIMEKEY AND C.EffectiveToTimeKey>=@TIMEKEY
	INNER JOIN DimAssetClass D On D.AssetClassAlt_Key=A.InitialAssetClassAlt_Key 
	AND D.EffectiveFromTimeKey<=@TIMEKEY AND D.EffectiveToTimeKey>=@TIMEKEY
	INNER JOIN DimAssetClass E On E.AssetClassAlt_Key=A.FinalAssetClassAlt_Key 
	AND E.EffectiveFromTimeKey<=@TIMEKEY AND E.EffectiveToTimeKey>=@TIMEKEY
	INNER JOIN Pro.CustomerCal_hist F On F.CustomerEntityId=A.CustomerEntityId
	AND F.EffectiveFromTimeKey<=@TIMEKEY AND F.EffectiveToTimeKey>=@TIMEKEY
	INNER JOIN SysDayMatrix G ON A.EffectiveFromTimekey=G.TimeKey
	INNER JOIN DIMSOURCEDB H ON H.SourceAlt_Key=A.SourceAlt_Key
	AND H.EffectiveFromTimeKey<=@TIMEKEY AND H.EffectiveToTimeKey>=@TIMEKEY
	INNER JOIN #DPD DPD      ON DPD.AccountEntityID=A.AccountEntityID
	LEFT JOIN pro.ACCOUNT_MOVEMENT_HISTORY I ON I.CustomerAcID=A.CustomerAcID 
	AND I.EffectiveFromTimeKey<=@TIMEKEY AND I.EffectiveToTimeKey>=@TIMEKEY
	LEFT JOIN DimAcBuSegment S  ON a.ActSegmentCode=S.AcBuSegmentCode
	AND s.EffectiveFromTimeKey<=@TIMEKEY AND s.EffectiveToTimeKey>=@TIMEKEY
	LEFT JOIN DimBranch R  ON A.BranchCode=R.BranchCode
	AND R.EffectiveFromTimeKey<=@TIMEKEY AND R.EffectiveToTimeKey>=@TIMEKEY
WHERE A.FinalAssetClassAlt_Key=1
AND F.FlgSMA='Y'
order by A.UcifEntityID,A.RefCustomerID
END
GO