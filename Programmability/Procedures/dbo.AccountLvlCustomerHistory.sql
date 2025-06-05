SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[AccountLvlCustomerHistory]

				@AccountID varchar(30)=''
				
AS
		BEGIN				 

Declare @TimeKey as Int
	--SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

	SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 
	
	select B.CustomerID
	   ,B.CustomerName
	   --,UCIC
	   ,B.AssetClassAlt_Key
	   ,D.AssetClassName
	   ,B.NPADate
	   ,B.SecurityValue
	   ,B.AdditionalProvision
	   --,B.FraudAccountFlagAlt_Key
	   --,C.ParameterName as FraudAccountFlag
	   --,B.FraudDate
	   ,B.MOCTypeAlt_Key
	   ,E.ParameterName as MOCType
	   ,B.MOCSourceAltkey
	   ,Y.MOCTypeName as MOCSource
	   ,B.MOCReason
	   ,B.MOCBy
	   ,B.Level1ApprovedBy
	   ,B.Level2ApprovedBy
	   ,'CustomerPostMOCHistory' TableName
	    from AccountLevelMOC_Mod A
		Inner Join AdvAcBasicDetail F on A.AccountID=F.CustomerACID
inner join CustomerLevelMOC_Mod B
on B.CustomerEntityId=F.CustomerEntityID
inner join DimAssetClass D
on B.AssetClassAlt_Key=D.AssetClassAlt_Key
AND D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey
--inner join(select ParameterAlt_Key,ParameterName,'Fraud' as Tablename
-- from DimParameter where DimParameterName='DimYesNo'
-- AND EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >=@Timekey)C
-- ON B.FraudAccountFlagAlt_Key=C.ParameterAlt_Key
inner join(select ParameterAlt_Key,ParameterName,'MOCType' as Tablename
 from DimParameter where DimParameterName='MOCType'
 AND EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >=@Timekey)E
 ON B.MOCTypeAlt_Key=E.ParameterAlt_Key

 inner join	(Select	 MOCTypeAlt_Key
														,MOCTypeName	,
														'MOCSource' as Tablename 
												from dimmoctype  
												Where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey)Y
									On Y.MOCTypeAlt_Key=B.MOCSourceAltKey
 where A.EffectiveFromTimeKey <=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
 AND A.AccountID=@AccountID

-- select A.CustomerID
--	   ,A.CustomerName
--	   ,UCIC
--	   ,B.AssetClassAlt_Key
--	   ,D.AssetClassName
--	   ,B.NPADate
--	   ,B.SecurityValue
--	   ,B.AdditionalProvision
--	   ,B.FraudAccountFlagAlt_Key
--	   ,C.ParameterName as FraudAccountFlag
--	   ,B.FraudDate
--	   ,B.MOCTypeAlt_Key
--	   ,E.ParameterName as MOCType
--	   ,B.MOCReason
--	   ,B.MOCBy
--	   ,B.Level1ApprovedBy
--	   ,B.Level2ApprovedBy
--	   ,'CustomerPreMOCHistory' TableName
--	    from AccountLevelPreMOC A
--inner join CustomerLevelPreMOC B
--on A.CustomerID=B.CustomerID
--inner join DimAssetClass D
--on B.AssetClassAlt_Key=D.AssetClassAlt_Key
--AND D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey
--inner join(select ParameterAlt_Key,ParameterName,'Fraud' as Tablename
-- from DimParameter where DimParameterName='DimYesNo'
-- AND EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >=@Timekey)C
-- ON B.FraudAccountFlagAlt_Key=C.ParameterAlt_Key
--inner join(select ParameterAlt_Key,ParameterName,'MOCType' as Tablename
-- from DimParameter where DimParameterName='MOCType'
-- AND EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >=@Timekey)E
-- ON B.MOCTypeAlt_Key=E.ParameterAlt_Key
-- Where A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
-- AND A.AccountID=@AccountID

	END

GO