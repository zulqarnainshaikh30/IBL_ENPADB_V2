SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



/*
Create By  - Manmohan Sharma
Report     - Masters Audit Log Report
Date       - 10 Nov 2021
*/

CREATE Procedure [dbo].[Rpt-037]
@DateFrom	AS VARCHAR(10),
@DateTo	AS VARCHAR(10)
AS

--DECLARE @DateFrom	AS VARCHAR(10)= '01/07/2021',
--        @DateTo	AS VARCHAR(10)= '12/11/2021'

DECLARE	@From1		DATE=(SELECT Rdate FROM dbo.DateConvert(@DateFrom))
DECLARE @To1		DATE=(SELECT Rdate FROM dbo.DateConvert(@DateTo))

-----------------------------------------------

SELECT 
'AcBuSegmentName' AS [Masters Name],
CONVERT(VARCHAR(MAX),AcBuSegmentCode)     AS [Masetr Code],
AcBuSegmentDescription                    AS [Description] ,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimAcBuSegment 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SplCategoryName',
CONVERT(VARCHAR(MAX),SplCatAlt_Key),
SplCatName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimAcSplCategory 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)
 
UNION

SELECT 
'Activity Name',
CONVERT(VARCHAR(MAX),ActivityValidCode),
ActivityName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimActivity 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1) 

UNION

SELECT 
'MappingName',
CONVERT(VARCHAR(MAX),ActivityValidCode),
ActivityName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimActivityMapping 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
     OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
     OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)
 
UNION

SELECT 
'MappingName',
CONVERT(VARCHAR(MAX),ActivityValidCode),
ActivityName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimActivityMapping _mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'AddressCategoryname',
CONVERT(VARCHAR(MAX),AddressCategoryAlt_Key),
AddressCategoryName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimAddressCategory 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'AreaName',
CONVERT(VARCHAR(MAX),AreaValidCode),
AreaName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimArea 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
     OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
     OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'AssetClassName',
CONVERT(VARCHAR(MAX),AssetClassValidCode),
AssetClassName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimAssetClass 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'AssestClassMappingName',
CONVERT(VARCHAR(MAX),SrcSysClassCode),
SrcSysClassName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimAssetClassMapping 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'AssestClassMappingName',
CONVERT(VARCHAR(MAX),SrcSysClassCode),
SrcSysClassName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimAssetClassMapping_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'AuthorityName',
CONVERT(VARCHAR(MAX),AuthorityValidCode),
AuthorityName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimAuthority 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'BankingArrangementName',
CONVERT(VARCHAR(MAX),BankingArrangementAlt_Key),
ArrangementDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimBankingArrangement 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'BankingArrangementName',
CONVERT(VARCHAR(MAX),BankingArrangementAlt_Key),
ArrangementDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimBankingArrangement_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
     OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
     OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'BankRPName',
CONVERT(VARCHAR(MAX),BankCode),
BankName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimBankRP 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'BankRPName',
CONVERT(VARCHAR(MAX),BankCode),
BankName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimBankRP_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'BranchName',
CONVERT(VARCHAR(MAX),BranchCode),
BranchName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimBranch 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'BranchName',
CONVERT(VARCHAR(MAX),BranchCode),
BranchName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimBranch_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'BusinessName',
CONVERT(VARCHAR(MAX),BusinessGroupValidCode),
BusinessGroupName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimBusinessGroup 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'BusinessRuleName',
CONVERT(VARCHAR(MAX),BusinessRuleColValidCode),
BusinessRuleColDesc,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimBusinessRuleCol 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'BusinessRuleSetup',
CONVERT(VARCHAR(MAX),BusinessRule_Alt_key),
Businesscolvalues1,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimBusinessRuleSetup 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'BusinessRuleSetup',
CONVERT(VARCHAR(MAX),BusinessRule_Alt_key),
Businesscolvalues1,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimBusinessRuleSetup_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)


UNION

SELECT 
'CASTeName', 
CONVERT(VARCHAR(MAX),CASTeValidCode),
CASTeName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCASTe 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'CityName',
CONVERT(VARCHAR(MAX),CityValidCode),
CityName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCity 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION


