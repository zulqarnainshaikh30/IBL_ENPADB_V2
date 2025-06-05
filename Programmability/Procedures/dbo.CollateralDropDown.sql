SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[CollateralDropDown]

---Exec [dbo].[CollateralDropDown]
  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')
		
	


		Select ParameterAlt_Key
		,ParameterName
		,'TaggingLevel' as Tablename 
		from DimParameter where DimParameterName='DimRatingType'
		and ParameterName not in ('Guarantor')
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		order by ParameterName Desc

		Select ParameterAlt_Key
		,ParameterName
		,'DistributionModel' as Tablename 
		from DimParameter where DimParameterName='Collateral'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select CollateralTypeAltKey
		,CollateralTypeDescription
		,'CollateralType' as Tablename 
		from DimCollateralType 
		where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select CollateralSubTypeAltKey
		,CollateralSubTypeDescription
		,'CollateralSubType' as Tablename 
		from DimCollateralSubType 
		where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select CollateralOwnerTypeAltKey
		,CollOwnerDescription
		,'CollateralOwnerType' as Tablename 
		from DimCollateralOwnerType 
		where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		and CollOwnerDescription not in ('Relative')

		Select SecurityChargeTypeAlt_Key
		,SecurityChargeTypeName
		,'ChargeNature' as Tablename 
		from DimSecurityChargeType 
		where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		and SecurityChargeTypeGroup='COLLATERAL'

		Select ParameterAlt_Key
		,ParameterName
		,'ShareAvailabletoBank' as Tablename 
		from DimParameter where DimParameterName='CollateralBank'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select CollateralChargeTypeAltKey
		,CollChargeDescription
		,'ChargeType' as Tablename 
		from DimCollateralChargeType 
		where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select ParameterAlt_Key
		,ParameterName
		,'CollateralOwnershipType' as Tablename 
		from DimParameter where DimParameterName='CollateralOwnershipType'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		



END
GO