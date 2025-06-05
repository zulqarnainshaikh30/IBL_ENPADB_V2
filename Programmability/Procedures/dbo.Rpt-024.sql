SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
Report Name:- Account Wise MOC Verification Report
*/

CREATE PROC [dbo].[Rpt-024]
	@TimeKey  INT
	AS

--DECLARE @TimeKey AS INT=27333

SET NOCOUNT ON ;  
-----------------------------------------
 IF(OBJECT_ID('TEMPDB..#MOCAcount')IS NOT NULL)
     DROP TABLE #MOCAcount


SELECT * INTO #MOCAcount FROM(
SELECT A.CustomerEntityID,A.AccountEntityID,A.CustomerAcID,B.ChangeField 
FROM  AdvAcBasicDetail A

INNER JOIN AccountLevelMOC_Mod B ON A.CustomerAcID=B.AccountID
WHERE B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      AND B.ChangeField IS NOT NULL AND B.AuthorisationStatus='A'
 )A

 OPTION(RECOMPILE)

 ----SELECT * FROM #MOCAcount WHERE CustomerEntityID='69947' 

 IF(OBJECT_ID('TEMPDB..#MOCAcount_1')IS NOT NULL)
   DROP TABLE #MOCAcount_1

SELECT 
CustomerEntityID
,AccountEntityID
,CustomerAcID
,items ChangeField
INTO #MOCAcount_1 
FROM #MOCAcount

CROSS APPLY DBO.Split(ChangeField,',')

OPTION(RECOMPILE)

 --------PREMOC
 
 IF(OBJECT_ID('TEMPDB..#PRE_MOC')IS NOT NULL)
   DROP TABLE #PRE_MOC

  SELECT H.RefCustomerID                    AS CustomerID  
        ,H.CustomerEntityID
	    ,H.CustomerName
		,MOC.AccountEntityID
		,MOC.CustomerACID
        ,MOC.ChangeField 
		,CASE WHEN MOC.ChangeField=2		 THEN 'POS in Rs.'
              WHEN MOC.ChangeField=3		 THEN 'Interest Receivable in Rs.' 
              WHEN MOC.ChangeField=6		 THEN 'Fraud Account Flag'
              WHEN MOC.ChangeField=7		 THEN 'Fraud Date'
              WHEN MOC.ChangeField=8		 THEN 'FITL Flag'
              WHEN MOC.ChangeField=9		 THEN 'DFV Amount'
              WHEN MOC.ChangeField=21		 THEN 'Additional Provision (Absolute)'
			  WHEN MOC.ChangeField=22		 THEN 'Additional Provision Per'
              WHEN MOC.ChangeField=25		 THEN 'Two Date'
			  WHEN MOC.ChangeField=26		 THEN 'Two Amount'
			  END AS Field
		,CASE WHEN MOC.ChangeField=2		 THEN CAST(ISNULL(AC.PrincOutStd,0)  AS VARCHAR(MAX))
              WHEN MOC.ChangeField=3		 THEN CAST(ISNULL(B.InterestReceivable,0) AS VARCHAR(MAX))
              WHEN MOC.ChangeField=6		 THEN ISNULL(AC.FlgFraud,'')   
              WHEN MOC.ChangeField=7		 THEN CONVERT(VARCHAR(20),AC.FraudDate,103) 
              WHEN MOC.ChangeField=8		 THEN ISNULL(AC.FlgFITL,'') 
              WHEN MOC.ChangeField=9		 THEN CAST(ISNULL(AC.DFVAmt,0) AS VARCHAR(MAX))
              WHEN MOC.ChangeField=21		 THEN CAST(ISNULL(AC.TotalProvision,0) AS VARCHAR(MAX))
			  WHEN MOC.ChangeField=22		 THEN CAST(ISNULL(AC.AddlProvisionPer,0) AS VARCHAR(MAX))
              WHEN MOC.ChangeField=25		 THEN CONVERT(VARCHAR(20),TWO.StatusDate,103) 
			  WHEN MOC.ChangeField=26		 THEN CAST(ISNULL(TWO.Amount,0) AS VARCHAR(MAX))			                                 
			  END AS Value

		,'Pre-Moc'   AS Moc_flag


