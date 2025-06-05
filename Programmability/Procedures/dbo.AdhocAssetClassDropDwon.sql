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
CREATE PROCEDURE [dbo].[AdhocAssetClassDropDwon] 
--@AssetClassAlt_Key INT =0
	

AS

   Begin
		
		Declare @TimeKey as Int
			 SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

 --  SET @EffectiveFromTimeKey  = @TimeKey

	--SET @EffectiveToTimeKey = @Timekey
 
	

				Select Distinct	 ParameterAlt_Key AS MOCReasonAlt_Key
					,ParameterName AS MOCReason
					,'ChangeReason' as Tablename 
			from DimParameter where DimParameterName='DimMoRreason'
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey



			Select	 AssetClassAlt_Key
					,AssetClassName
					,'AssetClass' as Tablename 
			from DimAssetClass 
			where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
			order by AssetClassAlt_Key
			
			Select	 ParameterAlt_Key
			,ParameterName
			,'ChangeType' as Tablename 
			from DimParameter where DimParameterName='MOCType'
							And	 EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey

					
		SELECT *, 'AdhocAssetClassChange' AS TableName FROM MetaScreenFieldDetail WHERE ScreenName='AdhocAssetClassChange'
	
	END


							



GO