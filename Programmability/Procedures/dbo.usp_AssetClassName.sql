SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Select * from DimAssetClass
CREATE PROC [dbo].[usp_AssetClassName] (@AssetClassAlt_Key INT)
AS

--Declare  @AssetClassAlt_Key as int =6

BEGIN
IF (@AssetClassAlt_Key=1)
Begin
Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key=2 
End

IF (@AssetClassAlt_Key=2)
Begin
Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (1,3) 
End


IF (@AssetClassAlt_Key=3)
Begin
Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (2,4) 
End

IF (@AssetClassAlt_Key=4)
Begin
Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (3,5) 
End

IF (@AssetClassAlt_Key=5)
Begin
Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (4,6) 
End

IF (@AssetClassAlt_Key=6)
Begin
Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (5) 
End

END
GO