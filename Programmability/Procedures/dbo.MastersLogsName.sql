SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[MastersLogsName]
As
Declare @Startdate date= '06/10/2021'
Declare @Enddate date = '07/12/2021'
select 'AcBuSegmentName' as [Masetr Name],AcBuSegmentCode as [Masetr Code],AcBuSegmentDescription as Description ,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [Modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
from dbo.DimAcBuSegment 
where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
UNION
select 'SplCategoryName',SplCatAlt_Key,SplCatName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimAcSplCategory where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate) 
Union
select 'Activity Name',ActivityValidCode,ActivityName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimActivity where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate) 
Union
select 'MappingName',ActivityValidCode,ActivityName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimActivityMapping where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate) 
Union
select 'MappingName',ActivityValidCode,ActivityName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimActivityMapping _mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
 select 'AddressCategoryname',AddressCategoryAlt_Key,AddressCategoryName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimAddressCategory where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'AreaName',AreaValidCode,AreaName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimArea where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'AssetClassName',AssetClassValidCode,AssetClassName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimAssetClass where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'AssestClassMappingName',SrcSysClassCode,SrcSysClassName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimAssetClassMapping where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'AssestClassMappingName',SrcSysClassCode,SrcSysClassName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimAssetClassMapping_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'AuthorityName',AuthorityValidCode,AuthorityName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimAuthority where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'BankingArrangementName',BankingArrangementAlt_Key,ArrangementDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimBankingArrangement where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'BankingArrangementName',BankingArrangementAlt_Key,ArrangementDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimBankingArrangement_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'BankRPName',BankCode,BankName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimBankRP where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'BankRPName',BankCode,BankName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimBankRP_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'BranchName',BranchCode,BranchName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimBranch where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'BranchName',BranchCode,BranchName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimBranch_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'BusinessNmae',BusinessGroupValidCode,BusinessGroupName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimBusinessGroup where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'BusinessRuleNmae',BusinessRuleColValidCode,BusinessRuleColDesc,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimBusinessRuleCol where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'BusinessRuleSetup',BusinessRule_Alt_key,Businesscolvalues1,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimBusinessRuleSetup where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'BusinessRuleSetup',BusinessRule_Alt_key,Businesscolvalues1,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimBusinessRuleSetup_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'casteName', CasteValidCode,CasteName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCaste where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'CityName',CityValidCode,CityName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCity where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'CollateralchargeName',CollateralChargeTypeAltKey,CollChargeDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralChargeType where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'CollateralchargeName',CollateralChargeTypeAltKey,CollChargeDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralChargeType_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'CollateralName',CollateralCode,CollateralDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralCode_Mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'CollateralOwnerName',CollateralOwnerTypeAltKey,OwnerShipType,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralOwnerType where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'CollateralOwnerName',CollateralOwnerTypeAltKey,OwnerShipType,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralOwnerType_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'CollateralsecurityMpapping Name',SecurityValidCode,SecurityName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralSecurityMapping where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
select 'CollateralsecurityMpapping Name',SecurityValidCode,SecurityName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralSecurityMapping_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'collateralSubTypeName',CollateralTypeAltKey,CollateralSubTypeDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralSubType where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'collateralSubTypeName',CollateralTypeAltKey,CollateralSubTypeDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralSubType_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
select 'CollateralTypeNmae',CollateralTypeAltKey,CollateralTypeDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralType where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select'CollateralTypeNmae',CollateralTypeAltKey,CollateralTypeDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCollateralType_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ConsortiumType',SrcSysConsortiumCode,Consortium_Name,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimConsortiumType where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ConstitutionNmae',ConstitutionValidCode,ConstitutionName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimConstitution where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'Country Nmae',CountryValidCode,CountryName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
from dbo.DimCountry where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'CreditratingNmae',CreditRatingValidCode,CreditRatingName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCreditRating where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'CurrencyName',CurrencyCode,CurrencyName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimCurrency where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'DepartmentName',DepartmentCode,DepartmentName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.dimdepartment where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'DesignationName',DesignationValidCode,DesignationName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.dimDesignation where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ExposureBucketName',ExposureBucketAlt_Key,BucketName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimExposureBucket where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ExposureBucketName',ExposureBucketAlt_Key,BucketName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimExposureBucket_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'AgencyName',RatingValidCode,AgencyRating,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimExtAgencyRating where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'FarmerCatNmat',FarmerCatAlt_Key,FarmerCatName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimFarmerCat where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'GeographyName',GeographyValidCode,DistrictName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimGeography where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'GLNmae',GLValidCode,GLName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimGL where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'GLNmae',GLValidCode,GLName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimGL_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ProductName',GLCode,GLName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimGLProduct where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'IndustryNmae',IndustryOrderKey,IndustryName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimIndustry where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'IssueCategoryNmae',IssuerCategoryAlt_Key,IssuerCategoryName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimIssuerCategory where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'KaretmasterName',KaretMasterAlt_Key,KaretMasterValueName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimKaretMaster where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'KaretmasterName',KaretMasterAlt_Key,KaretMasterValueName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimKaretMaster_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'LegalNaturename',LegalNatureOfActivityAlt_Key,LegalNatureOfActivityName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,NULL as [Approved Date]
 from dbo.DimLegalNatureOfActivity where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (NULL as date) between @Startdate and @Enddate)
