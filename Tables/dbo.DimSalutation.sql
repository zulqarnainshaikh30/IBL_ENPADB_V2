CREATE TABLE [dbo].[DimSalutation] (
  [Salutation_Key] [smallint] NOT NULL,
  [SalutationAlt_Key] [smallint] NULL,
  [SalutationName] [varchar](50) NULL,
  [SalutationShortName] [varchar](20) NULL,
  [SalutationShortNameEnum] [varchar](20) NULL,
  [SalutationGroup] [varchar](50) NULL,
  [SalutationSubGroup] [varchar](50) NULL,
  [SalutationSegment] [varchar](50) NULL,
  [SalutationValidCode] [char](1) NULL,
  [SrcSysSalutationCode] [varchar](50) NULL,
  [SrcSysSalutationName] [varchar](50) NULL,
  [DestSysSalutationCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
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