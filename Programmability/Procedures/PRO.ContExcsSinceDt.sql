SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [PRO].[ContExcsSinceDt]  
AS  
BEGIN  
  
DECLARE  @vEffectivefrom  Int SET @vEffectiveFrom=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')  
DECLARE @TimeKey  Int SET @TimeKey=(SELECT TimeKey FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')  
DECLARE @DATE AS DATE =(SELECT Date FROM [dbo].Automate_Advances WHERE EXT_FLG='Y')  
if @TimeKey=26267  
begin  
 select 'cont.excess skipped'  
end  
else  
begin  
IF OBJECT_ID('TEMPDB..#ContExcsSinceDtAccountCal') IS NOT NULL  
   DROP TABLE #ContExcsSinceDtAccountCal  
  
 SELECT  CustomerAcID INTO #ContExcsSinceDtAccountCal  
 FROM DIMBRANCH DB  
 INNER JOIN DBO.AdvAcBasicDetail ACBD  ON (ACBD.EffectiveFromTimeKey<=@TimeKey AND ACBD.EffectiveToTimeKey>=@TimeKey)  
           AND DB.EffectiveFromTimeKey<=@Timekey AND DB.EffectiveToTimeKey>=@Timekey  
           AND DB.BranchCode=ACBD.BranchCode  
 INNER JOIN DBO.ADVACBALANCEDETAIL AB ON (AB.EffectiveFromTimeKey<=@TimeKey AND AB.EffectiveToTimeKey>=@TimeKey)  
           AND  AB.AccountEntityId=ACBD.AccountEntityId  
 INNER   JOIN DBO.AdvFacCCDetail CC ON (CC.EffectiveFromTimeKey<=@TimeKey AND CC.EffectiveToTimeKey>=@TimeKey)  
           AND  CC.AccountEntityId=ACBD.AccountEntityId  
 INNER JOIN DBO.AdvAcFinancialDetail AFD ON (AFD.EffectiveFromTimeKey<=@TimeKey AND AFD.EffectiveToTimeKey>=@TimeKey)  
           AND  AFD.AccountEntityId=ACBD.AccountEntityId  
  WHERE  ISNULL(Balance,0)>ISNULL(ACBD.CurrentLimit,0)

   --WHERE  ISNULL(Balance,0)>ISNULL(ACBD.CurrentLimit,0) --ADDED BY PRASHANT ---13122023--------------
	
  AND ACBD.SourceAlt_Key =1 --- ONLY FOR FINALCE TO CHECK CC ACCOUNT CONT EXCESS DATE  
  
  EXCEPT  
   SELECT CustomerAcID FROM Pro.ContExcsSinceDtAccountCal where Effectivetotimekey=49999  
  
   
   INSERT INTO Pro.ContExcsSinceDtAccountCal  
   (  
     CustomerAcID  
  ,AccountEntityId  
  ,SanctionAmt  
  ,SanctionDt  
  ,Balance  
  ,DrawingPower  
  ,ContExcsSinceDt  
  ,EffectiveFromTimeKey  
  ,EffectiveToTimeKey  
   )  
SELECT   
  
 ACBD.CustomerAcID AS CustomerAcID  
,ACBD.AccountEntityId AS AccountEntityId  
,ACBD.CurrentLimit AS SanctionAmt  
,ACBD.CurrentLimitDt AS  SanctionDt  
,AB.Balance AS Balance  
,AFD.DrawingPower  AS DrawingPower  
,@DATE AS ContExcsSinceDt  
,@TimeKey AS EffectiveFromTimeKey  
,49999 AS  EffectiveToTimeKey  
FROM #ContExcsSinceDtAccountCal D  
 INNER JOIN DBO.AdvAcBasicDetail ACBD  ON (ACBD.EffectiveFromTimeKey<=@TimeKey AND ACBD.EffectiveToTimeKey>=@TimeKey)  
                                        AND  D.CustomerAcID=ACBD.CustomerAcID  
INNER JOIN DBO.ADVACBALANCEDETAIL AB ON (AB.EffectiveFromTimeKey<=@TimeKey AND AB.EffectiveToTimeKey>=@TimeKey)  
                AND  AB.AccountEntityId=ACBD.AccountEntityId  
INNER   JOIN DBO.AdvFacCCDetail CC ON (CC.EffectiveFromTimeKey<=@TimeKey AND CC.EffectiveToTimeKey>=@TimeKey)  
          AND  CC.AccountEntityId=ACBD.AccountEntityId  
INNER JOIN DBO.AdvAcFinancialDetail AFD ON (AFD.EffectiveFromTimeKey<=@TimeKey AND AFD.EffectiveToTimeKey>=@TimeKey)  
          AND  AFD.AccountEntityId=ACBD.AccountEntityId  
  
--WHERE  ISNULL(Balance,0)>(CASE WHEN  ISNULL(DrawingPower,0)<ISNULL(ACBD.CurrentLimit,0) THEN ISNULL(DrawingPower,0) ELSE ISNULL(ACBD.CurrentLimit,0) END )  
  WHERE  ISNULL(Balance,0)>ISNULL(ACBD.CurrentLimit,0) --ADDED BY PRASHANT ---13122023--------------
	
 AND ACBD.SourceAlt_Key =1 --- ONLY FOR FINALCE TO CHECK CC ACCOUNT CONT EXCESS DATE  
  
 IF OBJECT_ID('TEMPDB..#ContExcsSinceDtAccountCalEXP') IS NOT NULL  
   DROP TABLE #ContExcsSinceDtAccountCalEXP  
  
  
SELECT  CustomerAcID INTO #ContExcsSinceDtAccountCalEXP  
 FROM DIMBRANCH DB  
 INNER JOIN DBO.AdvAcBasicDetail ACBD  ON (ACBD.EffectiveFromTimeKey<=@TimeKey AND ACBD.EffectiveToTimeKey>=@TimeKey)  
           AND DB.EffectiveFromTimeKey<=@Timekey AND DB.EffectiveToTimeKey>=@Timekey  
           AND DB.BranchCode=ACBD.BranchCode  
 INNER JOIN DBO.ADVACBALANCEDETAIL AB ON (AB.EffectiveFromTimeKey<=@TimeKey AND AB.EffectiveToTimeKey>=@TimeKey)  
           AND  AB.AccountEntityId=ACBD.AccountEntityId  
 INNER   JOIN DBO.AdvFacCCDetail CC ON (CC.EffectiveFromTimeKey<=@TimeKey AND CC.EffectiveToTimeKey>=@TimeKey)  
           AND  CC.AccountEntityId=ACBD.AccountEntityId  
 INNER JOIN DBO.AdvAcFinancialDetail AFD ON (AFD.EffectiveFromTimeKey<=@TimeKey AND AFD.EffectiveToTimeKey>=@TimeKey)  
           AND  AFD.AccountEntityId=ACBD.AccountEntityId  
  --WHERE  ISNULL(Balance,0)>(CASE WHEN  ISNULL(DrawingPower,0)<ISNULL(ACBD.CurrentLimit,0) THEN ISNULL(DrawingPower,0) ELSE ISNULL(ACBD.CurrentLimit,0) END )  
    WHERE  ISNULL(Balance,0)>ISNULL(ACBD.CurrentLimit,0) --ADDED BY PRASHANT ---13122023--------------
	AND ACBD.SourceAlt_Key =1 --- ONLY FOR FINALCE TO CHECK CC ACCOUNT CONT EXCESS DATE  
  
  
--/*------EXPIRE DATA FOR ---------------------*/  
  
UPDATE A SET A.EffectiveToTimekey=@TimeKey-1  
FROM Pro.ContExcsSinceDtAccountCal A LEFT OUTER JOIN    
(  
select   A.CustomerAcID  from Pro.ContExcsSinceDtAccountCal a inner join #ContExcsSinceDtAccountCalEXP b  
 on a.CustomerAcID=b.CustomerAcID   
) C   
ON A.CustomerAcID=C.CustomerAcID  
WHERE C.CustomerAcID IS NULL AND A.EffectiveToTimekey=49999  
  
 DROP TABLE #ContExcsSinceDtAccountCal  
 DROP TABLE #ContExcsSinceDtAccountCalEXP  
   
END  
end  
  
  
GO