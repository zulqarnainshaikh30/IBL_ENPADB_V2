SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Proc [dbo].[TWO_Report_Postmoc]
as

begin

DEclare @Timekey int = 26298

DECLARE @Date date = 
(select Date from Automate_Advances where Timekey = @Timekey)

DECLARE @LastQtrDateKey INT = (select LastQtrDateKey from sysdaymatrix where timekey IN (@Timekey))
DECLARE @CurQtrDate Date = (select CurQtrDate from SysDayMatrix  where Timekey in (@timekey))


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
,REPLACE(BranchName,',','') as [Branch Name]
,B.CustomerAcID as [Account No.]
,SourceName as [Source System]
--,B.FacilityType as [Facility]
,SchemeType as [Scheme Type]
,B.ProductCode AS [Scheme Code]
,REPLACE(ProductName,',','') as [Scheme Description]
,ActSegmentCode as [Seg Code]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuSegmentDescription end [Segment Description]
--,CASE WHEN SourceName='Ganaseva' THEN 'FI'
--		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
--		else AcBuRevisedSegmentCode end [Business Segment]
,DPD_Max as [Account DPD]
--,FinalNpaDt as [NPA Date]
,Balance AS [Outstanding]
--,ISNULL(PrincOutStd,0) as [Principal Outstanding]
--,case when  ISNULL(PrincOutStd,0) < 0 then 0 else isnull(PrincOutStd,0) end as [Principal Outstanding]
--,a2.SrcSysClassCode as [Asset Classification]
--,zz.AssetClassCode as	[Soirce System Status]
--,ISNULL(IntOverdue,0)		[interest Dues]
----,ISNULL(penal_due,0)	
--,'' [Penal Dues]
--,ISNULL(OtherOverdue,0)			[Other Dues]
--,(ISNULL(int_receivable_adv,0) + ISNULL(Accrued_interest,0)) [interest accured but not due]
--,ISNULL(penal_int_receivable,0) [penal accured but not due]
--,ISNULL(Balance_INT,0) [Credit Card interest Outstanding]
--,ISNULL(Balance_FEES,0) [Credit Card other charges]
--,ISNULL(Balance_GST,0) [Credit Card GST/ST Outstanding]
--,ISNULL(Interest_DividendDueAmount,0) [Interest/Dividend on Bond/Debentures]

,ActSegmentCode as [Account Segment Code]
,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuSegmentDescription end [Account Segment Description]
		,B.FacilityType as [Facility]
		,ProductGroup as [Nature of Facility]
		,ISNULL(EF.Amount,0) as [Opening Balance]
		,(CASE WHEN ISNULL(EF.Amount,0) = 0 THEN  ISNULL(B.PrincOutStd,0)  ELSE 0 END) as [Addition]
		,(Case when ISNULL(EF.Amount,0) > 0 THEN 
							(CASE WHEN ISNULL(B.PrincOutStd,0) - ISNULL(EF.Amount,0) < 0 
							THEN 0 
							ELSE ISNULL(B.PrincOutStd,0) - ISNULL(B.WriteOffAmount,0) 	END)						
							ELSE 0 END) [Increase In Balance]
		,'' as [Cash Recovery]		
		,'' [Recovery from NPA Sale]
		,0 as [Write-off]
		,ISNULL(B.PrincOutStd,0) [Closing Balance POS]	---As requested by Sitaram sir 14/10/2021
		,(Case when ISNULL(B.WriteOffAmount,0) - ISNULL(B.PrincOutStd,0) < 0 THEN 0 ELSE ISNULL(B.WriteOffAmount,0) - ISNULL(B.PrincOutStd,0) END) [Reduction in Balance]
		,@CurQtrDate as [Reporting_Period]
		,ISNULL(DPD.DPD_MAX,0)[DPD] ---As requested by Sitaram sir
		,FinalNpaDt  as [NPA Date]---As requested by Sitaram sir
		,a2.AssetClassName as [Asset Classification]
		,CASE WHEN MOC.TwoDate IS NULL THEN EF.StatusDate ELSE MOC.TwoDate END as [Date of Technical Write-off]
		,SourceName as [Host System]
		,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else AcBuRevisedSegmentCode end [Business Segment]
		INTO #TEMP4
		--DROP TABLE #TEMP4
