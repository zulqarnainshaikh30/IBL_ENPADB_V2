SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
Report Name -  Summary Report on Asset Classification as on
Create by   -  KALIK DEV
Date        -  09 NOV 2021
*/

create PROCEDURE [dbo].[Rpt-033]
@Cost AS FLOAT,
@TimeKey AS INT

AS

--DECLARE @TimeKey INT=26190,
--        @cost FLOAT  =1

DECLARE @Date DATE=(SELECT [DATE] FROM SysDayMatrix WHERE TimeKey=@TimeKey)


 IF OBJECT_ID('TEMPDB..#Account') IS NOT NULL
	    DROP TABLE #Account

SELECT 
@Date                AS DateofData,
D.AssetClassAlt_Key,
C.SourceName,C.SourceAlt_Key,D.AssetClassShortName ,B.CustomerAcID,ISNULL(B.Balance,0)Balance, ISNULL(B.PrincOutStd,0)PrincOutStd
INTO #Account
FROM ACL_NPA_DATA B
LEFT JOIN DIMSOURCEDB C                  ON B.SourceName = C.SourceName	 
                                            AND C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey

LEFT JOIN DimAssetClass D                ON B.FinalAssetClassAlt_Key = D.AssetClassAlt_Key
                                            AND D.EffectiveFromTimeKey <= @Timekey AND D.EffectiveToTimeKey >= @Timekey

WHERE  CONVERT(DATE,B.Process_Date,105) = @Date

UNION

SELECT 
@Date                         AS DateofData,
D.AssetClassAlt_Key,
C.SourceName,C.SourceAlt_Key,D.AssetClassShortName ,B.CustomerAcID,ISNULL(B.Balance,0)Balance, ISNULL(B.PrincOutStd,0)PrincOutStd

FROM PRO.CUSTOMERCAL_Hist A  WITH (NOLOCK)
INNER JOIN PRO.AccountCAL_Hist B  WITH (NOLOCK)      ON A.CustomerEntityID = B.CustomerEntityID
                                                        
LEFT JOIN DIMSOURCEDB C                              ON B.SourceAlt_Key = C.SourceAlt_Key	 
                                                        AND C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey

LEFT JOIN DimAssetClass D                            ON B.FinalAssetClassAlt_Key = D.AssetClassAlt_Key
                                                        AND D.EffectiveFromTimeKey <= @Timekey AND D.EffectiveToTimeKey >= @Timekey

WHERE  B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey 
       AND B.FinalAssetClassAlt_Key = 1 
       AND A.EffectiveFromTimeKey <= @Timekey AND A.EffectiveToTimeKey >= @Timekey 

OPTION(RECOMPILE)
------------------#Account end----------------------------------------

IF OBJECT_ID('TEMPDB..#TWO') IS NOT NULL
	    DROP TABLE #TWO

(SELECT 
@Date                          AS DateofData,
9                              AS AssetClassAlt_Key,
C.SourceName                   AS [Source System],
c.SourceAlt_Key,
'TWO'                          AS AssetClass,
COUNT(DISTINCT U.ACID)         AS [Number of Accounts],
SUM(ISNULL(B.Balance,0))       AS [Balance Outstanding],
SUM(ISNULL(B.PrincOutStd,0))   AS [Principal Outstanding]

INTO #TWO
FROM ExceptionFinalStatusType U
INNER  JOIN PRO.AccountCal_Hist B            ON U.ACID = B.CustomerAcID

INNER JOIN Pro.Customercal_Hist A            ON A.CustomerEntityID = B.CustomerEntityID
                                                AND A.EffectiveFromTimeKey = B.EffectiveFromTimeKey

INNER JOIN DIMSOURCEDB C                     ON B.SourceAlt_Key = C.SourceAlt_Key	
                                                AND C.EffectiveFromTimeKey <= @Timekey AND C.EffectiveToTimeKey >= @Timekey

INNER JOIN DimAssetClass D                   ON B.FinalAssetClassAlt_Key = D.AssetClassAlt_Key
                                                AND D.EffectiveFromTimeKey <= @Timekey AND D.EffectiveToTimeKey >= @Timekey

WHERE  B.EffectiveFromTimeKey <= @Timekey AND B.EffectiveToTimeKey >= @Timekey  
GROUP BY C.SourceName,C.SourceAlt_Key)

