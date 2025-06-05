SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[AccountLevelDropDown]

  
AS
  BEGIN

  Declare @TimeKey as Int 

	Set @TimeKey = (Select Timekey from SysDataMatrix where CurrentStatus='C')
	
			select ParameterShortNameEnum as ParameterAlt_Key
			,ParameterName
			,'RestructureFlag' as TableName
			from dimparameter
			where DimParameterName='DimYesNo'
			And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

			select ParameterShortNameEnum as ParameterAlt_Key
			,ParameterName
			,'FITLFlag' as TableName
			from dimparameter
			where DimParameterName='DimYesNo'
			And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

			select ParameterShortNameEnum as ParameterAlt_Key
			,ParameterName
			,'InherentWeaknessFlag' as TableName
			from dimparameter
			where DimParameterName='DimYesNo'
			And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

			select ParameterShortNameEnum as ParameterAlt_Key
			,ParameterName
			,'SARFAESIFlag' as TableName
			from dimparameter
			where DimParameterName='DimYesNo'
			And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

			select ParameterShortNameEnum as ParameterAlt_Key
			,ParameterName
			,'UnusualBounceFlag' as TableName
			from dimparameter
			where DimParameterName='DimYesNo'
			And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

			select ParameterShortNameEnum as ParameterAlt_Key
			,ParameterName
			,'UnclearedEffectsFlag' as TableName
			from dimparameter
			where DimParameterName='DimYesNo'
			And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

			select ParameterShortNameEnum as ParameterAlt_Key
			,ParameterName
			,'RePossessionFlag' as TableName
			from dimparameter
			where DimParameterName='DimYesNo'
			And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey

			Select	 ParameterShortNameEnum as ParameterAlt_Key
					,ParameterName
					,'FraudAccountFlag' as Tablename 
			from DimParameter where DimParameterName ='DimYesNo'
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

      select MOCTypeAlt_Key,
			 MOCTypeName
			 ,'MOCSource' as TableName
			 from dimmoctype
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

			 select ParameterAlt_Key ,
			 ParameterName 
			 ,'MOCReason' as TableName
			 from DimParameter
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimMOCReason'


			   --------Added on 16/09/2022 to fetch SMA sub asset class value as per requirement by Priyali------- 

			  select AssetClassMappingAlt_Key,
			  AssetClassAlt_Key,
			 AssetClassShortName
			 ,'SMASubAssetClassValue' as TableName
			 from dimassetclassmapping

			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

			 --=========Get MetaData for Changes Fields=======
			 SELECT *, 'AccountLevelNPAMOC' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='AccountLevelNPAMOC'
END
GO