FROM PRO.CUSTOMERCAL_Hist A with (nolock)
INNER JOIN PRO.ACCOUNTCAL_Hist B with (nolock)
	ON A.CustomerEntityID=B.CustomerEntityID
	and isnull(b.WriteOffAmount,0)>0
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
LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and S.EffectiveToTimeKey=49999
LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999
LEFT JOIN dbo.AdvAcOtherFinancialDetail Y ON Y.AccountEntityID = B.AccountEntityID and Y.EffectiveToTimeKey = 49999
LEFT JOIN dbo.AdvCreditCardBalanceDetail YZ ON YZ.AccountEntityID = B.AccountEntityID and YZ.EffectiveToTimeKey = 49999
LEFT JOIN InvestmentFinancialDetail Z ON Z.RefInvID = B.CustomerAcID and Z.EffectiveToTimeKey = 49999
LEFT JOIN MOC_ChangeDetails MOC ON   MOC.AccountEntityID=B.AccountEntityID AND MOC.EffectiveFromTimeKey <=@Timekey AND MOC.EffectiveToTimeKey >=@Timekey
LEFT JOIN ExceptionFinalStatusType EF ON  EF.ACID=B.CUSTOMERACID AND EF.EffectiveFromTimeKey <=@Timekey AND EF.EffectiveToTimeKey >=@Timekey
LEFT JOIN (select distinct CustomerAcid,AssetClassCode 
from [ENBD_STGDB].dbo.ACCOUNT_ALL_SOURCE_SYSTEM) ZZ
ON B.CustomerAcID = ZZ.CustomerAcID
LEFT JOIN DPD DPD ON B.accountentityid = DPD.AccountEntityID
where  B.FinalAssetClassAlt_Key>1  
and A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey
and B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey


