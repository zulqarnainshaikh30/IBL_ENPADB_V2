SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*===========================================
AUTHER : TRILOKI KHANN
CREATE DATE : 27-11-2019
MODIFY DATE : 27-11-2019
DESCRIPTION : CALCULATE PREV QTR AND CURRENT QTR CREDIT AND PREV AND CURRENT QTR INT
--EXEC [PRO].[UpdateCADCADURefBalRecovery] 25490
===================================================*/
CREATE PROCEDURE [PRO].[UpdateCADCADURefBalRecovery]
@TimeKey INT
with recompile
AS
BEGIN
	SET NOCOUNT ON
         BEGIN TRY
	update pro.AccountCal set PreQtrCredit=0	,PrvQtrInt=0	,CurQtrCredit=0	,CurQtrInt=0

Declare  @QtrDefinition Varchar(5),@Refdate Date

SELECT @Refdate=Date FROM SysDayMatrix
WHERE TimeKey=@TimeKey


Declare  @StartDt DATE
		,@EndDt DATE
SELECT  @StartDt=DATEADD(day,-90,DATE),
            @EndDt=Date
	      	FROM SysDayMAtrix
	WHERE TimeKEy=@TimeKey




IF OBJECT_ID('Tempdb..#AcDailyTxnDetail') IS NOT NULL
DROP TABLE #AcDailyTxnDetail

SELECT A.*
INTO #AcDailyTxnDetail 
FROM AcDailyTxnDetail A
WHERE TxnType IN ('CREDIT','DEBIT')
AND TxnSubType IN ('RECOVERY','INTEREST') 
AND TxnDate BETWEEN @StartDt AND @EndDt
AND ISNULL(TxnAmount,0)>0 
and TrueCredit='Y'

CREATE CLUSTERED INDEX #AcDailyTxnDetail_Ctrl
ON #AcDailyTxnDetail (EntityKey)

CREATE NONCLUSTERED INDEX #AcDailyTxnDetail_001_IX
ON #AcDailyTxnDetail ([TxnType],[TxnSubType],[TxnDate])
INCLUDE ([AccountEntityID],[TxnAmount])

 

--***********************
--  90 DAYS Credit
--***********************
 
;WITH CTE_Credit(TxnAmount,AccountEntityID)
 AS
	(

		SELECT SUM(ISNULL(TxnAmount,0)),A.AccountEntityID
		FROM #AcDailyTxnDetail A 
		INNER JOIN PRO.AccountCal B ON A.AccountEntityID=B.AccountEntityID 
		INNER JOIN DimProduct C  ON B.ProductAlt_Key=C.ProductAlt_Key 
		and C.EffectiveFromTimeKey<=@timekey AND C.EffectiveToTimeKey>=@timekey 
		WHERE  TxnType='CREDIT' AND TxnSubType='RECOVERY' 
			AND TxnDate BETWEEN @StartDt AND @EndDt
			AND isnull(C.ProductSubGroup,'N') NOT in('Agri Busi','Agri TL','KCC')
		GROUP BY A.AccountEntityID
		
	)
UPDATE FCC 
SET CurQtrCredit= PQC.TxnAmount
FROM PRO.AccountCal FCC 
INNER JOIN CTE_Credit PQC
ON FCC.AccountEntityID=PQC.AccountEntityID 
where FCC.FinalAssetClassAlt_Key=1


--***********************
-- 90 DAYS Interest
--***********************
	
;WITH CTE_Interest(TxnAmount,AccountEntityID)
  AS
	(SELECT SUM(ISNULL(TxnAmount,0)), A.AccountEntityID 
		FROM #AcDailyTxnDetail A
		INNER JOIN PRO.AccountCal B ON A.AccountEntityID=B.AccountEntityID
		INNER JOIN DimProduct C  ON B.ProductAlt_Key=C.ProductAlt_Key 
		and C.EffectiveFromTimeKey<=@timekey AND C.EffectiveToTimeKey>=@timekey 
		WHERE  TxnType='DEBIT' AND TxnSubType='INTEREST' 
		AND TxnDate BETWEEN @StartDt AND @EndDt
		AND isnull(C.ProductSubGroup,'N') NOT in('Agri Busi','Agri TL','KCC')
		GROUP BY A.AccountEntityID
		
	)
UPDATE FCC 
SET CurQtrInt= PQC.TxnAmount
FROM PRO.AccountCal FCC 
INNER JOIN CTE_Interest PQC ON FCC.AccountEntityID=PQC.AccountEntityID
where FCC.FinalAssetClassAlt_Key=1

UPDATE PRO.ACCOUNTCAL SET PreQtrCredit=0 WHERE PreQtrCredit IS NULL 	
UPDATE PRO.ACCOUNTCAL SET PrvQtrInt=0    WHERE PrvQtrInt IS NULL 
UPDATE PRO.ACCOUNTCAL SET CurQtrCredit=0 WHERE CurQtrCredit IS NULL 
UPDATE PRO.ACCOUNTCAL SET CurQtrInt=0    WHERE CurQtrInt IS NULL 



	END TRY

	BEGIN CATCH
					SELECT 'Proc Name: ' + ISNULL(ERROR_PROCEDURE(),'') + ' ErrorMsg: ' + ISNULL(ERROR_MESSAGE(),'')
	END CATCH


	END

GO