SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ACLDataInsertion]
@DAte date = ''
AS

Declare @Timekey int = (select Timekey from Automate_Advances where Date = @Date)

---------------------------------------------------ACL OUTPUT ---------------


 Drop table if exists   #DPD 

select CustomerACID,AccountEntityid,B.SourceSystemCustomerID,B.IntNotServicedDt,@Date as ProcessDate,
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
into #DPD 
FROM PRO.Accountcal_Hist B WITH (NOLOCK)
INNER JOIN PRO.Customercal_Hist A       ON  A.CustomerEntityID=B.CustomerEntityID
WHERE  B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey	 >= @Timekey
AND A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey	 >= @Timekey

OPTION(RECOMPILE)

alter Table #DPD
add DPD_IntService int,DPD_NoCredit int,DPD_Overdrawn int,DPD_Overdue int,DPD_Renewal int,DPD_StockStmt int,DPD_PrincOverdue INT,DPD_IntOverdueSince INT,DPD_OtherOverdueSince INT,DPD_MAX INT


/*---------- CALCULATED ALL DPD---------------------------------------------------------*/

UPDATE A 
SET		 A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,ProcessDate)  ELSE 0 END)			   
             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL  THEN DATEDIFF(DAY,A.LastCrDate,  ProcessDate)       ELSE 0 END)
			 ,A.DPD_Overdrawn=  (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  ProcessDate)     ELSE 0 END)
			 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  ProcessDate)   ELSE 0 END) 
			 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, ProcessDate)      ELSE 0 END)
			 ,A.DPD_StockStmt=  (CASE WHEN  A.StockStDt IS NOT NULL		THEN   DATEDIFF(DAY,A.StockStDt,ProcessDate)       ELSE 0 END)
			 ,A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,ProcessDate)  ELSE 0 END)	 
             ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  ProcessDate)   ELSE 0 END)
			 ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  ProcessDate)  ELSE 0 END)
FROM			#DPD A 

OPTION(RECOMPILE)

/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/

 UPDATE #DPD SET DPD_IntService=0 WHERE isnull(DPD_IntService,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_NoCredit=0 WHERE isnull(DPD_NoCredit,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_Overdrawn=0 WHERE isnull(DPD_Overdrawn,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_Overdue=0 WHERE isnull(DPD_Overdue,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_Renewal=0 WHERE isnull(DPD_Renewal,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_StockStmt=0 WHERE isnull(DPD_StockStmt,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_PrincOverdue=0 WHERE isnull(DPD_PrincOverdue,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_IntOverdueSince=0 WHERE isnull(DPD_IntOverdueSince,0)<0

 OPTION(RECOMPILE)

 UPDATE #DPD SET DPD_OtherOverdueSince=0 WHERE isnull(DPD_OtherOverdueSince,0)<0

 OPTION(RECOMPILE)