UNION

SELECT @Date,9,A.SourceName,a.SourceAlt_Key,'TWO',0,0,0
FROM DIMSOURCEDB A 

INNER JOIN 
(SELECT DISTINCT SourceAlt_Key FROM DIMSOURCEDB
Except
SELECT DISTINCT SourceAlt_Key FROM ExceptionFinalStatusType  
)B 
 
ON A.SourceALt_Key = B.SourceAlt_Key

OPTION(RECOMPILE)

---#two end----
--------------Finacle--------

SELECT
CONVERT(VARCHAR(20),DateofData,103)    AS DateofData,
AssetClassAlt_Key,
[Source System],
SourceAlt_Key,
AssetClass,
SUM([Number of AcCOUNTs])              AS [Number of Accounts],
SUM([Balance Outstanding])/@Cost       AS [Balance Outstanding],
SUM([Principal Outstanding])/@Cost     AS [Principal Outstanding] 

FROM(
--------------Finacle--------

SELECT 
DateofData,
AssetClassAlt_Key,
[Source System],
SourceAlt_Key,
AssetClass,
[Number of AcCOUNTs],
[Balance Outstanding],
[Principal Outstanding]  

FROM (
SELECT  
DateofData,
AssetClassAlt_Key,
SourceName														AS [Source System],
SourceAlt_Key,
AssetClassShortName                                             AS AssetClass,
COUNT(DISTINCT CustomerAcID)									AS [Number of AcCOUNTs],
SUM(ISNULL(Balance,0))									        AS [Balance Outstanding],
SUM(ISNULL(PrincOutStd,0))					   		            AS [Principal Outstanding]

FROM #ACCOUNT 

WHERE CustomerACID NOT IN (SELECT DISTINCT AcID FROM ExceptionFinalStatusType) AND SourceAlt_Key<>7

GROUP BY SourceName,AssetClassShortName,AssetClassAlt_Key,DateofData,SourceAlt_Key

UNION ALL

SELECT * FROM #TWO WHERE SourceAlt_Key<>7

UNION ALL


SELECT 
@Date,
9                              AS AssetClassAlt_Key,
'Finacle'                      AS [Source System],
1,
'TWO'                          AS AssetClass,
0                              AS [Number of AcCOUNTs],
0                              AS [Balance Outstanding],
0                              AS [Principal Outstanding]

UNION ALL


SELECT 
@Date,
9                             AS AssetClassAlt_Key,
'Indus'                       AS [Source System],
2 ,
'TWO'                          AS AssetClass,
0                              AS [Number of AcCOUNTs],
0                              AS [Balance Outstanding],
0                              AS [Principal Outstanding]

UNION ALL


SELECT 
@Date,
9                             AS AssetClassAlt_Key,
'ECBF'                        AS [Source System],
3 ,
'TWO'                          AS AssetClass,
0                              AS [Number of AcCOUNTs],
0                              AS [Balance Outstanding],
0                              AS [Principal Outstanding]

UNION ALL


SELECT 
@Date,
9                              AS AssetClassAlt_Key,
'Mifin'                        AS [Source System],
4 ,
'TWO'                          AS AssetClass,
0                              AS [Number of AcCOUNTs],
0                              AS [Balance Outstanding],
0                              AS [Principal Outstanding]

UNION ALL


SELECT 
@Date,
9                              AS AssetClassAlt_Key,
'Ganaseva'                     AS [Source System],
5 ,
'TWO'                          AS AssetClass,
0                              AS [Number of AcCOUNTs],
0                              AS [Balance Outstanding],
0                              AS [Principal Outstanding]

UNION ALL


SELECT 
@Date,
9                              AS AssetClassAlt_Key,
'Visionplus'                   AS [Source System],
6 ,
'TWO'                          AS AssetClass,
0                              AS [Number of AcCOUNTs],
0                              AS [Balance Outstanding],
0                              AS [Principal Outstanding]

UNION ALL


SELECT 
@Date,
9                              AS AssetClassAlt_Key,
'Metagrid'                     AS [Source System],
8 ,
'TWO'                          AS AssetClass,
0                              AS [Number of AcCOUNTs],
0                              AS [Balance Outstanding],
0                              AS [Principal Outstanding]

UNION ALL


SELECT 
@Date,
9                              AS AssetClassAlt_Key,
'ALL'                          AS [Source System],
15 ,
'TWO'                          AS AssetClass,
0                              AS [Number of AcCOUNTs],
0                              AS [Balance Outstanding],
0                              AS [Principal Outstanding]

UNION ALL

SELECT @Date,AssetClassAlt_Key,'Finacle',1,AssetClassShortName,0,0,0

FROM 
(SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM DimAssetClass 
WHERE  EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey

EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #ACCOUNT
WHERE SourceName = 'Finacle' 
      AND  CustomerAcID NOT IN (SELECT DISTINCT AcID FROM ExceptionFinalStatusType)
)p

UNION ALL

SELECT 
DateofData,
10                             AS AssetClassAlt_Key,
SourceName                     AS [Source System],
1 ,
'Total'                        AS AssetClass,
COUNT(DISTINCT CustomerAcID)   AS [Number of AcCOUNTs],
SUM(ISNULL(Balance,0))         AS [Balance Outstanding],
SUM(ISNULL(PrincOutStd,0))     AS [Principal Outstanding]
FROM #ACCOUNT
WHERE SourceName= 'Finacle'  
GROUP BY SourceName,DateofData

UNION ALL


SELECT 
@Date,
10                             AS AssetClassAlt_Key,
'Finacle'                      AS [Source System],
1 ,
'Total'                        AS AssetClass,
0                              AS [Number of AcCOUNTs],
0                              AS [Balance Outstanding],
0                              AS [Principal Outstanding]

)P 

UNION  ALL  

----------------Indus--------


SELECT 
DateofData
,AssetClassAlt_Key
,[Source System]
,SourceAlt_Key
,AssetClass
,[Number of AcCOUNTs]
,[Balance Outstanding]
,[Principal Outstanding] 
FROM (

SELECT 
@Date                      AS DateofData,
AssetClassAlt_Key,
'Indus'                    AS [Source System],
2                          AS SourceAlt_Key,
AssetClassShortName        AS AssetClass,
0                          AS [Number of AcCOUNTs],
0                          AS [Balance Outstanding],
0                          AS [Principal Outstanding]
FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 

WHERE EffectiveFromTimeKey <= @Timekey  AND EffectiveToTimeKey >= @Timekey

EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #ACCOUNT
WHERE SourceName = 'Indus' 
      AND  CustomerAcID NOT IN (SELECT DISTINCT AcID FROM ExceptionFinalStatusType))p


UNION ALL

SELECT 
DateofData,
10                                           AS AssetClassAlt_Key,
SourceName                                   AS [Source System],
2,
'Total'                                      AS AssetClass,
COUNT(DISTINCT CustomerAcID)                 AS [Number of AcCOUNTs],
SUM(ISNULL(Balance,0))                       AS [Balance Outstanding],
SUM(ISNULL(PrincOutStd,0))                   AS [Principal Outstanding]
FROM #ACCOUNT
WHERE SourceName= 'Indus'  
GROUP BY SourceName,DateofData

UNION ALL

SELECT 
@Date,
10                                           AS AssetClassAlt_Key,
'Indus'                                      AS [Source System],
2,
'Total'                                      AS AssetClass,
0                                            AS [Number of AcCOUNTs],
0                                            AS [Balance Outstanding],
0                                            AS [Principal Outstanding]
 

)P 

