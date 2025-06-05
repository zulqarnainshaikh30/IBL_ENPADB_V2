SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[NHB-0002_SCH_V] 
        @TimeKey INT,
        @SelectReturn VARCHAR(50)
AS 

--DECLARE
--      @TimeKey INT=26694,  
--      @SelectReturn VARCHAR(50)=5

DECLARE @Date DATE=(SELECT CONVERT(DATE,[date]) FROM SysDayMatrix WHERE TimeKey=@TimeKey)

DECLARE @Date1 DATE,@Date2 DATE

SET @Date1=EOMONTH(DATEADD(MM,-1,@Date)) 
SET @Date2=EOMONTH(DATEADD(MM,-2,@Date)) 


DECLARE @TimeKey1 INT=(SELECT TimeKey FROM SysDayMatrix WHERE [DATE]=@Date1)
DECLARE @TimeKey2 INT=(SELECT TimeKey FROM SysDayMatrix WHERE [DATE]=@Date2)

---------------------------------------------------Current-------------------------------------------------------

IF OBJECT_ID('tempdb..#T2') IS NOT NULL 
    DROP TABLE #T2 


SELECT DISTINCT 
A.HFC_Alt_Key,
A.ReturnAlt_Key,
A.Schedule_id,
A.ReturnType 
INTO #T2
FROM ScheduleWorkflowDetail  A

WHERE A.ReturnAlt_Key=@SelectReturn AND A.ReturnDate=@Date 
      AND A.ReturnType=(SELECT MAX(B.Return_type) FROM POR_TRN_Return_upload B WHERE B.return_id=@SelectReturn AND B.return_date=@Date AND A.HFC_Alt_Key=B.Hfc_id)
      AND A.WorkFlowStageAlt_Key=11 AND A.HFC_Alt_Key<>1



OPTION(RECOMPILE)

IF OBJECT_ID('tempdb..#FactReturnData') IS NOT NULL 
    DROP TABLE #FactReturnData    
        
        SELECT     DISTINCT A.HFC_Alt_Key,
                    HFC_Name,
                    ReturnRowAlt_Key,    
                    ReturnAlt_Key,    
                    SubReturnAlt_Key,    
                    ReturnColumnAlt_Key,
                    DataValue

                INTO #FactReturnData
                FROM FactReturnData A
                INNER JOIN DimHFC      B            ON A.HFC_Alt_Key=B.HFC_Alt_Key
                                                       AND  B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
                                                      
                WHERE ReturnAlt_Key =@SelectReturn AND A.Schedule_id IN (SELECT Schedule_id FROM #T2 ) 
				      AND  A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey


				
OPTION(RECOMPILE)

    
IF OBJECT_ID('tempdb..#DataforValidation') IS NOT NULL 
    DROP TABLE #DataforValidation

        SELECT  DISTINCT
		        A.HFC_Alt_Key,
                A.HFC_Name,
                B.ReturnRowAlt_Key,    
                B.ReturnAlt_Key,                
                B.SubReturnAlt_Key,    
                C.ReturnColumnAlt_Key,

                CASE WHEN B.ReturnRowField_Code='R1295' AND C.ReturnColumnCode='C209'
					 THEN CASE WHEN   RTRIM(LTRIM(ReportDenomination))='Crores'
					 THEN	A.DataValue
					 WHEN   RTRIM(LTRIM(ReportDenomination))='Millions'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/10  AS	VARCHAR(MAX))
					 WHEN	RTRIM(LTRIM(ReportDenomination))='Lakh'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/100  AS	VARCHAR(MAX))
					 WHEN	RTRIM(LTRIM(ReportDenomination))='Thousands'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/10000  AS VARCHAR(MAX))
					 WHEN   RTRIM(LTRIM(ReportDenomination))='Absolute Rupees'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/10000000 AS	VARCHAR(MAX))
					 END
					 ELSE	A.DataValue END						AS DataValue,

                B.ReturnRowField_Code               AS RowCode,
                C.ReturnColumnCode                  AS ColumnCode,
				B.ReturnRowOrderKey,
				C.ReturnColumnOrderKey,
				HRM.ReportDenomination

        INTO #DataforValidation
        FROM #FactReturnData A 
        INNER JOIN [dbo].[DimReturnRow] B                   ON  A.ReturnRowAlt_Key=B.ReturnRowAlt_Key
                                                                AND B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey
                                                                AND A.ReturnAlt_Key=B.ReturnAlt_Key
                                                                AND A.SubReturnAlt_Key=B.SubReturnAlt_Key
                                                                AND ISNULL(ReturnRowType,'') IN('Control','SubTotal')

 

        INNER JOIN [dbo].[DimReturnColumn] C                ON C.ReturnColumnAlt_Key=A.ReturnColumnAlt_Key
                                                               AND A.ReturnAlt_Key=C.ReturnAlt_Key
                                                               AND A.SubReturnAlt_Key=C.SubReturnAlt_Key
                                                               AND C.EffectiveFromTimeKey<=@TimeKey AND C.EffectiveToTimeKey>=@TimeKey

		INNER JOIN HFCRetuenMapping   HRM                   ON A.HFC_Alt_Key=HRM.HFC_Alt_Key
                                                               AND A.ReturnAlt_Key=HRM.ReturnAlt_Key
													           AND HRM.EffectiveFromTimeKey<=@TimeKey AND HRM.EffectiveToTimeKey>=@TimeKey

        WHERE B.ReturnRowField_Code IN('R1376','R1377','R1301','R1318','R1312','R1318','R1295','R1403','R474')
              AND C.ReturnColumnCode IN ('C221','C209','C258','C140') AND C.ReturnAlt_Key=@SelectReturn
			  AND B.ReturnRowAlt_Key<>0
                
        ORDER BY ReturnRowOrderKey,ReturnColumnOrderKey


	
		

