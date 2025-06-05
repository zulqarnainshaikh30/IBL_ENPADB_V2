SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




/*=========================================
 AUTHER :TRILOKI KHANNA
 CREATE DATE : 27-11-2019
 MODIFY DATE : 07-04-2022
 DESCRIPTION : CALCULATION OF DPD
 --exec  [Pro].[DPD_Calculation]  @timekey=26299
=============================================*/
CREATE PROCEDURE [PRO].[DPD_Calculation] 
@TIMEKEY INT
with recompile
AS
BEGIN
  SET NOCOUNT ON
     BEGIN TRY

DECLARE @ProcessDate DATE =(SELECT Date FROM SysDayMatrix where TimeKey=@TIMEKEY)

UPDATE PRO.AccountCal SET IntNotServicedDt  = NULL   WHERE (IntNotServicedDt='1900-01-01' OR IntNotServicedDt='01/01/1900') 
UPDATE PRO.AccountCal SET LastCrDate        = NULL   WHERE (LastCrDate='1900-01-01' OR LastCrDate='01/01/1900') 
UPDATE PRO.AccountCal SET ContiExcessDt     = NULL   WHERE (ContiExcessDt='1900-01-01' OR ContiExcessDt='01/01/1900') 
UPDATE PRO.AccountCal SET OverDueSinceDt    = NULL   WHERE (OverDueSinceDt='1900-01-01' OR OverDueSinceDt='01/01/1900') 
UPDATE PRO.AccountCal SET ReviewDueDt       = NULL   WHERE (ReviewDueDt='1900-01-01' OR ReviewDueDt='01/01/1900') 
UPDATE PRO.AccountCal SET StockStDt         = NULL   WHERE (StockStDt='1900-01-01' OR StockStDt='01/01/1900') 


/*------------------INITIAL ALL DPD 0 FOR RE-PROCESSING------------------------------- */

UPDATE A SET A.DPD_IntService=0,A.DPD_NoCredit=0,A.DPD_Overdrawn=0,A.DPD_Overdue=0,A.DPD_Renewal=0,
             A.DPD_StockStmt=0,DPD_PrincOverdue=0,DPD_IntOverdueSince=0,DPD_OtherOverdueSince=0
FROM PRO.AccountCal A


/*---------- CALCULATED ALL DPD---------------------------------------------------------*/
if @TIMEKEY >26267
begin
UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL AND A.FacilityType in ('CC','OD')
                                       THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)+1  ELSE 0 END)			   
             ,A.DPD_NoCredit = CASE    WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>=90)
									   THEN (CASE WHEN  A.LastCrDate IS NOT NULL 
									   THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)+0
											ELSE 0  
											
											END)
									ELSE 0 END

			 ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END) 
			 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END) 
			 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)  +1    ELSE 0 END)
		--	 ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate) +1     ELSE 0 END)
		    ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL THEN   DateDiff(Day,DATEADD(month,3,A.StockStDt),@ProcessDate)+1 ELSE 0 END)-- DPD Counter will be started on 91st day and RefPeroid changed from 181 to 90 --changes done by triloki on 04-04-2022 as Discussed with Kandpal sir and Shishir sir
FROM PRO.AccountCal A 

end
else
begin

UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL  AND A.FacilityType in ('CC','OD')
THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)  ELSE 0 END)			   
             ,A.DPD_NoCredit = CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>=90)
											THEN (CASE WHEN  A.LastCrDate IS NOT NULL 
											THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate) 
											ELSE 0 
										
											 END)
									ELSE 0 END

			 ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END) 
			 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)  ELSE 0 END) 
			 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)      ELSE 0 END)
			 ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate)     ELSE 0 END)
FROM PRO.AccountCal A 
end


if @TIMEKEY >26267
begin

UPDATE A SET  A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,@ProcessDate)+1  ELSE 0 END)			   
             ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  @ProcessDate)+1       ELSE 0 END)
			 ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  @ProcessDate)+1  ELSE 0 END) 
FROM PRO.AccountCal A 

end
else
begin

UPDATE A SET  A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,@ProcessDate)  ELSE 0 END)			   
             ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  @ProcessDate)       ELSE 0 END)
			 ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  @ProcessDate)  ELSE 0 END) 
FROM PRO.AccountCal A 

end

