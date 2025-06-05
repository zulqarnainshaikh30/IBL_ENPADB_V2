SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ACLReport_HistData]
@Timekey int
AS
BEGIn

--DECLARE @Timekey int = 
--(26299)

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

select  convert(nvarchar,@Date , 105) AS  [Report date] 
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
,ActSegmentCode as [Seg Code]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuSegmentDescription end as [Segment Description]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuRevisedSegmentCode end as [Business Segment]
,DPD_Max as [Account DPD]
,FinalNpaDt as [NPA Date]
,Balance as [Outstanding]
,NetBalance as [Principal Outstanding]
,DrawingPower as [Drawing Power]
,CurrentLimit as [Sanction Limit]
,CASE WHEN SourceName = 'Finacle' AND SchemeType ='ODA' THEN (
		CASE WHEN (ISNULL(b.Balance,0) - (	CASE WHEN ISNULL(b.DrawingPower,0)<ISNULL(b.CurrentLimit,0) 
											THEN			ISNULL(b.DrawingPower,0) 
											ELSE ISNULL(b.CurrentLimit,0)  
											END 
										)
				  )<=0
		THEN	0	 
		ELSE  
		ISNULL(b.Balance,0) - (	CASE WHEN ISNULL(b.DrawingPower,0)<ISNULL(b.CurrentLimit,0) 
											THEN			ISNULL(b.DrawingPower,0) 
											ELSE ISNULL(b.CurrentLimit,0)  
											END 
										)
END) ELSE 0 END
 [OverDrawn Amount]
,DPD_Overdrawn 
,B.ContiExcessDt as [Limit/DP Overdrawn Date]
,B.ReviewDueDt as [Limit Expiry Date]
,DPD_Renewal as [DPD_Limit Expiry]
,B.StockStDt as [Stock Statement valuation date]
,DPD_StockStmt as [DPD_Stock Statement expiry]
,DebitSinceDt as [Debit Balance Since Date]
,B.LastCrDate as [Last Credit Date]
,DPD_NoCredit as [DPD_No Credit]
,CurQtrCredit as [Current quarter credit]
,CurQtrInt as [Current quarter interest]
,(CASE WHEN (CurQtrInt -CurQtrCredit) < 0 then 0 else(CurQtrInt -CurQtrCredit) END)
[Interest Not Serviced]
,DPD_IntService as [DPD_out of order]
,B.IntNotServicedDt [CC/OD Interest Service]
,OverdueAmt [Overdue Amount]
,B.OverDueSinceDt [Overdue Date]
,DPD_Overdue
,PrincOverdue [Principal Overdue]
,B.PrincOverdueSinceDt [Principal Overdue Date]
,DPD_PrincOverdue [DPD_Principal Overdue]
,IntOverdue as [Interest Overdue]
,B.IntOverdueSinceDt as [Interest Overdue Date]
,DPD_IntOverdueSince as [DPD_Interest Overdue]
,OtherOverdue as [Other OverDue]
,B.OtherOverdueSinceDt as [Other OverDue Date]
,DPD_OtherOverdueSince as  [DPD_Other Overdue]
,(CASE WHEN SchemeType = 'FBA' then OverdueAmt else 0 END) [Bill/PC Overdue Amount]
,'' [Overdue Bill/PC ID]
,(CASE WHEN SchemeType = 'FBA' then B.OverDueSinceDt else '' END) [Bill/PC Overdue Date]
,(CASE WHEN SchemeType = 'FBA' then DPD_Overdue else 0 END) [DPD Bill/PC]
,a2.AssetClassName as [Asset Classification]
,REPLACE(isnull(A.DegReason,b.NPA_Reason),',','') as [Degrade Reason]
,b.REFPERIODOVERDUE as [NPA Norms]

FROM PRO.CustomerCal_Hist A with (nolock)
INNER JOIN PRO.ACCOUNTCAL_Hist B with (nolock)
	ON A.CustomerEntityID=B.CustomerEntityID
	and isnull(b.WriteOffAmount,0)=0
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
and S.EffectiveToTimeKey = 49999
LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey = 49999
LEFT JOIN DPD DPD ON B.accountentityid = DPD.AccountEntityID
	WHERE  B.FinalAssetClassAlt_Key > 1
	and b.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey
and A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey


END 

GO