/*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/

UPDATE A SET DPD_NoCredit=0 FROM #DPD A 

OPTION(RECOMPILE)

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
			 FROM #DPD A 			
             INNER JOIN Pro.Customercal_hist B       			 
             ON A.SourceSystemCustomerID=B.SourceSystemCustomerID
			 WHERE ( 
			          isnull(DPD_IntService,0)>=isnull(RefPeriodIntService,0)
                   OR isnull(DPD_NoCredit,0)>=isnull(RefPeriodNoCredit,0)
				   OR isnull(DPD_Overdrawn,0)>=isnull(RefPeriodOverDrawn,0)
				   OR isnull(DPD_Overdue,0)>=isnull(RefPeriodOverdue,0)
				   OR isnull(DPD_Renewal,0)>=isnull(RefPeriodReview,0)
                   OR isnull(DPD_StockStmt,0)>=isnull(RefPeriodStkStatement,0)
			      ) AND (isnull(B.FlgProcessing,'N')='N' 
	
			      ) AND   B.EffectiveFromTimeKey <= @Timekey 
				  and B.EffectiveToTimeKey >= @Timekey   
			    
				--and A.RefCustomerID<>'0'
OPTION(RECOMPILE)
	/*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/

		UPDATE A SET A.DPD_Max=0
		 FROM #DPD A 
		 --inner join PRO.CUSTOMERCAL B on A.RefCustomerID=B.RefCustomerID
		 --WHERE  isnull(B.FlgProcessing,'N')='N'  
OPTION(RECOMPILE)


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
			 
		FROM  #DPD A 		
        INNER JOIN PRO.Customercal_Hist C       ON A.SourceSystemCustomerID=C.SourceSystemCustomerID
		WHERE  (isnull(C.FlgProcessing,'N')='N') 
		AND 
		(isnull(A.DPD_IntService,0)>0   OR isnull(A.DPD_Overdrawn,0)>0   OR  Isnull(A.DPD_Overdue,0)>0	 OR isnull(A.DPD_Renewal,0) >0 OR
		isnull(A.DPD_StockStmt,0)>0 OR isnull(DPD_NoCredit,0)>0)
		AND   C.EffectiveFromTimeKey <= @Timekey 
		and C.EffectiveToTimeKey >= @Timekey

OPTION(RECOMPILE)
------------------------------------------------=========================END===========================



IF (select count(*) from ACL_NPA_DATA 
	where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Date in (@Date))) > 0
	BEGIN
	delete from ACL_NPA_DATA where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Date in (@Date))
	END

	INSERT INTO  ACL_NPA_DATA
SELECT 
      convert(nvarchar,GETDATE() , 105) AS  [Generation Date]
	  ,  convert(nvarchar,@Date, 105) Process_Date,
	A.UCIF_ID as UCIC, A.RefCustomerID CustomerID, CustomerName,B.Branchcode,B.CustomerAcid, b.Facilitytype ,b.ProductCode
	,ProductName
	,Balance,DrawingPower	,CurrentLimit,UnserviedInt UnAppliedIntt, B.ReviewDueDt,CreditSinceDt,b.ContiExcessDt,B.StockStDt,DebitSinceDt
	,B.LastCrDate,PreQtrCredit,PrvQtrInt,CurQtrCredit,CurQtrInt,
	--IntNotServicedDt	
	OverdueAmt	,B.OverDueSinceDt	
	,SecurityValue,NetBalance,PrincOutStd	,ApprRV,SecuredAmt,UnSecuredAmt,Provsecured	
	,ProvUnsecured
	,TotalProvision,B.RefPeriodOverdue	,B.RefPeriodOverDrawn	,B.RefPeriodNoCredit,
	B.RefPeriodIntService,B.RefPeriodStkStatement,B.RefPeriodReview,PrincOverdue,	B.PrincOverdueSinceDt,	
	IntOverdue,	B.IntOverdueSinceDt,	OtherOverdue,	B.OtherOverdueSinceDt,DPD_IntService,	DPD_NoCredit,	
	DPD_Overdrawn	,DPD_Overdue,	DPD_Renewal,	DPD_StockStmt,DPD_PrincOverdue	,DPD_IntOverdueSince	
	,DPD_OtherOverdueSince,DPD_Max	,InitialNpaDt,	FinalNpaDt,InitialAssetClassAlt_Key
	,a1.AssetClassShortNameEnum InitialAssetClass
	,FinalAssetClassAlt_Key ,a2.AssetClassShortNameEnum FialAssetClass
	,b.DegReason,b.FlgDeg, b.FlgUpg,NPA_Reason,FLGSECURED As SecuredFlag
	,a.Asset_Norm
	,b.CD
	,pd.NPANorms,b.WriteOffAmount
	,b.ActSegmentCode,ProductSubGroup
	,SourceName
	,ProductGroup
	,PD.SchemeType
	,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else S.AcBuRevisedSegmentCode end AcBuRevisedSegmentCode
,a.DegDate
FROM PRO.CustomerCal_Hist A
	INNER JOIN PRO.ACCOUNTCAL_Hist B
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
	LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode and S.EffectiveToTimeKey = 49999	
LEFT JOIN #DPD  DPD   ON DPD.AccountEntityID=b.AccountEntityID                       
WHERE B.FinalAssetClassAlt_Key>1 
and B.EffectiveFromTimeKey <= @timekey 
and B.EffectiveFromTimeKey >= @Timekey
and A.EffectiveFromTimeKey <= @timekey 
and A.EffectiveFromTimeKey >= @Timekey
	--AND isnull(b.WriteOffAmount,0)=0	--	 where B.FlgUpg='U'

	
IF (select count(1) from ACL_UPG_DATA 
	where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Timekey = @Timekey)) > 0
	BEGIN
	delete from ACL_UPG_DATA where CONVERT(DATE,Process_Date,105) in (select convert(Date,Date,105) from Automate_Advances where Timekey = @Timekey) 
	 END


	INSERT INTO ACL_UPG_DATA
SELECT 
      convert(nvarchar,getdate() , 105) AS  [Generation Date]
	  ,  convert(nvarchar,@Date, 105) Process_Date,
	A.UCIF_ID as UCIC, A.RefCustomerID CustomerID, CustomerName,B.Branchcode,B.CustomerAcid, b.Facilitytype ,b.ProductCode
	,ProductName
	,Balance,DrawingPower	,CurrentLimit,UnserviedInt UnAppliedIntt, B.ReviewDueDt,CreditSinceDt,b.ContiExcessDt,B.StockStDt,DebitSinceDt
	,B.LastCrDate,PreQtrCredit,PrvQtrInt,CurQtrCredit,CurQtrInt,
	--IntNotServicedDt	
	OverdueAmt	,B.OverDueSinceDt	
	,SecurityValue,NetBalance,PrincOutStd	,ApprRV,SecuredAmt,UnSecuredAmt,Provsecured	
	,ProvUnsecured
	,TotalProvision,B.RefPeriodOverdue	,B.RefPeriodOverDrawn	,B.RefPeriodNoCredit,
	B.RefPeriodIntService,B.RefPeriodStkStatement,B.RefPeriodReview,PrincOverdue,	B.PrincOverdueSinceDt,	
	IntOverdue,	B.IntOverdueSinceDt,	OtherOverdue,	B.OtherOverdueSinceDt,DPD_IntService,	DPD_NoCredit,	
	DPD_Overdrawn	,DPD_Overdue,	DPD_Renewal,	DPD_StockStmt,DPD_PrincOverdue	,DPD_IntOverdueSince	
	,DPD_OtherOverdueSince,DPD_Max	,InitialNpaDt,	FinalNpaDt,InitialAssetClassAlt_Key
	,a1.AssetClassShortNameEnum InitialAssetClass
	,FinalAssetClassAlt_Key ,a2.AssetClassShortNameEnum FialAssetClass
	,b.DegReason,b.FlgDeg, b.FlgUpg,NPA_Reason,FLGSECURED As SecuredFlag
	,a.Asset_Norm
	,b.CD
	,pd.NPANorms,b.WriteOffAmount
	,b.ActSegmentCode,ProductSubGroup
	,SourceName
	,ProductGroup
	,PD.SchemeType
	,CASE WHEN SourceName='Ganaseva' THEN 'FI'
		  WHEN SourceName='VisionPlus' THEN 'Credit Card'
		else S.AcBuRevisedSegmentCode end AcBuRevisedSegmentCode
FROM PRO.CustomerCal_Hist A
	INNER JOIN PRO.AccountCal_Hist B
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
	LEFT JOIN DimAcBuSegment S  ON B.ActSegmentCode=S.AcBuSegmentCode
	and S.EffectiveToTimeKey = 49999
	LEFT JOIN #DPD  DPD   ON DPD.AccountEntityID=b.AccountEntityID 
	-- where B.FinalAssetClassAlt_Key>1
	 where B.InitialAssetClassAlt_Key > 1 and B.FinalAssetClassAlt_Key = 1
	 and 
A.EffectiveFromTimeKey <= @Timekey and A.EffectiveToTimeKey >= @Timekey 
and B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @Timekey 

	
GO