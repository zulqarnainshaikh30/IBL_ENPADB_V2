SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE proc [dbo].[rpt-sysDate]
as
SELECT
		TimeKey AS DateKey,
		CONVERT(VARCHAR(10),Date,103) AS 'DateCaption' ,
		TimeKey AS Code,
		CONVERT(VARCHAR(10),Date,103) AS 'Description' 
		
FROM Dbo.SysDayMatrix  SYDM

WHERE Date>='2019-03-31' AND TimeKey<=(SELECT TimeKey FROM   SysDataMatrix Where CurrentStatus='C')
		
ORDER BY TimeKey DESC 
GO