OPTION(RECOMPILE)

UPDATE #DataforValidation SET DataValue='0'  WHERE (DataValue) IN('',' ')

UPDATE #DataforValidation SET  DataValue=CAST(REPLACE(DataValue,'%','') AS DECIMAL(18,2));

--------------------------------------------------------------------------------------------------------------
--------------------------------------Last Month----------------------------------------------------------
IF OBJECT_ID('tempdb..#T2lM') IS NOT NULL 
    DROP TABLE #T2_LM 


SELECT DISTINCT 
A.HFC_Alt_Key,
A.ReturnAlt_Key,
A.Schedule_id,
A.ReturnType 
INTO #T2_LM
FROM ScheduleWorkflowDetail  A

WHERE A.ReturnAlt_Key=@SelectReturn AND A.ReturnDate=@Date1 
      AND A.ReturnType=(SELECT MAX(B.Return_type) FROM POR_TRN_Return_upload B WHERE B.return_id=@SelectReturn AND B.return_date=@Date1 AND A.HFC_Alt_Key=B.Hfc_id)
      AND A.WorkFlowStageAlt_Key=11 AND A.HFC_Alt_Key<>1

OPTION(RECOMPILE)

IF OBJECT_ID('tempdb..#FactReturnData1') IS NOT NULL 
    DROP TABLE #FactReturnData1    
        
        SELECT   DISTINCT   A.HFC_Alt_Key,
                    HFC_Name,
                    ReturnRowAlt_Key,    
                    ReturnAlt_Key,    
                    SubReturnAlt_Key,    
                    ReturnColumnAlt_Key,
                    DataValue

                INTO #FactReturnData1
                FROM FactReturnData A
                INNER JOIN DimHFC      B            ON A.HFC_Alt_Key=B.HFC_Alt_Key
                                                       AND  B.EffectiveFromTimeKey<=@TimeKey1 AND B.EffectiveToTimeKey>=@TimeKey1
                                                      
                WHERE ReturnAlt_Key =@SelectReturn AND A.Schedule_id IN (SELECT Schedule_id FROM #T2_LM ) 
				      AND  A.EffectiveFromTimeKey<=@TimeKey1 AND A.EffectiveToTimeKey>=@TimeKey1


				
OPTION(RECOMPILE)

    
IF OBJECT_ID('tempdb..#DataforValidation1') IS NOT NULL 
    DROP TABLE #DataforValidation1

        SELECT  DISTINCT
		        A.HFC_Alt_Key,
                A.HFC_Name,
                B.ReturnRowAlt_Key,    
                B.ReturnAlt_Key,                
                B.SubReturnAlt_Key,    
                C.ReturnColumnAlt_Key,
                CASE WHEN B.ReturnRowField_Code='R1295' AND C.ReturnColumnCode='C209'
					 THEN CASE WHEN   RTRIM(LTRIM(ReportDenomination))='Crores'
					 THEN	A.DataValue
					 WHEN   RTRIM(LTRIM(ReportDenomination))='Millions'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/10  AS	VARCHAR(MAX))
					 WHEN	RTRIM(LTRIM(ReportDenomination))='Lakh'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/100  AS	VARCHAR(MAX))
					 WHEN	RTRIM(LTRIM(ReportDenomination))='Thousands'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/10000  AS VARCHAR(MAX))
					 WHEN   RTRIM(LTRIM(ReportDenomination))='Absolute Rupees'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/10000000 AS	VARCHAR(MAX))
					 END
					 ELSE	A.DataValue END						AS DataValue,
                B.ReturnRowField_Code               AS RowCode,
                C.ReturnColumnCode                  AS ColumnCode,
				B.ReturnRowOrderKey,
				C.ReturnColumnOrderKey,
				HRM.ReportDenomination

        INTO #DataforValidation1
        FROM #FactReturnData1 A 
        INNER JOIN [dbo].[DimReturnRow] B                   ON  A.ReturnRowAlt_Key=B.ReturnRowAlt_Key
                                                                AND B.EffectiveFromTimeKey<=@TimeKey1 AND B.EffectiveToTimeKey>=@TimeKey1
                                                                AND A.ReturnAlt_Key=B.ReturnAlt_Key
                                                                AND A.SubReturnAlt_Key=B.SubReturnAlt_Key
                                                                AND ISNULL(ReturnRowType,'') IN('Control','SubTotal')

 

        INNER JOIN [dbo].[DimReturnColumn] C                ON C.ReturnColumnAlt_Key=A.ReturnColumnAlt_Key
                                                               AND A.ReturnAlt_Key=C.ReturnAlt_Key
                                                               AND A.SubReturnAlt_Key=C.SubReturnAlt_Key
                                                               AND C.EffectiveFromTimeKey<=@TimeKey1 AND C.EffectiveToTimeKey>=@TimeKey1

		INNER JOIN HFCRetuenMapping   HRM                   ON A.HFC_Alt_Key=HRM.HFC_Alt_Key
                                                               AND A.ReturnAlt_Key=HRM.ReturnAlt_Key
													           AND HRM.EffectiveFromTimeKey<=@TimeKey1 AND HRM.EffectiveToTimeKey>=@TimeKey1    

        WHERE B.ReturnRowField_Code IN('R1376','R1377','R1301','R1318','R1312','R1318','R1295','R1403','R474')
              AND C.ReturnColumnCode IN ('C221','C209','C258','C140') AND C.ReturnAlt_Key=@SelectReturn AND B.ReturnRowAlt_Key<>0
                
        ORDER BY ReturnRowOrderKey,ReturnColumnOrderKey


	
		