/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/

 UPDATE PRO.AccountCal SET DPD_IntService=0 WHERE isnull(DPD_IntService,0)<0
 UPDATE PRO.AccountCal SET DPD_NoCredit=0 WHERE isnull(DPD_NoCredit,0)<0
 UPDATE PRO.AccountCal SET DPD_Overdrawn=0 WHERE isnull(DPD_Overdrawn,0)<0
 UPDATE PRO.AccountCal SET DPD_Overdue=0 WHERE isnull(DPD_Overdue,0)<0
 UPDATE PRO.AccountCal SET DPD_Renewal=0 WHERE isnull(DPD_Renewal,0)<0
 UPDATE PRO.AccountCal SET DPD_StockStmt=0 WHERE isnull(DPD_StockStmt,0)<0
 UPDATE PRO.AccountCal SET DPD_PrincOverdue=0 WHERE isnull(DPD_PrincOverdue,0)<0
 UPDATE PRO.AccountCal SET DPD_IntOverdueSince=0 WHERE isnull(DPD_IntOverdueSince,0)<0
 UPDATE PRO.AccountCal SET DPD_OtherOverdueSince=0 WHERE isnull(DPD_OtherOverdueSince,0)<0

 
--- As per Bank Mail Dated 25/07/2022 DPD for credit balance a/c Modification Done By Triloki Khanna----

update a set DPD_IntService=0,DPD_NoCredit=0,DPD_Overdrawn=0,DPD_Overdue=0,DPD_Renewal=0,
DPD_StockStmt=0,DPD_PrincOverdue=0,DPD_IntOverdueSince=0,DPD_OtherOverdueSince=0
 from pro.ACCOUNTCAL A
inner join DimProduct B
on A.ProductCode=b.ProductCode
inner join AdvAcBalanceDetail C
on A.AccountEntityId=C.AccountEntityId
where B.SchemeType='CAA'
and isnull(a.balance,0)=0
and isnull(c.SignBalance,0)<0
 and B.EffectiveFromTimeKey <= @Timekey and B.EffectiveToTimeKey >= @TIMEkey 
 and C.EffectiveFromTimeKey <= @Timekey and C.EffectiveToTimeKey >= @TIMEkey
 and A.DebitSinceDt IS NULL

--------/* RESTR WORK */

;WITH CTE_FIN_DPD
AS(
		SELECT AccountEntityID,DPD_IntService DPD FROM PRO.ACCOUNTCAL	WHERE ISNULL(DPD_IntService,0)>0
		UNION ALL SELECT AccountEntityID,DPD_NoCredit   DPD FROM PRO.ACCOUNTCAL	WHERE ISNULL(DPD_NoCredit,0)>0
		UNION ALL SELECT AccountEntityID,DPD_Overdrawn  DPD FROM PRO.ACCOUNTCAL	WHERE ISNULL(DPD_Overdrawn,0)>0
		UNION ALL SELECT AccountEntityID,DPD_Overdue	  DPD FROM PRO.ACCOUNTCAL	WHERE ISNULL(DPD_Overdue,0)>0
)

UPDATE B
	SET B.DPD_MaxFin=A.DPD_MaxFin
FROM  (SELECT AccountEntityID, MAX(DPD) DPD_MaxFin FROM CTE_FIN_DPD 
		GROUP BY AccountEntityID
		)a 
	INNER JOIN PRO.AdvAcRestructureCal B
		ON A.AccountEntityID =B.AccountEntityId


;WITH CTE_NONFIN_DPD
AS(
		SELECT AccountEntityID,DPD_StockStmt DPD FROM PRO.ACCOUNTCAL	WHERE ISNULL(DPD_StockStmt,0)>0
		UNION ALL SELECT AccountEntityID,DPD_Renewal	  DPD FROM PRO.ACCOUNTCAL	WHERE ISNULL(DPD_Renewal,0)>0
)

UPDATE B
	SET B.DPD_MaxNonFin=A.DPD_MaxNonFin
FROM  (SELECT AccountEntityID, MAX(DPD) DPD_MaxNonFin FROM CTE_NONFIN_DPD 
		GROUP BY AccountEntityID
		)a 
	INNER JOIN PRO.AdvAcRestructureCal B
		ON A.AccountEntityID =B.AccountEntityId

	update PRO.AdvAcRestructureCal set DPD_MaxNonFin=0 where DPD_MaxNonFin is null
	update PRO.AdvAcRestructureCal set DPD_MaxFin=0    where DPD_MaxNonFin is null
/* END OF RETR */



UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='Y',ERRORDATE=NULL,ERRORDESCRIPTION=NULL,COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='DPD_Calculation'

 -----------------Added for DashBoard 04-03-2021
Update BANDAUDITSTATUS set CompletedCount=CompletedCount+1 where BandName='ASSET CLASSIFICATION'

END TRY
BEGIN  CATCH
	
	UPDATE PRO.ACLRUNNINGPROCESSSTATUS 
	SET COMPLETED='N',ERRORDATE=GETDATE(),ERRORDESCRIPTION=ERROR_MESSAGE(),COUNT=ISNULL(COUNT,0)+1
	WHERE RUNNINGPROCESSNAME='DPD_Calculation'
END CATCH
  SET NOCOUNT OFF
END














GO