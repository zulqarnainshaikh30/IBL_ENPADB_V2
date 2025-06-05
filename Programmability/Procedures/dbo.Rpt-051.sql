SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
Report Name:- UCIC Level MOC Verification Report
*/


CREATE PROC [dbo].[Rpt-051]
	@TimeKey  INT
	AS

--DECLARE @TimeKey AS INT=26479

SET NOCOUNT ON ;  
------------------------------------------

 IF(OBJECT_ID('TEMPDB..#CCLMOC')IS NOT NULL)
     DROP TABLE #CCLMOC

SELECT * INTO #CCLMOC FROM(

SELECT UcifID  AS UCIC_ID,CustomerID,ChangeField,ScreenFlag
FROM  Calypsocustomerlevelmoc_Mod 
WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
      AND MOCDate IS NOT NULL AND ChangeField IS NOT NULL AND AuthorisationStatus='A'
 )A

 OPTION(RECOMPILE)

---------------------------------------------------

 IF(OBJECT_ID('TEMPDB..#InvestmentDerivative')IS NOT NULL)
     DROP TABLE #InvestmentDerivative


SELECT * INTO #InvestmentDerivative FROM(
SELECT
IID.UcifId                                                                 AS UCIC_ID,
IID.IssuerID                                                               AS IssuerID,
IID.IssuerName                                                             AS IssuerName,													                       
CONVERT(VARCHAR(15),IFD.InitialNPIDt,103)                                         AS NPIDt,
(CASE WHEN DA.AssetClassName = 'LOS' THEN 'LOSS' ELSE DA.AssetClassName END)                                                         AS NPIAssetClass,
0 AddlProvisionPer
FROM dbo.InvestmentBasicDetail IBD
INNER JOIN DBO.InvestmentFinancialdetail     IFD			ON  IFD.InvEntityId=IBD.InvEntityId 
															    AND IFD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IFD.EffectiveToTimeKey>=@TimeKey
																AND IBD.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IBD.EffectiveToTimeKey>=@TimeKey
																
INNER JOIN DBO.InvestmentIssuerDetail   IID				    ON  IID.IssuerEntityId=IBD.IssuerEntityId 
															    AND IID.EffectiveFromTimeKey<=@TimeKey 
                                                                AND IID.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimAssetClass DA                                 ON DA.AssetClassAlt_Key=IFD.InitialAssetAlt_Key
                                                                AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                                AND DA.EffectiveToTimeKey>=@TimeKey
UNION ALL

SELECT
UCIC_ID,
CustomerID                                                               AS IssuerID,
CustomerName                                                             AS IssuerName,													                       
CONVERT(VARCHAR(15),InitialNPIDt,103)                                           AS NPIDt,
(CASE WHEN DA.AssetClassName = 'LOS' THEN 'LOSS' ELSE DA.AssetClassName END)                                                       AS NPIAssetClass,
0 AddlProvisionPer
FROM CURDAT.DerivativeDetail Derivative

INNER JOIN DimAssetClass DA                        ON DA.AssetClassAlt_Key=Derivative.InitialAssetAlt_Key
                                                      AND DA.EffectiveFromTimeKey<=@TimeKey 
                                                      AND DA.EffectiveToTimeKey>=@TimeKey

WHERE Derivative.EffectiveFromTimeKey<=@TimeKey AND Derivative.EffectiveToTimeKey>=@TimeKey

)DATA

OPTION(RECOMPILE)

----------------------------------------------
 IF(OBJECT_ID('TEMPDB..#Inv_Derv_POSTMOC')IS NOT NULL)
     DROP TABLE #Inv_Derv_POSTMOC


SELECT * INTO #Inv_Derv_POSTMOC FROM(
SELECT
UCICID                                                                AS UCIC_ID,
AssetClassAlt_Key,
NPA_Date,
AddlProvPer
FROM CalypsoInvMOC_ChangeDetails 
WHERE EffectiveFromTimeKey<=@TimeKey  AND EffectiveToTimeKey>=@TimeKey
      AND MOCType_Flag='CUST'

UNION ALL