UNION ALL 

--------------ECBF--------

SELECT 
DateofData,
AssetClassAlt_Key,
[Source System],
SourceAlt_Key,
AssetClass,
[Number of AcCOUNTs],
[Balance Outstanding],
[Principal Outstanding] 
FROM (
SELECT 
@Date DateofData,
AssetClassAlt_Key,
'ECBF'                AS [Source System],
3                     AS SourceAlt_Key,
AssetClassShortName   AS AssetClass,
0                     AS [Number of AcCOUNTs],
0                     AS [Balance Outstanding],
0                     AS [Principal Outstanding] 
FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE  EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey

EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #ACCOUNT
WHERE SourceName = 'ECBF' 
      AND  CustomerAcID NOT IN (SELECT DISTINCT AcID FROM ExceptionFinalStatusType))p

UNION ALL

SELECT 
DateofData,
10                           AS AssetClassAlt_Key,
SourceName                   AS [Source System],
3,
'Total'                      AS AssetClass,
COUNT(DISTINCT CustomerAcID) AS [Number of AcCOUNTs],
SUM(ISNULL(Balance,0))       AS [Balance Outstanding],
SUM(ISNULL(PrincOutStd,0))   AS [Principal Outstanding]
FROM #ACCOUNT
WHERE SourceName= 'ECBF'  
GROUP BY SourceName,DateofData

