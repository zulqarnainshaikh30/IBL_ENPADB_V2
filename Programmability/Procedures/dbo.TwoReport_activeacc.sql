SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TwoReport_activeacc]
--@Date date

AS
BEGIN


DECLARE @Date date = 
(select Date from Automate_Advances where Ext_flg = 'Y')

--DECLARE @Timekey int = 
--(@timekey)

--DECLARE @LastQtrTimekey int = (select LastQtrDateKey from SysDayMatrix  where Timekey in (@timekey))

--DECLARE @LastQtrDate date = (select LastQtrDate from SysDayMatrix  where Timekey in (@timekey))

--DECLARE @CurQtrDate Date = (select CurQtrDate from SysDayMatrix  where Timekey in (@timekey))

--DECLARE @LastMonthTimekey int = (select LastMonthDateKey from SysDayMatrix  where Timekey in (@timekey))

--DECLARE @LastMonthDate date = (select LastMonthDate from SysDayMatrix  where Timekey in (@timekey))


--DECLARE @Date date
--= (select Date from Automate_Advances where Ext_flg = 'Y')




DECLARE @Timekey int = 
(select Timekey from Automate_Advances where Date = @date)
--select @timekey

DECLARE @LastQtrTimekey int = (select LastQtrDateKey from SysDayMatrix  where Timekey in (@timekey))

DECLARE @LastQtrDate date = (select LastQtrDate from SysDayMatrix  where Timekey in (@timekey))

DECLARE @CurQtrDate Date = (select CurQtrDate from SysDayMatrix  where Timekey in (@timekey))

DECLARE @LastMonthTimekey int = (select LastMonthDateKey from SysDayMatrix  where Timekey in (@timekey))

DECLARE @LastMonthDate date = (select LastMonthDate from SysDayMatrix  where Timekey in (@timekey))

----------------------------------------
SELECT distinct CustomerAcID,FinalNpaDt,SMA_Class 
into #A
FROM PRO.AccountCal_Hist with (nolock) 
WHERE CustomerAcID IN (
SELECT DISTINCT b.CustomerAcID 
FROM		ExceptionFinalStatusType Z
LEFT JOIN	PRO.ACCOUNTCAL_Hist B with (nolock) ON Z.ACID = B.CustomerACID 
AND Z.EffectiveToTimeKey = 49999
LEFT JOIN PRO.CustomerCal_Hist A  with (nolock)
	ON A.CustomerEntityID=B.CustomerEntityID 
	
LEFT JOIN DIMSOURCEDB src
	on b.SourceAlt_Key =src.SourceAlt_Key	
LEFT JOIN DIMPRODUCT PD
	ON PD.EffectiveToTimeKey=49999
	AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
left join DimAssetClass a1
	on a1.EffectiveToTimeKey=49999
	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
left join DimAssetClass a2
	on a2.EffectiveToTimeKey=49999
	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and s.EffectiveToTimeKey = 49999
LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey = 49999
LEFT JOIN (
				select AcID as CustomerACID,Amount as WriteOffAmt,StatusDate as WriteOffDt 
				from ExceptionFinalStatusType with (nolock) 
				where cast(StatusDate as date) <= @LastQtrDate AND EffectiveToTimeKey = 49999
			)Y 
	ON B.CustomerAcID = Y.CustomerACID	
--LEFT JOIN #DPD  DPD ON DPD.AccountEntityID=b.AccountEntityID AND dpd.EffectiveFromTimeKey = B.EffectiveFromTimeKey
where ISNULL(Y.writeoffAmt,0) != 0  
and FinalNpaDt is  NULL
and A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey
and B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey
)	 
AND finalNPAdT IS NOT null

 Drop table if exists   #DPD 

select CustomerACID,AccountEntityid,B.SourceSystemCustomerID,B.IntNotServicedDt,@Date as Process_Date,
LastCrDate,ContiExcessDt,OverDueSinceDt,ReviewDueDt,StockStDt,
PrincOverdueSinceDt,IntOverdueSinceDt,OtherOverdueSinceDt
,RefPeriodIntService
,RefPeriodNoCredit
,RefPeriodOverDrawn
,RefPeriodOverdue
,RefPeriodReview
,RefPeriodStkStatement
,A.DegDate 
,b.EffectiveFromTimeKey
,b.EffectiveToTimeKey
into #DPD 
FROM PRO.AccountCal_Hist B WITH (NOLOCK)
INNER JOIN PRO.CustomerCal_Hist A ON  A.CustomerEntityID=B.CustomerEntityID
WHERE  A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey
AND B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey


