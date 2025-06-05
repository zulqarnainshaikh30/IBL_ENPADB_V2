SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--=======================================================
--Created By   :-LIPSA
--Created Date :-07/05/2022
----=======================================================
CREATE PROCEDURE [dbo].[Rpt-Month]

@Year Varchar(20)
AS

--DECLARE
--@Year Varchar(20)='2024'


SELECT Distinct DATENAME(MM,DATE) MonthName,DATEPART(MM,DATE) orderby
FROM   SysDayMatrix 
WHERE --TimeKey<=(SELECT TimeKey FROM   SysDataMatrix Where CurrentStatus='C')
Date<=GetDate()
      and  Year(Date)=@Year
ORDER BY orderby DESC
GO