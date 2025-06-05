SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CustomerDetailsScreenMetaFieldsBind_CommonFunc]
	@UserID varchar(20)='dm410',
    @TimeKey INT='49999'
AS
    
BEGIN
--------------For Customer Tab------------
SELECT [ScreenName]
      ,[CtrlName]
      ,[ResourceKey]
      ,[FldDataType]
      ,[Col_lg]
      ,[Col_md]
      ,[Col_sm]
      ,[MinLength]
      ,[MaxLength]
      ,[ErrorCheck]
      ,[DataSeq]
      ,[FldGridView]
      ,[CriticalErrorType]
      ,[ScreenFieldNo]
      ,[IsEditable]
      ,[IsVisible]
      ,[IsUpper]
      ,[IsMandatory]
      ,[AllowChar]
      ,[DisAllowChar]
      ,[DefaultValue]
      ,[AllowToolTip]
      ,[ReferenceColumnName]
      ,[ReferenceTableName]
      ,[MOC_Flag]
	  ,[HigherLevelEdit]
	  ,ISNULL(IsMocVisible,'N') as IsMocVisible
	  ,CASE WHEN ISNULL(IsExtractedEditable,'Y')='Y' THEN 'false' else 'true' end as IsExtractedEditable
	   FROM [dbo].[MetaScreenFieldDetail] WHERE ScreenName='Customer' order by DataSeq

---------For AdditionalCustomerDetails Tab--------
SELECT [ScreenName]
      ,[CtrlName]
      ,[ResourceKey]
      ,[FldDataType]
      ,[Col_lg]
      ,[Col_md]
      ,[Col_sm]
      ,[MinLength]
      ,[MaxLength]
      ,[ErrorCheck]
      ,[DataSeq]
      ,[FldGridView]
      ,[CriticalErrorType]
      ,[ScreenFieldNo]
      ,[IsEditable]
      ,[IsVisible]
      ,[IsUpper]
      ,[IsMandatory]
      ,[AllowChar]
      ,[DisAllowChar]
      ,[DefaultValue]
      ,[AllowToolTip]
      ,[ReferenceColumnName]
      ,[ReferenceTableName]
      ,[MOC_Flag]
	  ,[HigherLevelEdit]
	  ,CASE WHEN ISNULL(IsExtractedEditable,'Y')='Y' THEN 'false' else 'true' end as IsExtractedEditable
	   FROM [dbo].[MetaScreenFieldDetail] WHERE ScreenName='AdditionalCustomerDetails' order by DataSeq

---------------For AddressDetails Tab-------------
SELECT [ScreenName]
      ,[CtrlName]
      ,[ResourceKey]
      ,[FldDataType]
      ,[Col_lg]
      ,[Col_md]
      ,[Col_sm]
      ,[MinLength]
      ,[MaxLength]
      ,[ErrorCheck]
      ,[DataSeq]
      ,[FldGridView]
      ,[CriticalErrorType]
      ,[ScreenFieldNo]
      ,[IsEditable]
      ,[IsVisible]
      ,[IsUpper]
      ,[IsMandatory]
      ,[AllowChar]
      ,[DisAllowChar]
      ,[DefaultValue]
      ,[AllowToolTip]
      ,[ReferenceColumnName]
      ,[ReferenceTableName]
      ,[MOC_Flag]
	  ,[HigherLevelEdit]
	  ,CASE WHEN ISNULL(IsExtractedEditable,'Y')='Y' THEN 'false' else 'true' end as IsExtractedEditable
	   FROM [dbo].[MetaScreenFieldDetail] WHERE ScreenName='AddressDetails' order by DataSeq


		
		--- For Customer screen Speedup

		--Basic
		SELECT 'BasicDetailsMaster' TableName, 'DimConstitution' MasterTable UNION				--Y
		SELECT 'BasicDetailsMaster' TableName, 'DimReligion'	 MasterTable UNION				--Y
		SELECT 'BasicDetailsMaster' TableName, 'DimCaste'		 MasterTable UNION				--Y
		SELECT 'BasicDetailsMaster' TableName, 'DimSplCategory' MasterTable UNION				--N (Added in MetaParameterisedmasterTable)
		SELECT 'BasicDetailsMaster' TableName, 'DimASsetClass' MasterTable UNION				--Y
		SELECT 'BasicDetailsMaster' TableName, 'DimSalutation' MasterTable UNION				--Y
		SELECT 'BasicDetailsMaster' TableName, 'DimAddressCategory' MasterTable UNION				
		SELECT 'BasicDetailsMaster' TableName, 'DimType' MasterTable UNION
		SELECT 'BasicDetailsMaster' TableName, 'DimLegalNatureOfActivity' MasterTable UNION
		SELECT 'BasicDetailsMaster' TableName, 'DimMiscSuit' MasterTable UNION
		--SELECT 'BasicDetailsMaster' TableName, 'DimOccupation' MasterTable UNION
		SELECT 'BasicDetailsMaster' TableName, 'DimBorrowerGroup' MasterTable UNION
		SELECT 'BasicDetailsMaster' TableName, 'DimBranch' MasterTable
		SELECT 'BasicDetailsMaster' TableName, 'DimYesNo' MasterTable