OPTION(RECOMPILE)

UPDATE #DataforValidation1 SET DataValue='0'  WHERE (DataValue) IN('',' ')

UPDATE #DataforValidation1 SET  DataValue=CAST(REPLACE(DataValue,'%','') AS DECIMAL(18,2));
-----------------------------------------------------------------------------------------------------
----------------------------------------Last To Last Month------------------------------------------------------------------

IF OBJECT_ID('tempdb..#T2lM') IS NOT NULL 
    DROP TABLE #T2_LLM 


SELECT DISTINCT 
A.HFC_Alt_Key,
A.ReturnAlt_Key,
A.Schedule_id,
A.ReturnType 
INTO #T2_LLM
FROM ScheduleWorkflowDetail  A

WHERE A.ReturnAlt_Key=@SelectReturn AND A.ReturnDate=@Date2 
      AND A.ReturnType=(SELECT MAX(B.Return_type) FROM POR_TRN_Return_upload B WHERE B.return_id=@SelectReturn AND B.return_date=@Date2 AND A.HFC_Alt_Key=B.Hfc_id)
      AND A.WorkFlowStageAlt_Key=11 AND A.HFC_Alt_Key<>1


OPTION(RECOMPILE)

IF OBJECT_ID('tempdb..#FactReturnData2') IS NOT NULL 
    DROP TABLE #FactReturnData2    
        
        SELECT   DISTINCT   A.HFC_Alt_Key,
                    HFC_Name,
                    ReturnRowAlt_Key,    
                    ReturnAlt_Key,    
                    SubReturnAlt_Key,    
                    ReturnColumnAlt_Key,
                    DataValue

                INTO #FactReturnData2
                FROM FactReturnData A
                INNER JOIN DimHFC      B            ON A.HFC_Alt_Key=B.HFC_Alt_Key
                                                       AND  B.EffectiveFromTimeKey<=@TimeKey2 AND B.EffectiveToTimeKey>=@TimeKey2
                                                      
                WHERE ReturnAlt_Key =@SelectReturn AND A.Schedule_id IN (SELECT Schedule_id FROM #T2_LLM ) 
				      AND  A.EffectiveFromTimeKey<=@TimeKey2 AND A.EffectiveToTimeKey>=@TimeKey2


				
OPTION(RECOMPILE)

    
IF OBJECT_ID('tempdb..#DataforValidation2') IS NOT NULL 
    DROP TABLE #DataforValidation2

        SELECT  DISTINCT
		        A.HFC_Alt_Key,
                A.HFC_Name,
                B.ReturnRowAlt_Key,    
                B.ReturnAlt_Key,                
                B.SubReturnAlt_Key,    
                C.ReturnColumnAlt_Key,
                CASE WHEN B.ReturnRowField_Code='R1295' AND C.ReturnColumnCode='C209'
					 THEN CASE WHEN   RTRIM(LTRIM(ReportDenomination))='Crores'
					 THEN	A.DataValue
					 WHEN   RTRIM(LTRIM(ReportDenomination))='Millions'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/10  AS	VARCHAR(MAX))
					 WHEN	RTRIM(LTRIM(ReportDenomination))='Lakh'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/100  AS	VARCHAR(MAX))
					 WHEN	RTRIM(LTRIM(ReportDenomination))='Thousands'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/10000  AS VARCHAR(MAX))
					 WHEN   RTRIM(LTRIM(ReportDenomination))='Absolute Rupees'
					 THEN	CAST(CONVERT(MONEY,A.DataValue)/10000000 AS	VARCHAR(MAX))
					 END
					 ELSE	A.DataValue END						AS DataValue,
                B.ReturnRowField_Code               AS RowCode,
                C.ReturnColumnCode                  AS ColumnCode,
				B.ReturnRowOrderKey,
				C.ReturnColumnOrderKey,
				HRM.ReportDenomination

        INTO #DataforValidation2
        FROM #FactReturnData2 A 
        INNER JOIN [dbo].[DimReturnRow] B                   ON  A.ReturnRowAlt_Key=B.ReturnRowAlt_Key
                                                                AND B.EffectiveFromTimeKey<=@TimeKey2 AND B.EffectiveToTimeKey>=@TimeKey2
                                                                AND A.ReturnAlt_Key=B.ReturnAlt_Key
                                                                AND A.SubReturnAlt_Key=B.SubReturnAlt_Key
                                                                AND ISNULL(ReturnRowType,'') IN('Control','SubTotal')

 

        INNER JOIN [dbo].[DimReturnColumn] C                ON C.ReturnColumnAlt_Key=A.ReturnColumnAlt_Key
                                                               AND A.ReturnAlt_Key=C.ReturnAlt_Key
                                                               AND A.SubReturnAlt_Key=C.SubReturnAlt_Key
                                                               AND C.EffectiveFromTimeKey<=@TimeKey2 AND C.EffectiveToTimeKey>=@TimeKey2

        INNER JOIN HFCRetuenMapping   HRM                   ON A.HFC_Alt_Key=HRM.HFC_Alt_Key
                                                               AND A.ReturnAlt_Key=HRM.ReturnAlt_Key
													           AND HRM.EffectiveFromTimeKey<=@TimeKey2 AND HRM.EffectiveToTimeKey>=@TimeKey2                     

        WHERE B.ReturnRowField_Code IN('R1376','R1377','R1301','R1318','R1312','R1318','R1295','R1403','R474')
              AND C.ReturnColumnCode IN ('C221','C209','C258','C140') AND C.ReturnAlt_Key=@SelectReturn
			  AND B.ReturnRowAlt_Key<>0
                
        ORDER BY ReturnRowOrderKey,ReturnColumnOrderKey


	
		

