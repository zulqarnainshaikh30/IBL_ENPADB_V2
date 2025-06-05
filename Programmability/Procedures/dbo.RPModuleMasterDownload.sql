SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[RPModuleMasterDownload]

---Exec [dbo].[CollateralDropDown]
  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')
		
	


		--Select ParameterAlt_Key
		--,ParameterName
		--,'TaggingLevel' as Tablename 
		--from DimParameter where DimParameterName='DimRatingType'
		--and ParameterName not in ('Guarantor')
		--And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		--order by ParameterName Desc
		
	 --  Select ParameterAlt_Key
		--,ParameterName
		--,'DefaultStatus' as Tablename 
		
		--from DimParameter where DimParameterName='BorrowerDefaultStatus'
		--and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		--Order By ParameterAlt_Key

		--Select ParameterAlt_Key
		--,ParameterName
		--,'DimImplementationStatus' as Tablename 
		
		--from DimParameter where DimParameterName='ImplementationStatus'
		--and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		--Order By ParameterAlt_Key

		  Select ParameterAlt_Key
		,ParameterName
		,'ICAStatus' as Tablename 
		
		from DimParameter where DimParameterName='DimICAStatus'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By ParameterAlt_Key

		--  Select ParameterAlt_Key
		--,ParameterName
		--,'DimRBLExposure' as Tablename 
		
		--from DimParameter where DimParameterName='DimYesNo'
		--and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		--Order By ParameterAlt_Key

		Select 
		BucketName
		,'ExposureBucket' as Tablename 
		from DimExposureBucket
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By ExposureBucketAlt_Key

		Select BankName
		,'BankMaster' as Tablename 
		from DimBankRP
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By BankRPAlt_Key

		Select RPDescription

		,'ResolutionPlanNature' as Tablename 
		from DimResolutionPlanNature
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By RPNatureAlt_Key


		Select 
		ArrangementDescription

		,'BankingArrangement' as Tablename 
		from DimBankingArrangement
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By BankingArrangementAlt_Key

	



		

		
		-- Select  
		--AssetClassShortName
		--,'AssetClass' as TableName 
		--from DimAssetClass A 
		--where	 A.EffectiveFromTimeKey<=@TimeKey
		--AND A.EffectiveToTimeKey >=@TimeKey

END
GO