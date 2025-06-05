SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
Report Name:- Individual Record MOC Verification Report
*/

CREATE PROC [dbo].[Rpt-052]
	@TimeKey  INT
	AS

--DECLARE @TimeKey AS INT=26479

SET NOCOUNT ON ;  
-----------------------------------------
IF(OBJECT_ID('TEMPDB..#IndVMOC')IS NOT NULL)
     DROP TABLE #IndVMOC

SELECT * INTO #IndVMOC FROM(
SELECT AccountID,AccountEntityID,ChangeField,ScreenFlag
FROM  CalypsoAccountlevelmoc_Mod 
WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
      AND MOCDate IS NOT NULL AND ChangeField IS NOT NULL AND AuthorisationStatus='A'

 )A

 OPTION(RECOMPILE)

---------------------------------------------------

 IF(OBJECT_ID('TEMPDB..#InvestmentDerivative')IS NOT NULL)
     DROP TABLE #InvestmentDerivative


SELECT * INTO #InvestmentDerivative FROM(
SELECT
DISTINCT
IID.UcifId                                                                 AS UCIC_ID,
IID.IssuerName                                                             AS IssuerName,
IBD.InvID                                                                  AS 'InvestmentID/Derv No.',												                       
ISNULL(IFD.BookValue,0)                                                    AS BookValue
--FD.RFA_DateReportingByBank                                                 AS FraudDate
FROM dbo.InvestmentBasicDetail IBD
INNER JOIN DBO.InvestmentFinancialdetail     IFD			ON  IFD.InvEntityId=IBD.InvEntityId 
															    AND IFD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IFD.EffectiveToTimeKey>=@TimeKey
																AND IBD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IBD.EffectiveToTimeKey>=@TimeKey
																
INNER JOIN DBO.InvestmentIssuerDetail   IID				    ON  IID.IssuerEntityId=IBD.IssuerEntityId 
															    AND IID.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IID.EffectiveToTimeKey>=@TimeKey

--LEFT JOIN	 Fraud_Details		FD							ON  IID.IssuerID=FD.RefCustomerID  
--															    AND FD.EffectiveFromTimeKey<=@TimeKey 
--                                                                AND FD.EffectiveToTimeKey>=@TimeKey

UNION ALL

SELECT
DISTINCT
UCIC_ID,
CustomerName                                                             AS IssuerName,
DerivativeRefNo                                                          AS 'InvestmentID/Derv No.'	,												                       
ISNULL(MTMIncomeAmt,0)                                                   AS BookValue
--FD.RFA_DateReportingByBank                                               AS FraudDate
FROM CURDAT.DerivativeDetail Derivative
--LEFT JOIN Fraud_Details		FD					  ON  Derivative.CustomerID=FD.RefCustomerID 
--													  AND FD.EffectiveFromTimeKey<=@TimeKey 
--                                                      AND FD.EffectiveToTimeKey>=@TimeKey

WHERE Derivative.EffectiveFromTimeKey<=@TimeKey AND Derivative.EffectiveToTimeKey>=@TimeKey

)DATA

OPTION(RECOMPILE)

----------------------------------------------
 IF(OBJECT_ID('TEMPDB..#Inv_Derv_POSTMOC')IS NOT NULL)
     DROP TABLE #Inv_Derv_POSTMOC


SELECT * INTO #Inv_Derv_POSTMOC FROM(
SELECT
DISTINCT
 B.AccountID 
,A.BookValue 
,A.unserviedint                                                              	
,A.AddlProvAbs		
--,A.FraudDate		
--,A.TwoDate	
FROM CalypsoInvMOC_ChangeDetails A
INNER JOIN CalypsoAccountlevelmoc_Mod  B       ON A.AccountEntityID=B.AccountEntityID  
                                                  AND B.EffectiveFromTimeKey<=@TimeKey  AND B.EffectiveToTimeKey>=@TimeKey  
												   
WHERE A.EffectiveFromTimeKey<=@TimeKey  AND A.EffectiveToTimeKey>=@TimeKey
      AND MOCType_Flag='ACCT'

UNION ALL

SELECT
DISTINCT
 B.AccountID
,A.BookValue 
,A.unserviedint                                                              	
,A.AddlProvAbs		
--,A.FraudDate		
--,A.TwoDate
FROM CalypsoDervMOC_ChangeDetails A
INNER JOIN CalypsoAccountlevelmoc_Mod  B       ON A.AccountEntityID=B.AccountEntityID  
                                                  AND B.EffectiveFromTimeKey<=@TimeKey  AND B.EffectiveToTimeKey>=@TimeKey  
												   
WHERE A.EffectiveFromTimeKey<=@TimeKey  AND A.EffectiveToTimeKey>=@TimeKey
      AND MOCType_Flag='ACCT'

)DATA

