SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
Report Name:- Customer Wise MOC Verification Report
*/


CREATE PROC [dbo].[Rpt-023]
	@TimeKey  INT
	AS

--DECLARE @TimeKey AS INT=26629


SET NOCOUNT ON ;  
------------------------------------------
 IF(OBJECT_ID('TEMPDB..#MOCCUST')IS NOT NULL)
     DROP TABLE #MOCCUST

SELECT * INTO #MOCCUST FROM(
SELECT A.CustomerID,A.CustomerEntityID,B.ChangeField ,A.CustomerName
FROM  CustomerBasicDetail A
INNER JOIN CustomerLevelMOC_Mod B ON A.CustomerID=B.CustomerID
WHERE B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
      AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
      AND B.MOCDate IS NOT NULL   AND B.ChangeField IS NOT NULL AND B.AuthorisationStatus='A'
 )A

 OPTION(RECOMPILE)


 IF(OBJECT_ID('TEMPDB..#MOCCUST_1')IS NOT NULL)
   DROP TABLE #MOCCUST_1

SELECT 
 CustomerID
,CustomerEntityID
,items ChangeFld
,CustomerName

INTO #MOCCUST_1 
FROM #MOCCUST

CROSS APPLY DBO.Split(ChangeField,',')
ORDER BY CustomerID,items

OPTION(RECOMPILE)


 --------PREMOC
 
 IF(OBJECT_ID('TEMPDB..#PRE_MOC')IS NOT NULL)
   DROP TABLE #PRE_MOC

   
 IF(OBJECT_ID('TEMPDB..#POSTMOC')IS NOT NULL)
   DROP TABLE #POSTMOC


 SELECT  A.CustomerID  CustomerID
        ,A.CustomerEntityID
		,E.CustomerName
	    ,E.RefCustomerID
        ,A.ChangeFld 
		,CASE WHEN A.ChangeFld=2		      THEN 'Asset Class'
		      WHEN A.ChangeFld=3		      THEN 'NPA Date'
			  WHEN A.ChangeFld=4		      THEN 'Security Value'
			  WHEN A.ChangeFld=5		      THEN 'Additional Provision %'
			  END AS Field
		
		,CASE WHEN A.ChangeFld=2		      THEN ISNULL(D.AssetClassShortNameEnum,'') 
		      WHEN A.ChangeFld=3		      THEN CONVERT(VARCHAR(20),E.SysNPA_Dt ,103)
			  WHEN A.ChangeFld=4		      THEN CAST(ISNULL(E.CurntQtrRv,0) AS VARCHAR(MAX))
			  WHEN A.ChangeFld=5		      THEN CAST(ISNULL(E.AddlProvisionPer,0) AS VARCHAR(MAX))
			  END AS Value

		,'Pre-Moc'   as Moc_flag


INTO #PRE_MOC		
FROM #MOCCUST_1  A

INNER JOIN  Pro.CustomerCal_Hist E      ON A.CustomerEntityID=E.CustomerEntityID 
                                           AND E.EffectiveFromTimeKey<=@TimeKey AND E.EffectiveToTimeKey>=@TimeKey

INNER JOIN DimAssetClass   D            ON E.SysAssetClassAlt_Key=D.AssetClassAlt_Key
                                           AND D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey

WHERE E.RefCustomerID IS NOT NULL AND  A.ChangeFld IS NOT NULL

OPTION(RECOMPILE)

---------POSTMOC

 SELECT  A.CustomerID    CustomerID
        ,A.CustomerEntityID
		,A.CustomerName
        ,A.ChangeFld 
		,CASE WHEN A.ChangeFld=2		      THEN 'Asset Class'
		      WHEN A.ChangeFld=3		      THEN 'NPA Date'
			  WHEN A.ChangeFld=4		      THEN 'Security Value'
			  WHEN A.ChangeFld=5		      THEN 'Additional Provision %'
			  END AS Field
		
		,CASE WHEN A.ChangeFld=2		      THEN ISNULL(D.AssetClassShortNameEnum,'') 
		      WHEN A.ChangeFld=3		      THEN CONVERT(VARCHAR(20),C.NPA_Date,103)
			  WHEN A.ChangeFld=4		      THEN CAST(ISNULL(C.CurntQtrRv,0) AS VARCHAR(20))
			  WHEN A.ChangeFld=5		      THEN CAST(ISNULL(C.AddlProvPer,0) AS VARCHAR(20))
			  END AS Value

		,'Post-Moc'   as Moc_flag


INTO #POSTMOC		
FROM #MOCCUST_1  A
INNER JOIN MOC_ChangeDetails C    ON  A.CustomerEntityID=C.CustomerEntityId 
                                      AND C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey

LEFT JOIN DimAssetClass   D       ON C.AssetClassAlt_Key=D.AssetClassAlt_Key
                                     AND D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey

WHERE C.MOCType_Flag = 'CUST' AND A.ChangeFld IS NOT NULL

OPTION(RECOMPILE)


---------------------------------------
IF(OBJECT_ID('TEMPDB..#DATA')IS NOT NULL)
   DROP TABLE #DATA

SELECT * INTO #DATA FROM(

SELECT  
		 CustomerEntityId
        ,CustomerID
		,CustomerName
        , STUFF((SELECT  DISTINCT CHAR(10) +Field+':'+CAST( ISNULL(Value,'')AS VARCHAR(MAX))
				   FROM  #POSTMOC A WHERE A.CustomerEntityId=B.CustomerEntityId
					FOR XML PATH('')),1,1,'') AS A
		,'POST-MOC' AS FLAG
FROM #POSTMOC B
GROUP BY CustomerEntityId
        ,CustomerID
		,CustomerName


UNION ALL


SELECT   
		 CustomerEntityId
        ,CustomerID
		,CustomerName
        , STUFF((SELECT  DISTINCT CHAR(10) +Field+':'+CAST(ISNULL(Value,'') AS VARCHAR(MAX))
				   FROM  #PRE_MOC A WHERE A.CustomerEntityId=B.CustomerEntityId
					FOR XML PATH('')),1,1,'') AS A
		,'PRE-MOC' AS FLAG

FROM #PRE_MOC B 
GROUP BY 
         CustomerEntityId
        ,CustomerID
		,CustomerName

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
INTO #DATA1 
FROM #DATA

OPTION(RECOMPILE)

------------------============------------------============------------------============------------------============
ALTER  TABLE #DATA1 ADD  PreMoc  VARCHAR(MAX)
                    ,PostMoc VARCHAR(MAX)

UPDATE A
SET A.PreMoc=B.A 

FROM #DATA1 A
INNER JOIN #DATA B   ON A.CustomerEntityId=B.CustomerEntityId
WHERE B.FLAG='PRE-MOC'
OPTION(RECOMPILE)

------------------============------------------============------------------============------------------============
UPDATE A
SET  A.PostMoc=B.A 
FROM #DATA1 A
INNER JOIN #DATA B   ON A.CustomerEntityId=B.CustomerEntityId

WHERE B.FLAG='POST-MOC'

OPTION(RECOMPILE)

SELECT * FROM #DATA1

OPTION(RECOMPILE)

DROP TABLE #MOCCUST,#MOCCUST_1,#DATA,#DATA1,#POSTMOC,#PRE_MOC







GO