--UNION
--select  convert(nvarchar,@Date , 105) AS  [Report Date] 
--,A.UCIF_ID as UCIC
--,A.RefCustomerID as [CIF ID]
--,REPLACE(CustomerName,',','') as [Borrower Name]
--,B.BranchCode as [Branch Code]
--,REPLACE(BranchName,',','') as [Branch Name]
--,B.CustomerAcID as [Account No.]
--,SourceName as [Source System]
--,B.FacilityType as [Facility]
--,SchemeType as [Scheme Type]
--,B.ProductCode AS [Scheme Code]
--,REPLACE(ProductName,',','') as [Scheme Description]
--,ActSegmentCode as [Seg Code]
--,CASE WHEN SourceName='Ganaseva' THEN 'FI'
--		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
--		else AcBuSegmentDescription end [Segment Description]
--,CASE WHEN SourceName='Ganaseva' THEN 'FI'
--		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
--		else AcBuRevisedSegmentCode end [Business Segment]
--,DPD_Max as [Account DPD]
--,FinalNpaDt as [NPA Date]
--,Balance AS [Outstanding]
--,ISNULL(PrincOutStd,0) as [Principal Outstanding]
--,zz.AssetClassCode as [Asset Classification]
--,a2.SrcSysClassCode as	[Soirce System Status]
--,ISNULL(IntOverdue,0)		[interest Dues]
----,ISNULL(penal_due,0)	
--,'' [Penal Dues]
--,ISNULL(OtherOverdue,0)			[Other Dues]
--,(ISNULL(int_receivable_adv,0) + ISNULL(Accrued_interest,0)) [interest accured but not due]
--,ISNULL(penal_int_receivable,0) [penal accured but not due]
--,ISNULL(Balance_INT,0) [Credit Card interest Outstanding]
--,ISNULL(Balance_FEES,0) [Credit Card other charges]
--,ISNULL(Balance_GST,0) [Credit Card GST/ST Outstanding]
--,ISNULL(Interest_DividendDueAmount,0) [Interest/Dividend on Bond/Debentures]
--FROM PRO.CUSTOMERCAL A with (nolock)
--INNER JOIN PRO.ACCOUNTCAL B with (nolock)
--	ON A.CustomerEntityID=B.CustomerEntityID
--LEFT JOIN DIMSOURCEDB src
--	on b.SourceAlt_Key =src.SourceAlt_Key	
--LEFT JOIN DIMPRODUCT PD
--	ON PD.EffectiveToTimeKey=49999
--	AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
--left join DimAssetClass a1
--	on a1.EffectiveToTimeKey=49999
--	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
--left join DimAssetClass a2
--	on a2.EffectiveToTimeKey=49999
--	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
--LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and S.EffectiveToTimeKey=49999
--LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999
--LEFT JOIN dbo.AdvAcOtherFinancialDetail Y ON Y.AccountEntityID = B.AccountEntityID and Y.EffectiveToTimeKey = 49999
--INNER JOIN dbo.AdvCreditCardBalanceDetail YZ ON YZ.AccountEntityID = B.AccountEntityID and YZ.EffectiveToTimeKey = 49999
--LEFT JOIN InvestmentFinancialDetail Z ON Z.RefInvID = B.CustomerAcID and Z.EffectiveToTimeKey = 49999
--LEFT JOIN (select distinct CustomerAcid,AssetClassCode from [ENBD_STGDB].dbo.ACCOUNT_ALL_SOURCE_SYSTEM) ZZ ON B.CustomerAcID = ZZ.CustomerAcID
--where  B.FinalAssetClassAlt_Key>1  
--and (ISNULL(Balance_INT,0) > 0 OR 
--ISNULL(Balance_FEES,0) > 0 OR
--ISNULL(Balance_GST,0) > 0)
--UNION
--select  convert(nvarchar,@Date , 105) AS  [Report Date] 
--,A.UCIF_ID as UCIC
--,A.RefCustomerID as [CIF ID]
--,REPLACE(CustomerName,',','') as [Borrower Name]
--,B.BranchCode as [Branch Code]
--,REPLACE(BranchName,',','') as [Branch Name]
--,B.CustomerAcID as [Account No.]
--,SourceName as [Source System]
--,B.FacilityType as [Facility]
--,SchemeType as [Scheme Type]
--,B.ProductCode AS [Scheme Code]
--,REPLACE(ProductName,',','') as [Scheme Description]
--,ActSegmentCode as [Seg Code]
--,CASE WHEN SourceName='Ganaseva' THEN 'FI'
--		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
--		else AcBuSegmentDescription end [Segment Description]
--,CASE WHEN SourceName='Ganaseva' THEN 'FI'
--		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
--		else AcBuRevisedSegmentCode end [Business Segment]
--,DPD_Max as [Account DPD]
--,FinalNpaDt as [NPA Date]
--,Balance AS [Outstanding]
--,ISNULL(PrincOutStd,0) as [Principal Outstanding]
--,zz.AssetClassCode as [Asset Classification]
--,a2.SrcSysClassCode as	[Soirce System Status]
--,ISNULL(IntOverdue,0)		[interest Dues]
----,ISNULL(penal_due,0)	
--,'' [Penal Dues]
--,ISNULL(OtherOverdue,0)			[Other Dues]
--,(ISNULL(int_receivable_adv,0) + ISNULL(Accrued_interest,0)) [interest accured but not due]
--,ISNULL(penal_int_receivable,0) [penal accured but not due]
--,ISNULL(Balance_INT,0) [Credit Card interest Outstanding]
--,ISNULL(Balance_FEES,0) [Credit Card other charges]
--,ISNULL(Balance_GST,0) [Credit Card GST/ST Outstanding]
--,ISNULL(Interest_DividendDueAmount,0) [Interest/Dividend on Bond/Debentures]
--FROM PRO.CUSTOMERCAL A with (nolock)
--INNER JOIN PRO.ACCOUNTCAL B with (nolock)
--	ON A.CustomerEntityID=B.CustomerEntityID
--LEFT JOIN DIMSOURCEDB src
--	on b.SourceAlt_Key =src.SourceAlt_Key	
--LEFT JOIN DIMPRODUCT PD
--	ON PD.EffectiveToTimeKey=49999
--	AND PD.PRODUCTALT_KEY=b.PRODUCTALT_KEY
--left join DimAssetClass a1
--	on a1.EffectiveToTimeKey=49999
--	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
--left join DimAssetClass a2
--	on a2.EffectiveToTimeKey=49999
--	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key
--LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and S.EffectiveToTimeKey=49999
--LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey=49999
--LEFT JOIN dbo.AdvAcOtherFinancialDetail Y ON Y.AccountEntityID = B.AccountEntityID and Y.EffectiveToTimeKey = 49999
--LEFT JOIN dbo.AdvCreditCardBalanceDetail YZ ON YZ.AccountEntityID = B.AccountEntityID and YZ.EffectiveToTimeKey = 49999
--INNER JOIN InvestmentFinancialDetail Z ON Z.RefInvID = B.CustomerAcID and Z.EffectiveToTimeKey = 49999
--LEFT JOIN (select distinct CustomerAcid,AssetClassCode from [ENBD_STGDB].dbo.ACCOUNT_ALL_SOURCE_SYSTEM) ZZ ON B.CustomerAcID = ZZ.CustomerAcID
--where  B.FinalAssetClassAlt_Key>1  
--and ISNULL(Interest_DividendDueAmount,0) > 0 




--drop table #TEMP4

SELECT [Report Date],UCIC,[CIF ID],[Borrower Name] AS CustomerName,[Branch Code],[Branch Name],[Account No.],
 [Scheme Type],[Scheme Code],[Scheme Description],[Account Segment Code] ,[Account Segment Description], 
 Facility,[Nature of Facility],[Opening Balance],Addition,[Increase In Balance],[Cash Recovery],[Recovery from NPA Sale],
 [Write-off],[Closing Balance POS],[Reduction in Balance],Reporting_Period,DPD,[NPA Date],[Asset Classification],[Date of Technical Write-off],
 [Host System],[Business Segment]
 FROM #TEMP4
 --SELECT 21349662724.95-20061874666.10
 --select sum([Closing Balance POS]) from #TEMP4 WHERE Addition =0

 --select count(*) from #TEMP4 WHERE Addition =0

 --SELECT SUM(TwoAmount) FROM MOC_ChangeDetails
 --WHERE TwoAmount >0

 end
GO