alter Table #DPD
add DPD_IntService int,DPD_NoCredit int,DPD_Overdrawn int,DPD_Overdue int,DPD_Renewal int,DPD_StockStmt int,DPD_PrincOverdue INT,DPD_IntOverdueSince INT,DPD_OtherOverdueSince INT,DPD_MAX INT


/*---------- CALCULATED ALL DPD---------------------------------------------------------*/

UPDATE A 
SET		 A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,Process_Date)  ELSE 0 END)			   
             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL  THEN DATEDIFF(DAY,A.LastCrDate,  Process_Date)       ELSE 0 END)
			 ,A.DPD_Overdrawn=  (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  Process_Date)     ELSE 0 END)
			 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  Process_Date)   ELSE 0 END) 
			 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, Process_Date)      ELSE 0 END)
			 ,A.DPD_StockStmt=  (CASE WHEN  A.StockStDt IS NOT NULL		THEN   DATEDIFF(DAY,A.StockStDt,Process_Date)       ELSE 0 END)
			 ,A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,Process_Date)  ELSE 0 END)	 
             ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  Process_Date)   ELSE 0 END)
			 ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  Process_Date)  ELSE 0 END)
FROM			#DPD A 



/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/

 UPDATE #DPD SET DPD_IntService=0 WHERE isnull(DPD_IntService,0)<0
 UPDATE #DPD SET DPD_NoCredit=0 WHERE isnull(DPD_NoCredit,0)<0
 UPDATE #DPD SET DPD_Overdrawn=0 WHERE isnull(DPD_Overdrawn,0)<0
 UPDATE #DPD SET DPD_Overdue=0 WHERE isnull(DPD_Overdue,0)<0
 UPDATE #DPD SET DPD_Renewal=0 WHERE isnull(DPD_Renewal,0)<0
 UPDATE #DPD SET DPD_StockStmt=0 WHERE isnull(DPD_StockStmt,0)<0
 UPDATE #DPD SET DPD_PrincOverdue=0 WHERE isnull(DPD_PrincOverdue,0)<0
 UPDATE #DPD SET DPD_IntOverdueSince=0 WHERE isnull(DPD_IntOverdueSince,0)<0
 UPDATE #DPD SET DPD_OtherOverdueSince=0 WHERE isnull(DPD_OtherOverdueSince,0)<0

