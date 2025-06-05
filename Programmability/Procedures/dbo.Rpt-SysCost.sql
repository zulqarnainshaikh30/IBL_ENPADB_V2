SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE Proc [dbo].[Rpt-SysCost]

@ReportID Varchar(10)

AS
BEGIN

		SELECT 1			AS Value , 'Actuals'		AS Caption, 1			AS Code , 'Actuals'		AS 'Description'
		UNION ALL
		SELECT 1000			AS Value , 'Thousands'	AS Caption, 1000			AS Code , 'Thousands'	AS 'Description'
		UNION ALL
		SELECT 100000		AS Value , 'Lacs'		AS Caption,100000		AS Code , 'Lacs'		AS 'Description'
		UNION ALL
		SELECT 10000000		AS Value , 'Crores'		AS Caption,10000000		AS Code , 'Crores'		AS 'Description'


ORDER BY Value

END
GO