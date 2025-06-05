CREATE TABLE [dbo].[DimIssuerCategory] (
  [IssuerCategory_Key] [smallint] NOT NULL,
  [IssuerCategoryAlt_Key] [smallint] NULL,
  [IssuerCategoryName] [varchar](100) NULL,
  [IssuerCategoryShortName] [varchar](50) NULL,
  [IssuerCategoryShortNameEnum] [varchar](50) NULL,
  [IssuerCategoryGroup] [varchar](50) NULL,
  [IssuerCategorySubGroup] [varchar](50) NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO