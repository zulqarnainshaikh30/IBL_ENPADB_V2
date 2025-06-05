SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CollateralMasterDownload
Create PROC [dbo].[AccountLvlMOCMasterDownload]
As

BEGIN

Declare @TimeKey as Int
	--SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

	SET @TimeKey = (Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 

	

select 
			 MOCTypeName as MOCSource
			 ,'MOCSource' as TableName
			 from dimmoctype
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

		
select 
			 SourceName as SourceSystem
			 ,'SourceSystem' as TableName
			 from DIMSOURCEDB
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey



	
			select ParameterAlt_Key,
			 ParameterName 
			 ,'MOCReason' as TableName
			 from DimParameter
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimMOCReason'


		---------------Added by kapil on 28/11/2023
	Select    ParameterAlt_Key,
	           ParameterName,
	          'MOCType' as Tablename     
			from DimParameter where DimParameterName='MOCType' 
			And  EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey  
		
			
			


	END














GO