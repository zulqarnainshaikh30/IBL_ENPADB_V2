SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
Report Name -  Host System Tracking Report
Create by   -  Manmohan Sharma
Date        -  10 NOV 2021
*/

create PROCEDURE [dbo].[Rpt-038]
      @TimeKey AS INT,
	  @Cost    AS FLOAT
AS

--DECLARE 
--      @TimeKey AS INT=25992,
--	  @Cost    AS FLOAT=1


SELECT 
CONVERT(VARCHAR(20),[Report Date],103)           AS [Report Date]
,[UCIC Code]
,CustomerID
,CustomerName
,AccountNo
,[Host System Name]
,ISNULL(OSBalance,0)/@Cost                       AS OSBalance
,ActSegmentCode
,[Account Level Business Segment]
,[Business Seg Desc]
,[Base Account Scheme Code]
,[Base Account Scheme Owner]
,[Host System Status]
,Main_Classification
,Remarks
,CONVERT(VARCHAR(20),[Closed Date],103)          AS [Closed Date]
,[Cr/Dr]
FROM HostSystemStatus 
WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
	
OPTION(RECOMPILE)	
GO