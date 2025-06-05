SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--=======================================================
--Created By   :-KALIK DEV
--Created Date :-28/02/2024
--=======================================================
CREATE PROCEDURE [dbo].[Rpt-Year_NPA]

AS

--DECLARE @YEAR AS INT =(SELECT YEAR(DATE) FROM Automate_Advances WHERE EXT_FLG='Y')

SELECT Distinct YEAR(DATE) YearName
FROM   SysDayMatrix Where Date<=(SELECT (DATE) FROM Automate_Advances WHERE EXT_FLG='Y') AND Date>'2020-12-31'
Order by YearName DESC
GO