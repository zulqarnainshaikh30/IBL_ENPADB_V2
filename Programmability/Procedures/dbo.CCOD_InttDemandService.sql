SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
  
CREATE PROC [dbo].[CCOD_InttDemandService]  
 @date DATE  
AS  
  
  
SET NOCOUNT ON;  
  
--DECLARE @Date As DateTime='2020-04-04'--(Select DATE from NTBL_STGDB.DBO.Automate_Advances where EXT_FLG='Y')  
DECLARE @TimeKey AS INT =(SELECT TimeKey FROM SysDayMatrix WHERE DATE=@DATE)  
  
/* CHECK ALREADY PROCESSED FOR THE DATE */   
IF EXISTS(SELECT 1 FROM curdat.AdvAcDemandDetail where (DemandDate =@Date or RecDate =@Date)  and ACTYPE='CCOD')  
  BEGIN  
  SELECT 'INTEREST SERVICE ALREADY PROCECSSED FOR THE DATE '+convert(nvarchar, @date ,104)  
  RETURN 1  
 END  
  
----  
  
  
/* PREPARE TXNDATA*/  
 DROP TABLE IF EXISTS #AcDailyTxnDetail  
 SELECT Branchcode,CustomerAcID, AccountEntityId,TxnDate,TxnAmount,TxnType,TxnSubType  
 INTO #AcDailyTxnDetail   
 FROM dbo.AcDailyTxnDetail WHERE TXNDATE=@date  
  
   
/* PREPARE DEMAND DATA FOR CURRENT DATE*/  
 DROP TABLE IF EXISTS #DEMAND_DATA  
  SELECT   
       A.[BranchCode]  
      ,A.[AccountEntityID]  
      ,A.TxnSubType [DemandType]  
      ,A.[TxnDate] DemandDate  
      ,DATEADD(dd,1,txndate) [DemandOverDueDate]  
      ,SUM(A.TxnAmount) [DemandAmt]  
      ,CAST(0 AS DECIMAL(16,2)) [RecAmount]  
      ,SUM(A.TxnAmount) [BalanceDemand]  
      ,A.CustomerAcID [RefSystemACID]  
      ,'CCOD' [AcType]  
      ,@TimeKey [EffectiveFromTimeKey]  
      ,49999 [EffectiveToTimeKey]  
      ,'D2K'  [CreatedBy]  
      ,GETDATE() [DateCreated]  
    INTO #DEMAND_DATA  
  FROM #AcDailyTxnDetail A  
   INNER JOIN AdvAcBasicDetail B  
    ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey)  
    AND B.AccountEntityId=A.AccountEntityId  
    INNER JOIN AdvFacCCDetail C  
    ON (c.EffectiveFromTimeKey<=@TimeKey AND c.EffectiveToTimeKey>=@TimeKey)  
    AND C.AccountEntityId=B.AccountEntityId  
   WHERE TxnDate=@Date  
    AND TxnSubType IN('INTEREST')  
    AND TxnType='DEBIT'  
  GROUP BY  A.[BranchCode]  
      ,A.[AccountEntityID]  
      ,A.TxnSubType   
      ,A.[TxnDate]   
      ,txndate  
      ,A.CustomerAcID   
  
  
/* INSERT PREVIOUS BALANCE DEMAND DATA */  
 INSERT INTO #DEMAND_DATA  
      (  
       [BranchCode]  
      ,[AccountEntityID]  
      ,[DemandType]  
      ,[DemandDate]  
      ,[DemandOverDueDate]  
      ,[DemandAmt]  
      ,[RecAmount]  
      ,[BalanceDemand]  
      ,[RefSystemACID]  
      ,[AcType]  
      ,[EffectiveFromTimeKey]  
      ,[EffectiveToTimeKey]  
      ,[CreatedBy]  
      ,[DateCreated])  
 SELECT  
       [BranchCode]  
      ,[AccountEntityID]  
      ,[DemandType]  
      ,[DemandDate]  
      ,[DemandOverDueDate]  
      ,[DemandAmt]  
      ,CAST(0 AS DECIMAL(16,2)) [RecAmount]  
      ,[BalanceDemand]  
      ,[RefSystemACID]  
      ,[AcType]  
      ,[EffectiveFromTimeKey]  
      ,[EffectiveToTimeKey]  
      ,[CreatedBy]  
      ,GETDATE()[DateCreated]  
   FROM [CURDAT].[AdvAcDemandDetail] A  
    WHERE  AcType='CCOD' AND BalanceDemand>0   
    AND (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)  
  
   