SELECT 
'CollateralchargeName',
CONVERT(VARCHAR(MAX),CollateralChargeTypeAltKey),
CollChargeDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralChargeType 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'CollateralchargeName',
CONVERT(VARCHAR(MAX),CollateralChargeTypeAltKey),
CollChargeDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralChargeType_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'CollateralName',
CONVERT(VARCHAR(MAX),CollateralCode),
CollateralDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralCode_Mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'CollateralOwnerName',
CONVERT(VARCHAR(MAX),CollateralOwnerTypeAltKey),
OwnerShipType,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralOwnerType 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'CollateralOwnerName',
CONVERT(VARCHAR(MAX),CollateralOwnerTypeAltKey),
OwnerShipType,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralOwnerType_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'CollateralsecurityMpapping Name',
CONVERT(VARCHAR(MAX),SecurityValidCode),
SecurityName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralSecurityMapping 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'CollateralsecurityMpapping Name',
CONVERT(VARCHAR(MAX),SecurityValidCode),
SecurityName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralSecurityMapping_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'collateralSubTypeName',
CONVERT(VARCHAR(MAX),CollateralTypeAltKey),
CollateralSubTypeDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralSubType 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'collateralSubTypeName',
CONVERT(VARCHAR(MAX),CollateralTypeAltKey),
CollateralSubTypeDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralSubType_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'CollateralTypename',
CONVERT(VARCHAR(MAX),CollateralTypeAltKey),
CollateralTypeDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralType 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT
'CollateralTypeName',
CONVERT(VARCHAR(MAX),CollateralTypeAltKey),
CollateralTypeDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCollateralType_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ConsortiumType',
CONVERT(VARCHAR(MAX),SrcSysConsortiumCode),
Consortium_Name,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimConsortiumType 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ConstitutionName',
CONVERT(VARCHAR(MAX),ConstitutionValidCode),
ConstitutionName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimConstitution 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'Country Name',
CONVERT(VARCHAR(MAX),CountryValidCode),
CountryName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCountry 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'CreditratingName',
CONVERT(VARCHAR(MAX),CreditRatingValidCode),
CreditRatingName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCreditRating 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'CurrencyName',
CONVERT(VARCHAR(MAX),CurrencyCode),
CurrencyName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimCurrency 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'DepartmentName',
CONVERT(VARCHAR(MAX),DepartmentCode),
DepartmentName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.dimdepartment 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'DesignationName',
CONVERT(VARCHAR(MAX),DesignationValidCode),
DesignationName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.dimDesignation 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ExposureBucketName',
CONVERT(VARCHAR(MAX),ExposureBucketAlt_Key),
BucketName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimExposureBucket 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ExposureBucketName',
CONVERT(VARCHAR(MAX),ExposureBucketAlt_Key),
BucketName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimExposureBucket_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'AgencyName',
CONVERT(VARCHAR(MAX),RatingValidCode),
AgencyRating,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimExtAgencyRating 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'FarmerCatName',
CONVERT(VARCHAR(MAX),FarmerCatAlt_Key),
FarmerCatName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimFarmerCat 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'GeographyName',
CONVERT(VARCHAR(MAX),GeographyValidCode),
DistrictName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimGeography 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'GLName',
CONVERT(VARCHAR(MAX),GLValidCode),
GLName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimGL 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'GLName',
CONVERT(VARCHAR(MAX),GLValidCode),
GLName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimGL_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ProductName',
CONVERT(VARCHAR(MAX),GLCode),
GLName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimGLProduct 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'IndustryName',
CONVERT(VARCHAR(MAX),IndustryOrderKey),
IndustryName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimIndustry 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'IssueCategoryName',
CONVERT(VARCHAR(MAX),IssuerCategoryAlt_Key),
IssuerCategoryName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimIssuerCategory 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
       OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
       OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'KaretmasterName',