/*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/

UPDATE A SET DPD_NoCredit=0 FROM #DPD A 



/* CALCULATE MAX DPD */

	 IF OBJECT_ID('TEMPDB..#TEMPTABLE') IS NOT NULL
	    DROP TABLE #TEMPTABLE

	 SELECT A.CustomerAcID
			,CASE WHEN  isnull(A.DPD_IntService,0)>=isnull(A.RefPeriodIntService,0)		THEN A.DPD_IntService  ELSE 0   END DPD_IntService,  
			 CASE WHEN  isnull(A.DPD_NoCredit,0)>=isnull(A.RefPeriodNoCredit,0)			THEN A.DPD_NoCredit    ELSE 0   END DPD_NoCredit,  
			 CASE WHEN  isnull(A.DPD_Overdrawn,0)>=isnull(A.RefPeriodOverDrawn	,0)	    THEN A.DPD_Overdrawn   ELSE 0   END DPD_Overdrawn,  
			 CASE WHEN  isnull(A.DPD_Overdue,0)>=isnull(A.RefPeriodOverdue	,0)		    THEN A.DPD_Overdue     ELSE 0   END DPD_Overdue , 
			 CASE WHEN  isnull(A.DPD_Renewal,0)>=isnull(A.RefPeriodReview	,0)			THEN A.DPD_Renewal     ELSE 0   END  DPD_Renewal ,
			 CASE WHEN  isnull(A.DPD_StockStmt,0)>=isnull(A.RefPeriodStkStatement,0)       THEN A.DPD_StockStmt   ELSE 0   END DPD_StockStmt  			
			 INTO #TEMPTABLE
			 --FROM PRO.ACCOUNTCAL A inner join pro.CustomerCal B on a.RefCustomerID=b.RefCustomerID
			 FROM #DPD A inner join pro.CustomerCal_hist B on A.SourceSystemCustomerID=B.SourceSystemCustomerID
			 WHERE ( 
			          isnull(DPD_IntService,0)>=isnull(RefPeriodIntService,0)
                   OR isnull(DPD_NoCredit,0)>=isnull(RefPeriodNoCredit,0)
				   OR isnull(DPD_Overdrawn,0)>=isnull(RefPeriodOverDrawn,0)
				   OR isnull(DPD_Overdue,0)>=isnull(RefPeriodOverdue,0)
				   OR isnull(DPD_Renewal,0)>=isnull(RefPeriodReview,0)
                   OR isnull(DPD_StockStmt,0)>=isnull(RefPeriodStkStatement,0)
			      ) AND (isnull(B.FlgProcessing,'N')='N' 
	
			      ) 
				  AND B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey
			    
				--and A.RefCustomerID<>'0'

	/*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/

		UPDATE A SET A.DPD_Max=0
		 FROM #DPD A 
		 --inner join PRO.CUSTOMERCAL B on A.RefCustomerID=B.RefCustomerID
		 --WHERE  isnull(B.FlgProcessing,'N')='N'  


		/*----------------FIND MAX DPD---------------------------------------*/

		UPDATE   A SET A.DPD_Max= (CASE    WHEN (isnull(A.DPD_IntService,0)>=isnull(A.DPD_NoCredit,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdrawn,0) AND    isnull(A.DPD_IntService,0)>=isnull(A.DPD_Overdue,0) AND  isnull(A.DPD_IntService,0)>=isnull(A.DPD_Renewal,0) AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_StockStmt,0) 
		AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_PrincOverdue,0) 
		AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_IntOverDueSince,0) 
		AND isnull(A.DPD_IntService,0)>=isnull(A.DPD_OtherOverDueSince,0)) 
		THEN isnull(A.DPD_IntService,0)
										   WHEN (isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntService,0) 
										   AND isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Overdrawn,0) 
										   AND    isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_Overdue,0) 
										   AND    isnull(A.DPD_NoCredit,0)>=  isnull(A.DPD_Renewal,0) 
										   AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_StockStmt,0)
										   AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_PrincOverdue,0) 
											AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_IntOverDueSince,0) 
											AND isnull(A.DPD_NoCredit,0)>=isnull(A.DPD_OtherOverDueSince,0)) 
										    THEN   isnull(A.DPD_NoCredit ,0)
										   WHEN (isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_NoCredit,0)  AND isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_Overdue,0) AND   isnull(A.DPD_Overdrawn,0)>= isnull(A.DPD_Renewal,0) AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_StockStmt,0)
										   AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_PrincOverdue,0) 
											AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_IntOverDueSince,0) 
											AND isnull(A.DPD_Overdrawn,0)>=isnull(A.DPD_OtherOverDueSince,0)) THEN  isnull(A.DPD_Overdrawn,0)
										   WHEN (isnull(A.DPD_Renewal,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Renewal,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Renewal,0)>=   isnull(A.DPD_Overdue,0)  AND isnull(A.DPD_Renewal,0) >=isnull(A.DPD_StockStmt ,0)
										   AND isnull(A.DPD_Renewal,0)>=isnull(A.DPD_PrincOverdue,0) 
											AND isnull(A.DPD_Renewal,0)>=isnull(A.DPD_IntOverDueSince,0) 
											AND isnull(A.DPD_Renewal,0)>=isnull(A.DPD_OtherOverDueSince,0)) THEN isnull(A.DPD_Renewal,0)
										   WHEN (isnull(A.DPD_Overdue,0)>=isnull(A.DPD_NoCredit,0)    AND isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_IntService,0)  AND  isnull(A.DPD_Overdue,0)>=isnull(A.DPD_Overdrawn,0)  AND  isnull(A.DPD_Overdue,0)>=   isnull(A.DPD_Renewal,0)  AND isnull(A.DPD_Overdue ,0)>=isnull(A.DPD_StockStmt ,0)
										   AND isnull(A.DPD_Overdue,0)>=isnull(A.DPD_PrincOverdue,0) 
											AND isnull(A.DPD_Overdue,0)>=isnull(A.DPD_IntOverDueSince,0) 
											AND isnull(A.DPD_Overdue,0)>=isnull(A.DPD_OtherOverDueSince,0))  THEN   isnull(A.DPD_Overdue,0)
										   WHEN (isnull(A.DPD_StockStmt,0)>=isnull(A.DPD_NoCredit,0)    
										   AND isnull(A.DPD_StockStmt,0)>=   isnull(A.DPD_IntService,0)  
										   AND  isnull(A.DPD_StockStmt,0)>=isnull(A.DPD_Overdrawn,0)  
										   AND  isnull(A.DPD_StockStmt,0)>=   isnull(A.DPD_Renewal,0)  
										   AND isnull(A.DPD_StockStmt ,0)>=isnull(A.DPD_Overdue ,0)
										   AND isnull(A.DPD_StockStmt,0)>=isnull(A.DPD_PrincOverdue,0) 
											AND isnull(A.DPD_StockStmt,0)>=isnull(A.DPD_IntOverDueSince,0) 
											AND isnull(A.DPD_StockStmt,0)>=isnull(A.DPD_OtherOverDueSince,0))  THEN   isnull(A.DPD_StockStmt,0)
										   WHEN (isnull(A.DPD_PrincOverdue,0)>=isnull(A.DPD_NoCredit,0)    
										   AND isnull(A.DPD_PrincOverdue,0)>=   isnull(A.DPD_IntService,0)  
										   AND  isnull(A.DPD_PrincOverdue,0)>=isnull(A.DPD_Overdrawn,0)  
										   AND  isnull(A.DPD_PrincOverdue,0)>=   isnull(A.DPD_Renewal,0)  
										   AND isnull(A.DPD_PrincOverdue ,0)>=isnull(A.DPD_StockStmt ,0)
										   AND isnull(A.DPD_PrincOverdue,0)>=isnull(A.DPD_Overdue,0) 
											AND isnull(A.DPD_PrincOverdue,0)>=isnull(A.DPD_IntOverDueSince,0) 
											AND isnull(A.DPD_PrincOverdue,0)>=isnull(A.DPD_OtherOverDueSince,0))  THEN   isnull(DPD_PrincOverdue,0)
										   WHEN (isnull(A.DPD_IntOverDueSince,0)>=isnull(A.DPD_NoCredit,0)    
										   AND isnull(A.DPD_IntOverDueSince,0)>=   isnull(A.DPD_IntService,0)  
										   AND  isnull(A.DPD_IntOverDueSince,0)>=isnull(A.DPD_Overdrawn,0)  
										   AND  isnull(A.DPD_IntOverDueSince,0)>=   isnull(A.DPD_Renewal,0)  
										   AND isnull(A.DPD_IntOverDueSince ,0)>=isnull(A.DPD_StockStmt ,0)
										   AND isnull(A.DPD_IntOverDueSince,0)>=isnull(A.DPD_Overdue,0) 
											AND isnull(A.DPD_IntOverDueSince,0)>=isnull(A.DPD_PrincOverdue,0) 
											AND isnull(A.DPD_IntOverDueSince,0)>=isnull(A.DPD_OtherOverDueSince,0))  THEN   isnull(A.DPD_IntOverDueSince,0)
										   ELSE isnull(A.DPD_OtherOverDueSince,0) END) 
			 
		FROM  #DPD a 
		--INNER JOIN PRO.CUSTOMERCAL C ON C.RefCustomerID=a.RefCustomerID
		INNER JOIN PRO.CustomerCal_Hist C ON C.SourceSystemCustomerID=a.SourceSystemCustomerID
		WHERE  (isnull(C.FlgProcessing,'N')='N') 
		AND 
		(isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0	 OR isnull(A.DPD_Renewal,0) >0 OR
		isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)
		and C.EffectiveFromTimeKey <= @Timekey and C.EffectiveToTimeKey >= @Timekey



