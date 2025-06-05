SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




CREATE PROCEDURE [dbo].[Rpt-026_DateDiff]
      @DateFrom	AS VARCHAR(15),
      @DateTo		AS VARCHAR(15)
	  
AS

--DECLARE 
--    @DateFrom	AS VARCHAR(15)='01/08/2021',
--    @DateTo		AS VARCHAR(15)='09/08/2021'



DECLARE	@From1		DATE=(SELECT Rdate FROM dbo.DateConvert(@DateFrom))
DECLARE @to1		DATE=(SELECT Rdate FROM dbo.DateConvert(@DateTo))


SELECT 
DATEDIFF(DD,@From1,@to1)                               AS DDiff,
@From1                                                 AS FromDate,
@to1                                                   AS ToDate  






GO