--Additional Details

		--SELECT 'AdditionalDetailsMaster' TableName, 'DimReasonForWillfulDefault' MasterTable UNION
		SELECT 'AdditionalDetailsMaster' TableName, 'DimConsortiumType' MasterTable UNION
		SELECT 'AddressDetailsMaster' TableName, 'DimTypeServiceSummon' MasterTable 


-- Address Details
		SELECT 'AddressDetailsMaster' TableName, 'DimType' MasterTable UNION
		SELECT 'AddressDetailsMaster' TableName, 'DimCity' MasterTable UNION						
		SELECT 'AddressDetailsMaster' TableName, 'DimGeography' MasterTable UNION					
		SELECT 'AddressDetailsMaster' TableName, 'DimCountry' MasterTable --UNION		
		--SELECT 'AddressDetailsMaster' TableName, 'DimAddressCategory' MasterTable 	


		--- All MasterList for $scope.ListModel

		SELECT 'AllMasterList' TableName, 'DimConstitution' MasterTable UNION				
		SELECT 'AllMasterList' TableName, 'DimReligion'	 MasterTable UNION				
		SELECT 'AllMasterList' TableName, 'DimCaste'		 MasterTable UNION				
		SELECT 'AllMasterList' TableName, 'DimSplCategory' MasterTable UNION				
		SELECT 'AllMasterList' TableName, 'DimASsetClass' MasterTable UNION				
		SELECT 'AllMasterList' TableName, 'DimSalutation' MasterTable UNION				
		SELECT 'AllMasterList' TableName, 'DimYesNo' MasterTable UNION
		SELECT 'AllMasterList' TableName, 'DimBranch' MasterTable UNION
		--Additional Details
		SELECT 'AllMasterList' TableName, 'DimReasonForWillfulDefault' MasterTable UNION
		SELECT 'AllMasterList' TableName, 'DimConsortiumType' MasterTable UNION
		-- Address Details
		SELECT 'AllMasterList' TableName, 'DimCity' MasterTable UNION						
		SELECT 'AllMasterList' TableName, 'DimGeography' MasterTable UNION					
		SELECT 'AllMasterList' TableName, 'DimCountry' MasterTable UNION		
		SELECT 'AllMasterList' TableName, 'DimAddressCategory' MasterTable UNION
		SELECT 'AllMasterList' TableName, 'DimType' MasterTable UNION
		SELECT 'AllMasterList' TableName, 'DimOccupation' MasterTable UNION
		SELECT 'AllMasterList' TableName, 'DimTypeServiceSummon' MasterTable
		

		---


		SELECT 'Customer' ResourceTable UNION
		SELECT 'OtherCustomer' ResourceTable UNION
		SELECT 'AdditionalCustomerDetails' ResourceTable UNION
		SELECT 'AddressDetails' ResourceTable 


END

GO