SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--/*
--CREATE BY	           : KALIK DEV
--CREATE DATE	       : 21/12/2023 
--DISCRIPTION	       : Credit Card Asset Classification Processing 
--*/



create PROC [dbo].[Rpt-055_Partner_Selection] 
	@TimeKey int
 
	
  AS

--DECLARE 
--	@Timekey int=26999

SELECT 
SourceAlt_Key,
SourceName
FROM DIMSOURCEDB WHERE SourceAlt_Key NOT IN(1,5) AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
ORDER BY SourceName
GO