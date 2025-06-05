SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



create PROC [dbo].[Rpt-031]
	@FromDate AS VARCHAR(20),
	@ToDate   AS VARCHAR(20),
	@SourceSystem AS VARCHAR(200)
AS 


--DECLARE  @FromDate AS VARCHAR(20)='01/05/2021',
--         @ToDate   AS VARCHAR(20)='31/05/2021',
--		 @SourceSystem AS VARCHAR(200)='Finacle'
		  

DECLARE	@From1		DATE=(SELECT Rdate FROM dbo.DateConvert(@FromDate))
DECLARE @To1		DATE=(SELECT Rdate FROM dbo.DateConvert(@ToDate))


SELECT 
[UCIC Code]	
,CustomerID	                               AS [CIF ID]
,CustomerName                              AS [Customer Name]	
,AccountNo	                               AS [Account No]
,[Host System Name]					       
,SUM(ISNULL(OSBalance,0))	               AS [OS Balance]
,CONVERT(VARCHAR(20),[Report Date],103)	   AS [Report Date]	
,[Account Level Business Segment]	
,[Business Seg Desc]	
,[Base Account Scheme Code]	
,[Base Account Scheme Owner]	
,[Host System Status]	
,Remarks	
,CONVERT(VARCHAR(20),[Closed Date],103)   AS [Closed Date]	
,[Cr/Dr]
	
FROM [dbo].[HostSystemStatus]

WHERE CAST([Report Date] AS DATE)  BETWEEN @From1 AND @To1
      AND [Host System Name] IN(SELECT  * FROM Dbo.Split(@SourceSystem,',' )) 

GROUP BY
[UCIC Code]	
,CustomerID	       
,CustomerName      
,AccountNo	       
,[Host System Name]
,[Report Date]
,[Closed Date]
,[Cr/Dr]
,[Account Level Business Segment]	
,[Business Seg Desc]	
,[Base Account Scheme Code]	
,[Base Account Scheme Owner]	
,[Host System Status]	
,Remarks	


OPTION(RECOMPILE)
GO