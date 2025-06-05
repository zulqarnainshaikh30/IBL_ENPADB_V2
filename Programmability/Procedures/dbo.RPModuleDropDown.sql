SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[RPModuleDropDown]

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
		
	   Select ParameterAlt_Key
		,ParameterName
		,'BorrowerDefaultStatus' as Tablename 
		
		from DimParameter where DimParameterName='BorrowerDefaultStatus'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By ParameterAlt_Key

		Select ParameterAlt_Key
		,ParameterName
		,'DimImplementationStatus' as Tablename 
		
		from DimParameter where DimParameterName='ImplementationStatus'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		and ParameterAlt_Key in (2,4)
		Order By ParameterAlt_Key

		Select ParameterAlt_Key
		,ParameterName
		,'DimNewRPImplementationStatus' as Tablename 
		
		from DimParameter where DimParameterName='ImplementationStatus'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		And ParameterAlt_Key in (2,4)
		Order By ParameterAlt_Key

			Select ParameterAlt_Key
		,ParameterName
		,'DimStatusRevisedRPDeadline' as Tablename 
		
		from DimParameter where DimParameterName='StatusRevisedRPDeadline'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		and ParameterAlt_Key in (1,3)
		Order By ParameterAlt_Key

		  Select ParameterAlt_Key
		,ParameterName
		,'DimICAStatus' as Tablename 
		
		from DimParameter where DimParameterName='DimICAStatus'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By ParameterAlt_Key

		  Select ParameterAlt_Key
		,ParameterName
		,'DimRBLExposure' as Tablename 
		
		from DimParameter where DimParameterName='DimYesNo'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By ParameterAlt_Key

		Select ExposureBucketAlt_Key
		,BucketName
		,'DimExposureBucket' as Tablename 
		from DimExposureBucket
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By ExposureBucketAlt_Key

		Select BankRPAlt_Key
		,BankName
		,'BankMaster' as Tablename 
		from DimBankRP
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By BankRPAlt_Key

		Select RPNatureAlt_Key
		,RPDescription

		,'DimResolutionPlanNature' as Tablename 
		from DimResolutionPlanNature
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By RPNatureAlt_Key


		Select BankingArrangementAlt_Key
		,ArrangementDescription

		,'DimBankingArrangement' as Tablename 
		from DimBankingArrangement
		Where EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By BankingArrangementAlt_Key

	



		

		
		 Select  AssetClassAlt_Key
		,AssetClassShortName
		,'DimAssetClass' as TableName 
		from DimAssetClass A 
		where	 A.EffectiveFromTimeKey<=@TimeKey
		AND A.EffectiveToTimeKey >=@TimeKey

		Select ParameterAlt_Key
		,ParameterName
		,'Active_Inactive' as Tablename 
		
		from DimParameter where DimParameterName='DimYN'
		and EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
		Order By ParameterAlt_Key


		select CtrlName,ScreenFieldNo,'CurrentMeta' as Tablename from MetaScreenFieldDetail where ScreenName='Monitoring of Assets under Resolution Plan'
		 and CtrlName!='PAN_nO' and CtrlName!='AadharNo'
		order by ScreenFieldNo

		
		select *,'RPDetails' as Tablename from MetaScreenFieldDetail where ScreenName='Monitoring of Assets under Resolution Plan'
		and CtrlName!='PAN_NO' and CtrlName!='AadharNo'
		order by ScreenFieldNo


END





GO