OPTION(RECOMPILE)

UPDATE #DataforValidation2 SET DataValue='0'  WHERE (DataValue) IN('',' ')

UPDATE #DataforValidation2 SET  DataValue=CAST(REPLACE(DataValue,'%','') AS DECIMAL(18,2));
-----------------------------------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#V_3') IS NOT NULL
DROP TABLE #V_3


;WITH CTE AS
(

SELECT * 
FROM #DataforValidation 
WHERE RowCode IN('R1301') AND ColumnCode='C209'  
),
B AS
(
SELECT * 
FROM #DataforValidation 
WHERE RowCode IN('R1318') AND ColumnCode='C209' 
)

SELECT A.HFC_Alt_Key,A.HFC_Name,A.DataValue D,B.DataValue E, 
CASE WHEN  CAST(B.DataValue AS DECIMAL(18,2))>0.0 THEN  CAST(A.DataValue AS DECIMAL(18,2))/CAST(B.DataValue AS DECIMAL(18,2))*100 END DataValue 
INTO #V_3
FROM  CTE A 
INNER JOIN  B B                ON A.HFC_Alt_Key=B.HFC_Alt_Key
;
UPDATE #V_3 SET DataValue='0.0'   WHERE DataValue IS NULL
UPDATE #V_3 SET  DataValue=CAST(REPLACE(DataValue,'%','') AS DECIMAL(18,2));