CONVERT(VARCHAR(MAX),KaretMasterAlt_Key),
KaretMasterValueName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimKaretMaster 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'KaretmasterName',
CONVERT(VARCHAR(MAX),KaretMasterAlt_Key),
KaretMasterValueName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimKaretMaster_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'LegalNaturename',
CONVERT(VARCHAR(MAX),LegalNatureOfActivityAlt_Key),
LegalNatureOfActivityName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
NULL                                      AS [Approved Date]
FROM dbo.DimLegalNatureOfActivity 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (NULL AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'LoginAllowanceName',
CONVERT(VARCHAR(MAX),UserLocationCode),
UserLocationName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimMaxLoginAllow 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'MIscSuitName',
CONVERT(VARCHAR(MAX),LegalMiscSuitAlt_Key),
LegalMiscSuitName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
NULL                                      AS [Approved Date] 
FROM dbo.DimMiscSuit 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (NULL AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'MOCTYPEName',
CONVERT(VARCHAR(MAX),MOCTypeAlt_Key),
MOCTypeName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimMOCType 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'NPAAgeingName',
CONVERT(VARCHAR(MAX),NPAAlt_Key),
BusinessRule,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimNPAAgeingMaster 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'NPAAgeingName',
CONVERT(VARCHAR(MAX),NPAAlt_Key),
BusinessRule,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimNPAAgeingMaster 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'OccupationName',
CONVERT(VARCHAR(MAX),OccupationValidCode),
OccupationName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimOccupation 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ParameterName',
CONVERT(VARCHAR(MAX),SrcSysParameterCode),
ParameterName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimParameter 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'partitionName',
CONVERT(VARCHAR(MAX),PartitionTbaleValidCode),
PartitionTbaleName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimPartitionTable 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ProductName',
CONVERT(VARCHAR(MAX),ProductCode),
ProductName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimProduct 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ProductName',
CONVERT(VARCHAR(MAX),ProductCode),
ProductName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimProduct_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ProvisionSegName',
CONVERT(VARCHAR(MAX),ProvisionAlt_Key),
ProvisionRule,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimProvision_Seg 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ProvisionSegName',
CONVERT(VARCHAR(MAX),ProvisionAlt_Key),
ProvisionRule,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimProvision_Seg_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'RegionName',
CONVERT(VARCHAR(MAX),RegionValidCode),
RegionName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimRegion 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ReligionName',
CONVERT(VARCHAR(MAX),ReligionValidCode),
ReligionName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimReligion 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ReportFrequencyName',
CONVERT(VARCHAR(MAX),ReportFrequencyValidCode),
ReportFrequencyName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimReportFrequency 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ResolutionNatureName',
CONVERT(VARCHAR(MAX),RPNatureAlt_Key),
RPDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimResolutionPlanNature
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ResolutionNatureName',
CONVERT(VARCHAR(MAX),RPNatureAlt_Key),
RPDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimResolutionPlanNature_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SaluationName',
CONVERT(VARCHAR(MAX),SalutationValidCode),
SalutationName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimSalutation 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SchemeName',
CONVERT(VARCHAR(MAX),SchemeValidCode),
SchemeName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DIMSCHEME 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SecurityChargeTypename',
CONVERT(VARCHAR(MAX),SecurityChargeTypeCode),
SecurityChargeTypeName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimSecurityChargeType 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SecurityErosionTypeName',
CONVERT(VARCHAR(MAX),SecurityAlt_Key),
BusinessRule,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimSecurityErosionMaster_Mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
     OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
     OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SegmentName',
CONVERT(VARCHAR(MAX),EWS_SegmentValidCode),
EWS_SegmentName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimSegment 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SMAName',
CONVERT(VARCHAR(MAX),SMAAlt_Key),
CustomerACID,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimSMA 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SMAName',
CONVERT(VARCHAR(MAX),SMAAlt_Key),
CustomerACID,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimSMA_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SourceName',
CONVERT(VARCHAR(MAX),SourceAlt_Key),
SourceName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DIMSOURCEDB
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SourceName',
CONVERT(VARCHAR(20),SourceAlt_Key),
SourceName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DIMSOURCEDB_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SplCategoryName',
CONVERT(VARCHAR(MAX),SplCatValidCode),
SplCatName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimSplCategory 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'StateName',
CONVERT(VARCHAR(MAX),StateValidCode),
StateName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimState 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'SubsectorName',
CONVERT(VARCHAR(MAX),SubSectorValidCode),
SubSectorName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModifie      AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimSubSector 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModifie AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'TransactionSubTypeName',
CONVERT(VARCHAR(MAX),Transaction_Sub_Type_Code),
Transaction_Sub_Type_Description,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimTransactionSubTypeMaster 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'TransactionSubTypeName',
CONVERT(VARCHAR(MAX),Transaction_Sub_Type_Code),
Transaction_Sub_Type_Description,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimTransactionSubTypeMaster_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'TypeServiceSummonName',
CONVERT(VARCHAR(MAX),ServiceSummonValidCode),
ServiceSummonName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimTypeServiceSummon 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'UserDeletionReasonname',
CONVERT(VARCHAR(MAX),UserDeletionReasonValidCode),
UserDeletionReasonName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimUserDeletionReason 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'UserDeptGroupName',
CONVERT(VARCHAR(MAX),DeptGroupCode),
DeptGroupName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimUserDeptGroup 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'UserDeptGroupName',
CONVERT(VARCHAR(MAX),DeptGroupCode),
DeptGroupName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimUserDeptGroup_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'UserInfoName',
CONVERT(VARCHAR(MAX),UserLocationCode),
UserName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimUserInfo 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'UserInfoName',
CONVERT(VARCHAR(MAX),UserLocationCode),
UserName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimUserInfo_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'UserlocationName',
CONVERT(VARCHAR(MAX),UserLocationValidCode),
LocationName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.dimuserlocation 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'UserParametersName',
CONVERT(VARCHAR(MAX),EntityKey),
ParameterType,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimUserParameters 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'UserParametersName',
CONVERT(VARCHAR(MAX),EntityKey),
ParameterType,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimUserParameters_mod 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'UserRoleName',
CONVERT(VARCHAR(MAX),UserRoleValidCode),
RoleDescription,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
NULL                                      AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
NULL                                      AS [Approved Date] 
FROM dbo.DimUserRole 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (NULL AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ValueExpirationName',
CONVERT(VARCHAR(MAX),ValueExpirationAltKey),
Documents,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifiedBy                                AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimValueExpiration 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'WorkFlowUseName',
CONVERT(VARCHAR(MAX),SrcSysWorkFlowUserRoleCode),
WorkFlowUserRoleName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date]
FROM dbo.DimWorkFlowUserRole 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)

UNION

SELECT 
'ZoneName',
CONVERT(VARCHAR(MAX),ZoneValidCode),
ZoneName,
CreatedBy                                 AS [Created By],
DateCreated      AS [Date Created],
ModifyBy                                  AS [Modifiedby],
DateModified     AS [Modified Date],
ApprovedBy                                AS [Approved By],
DateApproved     AS [Approved Date] 
FROM dbo.DimZone 
WHERE (CAST (DateCreated AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateModified AS DATE) BETWEEN @From1 AND @To1
      OR CAST (DateApproved AS DATE) BETWEEN @From1 AND @To1)


ORDER BY [Masters Name]
GO