SELECT
UCICID                                                                AS UCIC_ID,
AssetClassAlt_Key,
NPA_Date,
AddlProvPer
FROM CalypsoDervMOC_ChangeDetails
WHERE EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
      AND MOCType_Flag='CUST'

)DATA

OPTION(RECOMPILE)

---------------------------------------------

 IF(OBJECT_ID('TEMPDB..#MOCUCIC')IS NOT NULL)
     DROP TABLE #MOCUCIC

SELECT * INTO #MOCUCIC FROM(
SELECT A.UCIC_ID,A.IssuerID,B.ChangeField ,A.IssuerName,ScreenFlag
FROM  #InvestmentDerivative A
LEFT JOIN #CCLMOC B ON A.UCIC_ID=B.UCIC_ID

 )A

 OPTION(RECOMPILE)

----------------------------------------------

 IF(OBJECT_ID('TEMPDB..#MOCUCIC_1')IS NOT NULL)
   DROP TABLE #MOCUCIC_1

SELECT 
 UCIC_ID
,IssuerID
,items ChangeFld
,IssuerName
,ScreenFlag
INTO #MOCUCIC_1 
FROM #MOCUCIC

CROSS APPLY DBO.Split(ChangeField,',')

OPTION(RECOMPILE)


 --------PREMOC
 
 IF(OBJECT_ID('TEMPDB..#PRE_MOC')IS NOT NULL)
   DROP TABLE #PRE_MOC

   
 IF(OBJECT_ID('TEMPDB..#POSTMOC')IS NOT NULL)
   DROP TABLE #POSTMOC


 SELECT  
         A.IssuerID  
		,A.IssuerName
	    ,A.UCIC_ID
        ,A.ChangeFld 
		,CASE WHEN (A.ChangeFld=2 AND ScreenFlag='S')	OR (A.ChangeFld=3 AND ScreenFlag='U')	          THEN 'Asset Class'
		      WHEN (A.ChangeFld=3 AND ScreenFlag='S')	OR (A.ChangeFld=4 AND ScreenFlag='U')		      THEN 'NPA Date'
			  WHEN A.ChangeFld=5		      THEN 'Additional Provision %'
			  END AS Field
		
		,CASE WHEN (A.ChangeFld=2 AND ScreenFlag='S')	OR (A.ChangeFld=3 AND ScreenFlag='U')		      THEN ISNULL(NPIAssetClass,'') 
		      WHEN (A.ChangeFld=3 AND ScreenFlag='S')	OR (A.ChangeFld=4 AND ScreenFlag='U')		      THEN CONVERT(VARCHAR(20),B.NPIDt ,103)
			  WHEN A.ChangeFld=5		      THEN CAST(ISNULL(AddlProvisionPer,0) AS VARCHAR(MAX))
			  END AS Value

		,'Pre-Moc'   as Moc_flag


INTO #PRE_MOC		
FROM #MOCUCIC_1  A
INNER JOIN  #InvestmentDerivative B 
ON  A.UCIC_ID=B.UCIC_ID

OPTION(RECOMPILE)


---------POSTMOC

 SELECT  A.UCIC_ID    
        ,A.IssuerID
		,A.IssuerName
        ,A.ChangeFld 
		,CASE WHEN (A.ChangeFld=2 AND ScreenFlag='S')	OR (A.ChangeFld=3 AND ScreenFlag='U')		      THEN 'Asset Class'
		      WHEN (A.ChangeFld=3 AND ScreenFlag='S')	OR (A.ChangeFld=4 AND ScreenFlag='U')		      THEN 'NPA Date'
			  WHEN A.ChangeFld=5		      THEN 'Additional Provision %'
			  END AS Field
		
		,CASE WHEN (A.ChangeFld=2 AND ScreenFlag='S')	OR (A.ChangeFld=3 AND ScreenFlag='U')		      THEN (CASE WHEN ISNULL(D.AssetClassName,'')  = 'LOS' THEN 'LOSS' ELSE ISNULL(D.AssetClassName,'')  END)
		      WHEN (A.ChangeFld=3 AND ScreenFlag='S')	OR (A.ChangeFld=4 AND ScreenFlag='U')		      THEN CONVERT(VARCHAR(20),C.NPA_Date,103)
			  WHEN A.ChangeFld=5		      THEN CAST(ISNULL(C.AddlProvPer,0) AS VARCHAR(MAX))
			  END AS Value

		,'Post-Moc'   as Moc_flag


