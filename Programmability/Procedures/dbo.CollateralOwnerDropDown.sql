SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[CollateralOwnerDropDown]

  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')
		
	


		Select  ParameterAlt_Key
		,ParameterName
		,'CustomeroftheBank' as Tablename 
		from DimParameter where DimParameterName ='DimYesNo'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select CollateralOwnerTypeAltKey
		,CollOwnerDescription
		,'OtherOwnerRelationship' as Tablename 
		from DimCollateralOwnerType 
		where CollOwnerDescription not in ('Primary Customer','Proprietor')
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

		Select  ParameterAlt_Key
		,ParameterName
		,'Relation' as Tablename 
		from DimParameter where DimParameterName ='Relation'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

END
GO