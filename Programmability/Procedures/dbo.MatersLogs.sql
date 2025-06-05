SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[MatersLogs]
As
Declare @Startdate date= '06/10/2021'
Declare @Enddate date = '07/12/2021'
select 'AcBuSegmentName' as [Masetr Name],AcBuSegmentCode as [Masetr Code],AcBuSegmentDescription as Description ,CreatedBy as [Created By]
,DateCreated as [Date Created]
,ModifyBy as [Modifiedby]
,DateModified as [Modified Date]
,ApprovedBy as [Approved By]
,DateApproved as [Approved Date]
from dbo.DimAcBuSegment where (cast (DateCreated as date) between @Startdate and @Enddate
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











GO