OPTION(RECOMPILE)
---------------------------------------------

 IF(OBJECT_ID('TEMPDB..#MOCIndv')IS NOT NULL)
     DROP TABLE #MOCIndv

SELECT * INTO #MOCIndv FROM(
SELECT DISTINCT A.UCIC_ID,B.AccountID,B.ChangeField ,A.IssuerName,ScreenFlag
FROM  #InvestmentDerivative A
LEFT JOIN #IndVMOC B ON A.[InvestmentID/Derv No.]=B.AccountID

 )A

 OPTION(RECOMPILE)

----------------------------------------------

 IF(OBJECT_ID('TEMPDB..#MOCIndv_1')IS NOT NULL)
   DROP TABLE #MOCIndv_1

SELECT 
DISTINCT
 UCIC_ID
,AccountID
,items ChangeFld
,IssuerName
,ScreenFlag
INTO #MOCIndv_1 
FROM #MOCIndv

CROSS APPLY DBO.Split(ChangeField,',')

OPTION(RECOMPILE)

 --------PREMOC
 
 IF(OBJECT_ID('TEMPDB..#PRE_MOC')IS NOT NULL)
   DROP TABLE #PRE_MOC

  SELECT DISTINCT
         A.UCIC_ID    
        ,A.AccountID
		,A.IssuerName
        ,A.ChangeFld 
		,CASE WHEN A.ChangeFld=3 AND A.ScreenFlag='S'		                                             THEN 'Unserviced Interest'
              WHEN (A.ChangeFld=21 AND A.ScreenFlag='S') OR (A.ChangeFld=3 AND A.ScreenFlag='U')		 THEN 'Additional Provision (Absolute)'
			  --WHEN (A.ChangeFld=7 AND A.ScreenFlag='S') OR (A.ChangeFld=4 AND A.ScreenFlag='U')          THEN 'FraudDate'
     --         WHEN A.ChangeFld=5		                                                                 THEN 'Two Date'
			  WHEN A.ChangeFld=26                                                                        THEN 'Book Value INR / MTM Value'
			  END AS Field
		,CASE WHEN A.ChangeFld=3 AND A.ScreenFlag='S'		                                             THEN '0'
              WHEN (A.ChangeFld=21 AND A.ScreenFlag='S') OR (A.ChangeFld=3 AND A.ScreenFlag='U')		 THEN '0' 
              --WHEN (A.ChangeFld=7 AND A.ScreenFlag='S') OR (A.ChangeFld=4 AND A.ScreenFlag='U')		     THEN CONVERT(VARCHAR(20),B.FraudDate,103)
              --WHEN A.ChangeFld=5		                                                                 THEN CONVERT(VARCHAR(20),TWO.StatusDate,103) 
              WHEN A.ChangeFld=26		                                                                 THEN CAST(ISNULL(B.BookValue,0) AS VARCHAR(MAX))			                                 
			  END AS Value

		,'Pre-Moc'   AS Moc_flag


INTO #PRE_MOC		
FROM #MOCIndv_1  A
INNER JOIN  #InvestmentDerivative B       ON  A.AccountID=B.[InvestmentID/Derv No.]
                                              AND A.UCIC_ID=B.UCIC_ID

LEFT JOIN (SELECT  DISTINCT ACID,StatusDate,ISNULL(Amount,0) Amount FROM  ExceptionFinalStatusType
                             WHERE StatusType='TWO'
                         AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) TWO
                               ON   A.AccountID=TWO.ACID 

WHERE ChangeFld IS NOT NULL

OPTION(RECOMPILE)

IF(OBJECT_ID('TEMPDB..#POSTMOC')IS NOT NULL)
   DROP TABLE #POSTMOC

---------POSTMOC

 SELECT  DISTINCT
         A.UCIC_ID    
        ,A.AccountID
		,A.IssuerName
        ,A.ChangeFld 
		,CASE WHEN A.ChangeFld=3 AND A.ScreenFlag='S'		                                             THEN 'Unserviced Interest'
              WHEN (A.ChangeFld=21 AND A.ScreenFlag='S') OR (A.ChangeFld=3 AND A.ScreenFlag='U')		 THEN 'Additional Provision (Absolute)'
			  --WHEN (A.ChangeFld=7 AND A.ScreenFlag='S') OR (A.ChangeFld=4 AND A.ScreenFlag='U')          THEN 'FraudDate'
     --         WHEN A.ChangeFld=5		                                                                 THEN 'Two Date'
			  WHEN A.ChangeFld=26                                                                        THEN 'Book Value INR / MTM Value'
			  END AS Field
		
		,CASE WHEN A.ChangeFld=3 AND A.ScreenFlag='S'		                                             THEN CAST(ISNULL(unserviedint,0) AS VARCHAR(MAX))
              WHEN (A.ChangeFld=21 AND A.ScreenFlag='S') OR (A.ChangeFld=3 AND A.ScreenFlag='U')		 THEN CAST(ISNULL(AddlProvAbs,0) AS VARCHAR(MAX)) 
              --WHEN (A.ChangeFld=7 AND A.ScreenFlag='S') OR (A.ChangeFld=4 AND A.ScreenFlag='U')		     THEN CONVERT(VARCHAR(20),FraudDate,103) 
              --WHEN A.ChangeFld=5		                                                                 THEN CONVERT(VARCHAR(20),TwoDate,103)
              WHEN A.ChangeFld=26		                                                                 THEN CAST(ISNULL(BookValue,0) AS VARCHAR(MAX)) 			                                 
			  END AS Value 

		,'Post-Moc'   AS Moc_flag

