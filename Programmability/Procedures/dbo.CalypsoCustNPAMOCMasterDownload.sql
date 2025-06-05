SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--CollateralMasterDownload
CREATE PROC [dbo].[CalypsoCustNPAMOCMasterDownload]
As

BEGIN

Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

		Select	 ParameterName
					,'MOCType' as Tablename 
			from DimParameter where DimParameterName='MOCType'
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
	
			Select	 AssetClassAlt_Key
					,AssetClassName,Case When AssetClassName='SUB-STANDARD' Then 'If  SUB-STANDARD then NPA Date Mandatory , date format DD/MM/YYYY'
					                     When AssetClassName='DOUBTFUL I' Then 'If  DOUBTFUL I then NPA Date Mandatory , date format DD/MM/YYYY'
                                          When AssetClassName='LOS' Then 'If  LOS I then NPA Date Mandatory , date format DD/MM/YYYY'
										  ELSE '' END as NPADate

		  ,'AssetClass' as Tablename 
			from DimAssetClass 
			where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
			and AssetClassAlt_Key NOT IN (4,5)

select 
			 MOCTypeName
			 ,'MOCSource' as TableName
			 from dimmoctype
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey


		
--select 
--			 SourceName as SourceSystem
--			 ,'SourceSystem' as TableName
--			 from DIMSOURCEDB
--			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
	


			select ParameterAlt_Key,
			 ParameterName 
			 ,'MOCReason' as TableName
			 from DimParameter
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimMOCReason'
		
	
			
		
			
			


	END










GO