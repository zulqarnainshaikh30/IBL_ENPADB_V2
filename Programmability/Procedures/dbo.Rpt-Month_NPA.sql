SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--=======================================================
--Created By   :-LIPSA
--Created Date :-07/05/2022
----=======================================================
CREATE PROCEDURE [dbo].[Rpt-Month_NPA]

@Year Varchar(20)
AS

--DECLARE
--@Year Varchar(20)='2023'


SELECT Distinct DATENAME(MM,DATE) MonthName,DATEPART(MM,DATE) orderby
FROM   SysDayMatrix 
WHERE --TimeKey<=(SELECT TimeKey FROM   SysDataMatrix Where CurrentStatus='C')
Date<=(SELECT (DATE) FROM Automate_Advances WHERE EXT_FLG='Y')
      and  Year(Date)=@Year
ORDER BY orderby DESC
GO