IF OBJECT_ID('tempdb..#V_3_LM') IS NOT NULL
DROP TABLE #V_3_LM

;WITH CTE AS
(

SELECT * 
FROM #DataforValidation1
WHERE RowCode IN('R1301') AND ColumnCode='C209'  
),
B AS
(
SELECT * 
FROM #DataforValidation1 
WHERE RowCode IN('R1318') AND ColumnCode='C209' 
)

SELECT A.HFC_Alt_Key,A.HFC_Name,A.DataValue D,B.DataValue E, 
CASE WHEN  CAST(B.DataValue AS DECIMAL(18,2))>0.0 THEN  CAST(A.DataValue AS DECIMAL(18,2))/CAST(B.DataValue AS DECIMAL(18,2))*100 END DataValue 
INTO #V_3_LM
FROM  CTE A 
INNER JOIN  B B                ON A.HFC_Alt_Key=B.HFC_Alt_Key
;
UPDATE #V_3_LM SET DataValue='0.0'   WHERE DataValue IS NULL
UPDATE #V_3_LM SET  DataValue=CAST(REPLACE(DataValue,'%','') AS DECIMAL(18,2));

IF OBJECT_ID('tempdb..#V_3_LLM') IS NOT NULL
DROP TABLE #V_3_LLM

;WITH CTE AS
(

SELECT * 
FROM #DataforValidation2 
WHERE RowCode IN('R1301') AND ColumnCode='C209'  
),
B AS
(
SELECT * 
FROM #DataforValidation2 
WHERE RowCode IN('R1318') AND ColumnCode='C209' 
)

SELECT A.HFC_Alt_Key,A.HFC_Name,A.DataValue D,B.DataValue E, 
CASE WHEN  CAST(B.DataValue AS DECIMAL(18,2))>0.0 THEN  CAST(A.DataValue AS DECIMAL(18,2))/CAST(B.DataValue AS DECIMAL(18,2))*100 END DataValue 
INTO #V_3_LLM
FROM  CTE A 
INNER JOIN  B B                ON A.HFC_Alt_Key=B.HFC_Alt_Key
;
UPDATE #V_3_LLM SET DataValue='0.0'   WHERE DataValue IS NULL
UPDATE #V_3_LLM SET  DataValue=CAST(REPLACE(DataValue,'%','') AS DECIMAL(18,2));

