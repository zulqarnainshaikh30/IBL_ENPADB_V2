SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ProvisionComputationReport_HistData]
@Timekey int

AS


--DECLARE @Timekey int = 26298

DECLARE @Date date = 
(select Date from Automate_Advances where Timekey = @Timekey)


DECLARE @LastQtrDateKey INT = (select LastQtrDateKey from sysdaymatrix where timekey IN (@Timekey))


 Drop table if exists   DPD 

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
into DPD 
FROM PRO.AccountCal_Hist B WITH (NOLOCK)
INNER JOIN PRO.CustomerCal_Hist A ON  A.CustomerEntityID=B.CustomerEntityID
WHERE  A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey
AND B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey


alter Table DPD
add DPD_IntService int,DPD_NoCredit int,DPD_Overdrawn int,DPD_Overdue int,DPD_Renewal int,DPD_StockStmt int,DPD_PrincOverdue INT,DPD_IntOverdueSince INT,DPD_OtherOverdueSince INT,DPD_MAX INT

--------
if @TIMEKEY >26267
begin

UPDATE A SET  A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,Process_Date)+1  ELSE 0 END)			   
             ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  Process_Date)+1       ELSE 0 END)
			 ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  Process_Date)+1  ELSE 0 END) 
FROM DPD A 

end
else
begin

UPDATE A SET  A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,Process_Date)  ELSE 0 END)			   
             ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  Process_Date)       ELSE 0 END)
			 ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  Process_Date)  ELSE 0 END) 
FROM DPD A 

end

/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/

 UPDATE DPD SET DPD_IntService=0 WHERE isnull(DPD_IntService,0)<0
 UPDATE DPD SET DPD_NoCredit=0 WHERE isnull(DPD_NoCredit,0)<0
 UPDATE DPD SET DPD_Overdrawn=0 WHERE isnull(DPD_Overdrawn,0)<0
 UPDATE DPD SET DPD_Overdue=0 WHERE isnull(DPD_Overdue,0)<0
 UPDATE DPD SET DPD_Renewal=0 WHERE isnull(DPD_Renewal,0)<0
 UPDATE DPD SET DPD_StockStmt=0 WHERE isnull(DPD_StockStmt,0)<0
 UPDATE DPD SET DPD_PrincOverdue=0 WHERE isnull(DPD_PrincOverdue,0)<0
 UPDATE DPD SET DPD_IntOverdueSince=0 WHERE isnull(DPD_IntOverdueSince,0)<0
 UPDATE DPD SET DPD_OtherOverdueSince=0 WHERE isnull(DPD_OtherOverdueSince,0)<0

