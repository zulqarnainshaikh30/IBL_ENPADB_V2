SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE proc [dbo].[rpt-037_sysDate]
as
SELECT
		TimeKey AS DateKey,
		CONVERT(VARCHAR(10),Date,103) AS 'DateCaption' ,
		TimeKey AS Code,
		CONVERT(VARCHAR(10),Date,103) AS 'Description' 
		
FROM Dbo.SysDayMatrix  SYDM
------------- SUDARSHAN AND Khandpal sir suggested for current date (Pradeep)--------------
--WHERE Date>='2019-03-31' AND TimeKey<=(SELECT TimeKey FROM   SysDataMatrix Where CurrentStatus='C')
WHERE Date>='2019-03-31' AND Date<=GETDATE()
		
ORDER BY TimeKey DESC 
GO