UNION ALL

SELECT 
@Date,
10                                           AS AssetClassAlt_Key,
'ECBF'                                       AS [Source System],
3,
'Total'                                      AS AssetClass,
0                                            AS [Number of AcCOUNTs],
0                                            AS [Balance Outstanding],
0                                            AS [Principal Outstanding]
)P 

UNION ALL

--------------Mifin--------

SELECT 
DateofData,
AssetClassAlt_Key,
[Source System],
SourceAlt_Key,
AssetClass,
[Number of AcCOUNTs],
[Balance Outstanding],
[Principal Outstanding] 
FROM (
SELECT 
@Date                 AS DateofData,
AssetClassAlt_Key,
'Mifin'               AS [Source System],
4                     AS SourceAlt_Key,
AssetClassShortName   AS AssetClass,
0                     AS [Number of AcCOUNTs],
0                     AS [Balance Outstanding],
0                     AS [Principal Outstanding]

FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE  EffectiveFromTimeKey <= @Timekey  AND EffectiveToTimeKey >= @Timekey

EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #ACCOUNT
WHERE SourceName = 'Mifin' 
      AND  CustomerAcID NOT IN (SELECT DISTINCT AcID FROM ExceptionFinalStatusType))p

UNION ALL

SELECT 
DateofData,
10                               AS AssetClassAlt_Key,
SourceName                       AS [Source System],
4,
'Total'                          AS AssetClass, 
COUNT(DISTINCT CustomerAcID)     AS [Number of AcCOUNTs],
SUM(ISNULL(Balance,0))           AS [Balance Outstanding],
SUM(ISNULL(PrincOutStd,0))       AS [Principal Outstanding]
FROM #ACCOUNT
WHERE SourceName= 'Mifin'  
GROUP BY SourceName,DateofData

UNION ALL

SELECT 
@Date,
10                                           AS AssetClassAlt_Key,
'Mifin'                                      AS [Source System],
4,
'Total'                                      AS AssetClass,
0                                            AS [Number of AcCOUNTs],
0                                            AS [Balance Outstanding],
0                                            AS [Principal Outstanding]
)P 

 UNION ALL

--------------Ganaseva--------