/* PREPARING RECOVERY DATA */  
  
  ALTER TABLE #DEMAND_DATA ADD ENTITYKEY INT IDENTITY(1,1)  
  
  DROP TABLE IF EXISTS #RECOVERY_DATA  
  
  ;WITH CTE_DMD  
  AS(SELECT AccountEntityId FROM #DEMAND_DATA GROUP BY AccountEntityId)  
    SELECT A.AccountEntityId,SUM(TXNAMOUNT)  RecAmount   
    INTO #RECOVERY_DATA  
   FROM dbo.AcDailyTxnDetail A  
    INNER JOIN CTE_DMD B  
     ON A.AccountEntityId=B.AccountEntityID  
  WHERE TxnDate=@Date  
   AND TxnSubType IN ('RECOVERY' ,'OTHER CREDIT')  
  GROUP BY A.AccountEntityId  
  
  
/* ADJUSTING INTEREST DEMAND  WITH RECOOVERY */  
  DROP TABLE IF EXISTS #DMD_REC_DATA  
  select A.* --a.AccountEntityId,DemandDate  
   --,a.BalanceDemand, B.RecAmount--,--   
   ,SUM(A.BalanceDemand) OVER (PARTITION BY a.AccountEntityId ORDER BY a.AccountEntityId,DEMANDDATE,ENTITYKEY) DmdRunTotal  
   ,b.RecAmount GrossRec  
   ,CAST(0  AS DECIMAL(18,2)) RecCalc  
   ,CAST(0  AS DECIMAL(18,2))RecAdjusted  
   ,@Date RecDAte  
   ,@Date RecAdjDAte  
   ,ROW_NUMBER() over (order by A.Accountentityid,A.demanddate) RID  
   INTO #DMD_REC_DATA  
  FROM #DEMAND_DATA  a  
   left JOIN #RECOVERY_DATA b  
    ON A.AccountEntityId=b.AccountEntityId  
  ORDER BY AccountEntityId,DemandDate  
  
  /* CALCULATING BALANCE DEMAND AND ADJUSTED RECOVERY */  
  
  
  UPDATE #DMD_REC_DATA SET RecCalc=GrossRec where GrossRec=DmdRunTotal  
  UPDATE #DMD_REC_DATA SET RecCalc=GrossRec-DmdRunTotal where RecCalc=0  
  UPDATE #DMD_REC_DATA SET RecAdjusted =BalanceDemand  WHERE RecCalc>0  
  
  ;WITH CTE_AC  
  AS  
  (SELECT AccountEntityId,MIN(RID) RID FROM #DMD_REC_DATA WHERE RecCalc<0 GROUP BY AccountEntityId)  
    
  UPDATE A  
   SET A.RecAdjusted=BalanceDemand -(RecCalc*-1)  
  FROM #DMD_REC_DATA A  
   INNER JOIN CTE_AC B  
    ON A.AccountEntityId=B.AccountEntityId  
    AND A.RID=B.RID  
   
  UPDATE #DMD_REC_DATA SET BalanceDemand=BalanceDemand-ISNULL(RecAdjusted,0)  
     ,RecAmount=ISNULL(RecAdjusted,0)  
    WHERE ISNULL(RecAdjusted,0)>0  
    
  /* UPDATEING REC DATE AND RECADJ DATE  */  
  UPDATE #DMD_REC_DATA SET RECDATE=NULL WHERE ISNULL(RecAdjusted,0)=0  
  
  UPDATE #DMD_REC_DATA SET RECADJDATE=NULL WHERE ISNULL(BalanceDemand,0)>0  
   
  UPDATE #DMD_REC_DATA SET RECADJDATE=RECDATE WHERE ISNULL(BalanceDemand,0)=0  
  
    
   /* CHANGE EFFECTIVEFFROMTIMEKEY FOR PREVIOUS DATE DEMAND SERVICED DATA */  
  UPDATE  #DMD_REC_DATA SET EffectiveFromTimeKey=@TimeKey WHERE EffectiveFromTimeKey <@TimeKey AND ISNULL(RecAdjusted,0)>0  
  
  /* DELETE PREVISOU DATES UNSERVE DEMAND DATA - NOT REQUIRED ANY CHANGE IN MAIN TABLE*/  
  DELETE #DMD_REC_DATA WHERE EffectiveFromTimeKey <@TimeKey AND ISNULL(RecAdjusted,0)=0  
  
  
/*MERGE DEMAND INTO MAIN  TABLE */  
   
 UPDATE O  
  SET O.EffectiveToTimeKey=@TimeKey-1  
 FROM CURDAT.AdvAcDemandDetail O  
  INNER JOIN #DMD_REC_DATA T  
 ON  O.AccountEntityID=T.AccountEntityID  
  AND O.DemandType=T.DemandType  
  AND O.DemandDate=T.DemandDate  
  AND ISNULL(O.[DemandAmt],0) =ISNULL(T.[DemandAmt],0)  
  AND O.EffectiveToTimeKey=49999  
  AND O.BalanceDemand <>T.BalanceDemand   
   
---------------------------------------------------------------------------------------------------------------  
/* INSERT DATA INTO MAIN TABLE */  
INSERT INTO CURDAT.AdvAcDemandDetail  
           ([BranchCode]  
           ,[AccountEntityID]  
           ,[DemandType]  
           ,[DemandDate]  
           ,[DemandOverDueDate]  
           ,[DemandAmt]  
           ,[RecDate]  
           ,[RecAdjDate]  
           ,[RecAmount]  
           ,[BalanceDemand]  
           ,[RefSystemACID]  
           ,[AcType]  
           ,[EffectiveFromTimeKey]  
           ,[EffectiveToTimeKey]  
           ,[CreatedBy]  
           ,[DateCreated]  
     )  
 SELECT  
     T.[BranchCode]  
           ,T.[AccountEntityID]  
           ,T.[DemandType]  
           ,T.[DemandDate]  
           ,T.[DemandOverDueDate]  
           ,T.[DemandAmt]  
           ,T.[RecDate]  
           ,T.[RecAdjDate]  
           ,T.[RecAmount]  
           ,T.[BalanceDemand]  
           ,T.[RefSystemACID]  
           ,T.[AcType]  
           ,T.[EffectiveFromTimeKey]  
           ,T.[EffectiveToTimeKey]  
           ,T.[CreatedBy]  
           ,T.[DateCreated]  
 FROM #DMD_REC_DATA T  
  WHERE EffectiveToTimeKey=49999  
   AND EffectiveFromTimeKey=@TimeKey  
  
  
/* INSERT RECOVERY DATA */  
INSERT INTO  AdvAcRecoveryDetail  
 (  
   CashRecDate  
   ,BranchCode  
   ,AcType  
   ,CreatedBy  
   ,AccountEntityID  
   ,RecAmt  
   ,RecDate  
   ,DemandDate  
   ,RefSystemACID  
   ,DateCreated  
 )  
SELECT   
    RECDATE CashRecDate  
   ,BranchCode  
   ,AcType  
   ,'D2K' CreatedBy  
   ,AccountEntityID  
   ,RecAmount RecAmt  
   ,RecDate  
   ,DemandDate  
   ,RefSystemACID  
   ,GETDATE() DateCreated  
FROM #DMD_REC_DATA  
WHERE ISNULL(RecAmount,0)>0  
   
  
GO