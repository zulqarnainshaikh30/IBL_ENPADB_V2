﻿CREATE TABLE [dbo].[DimConstitution] (
  [Constitution_Key] [smallint] NOT NULL,
  [ConstitutionAlt_Key] [smallint] NOT NULL,
  [ConstitutionName] [varchar](50) NULL,
  [ConstitutionShortName] [varchar](20) NULL,
  [ConstitutionShortNameEnum] [varchar](20) NULL,
  [ConstitutionGroup] [varchar](50) NULL,
  [ConstitutionSubGroup] [varchar](50) NULL,
  [ConstitutionSegment] [varchar](50) NULL,
  [ConstitutionValidCode] [char](1) NULL,
  [BsrOrganisationCode] [varchar](5) NULL,
  [AssetClass] [varchar](20) NULL,
  [CIBILConstitution] [varchar](5) NULL,
  [CIBILDetectConstitutionCode] [varchar](2) NULL,
  [RelationGroup] [varchar](20) NULL,
  [CrmSecuIssue] [smallint] NULL,
  [BaselExtRtngAppl] [char](1) NULL,
  [SrcSysConstitutionCode] [varchar](10) NULL,
  [SrcSysConstitutionName] [varchar](50) NULL,
  [DestSysConstitutionCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  [Remarks] [varchar](500) NULL,
  [Remarks1] [varchar](500) NULL,
  [SrcSysConstitutionCode1] [varchar](50) NULL
)
ON [PRIMARY]
GO