SELECT 
DateofData,
AssetClassAlt_Key,
[Source System],
SourceAlt_Key,
AssetClass,
[Number of AcCOUNTs],
[Balance Outstanding],
[Principal Outstanding] 
FROM (
SELECT 
@Date DateofData,
AssetClassAlt_Key,
'Ganaseva' [Source System],
5          SourceAlt_Key,
AssetClassShortName AssetClass,
0 [Number of AcCOUNTs],
0 [Balance Outstanding],
0 [Principal Outstanding]

FROM 
(
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey

EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #ACCOUNT
WHERE SourceName = 'Ganaseva' 
      AND  CustomerAcID NOT IN (SELECT DISTINCT AcID FROM ExceptionFinalStatusType))p

UNION ALL

SELECT 
DateofData,
10                              AS AssetClassAlt_Key,
SourceName                      AS [Source System],
5,
'Total'                         AS AssetClass,
COUNT(DISTINCT CustomerAcID)    AS [Number of AcCOUNTs],
SUM(ISNULL(Balance,0))          AS [Balance Outstanding],
SUM(ISNULL(PrincOutStd,0))      AS [Principal Outstanding]
FROM #ACCOUNT
WHERE SourceName= 'Ganaseva'  
GROUP BY SourceName,DateofData

UNION ALL

SELECT 
@Date,
10                                           AS AssetClassAlt_Key,
'Ganaseva'                                   AS [Source System],
5,
'Total'                                      AS AssetClass,
0                                            AS [Number of AcCOUNTs],
0                                            AS [Balance Outstanding],
0                                            AS [Principal Outstanding]
)P 

--------------Visionplus--------

UNION ALL


SELECT 
DateofData,
AssetClassAlt_Key,
[Source System],
SourceAlt_Key,
AssetClass,
[Number of AcCOUNTs],
[Balance Outstanding],
[Principal Outstanding] 
FROM (
SELECT 
@Date DateofData,
AssetClassAlt_Key,
'Visionplus'        AS [Source System],
6                   AS SourceAlt_Key,
AssetClassShortName AS AssetClass,
0                   AS [Number of AcCOUNTs],
0                   AS [Balance Outstanding],
0                   AS [Principal Outstanding]
FROM 
(SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 

WHERE  EffectiveFromTimeKey <= @Timekey     AND EffectiveToTimeKey >= @Timekey

EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #ACCOUNT
WHERE SourceName = 'VisionPlus' 
	AND  CustomerAcID not in (SELECT DISTINCT AcID FROM ExceptionFinalStatusType))p


UNION ALL

SELECT 
DateofData,
10                             AS AssetClassAlt_Key,
SourceName                     AS [Source System],
6,
'Total'                        AS AssetClass,
COUNT(DISTINCT CustomerAcID)   AS [Number of AcCOUNTs],
SUM(ISNULL(Balance,0))         AS [Balance Outstanding],
SUM(ISNULL(PrincOutStd,0))     AS [Principal Outstanding]
FROM #ACCOUNT
WHERE SourceName= 'VisionPlus'  
GROUP BY SourceName,DateofData

UNION ALL

SELECT 
@Date,
10                                           AS AssetClassAlt_Key,
'VisionPlus'                                 AS [Source System],
6,
'Total'                                      AS AssetClass,
0                                            AS [Number of AcCOUNTs],
0                                            AS [Balance Outstanding],
0                                            AS [Principal Outstanding]
)P 

UNION ALL

--------------Metagrid--------

SELECT 
DateofData,
AssetClassAlt_Key,
[Source System],
SourceAlt_Key,
AssetClass,
[Number of AcCOUNTs],
[Balance Outstanding],
[Principal Outstanding] 