union
select 'LoginAllowanceName',UserLocationCode,UserLocationName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
 from dbo.DimMaxLoginAllow where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'MIscSuitNmae',LegalMiscSuitAlt_Key,LegalMiscSuitName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,NULL as [Approved Date] 
 from dbo.DimMiscSuit where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (NULL as date) between @Startdate and @Enddate)
union
select 'MOCTYPEName',MOCTypeAlt_Key,MOCTypeName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimMOCType where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'NPAAgeingName',NPAAlt_Key,BusinessRule,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimNPAAgeingMaster where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'NPAAgeingName',NPAAlt_Key,BusinessRule,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimNPAAgeingMaster where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'OccupationName',OccupationValidCode,OccupationName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimOccupation where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ParameterName',SrcSysParameterCode,ParameterName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimParameter where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'partitionNmae',PartitionTbaleValidCode,PartitionTbaleName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimPartitionTable where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ProductName',ProductCode,ProductName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimProduct where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ProductName',ProductCode,ProductName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimProduct_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ProvisionSegName',ProvisionAlt_Key,ProvisionRule,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimProvision_Seg where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ProvisionSegName',ProvisionAlt_Key,ProvisionRule,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimProvision_Seg_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'RegionName',RegionValidCode,RegionName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimRegion where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'ReligionName',ReligionValidCode,ReligionName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimReligion where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'ReportFrequencyName',ReportFrequencyValidCode,ReportFrequencyName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Apprved By]
,DateApproved as [Approved Date] 
 from dbo.DimReportFrequency where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ResolutionNatureName',RPNatureAlt_Key,RPDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimResolutionPlanNature where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'ResolutionNatureName',RPNatureAlt_Key,RPDescription,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimResolutionPlanNature_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'SaluationName',SalutationValidCode,SalutationName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimSalutation where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'SchemeName',SchemeValidCode,SchemeName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DIMSCHEME where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'SecurityChargeTypename',SecurityChargeTypeCode,SecurityChargeTypeName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimSecurityChargeType where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'SecurityErosionTypename',SecurityAlt_Key,BusinessRule,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimSecurityErosionMaster_Mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
UNION
select 'SegmentName',EWS_SegmentValidCode,EWS_SegmentName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimSegment where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
UNION
select 'SMANmae',SMAAlt_Key,CustomerACID,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimSMA where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'SMANmae',SMAAlt_Key,CustomerACID,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimSMA_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'SourceNmae',SourceAlt_Key,SourceName,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DIMSOURCEDB where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'SourceNmae',SourceAlt_Key,SourceName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DIMSOURCEDB_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'SplCategoryNmae',SplCatValidCode,SplCatName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimSplCategory where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'StateName',StateValidCode,StateName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimState where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
UNION
select 'Subsectorname',SubSectorValidCode,SubSectorName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModifie as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimSubSector where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModifie as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'TransactionSubTypeName',Transaction_Sub_Type_Code,Transaction_Sub_Type_Description
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimTransactionSubTypeMaster where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'TransactionSubTypeName',Transaction_Sub_Type_Code,Transaction_Sub_Type_Description
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimTransactionSubTypeMaster_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
UNION
select 'TypeServiceSummonName',ServiceSummonValidCode,ServiceSummonName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimTypeServiceSummon where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'UserDeletionReasonname',UserDeletionReasonValidCode,UserDeletionReasonName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimUserDeletionReason where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'UserDeptGroupname',DeptGroupCode,DeptGroupName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimUserDeptGroup where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'UserDeptGroupname',DeptGroupCode,DeptGroupName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimUserDeptGroup_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'UserInfoname',UserLocationCode,UserName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimUserInfo where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'UserInfoname',UserLocationCode,UserName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimUserInfo_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union

select 'userlocationname',UserLocationValidCode,LocationName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.dimuserlocation where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'UserParametersname',EntityKey,ParameterType
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimUserParameters where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'UserParametersname',EntityKey,ParameterType
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimUserParameters_mod where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
union
select 'UserRolename',UserRoleValidCode,RoleDescription
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,NULl as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,NULL as [Approved Date] 
 from dbo.DimUserRole where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (NULL as date) between @Startdate and @Enddate)
UNION
select 'ValueExpirationNmae',ValueExpirationAltKey,Documents
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifiedBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimValueExpiration where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
Union
select 'WorkFlowUseNmae',SrcSysWorkFlowUserRoleCode,WorkFlowUserRoleName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimWorkFlowUserRole where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)
UNION
select 'ZoneNmae',ZoneValidCode,ZoneName
,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date] 
 from dbo.DimZone where (cast (DateCreated as date) between @Startdate and @Enddate
OR cast (DateModified as date) between @Startdate and @Enddate
OR cast (DateApproved as date) between @Startdate and @Enddate)















GO