---------------------------------------------------------------------------
IF OBJECT_ID('tempdb..#V_4') IS NOT NULL
DROP TABLE #V_4


;WITH CTE AS
(

SELECT * 
FROM #DataforValidation 
WHERE RowCode IN('R1312') AND ColumnCode='C209'  
),
B AS
(
SELECT * 
FROM #DataforValidation 
WHERE RowCode IN('R1318') AND ColumnCode='C209'  
)

SELECT A.HFC_Alt_Key,A.HFC_Name,A.DataValue D,B.DataValue E, CASE WHEN  CAST(B.DataValue AS DECIMAL(18,2))>0.0 THEN  CAST(A.DataValue AS DECIMAL(18,2))/CAST(B.DataValue AS DECIMAL(18,2))*100 END DataValue 
INTO #V_4
FROM  CTE A 
INNER JOIN  B B
ON A.HFC_Alt_Key=B.HFC_Alt_Key
;
UPDATE #V_4 SET DataValue='0.0'   WHERE DataValue IS NULL
UPDATE #V_4 SET  DataValue=CAST(REPLACE(DataValue,'%','') AS DECIMAL(18,2));

IF OBJECT_ID('tempdb..#V_4_LM') IS NOT NULL
DROP TABLE #V_4_LM


;WITH CTE AS
(

SELECT * 
FROM #DataforValidation1 
WHERE RowCode IN('R1312') AND ColumnCode='C209'  
),
B AS
(
SELECT * 
FROM #DataforValidation1 
WHERE RowCode IN('R1318') AND ColumnCode='C209'  
)

SELECT A.HFC_Alt_Key,A.HFC_Name,A.DataValue D,B.DataValue E, CASE WHEN  CAST(B.DataValue AS DECIMAL(18,2))>0.0 THEN  CAST(A.DataValue AS DECIMAL(18,2))/CAST(B.DataValue AS DECIMAL(18,2))*100 END DataValue 
INTO #V_4_LM
FROM  CTE A 
INNER JOIN  B B
ON A.HFC_Alt_Key=B.HFC_Alt_Key
;
UPDATE #V_4_LM SET DataValue='0.0'   WHERE DataValue IS NULL
UPDATE #V_4_LM SET  DataValue=CAST(REPLACE(DataValue,'%','') AS DECIMAL(18,2));

IF OBJECT_ID('tempdb..#V_4_LLM') IS NOT NULL
DROP TABLE #V_4_LLM


;WITH CTE AS
(

SELECT * 
FROM #DataforValidation2 
WHERE RowCode IN('R1312') AND ColumnCode='C209'  
),
B AS
(
SELECT * 
FROM #DataforValidation2 
WHERE RowCode IN('R1318') AND ColumnCode='C209'  
)

SELECT A.HFC_Alt_Key,A.HFC_Name,A.DataValue D,B.DataValue E, CASE WHEN  CAST(B.DataValue AS DECIMAL(18,2))>0.0 THEN  CAST(A.DataValue AS DECIMAL(18,2))/CAST(B.DataValue AS DECIMAL(18,2))*100 END DataValue 
INTO #V_4_LLM
FROM  CTE A 
INNER JOIN  B B   ON A.HFC_Alt_Key=B.HFC_Alt_Key
;
UPDATE #V_4_LLM SET DataValue='0.0'   WHERE DataValue IS NULL
UPDATE #V_4_LLM SET  DataValue=CAST(REPLACE(DataValue,'%','') AS DECIMAL(18,2));