/*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/

UPDATE A SET DPD_NoCredit=0 FROM DPD A 



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
			 FROM DPD A inner join pro.CustomerCal_hist B on A.SourceSystemCustomerID=B.SourceSystemCustomerID
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
		 FROM DPD A 
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
			 
		FROM  DPD a 
		--INNER JOIN PRO.CUSTOMERCAL C ON C.RefCustomerID=a.RefCustomerID
		INNER JOIN PRO.CustomerCal_Hist C ON C.SourceSystemCustomerID=a.SourceSystemCustomerID
		WHERE  (isnull(C.FlgProcessing,'N')='N') 
		AND 
		(isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0	 OR isnull(A.DPD_Renewal,0) >0 OR
		isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)
		and C.EffectiveFromTimeKey <= @Timekey and C.EffectiveToTimeKey >= @Timekey
		
select  distinct convert(nvarchar,@Date , 105) AS  [Report Date] 
,A.UCIF_ID as UCIC
,A.RefCustomerID as [CIF ID]
,REPLACE(CustomerName,',','') as [Borrower Name]
,B.BranchCode as [Branch Code]
,REPLACE(BranchName,',','') as  [Branch Name]
,B.CustomerAcID as [Account No.]
,SourceName as [Source System]
,B.FacilityType as [Facility]
,SchemeType as [Scheme Type]
,B.ProductCode as [Scheme Code]
,ProductName as [Scheme Description]
,CASE WHEN B.SecApp ='S' THEN 'SECURED' ELSE 'UNSECURED'  END [Secured/Unsecured]
,ActSegmentCode as [Seg Code]
,(CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuSegmentDescription end) as [Segment Description]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuRevisedSegmentCode end  as [Business Segment]
,DPD_Max as [Account DPD]
,CD [Cycle Past due]
,FinalNpaDt [NPA Date]
,A2.AssetClassName as [Asset Classification]
,B.REFPERIODOVERDUE [NPA Norms]  --NPANorms as [NPA Norms] 
,B.NetBalance [Balance Outstanding]
,CurntQtrRv [Customer Security Value]
-----,SecurityValue as [Account Security Value]   -- TO BE REMOVED
,ApprRV as [Security Value Appropriated]
,B.SecuredAmt as [Secured Outstanding]
,B.UnSecuredAmt as [Unsecured Outstanding]
,B.TotalProvision as [Provision Total]
,B.Provsecured as [Provision Secured]
,B.ProvUnsecured as [Provision Unsecured]
,ISNULL((B.NetBalance-B.TotalProvision),0)[Net NPA]
,cast((ISNULL((B.Provsecured/NULLIF(B.SecuredAmt,0))*100,0)) as decimal(5,2)) [ProvisionSecured%]
,cast((ISNULL((B.ProvUnsecured/NULLIF(B.UnSecuredAmt,0))*100,0))  as decimal(5,2)) [ProvisionUnSecured%]
,cast((ISNULL((B.TotalProvision/NULLIF(B.NetBalance,0))*100,0))  as decimal(5,2)) [ProvisionTotal%]
,ISNULL(y.NetBalance,0) [Prev. Qtr. Balance Outstanding]
,ISNULL(y.SecuredAmt,0)	[Prev. Qtr. Secured Outstanding],
ISNULL(y.UnSecuredAmt,0)	[Prev. Qtr. Unsecured Outstanding],
ISNULL(y.TotalProvision,0)	[Prev. Qtr.Provision Total],
ISNULL(y.Provsecured,0)	[Prev. Qtr.Provision Secured]
,ISNULL(y.ProvUnsecured,0)	[Prev. Qtr. Provision Unsecured]
,ISNULL(y.NetNPA,0)	[Prev. Qtr. Net NPA]
,CASE WHEN ISNULL((ISNULL(B.NetBalance,0) - ISNULL(Y.netBalance,0)),0) < 0 
			then 0 
		ELSE ISNULL((ISNULL(B.NetBalance,0) - ISNULL(Y.netBalance,0)),0) 
	END NPAIncrease
,CASE WHEN ISNULL((B.NetBalance - ISNULL(Y.netBalance,0)),0) >= 0 then 0 
ELSE ISNULL((B.NetBalance - ISNULL(Y.netBalance,0)),0) END NPADecrease
,CASE WHEN ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) < 0 then 0 
ELSE ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) END ProvisionIncrease
,CASE WHEN ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) >= 0 then 0 
ELSE ISNULL((B.TotalProvision - ISNULL(Y.TotalProvision,0)),0) END ProvisionDecrease
,CASE WHEN ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - y.NetNPA),0) < 0 then 0 
ELSE ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - ISNULL(y.NetNPA,0)),0) END NetNPAIncrease
,CASE WHEN ISNULL(((B.NetBalance-ISNULL(B.TotalProvision,0)) - ISNULL(y.NetNPA,0)),0) >= 0 then 0 ELSE ISNULL(((B.NetBalance-B.TotalProvision) - ISNULL(y.NetNPA,0)),0) END NetNPAnDecrease
--into prashant3112
FROM PRO.CustomerCal_Hist A with (nolock)
INNER JOIN PRO.AccountCal_Hist B with (nolock)
	ON A.CustomerEntityID=B.CustomerEntityID	
	AND ISNULL(B.WriteOffAmount,0)=0
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
LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode 
and S.EffectiveToTimeKey=49999
LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999
LEFT JOIN (
select A.CustomerEntityID,sum(NetBalance)NetBalance,sum(SecuredAmt)SecuredAmt
,sum(UnSecuredAmt)UnSecuredAmt,sum(TotalProvision)TotalProvision,sum(Provsecured)Provsecured,
sum(ProvUnsecured)ProvUnsecured,suM(NetBalance)-sum(ISNULL(totalprovision,0))NetNPA
FROM PRO.CustomerCal_Hist A with (nolock)
INNER JOIN PRO.AccountCal_Hist B with (nolock)
	ON A.CustomerEntityID=B.CustomerEntityID 
	WHERE B.EffectiveFromTimeKey <= @LastQtrDateKey AND b.EffectiveToTimeKey >=  @LastQtrDateKey and 
	A.EffectiveFromTimeKey <= @LastQtrDateKey AND A.EffectiveToTimeKey >=  @LastQtrDateKey and
	B.FinalAssetClassAlt_Key>1 group by  A.CustomerEntityID)Y 
	ON A.CustomerEntityID = Y.CustomerEntityID
	LEFT JOIN DPD DPD ON B.accountentityid = DPD.AccountEntityID 
WHERE B.FinalAssetClassAlt_Key>1 
and b.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey
and A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey

GO