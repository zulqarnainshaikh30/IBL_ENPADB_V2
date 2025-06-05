CREATE TABLE [dbo].[AdvAcRelations_Mod] (
  [EntityKey] [int] IDENTITY,
  [BranchCode] [varchar](10) NULL,
  [RelationEntityId] [int] NULL,
  [CustomerEntityId] [int] NOT NULL,
  [AccountEntityId] [int] NOT NULL,
  [RelationTypeAlt_Key] [smallint] NULL,
  [RelationSrNo] [smallint] NULL,
  [RelationshipAuthorityCodeAlt_Key] [smallint] NULL,
  [InwardNo] [int] NULL,
  [FacilityNo] [varchar](10) NULL,
  [GuaranteeValue] [decimal](16, 2) NULL,
  [RefCustomerID] [varchar](20) NULL,
  [RefSystemAcId] [varchar](30) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  [StatusActionTaken] [varchar](1000) NULL
)
ON [PRIMARY]
GO