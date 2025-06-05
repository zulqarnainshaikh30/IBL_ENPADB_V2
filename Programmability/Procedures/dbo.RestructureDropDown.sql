SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Proc [dbo].[RestructureDropDown]

AS

  BEGIN

Declare @Timekey as Int

Set @Timekey= (select Timekey from SysDataMatrix where currentstatus='C')

	BEGIN
	---  Drop Down for asset Class----
	   Select
          AssetClassAlt_Key
		 ,AssetClassName
		 ,'AssetClassList' As TableName
		from [dbo].[DimAssetClass]
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey

	---  Drop Down for BankingRelationship---- 
		Select 
		  ParameterAlt_Key
		 ,ParameterName
		,'BankingRelationship' As TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='BankingRelationship'

		-----  Drop Down for CovidMoratorium---- 
		--Select 
		-- ParameterAlt_Key
		--,ParameterName
		--,'CovidMoratorium' As TableName
		-- from DimParameter 
		--Where EffectiveFromTimeKey<=@TimeKey
		--And EffectiveToTimeKey>=@TimeKey
		--And DimParameterName='DimYesNoNA'


		---  Drop Down for CovidOTRCategory---- 

		Select 
		 ParameterAlt_Key
		,ParameterName
		,'CovidOTRCategory' As TableName
		 from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='Covid - OTR Category'

		---  Drop Down for RestructureFacility---- 

		Select 
		 ParameterAlt_Key
		,ParameterName
		,'RestructureFacility' As TableName
		from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='RestructureFacility'

		

		---  Drop Down for SLBCRestructuring---- 
		Select 
		 ParameterAlt_Key
		,ParameterName
		,'SLBCRestructuring' As TableName
		 from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='DimYesNoNA'
		
		---  Drop Down for StatusofMonitoringPeriod---- 


		--Select 
		--ParameterAlt_Key
		--,ParameterName
		--,'StatusofMonitoringPeriod' As TableName
		-- from DimParameter 
		--Where EffectiveFromTimeKey<=@TimeKey
		--And EffectiveToTimeKey>=@TimeKey
		--And DimParameterName='StatusofMonitoringPeriod'




		---  Drop Down for StatusofSpecificPeriod---- 


		Select 
		ParameterAlt_Key
		,ParameterName
		,'StatusofSpecificPeriod' As TableName
		 from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='StatusofSpecificPeriod'

		

		---  Drop Down for TypeofRestructuring---- 

		Select 
		--Parameter_Key
		ParameterAlt_Key
		,ParameterName
		,'TypeofRestructuring' As TableName
		 from DimParameter 
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey
		And DimParameterName='TypeofRestructuring'

		
Select
          EWS_SegmentAlt_Key
		 ,EWS_SegmentName
		 ,'RevisedBusinessSegment' As TableName
		from DimSegment
		Where EffectiveFromTimeKey<=@TimeKey
		And EffectiveToTimeKey>=@TimeKey


		END

	END
GO