------------------------------------------------------------------------------------------
SELECT DENSE_RANK()OVER(ORDER BY Parameter)RN,* FROM(
SELECT 
'Indicator 1'                    AS Parameter,
'Percentage of gross non-performing assets (GNPA) to total loans & advances(>=5 %)'                    AS ParameterName,
HFC_Alt_Key,
--DataValue,
CASE  WHEN CAST(SUBSTRING(DataValue,1,4) AS DECIMAL(30,2))>=5.0
      THEN CONCAT(HFC_Name,'('+DataValue +'%)')
      ELSE ''
      END                          AS Threshold,
CASE WHEN CAST(SUBSTRING(DataValue,1,4) AS DECIMAL(30,2))>=7.0 
     THEN CONCAT(HFC_Name,'('+DataValue +'%)')
     ELSE ''
     END                         AS EWSThreshold1,
CASE WHEN CAST(SUBSTRING(DataValue,1,4) AS DECIMAL(30,2))>=3.0
     THEN CONCAT(HFC_Name,'('+DataValue +'%)')
     ELSE ''
     END                         AS EWSThreshold2
FROM #DataforValidation 
WHERE RowCode='R1376' AND ColumnCode='C221'

UNION ALL

SELECT  
'Indicator 2'                    AS Parameter,
'Percentage of net non-performing assets (NNPA) to net loans & advances(>=3 %)'                    AS ParameterName,
HFC_Alt_Key,
--DataValue,
CASE WHEN CAST(SUBSTRING(DataValue,1,4) AS DECIMAL(30,2))>=3.0
     THEN CONCAT(HFC_Name,'('+DataValue +'%)')
     ELSE ''
     END                          AS Threshold,
CASE WHEN CAST(SUBSTRING(DataValue,1,4) AS DECIMAL(30,2))>=5.0
     THEN CONCAT(HFC_Name,'('+DataValue +'%)')
     ELSE ''
     END                         AS EWSThreshold1,
CASE WHEN CAST(SUBSTRING(DataValue,1,4) AS DECIMAL(30,2))>=1.0
     THEN CONCAT(HFC_Name,'('+DataValue +'%)')
     ELSE ''
     END                         AS EWSThreshold2

FROM #DataforValidation 
WHERE RowCode='R1377' AND ColumnCode='C221'

UNION ALL

SELECT  
'Indicator 3'                    AS Parameter,
'Percentage of disbursement (housing loans to builder + corporate) to total disbursement of loans and advances (Continuously for 3 months) i.e. in three consecutive returns(>75 %)'                    AS ParameterName,
A.HFC_Alt_Key,
--A.DataValue,
CASE WHEN ISNULL(CAST(A.DataValue AS DECIMAL(18,2)),0.0)>75.0 AND ISNULL(CAST(B.DataValue AS DECIMAL(18,2)),0.0)>75.0 AND ISNULL(CAST(C.DataValue AS DECIMAL(18,2)),0.0)>75.0
     THEN CONCAT(A.HFC_Name,'('+CAST(CAST(A.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
	      '('+CAST(CAST(B.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
		  '('+CAST(CAST(C.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)')
     ELSE ''
     END                          AS Threshold,
CASE WHEN ISNULL(CAST(A.DataValue AS DECIMAL(18,2)),0.0)>77.0 AND ISNULL(CAST(B.DataValue AS DECIMAL(18,2)),0.0)>77.0 AND ISNULL(CAST(C.DataValue AS DECIMAL(18,2)),0.0)>77.0
     THEN CONCAT(A.HFC_Name,'('+CAST(CAST(A.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
	      '('+CAST(CAST(B.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
		  '('+CAST(CAST(C.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)') 
     ELSE ''
     END                         AS EWSThreshold1,
CASE WHEN ISNULL(CAST(A.DataValue AS DECIMAL(18,2)),0.0)>73.0 AND ISNULL(CAST(B.DataValue AS DECIMAL(18,2)),0.0)>73.0 AND ISNULL(CAST(C.DataValue AS DECIMAL(18,2)),0.0)>73.0
     THEN CONCAT(A.HFC_Name,'('+CAST(CAST(A.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
	      '('+CAST(CAST(B.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
		  '('+CAST(CAST(C.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)')
     ELSE ''
     END                         AS EWSThreshold2

FROM #V_3 A
LEFT JOIN #V_3_LM  B                    ON A.HFC_Alt_Key=B.HFC_Alt_Key
LEFT JOIN #V_3_LLM C                    ON A.HFC_Alt_Key=C.HFC_Alt_Key

UNION ALL

SELECT  
'Indicator 4'                    AS Parameter,
'Percentage of disbursement (non- housing loans to builder + corporate) to total disbursement of loans and advances (Continuously for 3 months) i.e. in three consecutive returns(>75 %)'                    AS ParameterName,
A.HFC_Alt_Key,
--A.DataValue,
CASE WHEN ISNULL(CAST(A.DataValue AS DECIMAL(18,2)),0.0)>75.0 AND ISNULL(CAST(B.DataValue AS DECIMAL(18,2)),0.0)>75.0 AND ISNULL(CAST(C.DataValue AS DECIMAL(18,2)),0.0)>75.0
     THEN CONCAT(A.HFC_Name,'('+CAST(CAST(A.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
	      '('+CAST(CAST(B.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
		  '('+CAST(CAST(C.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)')
     ELSE ''
     END                          AS Threshold,
CASE WHEN ISNULL(CAST(A.DataValue AS DECIMAL(18,2)),0.0)>77.0 AND ISNULL(CAST(B.DataValue AS DECIMAL(18,2)),0.0)>77.0 AND ISNULL(CAST(C.DataValue AS DECIMAL(18,2)),0.0)>77.0
     THEN CONCAT(A.HFC_Name,'('+CAST(CAST(A.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
	      '('+CAST(CAST(B.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
		  '('+CAST(CAST(C.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)') 
     ELSE ''
     END                         AS EWSThreshold1,
CASE WHEN ISNULL(CAST(A.DataValue AS DECIMAL(18,2)),0.0)>73.0 AND ISNULL(CAST(B.DataValue AS DECIMAL(18,2)),0.0)>73.0 AND ISNULL(CAST(C.DataValue AS DECIMAL(18,2)),0.0)>73.0
     THEN CONCAT(A.HFC_Name,'('+CAST(CAST(A.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
	      '('+CAST(CAST(B.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
		  '('+CAST(CAST(C.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)')
     ELSE ''
     END                         AS EWSThreshold2

FROM #V_4 A
LEFT JOIN #V_4_LM  B                    ON A.HFC_Alt_Key=B.HFC_Alt_Key
LEFT JOIN #V_4_LLM C                    ON A.HFC_Alt_Key=C.HFC_Alt_Key


UNION ALL

SELECT 
DISTINCT
'Indicator 5'                    AS Parameter,
'Cumulative disbursements of Individual Housing Loans during the previous 3 months i.e. total value of the previous three consecutive returns (< 1 Crore)'                    AS ParameterName,
A.HFC_Alt_Key,
--A.DataValue,
CASE WHEN ISNULL(CAST(A.DataValue AS DECIMAL(18,2)),0.0)<1.0 AND ISNULL(CAST(B.DataValue AS DECIMAL(18,2)),0.0)<1.0 AND ISNULL(CAST(C.DataValue AS DECIMAL(18,2)),0.0)<1.0
     THEN CONCAT(A.HFC_Name,'('+CAST(CAST(A.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
	      '('+CAST(CAST(B.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)',
		  '('+CAST(CAST(C.DataValue AS DECIMAL(18,2)) AS VARCHAR(50)) +'%)')
     ELSE ''
     END
									AS Threshold,
		''							AS EWSThreshold1,
		''							AS EWSThreshold2

FROM #DataforValidation A
LEFT JOIN #DataforValidation1  B                    ON A.HFC_Alt_Key=B.HFC_Alt_Key
                                                      AND A.ColumnCode=B.ColumnCode
													  AND A.RowCode=B.RowCode

LEFT JOIN #DataforValidation2 C						ON A.HFC_Alt_Key=C.HFC_Alt_Key
                                                      AND A.ColumnCode=C.ColumnCode
													  AND A.RowCode=C.RowCode
)DA
WHERE ISNULL(Threshold,'')<>'' 
ORDER BY Parameter,Threshold

 

OPTION(RECOMPILE)


DROP TABLE  #DataforValidation,#FactReturnData,#DataforValidation1,#DataforValidation2,#FactReturnData1,#FactReturnData2,#T2,#T2_LLM,#T2_LM,#V_3,#V_4


GO