INTO #PRE_MOC		
FROM #MOCAcount_1  MOC

INNER JOIN Pro.AccountCal_Hist AC        ON AC.AccountEntityId=MOC.AccountEntityId 
                                            AND AC.EffectiveFromTimeKey <=@TimeKey AND AC.EffectiveToTimeKey >=@TimeKey


INNER JOIN AdvAcBalanceDetail B         ON B.AccountEntityId=MOC.AccountEntityId 
                                            AND B.EffectiveFromTimeKey <=@TimeKey AND B.EffectiveToTimeKey >=@TimeKey

INNER JOIN Pro.CustomerCal_Hist H        ON AC.RefCustomerId=H.RefCustomerId   
                                            AND H.EffectiveFromTimeKey <=@TimeKey AND H.EffectiveToTimeKey >=@TimeKey 

LEFT JOIN (SELECT  CustomerID,ACID,StatusType,StatusDate,ISNULL(Amount,0) Amount FROM  ExceptionFinalStatusType
                             WHERE StatusType='TWO'
                         AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) TWO
                               ON   AC.CustomerACID=TWO.ACID  
 
WHERE  MOC.ChangeField IS NOT NULL


OPTION(RECOMPILE)

 --SELECT * FROM #PRE_MOC WHERE CUSTOMERID='8371687'

IF(OBJECT_ID('TEMPDB..#POSTMOC')IS NOT NULL)
   DROP TABLE #POSTMOC

---------POSTMOC

 SELECT  C.CustomerID  
        ,C.CustomerEntityID
	    ,C.CustomerName
		,A.AccountEntityID
		,A.CustomerACID
        ,A.ChangeField 
		,CASE WHEN A.ChangeField=2		 THEN 'POS in Rs.'
              WHEN A.ChangeField=3		 THEN 'Interest Receivable in Rs.' 
              WHEN A.ChangeField=6		 THEN 'Fraud Account Flag'
              WHEN A.ChangeField=7		 THEN 'Fraud Date'
              WHEN A.ChangeField=8		 THEN 'FITL Flag'
              WHEN A.ChangeField=9		 THEN 'DFV Amount'
              WHEN A.ChangeField=21		 THEN 'Additional Provision (Absolute)'
			  WHEN a.ChangeField=22		 THEN 'Additional Provision Per'
              WHEN A.ChangeField=25		 THEN 'Two Date'
			  WHEN A.ChangeField=26		 THEN 'Two Amount'
			  END AS Field
		
		,CASE WHEN A.ChangeField=2		 THEN CAST(ISNULL(PrincOutStd,0)  AS VARCHAR(MAX))
              WHEN A.ChangeField=3		 THEN CAST(ISNULL(unserviedint,0) AS VARCHAR(MAX))
              WHEN A.ChangeField=6		 THEN ISNULL(FlgFraud,'')
              WHEN A.ChangeField=7		 THEN CONVERT(VARCHAR(20),FraudDate,103)
              WHEN A.ChangeField=8		 THEN ISNULL(FlgFITL,'')
              WHEN A.ChangeField=9		 THEN CAST(ISNULL(DFVAmt,0) AS VARCHAR(MAX))
              WHEN A.ChangeField=21		 THEN CAST(ISNULL(B.AddlProvAbs,0) AS VARCHAR(MAX))
			  WHEN A.ChangeField=22		 THEN CAST(ISNULL(B.AddlProvPer,0) AS VARCHAR(MAX))
              WHEN A.ChangeField=25		 THEN CONVERT(VARCHAR(20),TwoDate,103)
			  WHEN A.ChangeField=26		 THEN CAST(ISNULL(B.TwoAmount,0) AS VARCHAR(MAX))             
			  END AS Value

		,'Post-Moc'   AS Moc_flag