select  distinct convert(nvarchar,@Date , 105) AS  [Report date] 
,A.UCIF_ID as UCIC
,A.RefCustomerID as [CIF ID]
,REPLACE(A.CustomerName,',','') as [Customer Name]
,B.BranchCode as [Branch Code]
,REPLACE(BranchName,',','') as  [Branch Name]
,B.CustomerAcID as [Account No.]
,SchemeType as [Scheme Type]
,B.ProductCode as [Scheme Code]
,ProductName as [Scheme Description]
,ActSegmentCode as [Account Segment Code]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuSegmentDescription end [Account Segment Description]
		,B.FacilityType as [Facility]
		,ProductGroup as [Nature of Facility]
		,ISNULL(Y.WriteOffAmt,0) as [Opening Balance]
		,(CASE WHEN ISNULL(Y.WriteOffAmt,0) = 0 THEN  ISNULL(B.PrincOutStd,0)  ELSE 0 END) as [Addition]
		,(Case when ISNULL(Y.WriteOffAmt,0) > 0 THEN 
							(CASE WHEN ISNULL(B.PrincOutStd,0) - ISNULL(Y.WriteOffAmt,0) < 0 
							THEN 0 
							ELSE ISNULL(B.PrincOutStd,0) - ISNULL(Y.WriteOffAmt,0) 	END)						
							ELSE 0 END) [Increase In Balance]
		,'' as [Cash Recovery]		
		,'' [Recovery from NPA Sale]
		,0 as [Write-off]
		,ISNULL(B.PrincOutStd,0) [Closing Balance POS]	---As requested by Sitaram sir 14/10/2021
		,(Case when ISNULL(Y.WriteOffAmt,0) - ISNULL(B.PrincOutStd,0) < 0 THEN 0 ELSE ISNULL(Y.WriteOffAmt,0) - ISNULL(B.PrincOutStd,0) END) [Reduction in Balance]
		,@CurQtrDate as [Reporting_Period]
		,ISNULL(DPD_Max,0)[DPD] ---As requested by Sitaram sir
		,FinalNpaDt  as [NPA Date]---As requested by Sitaram sir
		,a2.AssetClassName as [Asset Classification]
		,Z.StatusDate as [Date of Technical Write-off]
		,SourceName as [Host System]
		,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuRevisedSegmentCode end [Business Segment]
		INTO #TWOReport