FROM (
SELECT 
@Date DateofData,
AssetClassAlt_Key,
'Metagrid'            AS [Source System],
8                     AS SourceAlt_Key,
AssetClassShortName   AS AssetClass,
0 [Number of AcCOUNTs],
0 [Balance Outstanding],
0 [Principal Outstanding]

FROM 

(SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM DimAssetClass 
WHERE  EffectiveFromTimeKey <= @Timekey  AND EffectiveToTimeKey >= @Timekey

EXCEPT

SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 

FROM #ACCOUNT

WHERE SourceName = 'Metagrid' 
     AND  CustomerAcID NOT IN (SELECT DISTINCT AcID FROM ExceptionFinalStatusType))p

UNION ALL

SELECT 
DateofData,
10															AS AssetClassAlt_Key,
SourceName													AS [Source System],
8,
'Total'														AS AssetClass,
COUNT(DISTINCT CustomerAcID)								AS [Number of AcCOUNTs],
SUM(ISNULL(Balance,0))										AS [Balance Outstanding],
SUM(ISNULL(PrincOutStd,0))									AS [Principal Outstanding]

FROM #ACCOUNT

WHERE SourceName= 'Metagrid'  
GROUP BY SourceName,DateofData

UNION ALL

SELECT 
@Date,
10                                           AS AssetClassAlt_Key,
'Metagrid'                                   AS [Source System],
8,
'Total'                                      AS AssetClass,
0                                            AS [Number of AcCOUNTs],
0                                            AS [Balance Outstanding],
0                                            AS [Principal Outstanding]
) P 

UNION ALL

SELECT 
DateofData,
AssetClassAlt_Key,
'ALL' [Source System],
SourceAlt_Key,
AssetClass,
[Number of Accounts]
,[Balance Outstanding]
,[Principal Outstanding] 
FROM (
SELECT  
DateofData,
AssetClassAlt_Key,
15 SourceAlt_Key,
AssetClassShortName                   AS AssetClass,
COUNT(DISTINCT CustomerAcID)          AS [Number of Accounts],
SUM(ISNULL(Balance,0))                AS [Balance Outstanding],
SUM(ISNULL(PrincOutStd,0))            AS [Principal Outstanding]
FROM #Account 
WHERE  CustomerACID NOT IN (SELECT DISTINCT AcID FROM ExceptionFinalStatusType)
GROUP BY AssetClassShortName,AssetClassAlt_Key,DateofData

UNION ALL
SELECT @Date,AssetClassAlt_Key,15,AssetClassShortName,0,0,0
FROM (
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName FROM DimAssetClass 
WHERE EffectiveFromTimeKey <= @Timekey  AND EffectiveToTimeKey >= @Timekey
EXCEPT
		
SELECT DISTINCT AssetClassAlt_key,AssetClassShortName 
FROM #Account
WHERE   CustomerAcID NOT IN (SELECT DISTINCT AcID FROM ExceptionFinalStatusType))p

UNION ALL

SELECT 
DateofData,
AssetClassAlt_Key,
15 SourceAlt_Key,
AssetClass,
SUM([Number of Accounts]),
SUM([Balance Outstanding]),
SUM([Principal Outstanding]) 
FROM #TWO 
GROUP BY DateofData,AssetClassAlt_Key,AssetClass

UNION ALL

SELECT 
DateofData,
10 AS AssetClassAlt_Key,
15 SourceAlt_Key,
'Total'                            AS AssetClass,
COUNT(DISTINCT CustomerAcID)       AS [Number of Accounts],
SUM(ISNULL(Balance,0))             AS [Balance Outstanding],
SUM(ISNULL(PrincOutStd,0))         AS [Principal Outstanding]
FROM #Account
GROUP BY  DateofData

)P

UNION ALL

SELECT 
@Date,
10                                           AS AssetClassAlt_Key,
'ALL'                                        AS [Source System],
15,
'Total'                                      AS AssetClass,
0                                            AS [Number of AcCOUNTs],
0                                            AS [Balance Outstanding],
0                                            AS [Principal Outstanding]

)DATA
where [Source System] not in('Test','Sudesh','test123') 
GROUP BY
DateofData,
AssetClassAlt_Key,
[Source System],
SourceAlt_Key,
AssetClass

ORDER BY SourceAlt_Key,AssetClassAlt_Key

OPTION(RECOMPILE)

--DROP TABLE #ACCOUNT,#TWO
GO