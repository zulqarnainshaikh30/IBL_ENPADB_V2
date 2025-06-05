SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--(If  SUB-STANDARD then NPA Date Mandatory , date format DD-MM-YYYY
--(If DOUBTFUL I  then NPA Date Mandatory , date format DD-MM-YYYY
--(If LOS then NPA Date Mandatory , date format DD-MM-YYYY


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================  
-- Author:    <FARAHNAAZ>  Exec [CustomerLvlNPAMOCDropDown] @AssetClassAlt_Key=1
-- Create date:   <05/04/2021>  
-- Description:   <All DropDown Select Query for [CustomerLvlNPAMOCDropDown]
-- =============================================  
CREATE PROCEDURE [dbo].[CalypsoCustomerLvlNPAMOCDropDown] 
--@AssetClassAlt_Key INT =0
	

AS

   Begin
		
		Declare @TimeKey as Int
			SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 
				
			 
	

			Select	 ParameterAlt_Key
					,ParameterName
					,'MOCType' as Tablename 
			from DimParameter where DimParameterName='MOCType'
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
					
					
					Select	 ParameterAlt_Key
					,ParameterName
					,'FraudAccountFlag' as Tablename 
			from DimParameter where DimParameterName ='DimYesNo'
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

			Select	 AssetClassAlt_Key
					,AssetClassName
					,'AssetClass' as Tablename 
			from DimAssetClass 
			where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
			and AssetClassAlt_Key NOT IN (4,5)
			order by AssetClassAlt_Key

			select MOCTypeAlt_Key,
			 MOCTypeName
			 ,'MOCSource' as TableName
			 from dimmoctype
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey


			select ParameterAlt_Key,
			 ParameterName 
			 ,'MOCReason' as TableName
			 from DimParameter
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimMOCReason'


			  select 
			 SourceName as SourceSystem
			 ,'SourceSystem' as TableName
			 from DIMSOURCEDB
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey



			--BEGIN
			--IF (@AssetClassAlt_Key=1)
			--Begin
			--Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key=2 
			--End

			--	IF (@AssetClassAlt_Key=2)
			--	Begin
			--	Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (1,3) 
			--	End


			--	IF (@AssetClassAlt_Key=3)
			--	Begin
			--	Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (2,4) 
			--	End

			--	IF (@AssetClassAlt_Key=4)
			--	Begin
			--	Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (3,5) 
			--	End

			--	IF (@AssetClassAlt_Key=5)
			--	Begin
			--	Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (4,6) 
			--	End

			--	IF (@AssetClassAlt_Key=6)
			--	Begin
			--	Select AssetClassAlt_Key,AssetClassName from DimAssetClass where AssetClassAlt_Key in (5) 
			--	End
			SELECT *, 'CalypsoCustomerLevelNPAMOC' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='CalypsoCustomerLevelNPAMOC'
	
	END


							



GO