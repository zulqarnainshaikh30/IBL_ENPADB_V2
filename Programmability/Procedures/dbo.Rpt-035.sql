SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


/*
Report Name			-  Degrade Status Report As On
Create by			-  KALIK DEV
Date				-  10 NOV 2021
*/

create PROCEDURE [dbo].[Rpt-035]
@DateFrom	AS VARCHAR(15),
@DateTo		AS VARCHAR(15)

AS

BEGIN


--DECLARE 
	  
--@DateFrom	AS VARCHAR(15)='01/01/2021',
--@DateTo		AS VARCHAR(15)='12/11/2021'

DECLARE	@From1		DATE=(SELECT Rdate FROM dbo.DateConvert(@DateFrom))
DECLARE @To1		DATE=(SELECT Rdate FROM dbo.DateConvert(@DateTo))


IF OBJECT_ID('TEMPDB..#AA') IS NOT NULL
   DROP TABLE #AA

SELECT	
DISTINCT 
DateofData,SourceSystemName AS [Host System],COUNT(1) COUNT
INTO #AA
FROM  ReverseFeedData 
WHERE AssetClass > 1
GROUP BY DateofData,SourceSystemName
ORDER BY DateofData,SourceSystemName

OPTION(RECOMPILE)

---------Degrade Report-------------------

IF OBJECT_ID('TEMPDB..#BB') IS NOT NULL
   DROP TABLE #BB

SELECT 
DISTINCT
CONVERT(DATE,SD.Date, 105)					           AS  [Process_date]
,SourceName                                            AS  [Host System]
,COUNT(1) COUNT
INTO #BB
FROM PRO.AccountCal_Hist B 

INNER JOIN SYSDAYMATRIX SD								ON B.EffectiveFromTimeKey=SD.TIMEKEY


INNER JOIN PRO.CustomerCal_Hist A						ON A.EffectiveFromTimeKey=SD.TIMEKEY
														   AND A.CustomerEntityID=B.CustomerEntityID


LEFT JOIN DIMSOURCEDB src        						ON B.SourceAlt_Key =src.SourceAlt_Key
														   AND SRC.EffectiveToTimeKey = 49999

	
WHERE InitialAssetClassAlt_Key = 1 AND FinalAssetClassAlt_Key > 1
      AND CAST(SD.DATE AS DATE) BETWEEN @From1 AND @To1

GROUP BY CONVERT(DATE,SD.DATE, 105) ,SourceName
ORDER BY CONVERT(DATE,SD.DATE, 105) ,SourceName

OPTION(RECOMPILE)

SELECT 
CONVERT(VARCHAR(20),DateofData,103)     AS DATE,
A.[Host System],
A.COUNT                          AS DegradeRFCount,
B.COUNT                          AS DegradeReportCount,
(CASE WHEN A.COUNT = B.COUNT 
      THEN 'TRUE' 
	  ELSE 'FALSE' 
	  END)                       AS Status

FROM #AA A 
INNER JOIN   #BB B            ON CONVERT(DATE,DateofData,105) = CONVERT(DATE,Process_date,105)  
                                 AND A.[Host System] = B.[Host System]

ORDER BY CONVERT(DATE,DateofData,105) 

OPTION(RECOMPILE)

END

DROP TABLE #AA,#BB
GO