FROM		ExceptionFinalStatusType Z
LEFT JOIN	PRO.ACCOUNTCAL_Hist B with (nolock) 
ON Z.ACID = B.CustomerACID 
AND z.EffectiveToTimeKey = 49999
LEFT JOIN PRO.CustomerCal_Hist A  with (nolock)
	ON A.CustomerEntityID=B.CustomerEntityID 
LEFT JOIN DIMSOURCEDB src
	on b.SourceAlt_Key =src.SourceAlt_Key	
LEFT JOIN DIMPRODUCT PD
	ON PD.EffectiveToTimeKey=49999
	AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
left join DimAssetClass a1
	on a1.EffectiveToTimeKey=49999
	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
left join DimAssetClass a2
	on a2.EffectiveToTimeKey=49999
	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and s.EffectiveToTimeKey = 49999
LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey = 49999
LEFT JOIN (
				select ACID as CustomerAcID,Amount as WriteOffAmt,StatusDate as WriteOffDt 
				from ExceptionFinalStatusType with (nolock) 
				where cast(StatusDate as date) <= @LastQtrDate AND EffectiveToTimeKey	 = 49999
			)Y 
	ON B.CustomerAcID = Y.CustomerAcID	
LEFT JOIN #DPD  DPD ON DPD.AccountEntityID=b.AccountEntityID AND dpd.EffectiveFromTimeKey = B.EffectiveFromTimeKey
where ISNULL(Y.writeoffAmt,0) != 0 
--and FinalNpaDt is not NULL
and A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey 
and B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey 


update A Set A.[NPA Date] = B.FinalNpaDt,
A.[Asset Classification]= (CASE WHEN B.SMA_Class = 'SUB' THEN 'SUB-STANDARD' WHEN B.SMA_Class = 'DB1' THEN 'DOUBTFUL I' WHEN B.SMA_Class = 'DB2' THEN 'DOUBTFUL II' WHEN B.SMA_Class = 'DB3' THEN 'DOUBTFUL III' else B.SMA_Class end)
from #TWOReport A 
INNER JOIN #A B ON A.[Account No.] = B.CustomerACID

Update A Set A.[NPA Date] = CONVERT(Date,B.[NPA date1],105) ,A.[Asset Classification] = B.[Assets Class ]
from #TWOReport A INNER JOIN TWO_653 B ON A.[Account No.] = B.[Account No#]
where A.[NPA Date] is nULL
	
	

update #TWOReport set [Asset Classification] = (CASE WHEN [Asset Classification] = 'SUB' THEN 'SUB-STANDARD' WHEN [Asset Classification] = 'DB1' THEN 'DOUBTFUL I' WHEN [Asset Classification] = 'DB2' THEN 'DOUBTFUL II' WHEN [Asset Classification] = 'DB3' THEN 'DOUBTFUL III' else [Asset Classification] end)

select * from #TWOReport

END


GO