INTO #POSTMOC		
FROM #MOCAcount_1  A

INNER JOIN MOC_ChangeDetails   B                    ON A.AccountEntityID=B.AccountEntityID
                                                       AND B.EffectiveFromTimeKey<=@TimeKey 
													   AND B.EffectiveToTimeKey>=@TimeKey
   
 LEFT JOIN Dbo.CustomerBasicDetail   C              ON C.CustomerEntityID=B.CustomerEntityID
                                                       AND C.EffectiveFromTimeKey<=@TimeKey 
														AND C.EffectiveToTimeKey>=@TimeKey

WHERE B.MOCType_Flag = 'ACCT' AND A.ChangeField IS NOT NULL

OPTION(RECOMPILE)

--SELECT * FROM #POSTMOC WHERE CUSTOMERID='8371687'
---------------------------------------
IF(OBJECT_ID('TEMPDB..#DATA')IS NOT NULL)
   DROP TABLE #DATA

SELECT * INTO #DATA FROM(

SELECT  
		 CustomerEntityId
        ,CustomerID
		,CustomerName
		,AccountEntityId
		,CustomerAcID
        , STUFF((SELECT  DISTINCT CHAR(10) +Field+':'+CAST(ISNULL(Value,'') AS VARCHAR(MAX))
				   FROM  #POSTMOC A WHERE A.AccountEntityId=B.AccountEntityId
					FOR XML PATH('')),1,1,'') AS A
		,'POST-MOC' AS FLAG
FROM #POSTMOC B
GROUP BY CustomerEntityId
        ,CustomerID
		,CustomerName
		,AccountEntityId
		,CustomerAcID

UNION ALL


SELECT   
		 CustomerEntityId
        ,CustomerID
		,CustomerName
		,AccountEntityId
		,CustomerAcID
        , STUFF((SELECT  DISTINCT CHAR(10) +Field+':'+CAST(ISNULL(Value,'') AS VARCHAR(MAX))
				   FROM  #PRE_MOC A WHERE A.AccountEntityId=B.AccountEntityId
					FOR XML PATH('')),1,1,'') AS A
		,'PRE-MOC' AS FLAG

FROM #PRE_MOC B 
GROUP BY 
         CustomerEntityId
        ,CustomerID
		,CustomerName
		,AccountEntityId
		,CustomerAcID
)D

OPTION(RECOMPILE) 

------------------------------

IF(OBJECT_ID('TEMPDB..#DATA1')IS NOT NULL)
   DROP TABLE #DATA1

SELECT 
DISTINCT  
 CustomerEntityId
,CustomerID
,CustomerName 
,AccountEntityId
,CustomerAcID
INTO #DATA1 
FROM #DATA

OPTION(RECOMPILE)

------------------============------------------============------------------============------------------============
ALTER  TABLE #DATA1 ADD  PreMoc  VARCHAR(MAX)
                    ,PostMoc VARCHAR(MAX)

UPDATE A
SET A.PreMoc=B.A 

FROM #DATA1 A
INNER JOIN #DATA B   ON A.AccountEntityId=B.AccountEntityId
WHERE B.FLAG='PRE-MOC'
OPTION(RECOMPILE)

------------------============------------------============------------------============------------------============
UPDATE A
SET  A.PostMoc=B.A 
FROM #DATA1 A
INNER JOIN #DATA B   ON A.AccountEntityId=B.AccountEntityId

WHERE B.FLAG='POST-MOC'

OPTION(RECOMPILE)

SELECT 
ISNULL(CustomerID,'')+'('+ISNULL(CustomerAcID,'')+')'  CustomerID,
CustomerName,
PreMoc,
PostMoc
FROM #DATA1

OPTION(RECOMPILE)

--DROP TABLE #MOCAcount,#MOCAcount_1,#DATA,#DATA1,#POSTMOC,#PRE_MOC


GO