INTO #POSTMOC		
FROM #MOCUCIC_1  A
INNER JOIN #Inv_Derv_POSTMOC C         ON  A.UCIC_ID=C.UCIC_ID 


LEFT JOIN DimAssetClass   D            ON C.AssetClassAlt_Key=D.AssetClassAlt_Key
                                          AND D.EffectiveFromTimeKey<=@TimeKey 
	                                      AND D.EffectiveToTimeKey>=@TimeKey

WHERE (CASE WHEN (A.ChangeFld=2 AND ScreenFlag='S')	OR (A.ChangeFld=3 AND ScreenFlag='U')		      THEN (CASE WHEN ISNULL(D.AssetClassName,'')  = 'LOS' THEN 'LOSS' ELSE ISNULL(D.AssetClassName,'')  END)
		    WHEN (A.ChangeFld=3 AND ScreenFlag='S')	OR (A.ChangeFld=4 AND ScreenFlag='U')		      THEN CONVERT(VARCHAR(20),C.NPA_Date,103)
			WHEN A.ChangeFld=5		      THEN CAST(ISNULL(C.AddlProvPer,0) AS VARCHAR(20))
			END) IS NOT NULL

OPTION(RECOMPILE)


---------------------------------------
IF(OBJECT_ID('TEMPDB..#DATA')IS NOT NULL)
   DROP TABLE #DATA

SELECT * INTO #DATA FROM(

SELECT  
		 UCIC_ID
        ,IssuerID
		,IssuerName
        , STUFF((SELECT  DISTINCT CHAR(10) +Field+':'+CAST( ISNULL(Value,'')AS VARCHAR(MAX))
				   FROM  #POSTMOC A WHERE A.UCIC_ID=B.UCIC_ID
					FOR XML PATH('')),1,1,'') AS A
		,'POST-MOC' AS FLAG
FROM #POSTMOC B
GROUP BY UCIC_ID
        ,IssuerID
		,IssuerName


UNION ALL


SELECT   
		 UCIC_ID
        ,IssuerID
		,IssuerName
        , STUFF((SELECT  DISTINCT CHAR(10) +Field+':'+CAST(ISNULL(Value,'') AS VARCHAR(MAX))
				   FROM  #PRE_MOC A WHERE A.UCIC_ID=B.UCIC_ID
					FOR XML PATH('')),1,1,'') AS A
		,'PRE-MOC' AS FLAG

FROM #PRE_MOC B 
GROUP BY 
         UCIC_ID
        ,IssuerID
		,IssuerName

)D

OPTION(RECOMPILE) 

------------------------------

IF(OBJECT_ID('TEMPDB..#DATA1')IS NOT NULL)
   DROP TABLE #DATA1

SELECT 
DISTINCT  
 UCIC_ID
,IssuerID
,IssuerName 
INTO #DATA1 
FROM #DATA

OPTION(RECOMPILE)

------------------===============================================

ALTER  TABLE #DATA1 ADD  PreMoc  VARCHAR(MAX)
                    ,PostMoc VARCHAR(MAX)

UPDATE A
SET A.PreMoc=B.A 

FROM #DATA1 A
INNER JOIN #DATA B   ON A.UCIC_ID=B.UCIC_ID
WHERE B.FLAG='PRE-MOC'
OPTION(RECOMPILE)

------------------================================================
UPDATE A
SET  A.PostMoc=B.A 
FROM #DATA1 A
INNER JOIN #DATA B   ON A.UCIC_ID=B.UCIC_ID

WHERE B.FLAG='POST-MOC'

OPTION(RECOMPILE)

SELECT * FROM #DATA1

OPTION(RECOMPILE)

DROP TABLE #MOCUCIC,#MOCUCIC_1,#DATA,#DATA1,#POSTMOC,#PRE_MOC,#CCLMOC,#Inv_Derv_POSTMOC,#InvestmentDerivative



GO