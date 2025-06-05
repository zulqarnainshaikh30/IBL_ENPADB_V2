SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--=======================================================
--Created By   :-LIPSA
--Created Date :-07/05/2022
--=======================================================
CREATE PROCEDURE [dbo].[Rpt-Year]

AS


SELECT Distinct YEAR(DATE) YearName
FROM   SysDayMatrix Where Date<=GetDate() AND Date>'2020-12-31'
Order by YearName DESC
GO