INTO #POSTMOC		
FROM #MOCIndv_1  A
INNER JOIN #Inv_Derv_POSTMOC C         ON  A.AccountID=C.AccountID 

WHERE CASE WHEN A.ChangeFld=3 AND A.ScreenFlag='S'		                                                 THEN CAST(ISNULL(unserviedint,0) AS VARCHAR(MAX))
              WHEN (A.ChangeFld=21 AND A.ScreenFlag='S') OR (A.ChangeFld=3 AND A.ScreenFlag='U')		 THEN CAST(ISNULL(AddlProvAbs,0) AS VARCHAR(MAX)) 
              --WHEN (A.ChangeFld=7 AND A.ScreenFlag='S') OR (A.ChangeFld=4 AND A.ScreenFlag='U')		     THEN CONVERT(VARCHAR(20),FraudDate,103) 
              --WHEN A.ChangeFld=5		                                                                 THEN CONVERT(VARCHAR(20),TwoDate,103)
              WHEN A.ChangeFld=26		                                                                 THEN CAST(ISNULL(BookValue,0) AS VARCHAR(MAX)) 			                                 
			  END IS NOT NULL AND ChangeFld IS NOT NULL

OPTION(RECOMPILE)

---------------------------------------
IF(OBJECT_ID('TEMPDB..#DATA')IS NOT NULL)
   DROP TABLE #DATA

SELECT * INTO #DATA FROM(

SELECT  
		 UCIC_ID    
        ,AccountID
		,IssuerName
        , STUFF((SELECT  DISTINCT CHAR(10) +Field+':'+CAST(ISNULL(Value,'') AS VARCHAR(MAX))
				   FROM  #POSTMOC A WHERE A.AccountID=B.AccountID
					FOR XML PATH('')),1,1,'') AS A
		,'POST-MOC' AS FLAG
FROM #POSTMOC B
GROUP BY UCIC_ID    
        ,AccountID
		,IssuerName

UNION ALL


SELECT   
		 UCIC_ID    
        ,AccountID
		,IssuerName
        , STUFF((SELECT  DISTINCT CHAR(10) +Field+':'+CAST(ISNULL(Value,'') AS VARCHAR(MAX))
				   FROM  #PRE_MOC A WHERE A.AccountID=B.AccountID
					FOR XML PATH('')),1,1,'') AS A
		,'PRE-MOC' AS FLAG

FROM #PRE_MOC B 
GROUP BY 
         UCIC_ID    
        ,AccountID
		,IssuerName
)D

OPTION(RECOMPILE) 

------------------------------

IF(OBJECT_ID('TEMPDB..#DATA1')IS NOT NULL)
   DROP TABLE #DATA1

SELECT 
DISTINCT  
 UCIC_ID    
,AccountID
,IssuerName
INTO #DATA1 
FROM #DATA

OPTION(RECOMPILE)

------------------============------------------============------------------============------------------============
ALTER  TABLE #DATA1 ADD  PreMoc  VARCHAR(MAX)
                    ,PostMoc VARCHAR(MAX)

UPDATE A
SET A.PreMoc=B.A 

FROM #DATA1 A
INNER JOIN #DATA B   ON A.AccountID=B.AccountID
WHERE B.FLAG='PRE-MOC'
OPTION(RECOMPILE)

------------------============------------------============------------------============------------------============
UPDATE A
SET  A.PostMoc=B.A 
FROM #DATA1 A
INNER JOIN #DATA B   ON A.AccountID=B.AccountID

WHERE B.FLAG='POST-MOC'

OPTION(RECOMPILE)

SELECT 
UCIC_ID ,   
AccountID,
IssuerName,
PreMoc,
PostMoc
FROM #DATA1

OPTION(RECOMPILE)

DROP TABLE #DATA,#DATA1,#POSTMOC,#PRE_MOC,#IndVMOC,#Inv_Derv_POSTMOC,#InvestmentDerivative,#MOCIndv,#MOCIndv_1

GO