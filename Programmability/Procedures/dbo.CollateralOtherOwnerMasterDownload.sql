SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[CollateralOtherOwnerMasterDownload]  
As  
  
BEGIN  
  
Declare @TimeKey as Int  
 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')  
  
 select CollateralOwnerTypeAltKey,CollOwnerDescription,'OtherOwnerDetails' as TableName  
 from DimCollateralOwnerType  
 where EffectiveFromTimeKey<=@TimeKey  
 AND EffectiveToTimeKey >=@TimeKey  
 order by CollateralOwnerTypeAltKey  
  
 --select RelationshipAuthorityCodeAlt_Key,RelationshipAuthorityCodeName,'Relationshipmaster' as TableName from DimRelationshipAuthorityCode A  
 --where A.EffectiveFromTimeKey<=@TimeKey  
 --AND A.EffectiveToTimeKey >=@TimeKey  
 --order by RelationshipAuthorityCodeAlt_Key  

 Select  ParameterAlt_Key
		,ParameterName
		,'Relation' as Tablename 
		from DimParameter where DimParameterName ='Relation'
		And EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey
   
 Select AddressCategory_Key,AddressCategoryName,'AddressCategory' as TableName from DimAddressCategory  
 Where EffectiveFromTimeKey<=@TimeKey  
 AND EffectiveToTimeKey >=@TimeKey  
   Order By AddressCategory_Key   
END
GO