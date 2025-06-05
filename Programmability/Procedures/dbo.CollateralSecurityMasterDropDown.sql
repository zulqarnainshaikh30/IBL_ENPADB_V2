SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[CollateralSecurityMasterDropDown]

  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')

		
		Select 
		CollateralTypeAltKey
		,CollateralTypeID
		,CollateralType
		,CollateralTypeDescription
		,'CollateralType' TableName
		from DimCollateralType 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey

		
		Select  ParameterAlt_Key
		,ParameterName
		,'Valid' as Tablename 
		from DimParameter where DimParameterName ='DimYesNo'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey




 END
GO