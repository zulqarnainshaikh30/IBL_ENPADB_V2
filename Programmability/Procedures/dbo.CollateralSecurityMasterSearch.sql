SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[CollateralSecurityMasterSearch]
   @CollateralID Int=0

AS

SELECT CollateralSubTypeAltKey,
CollateralSubTypeDescription,
'CollateralSubType' TableName 
FROM DimCollateralSubType WHERE CollateralTypeAltKey=@CollateralID
GO