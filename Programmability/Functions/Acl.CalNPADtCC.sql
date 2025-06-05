SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Madhur Nagar>
-- Create date: <21/04/2011>
-- Description:	<Calculation of minimum NPA DATE IN CC>

-- Modified by: Shivendra Kumar Yadav
-- =============================================

CREATE FUNCTION [Acl].[CalNPADtCC](@Timekey int,@DtReviewDeg date,@DtStockDeg date,@DtConExcessDeg date,@CADDegDt date,@DtLastCrDeg date,@ODDtDeg date)
RETURNS SmallDatetime
--WITH ENCRYPTION
AS
BEGIN

        DECLARE @NPADt date , @AssetClassificationDt date 

		SELECT @AssetClassificationDt = [Date]
		FROM SysDayMatrix
		WHERE TimeKey = @Timekey


		SELECT @NPADt = MIN(Dt)
		FROM (
				SELECT @DtReviewDeg AS Dt
				UNION ALL
				SELECT @DtStockDeg AS Dt
				UNION ALL
				SELECT @DtConExcessDeg AS Dt
				UNION ALL
				SELECT @CADDegDt AS Dt
				UNION ALL
				SELECT @DtLastCrDeg
				UNION ALL
				SELECT @ODDtDeg
				UNION ALL
				SELECT @AssetClassificationDt AS Dt
		     )Dt


    /*
	   --DECLARETION PART
		DECLARE @NPADt smalldatetime,@dtTest smalldatetime,@dtTestNPA smalldatetime
		
		--SET DEFAULT NULL
		SELECT @NPADt=NULL
		
		
		--Calculate Minimum NPA Date
		IF @CADDegDt IS NOT NULL
		BEGIN
			If @DtReviewDeg <= @DtStockDeg 
				BEGIN
					SELECT @dtTest = @DtReviewDeg
					SELECT @dtTestNPA = @dtTest
				END 
			Else
				BEGIN
					SELECT @dtTest = @DtStockDeg
					SELECT @dtTestNPA = @dtTest
				END
	      
			If @dtTest <= @DtConExcessDeg 
				BEGIN
					SELECT @dtTest = @dtTest
					SELECT @dtTestNPA = @dtTest
				END
			Else
				BEGIN
					SELECT @dtTest = @DtConExcessDeg
					SELECT @dtTestNPA = @dtTest
				END 
	      
			If @dtTest <= @CADDegDt
				BEGIN 
					SELECT @dtTest = @dtTest
					SELECT @dtTestNPA = @dtTest
				END
			Else
				BEGIN
					SELECT @dtTest = @CADDegDt
					SELECT @dtTestNPA = @dtTest
				END
	         
			 SELECT @NPADt=@dtTest
       END

	   */

	RETURN @NPADt	
END
GO