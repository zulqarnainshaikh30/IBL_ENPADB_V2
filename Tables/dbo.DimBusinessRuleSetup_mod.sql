CREATE TABLE [dbo].[DimBusinessRuleSetup_mod] (
  [Entitykey] [int] IDENTITY,
  [BusinessRule_Alt_key] [int] NULL,
  [CatAlt_key] [int] NULL,
  [UniqueID] [int] NULL,
  [Businesscolalt_key] [int] NULL,
  [Scope] [int] NULL,
  [Businesscolvalues1] [varchar](max) NULL,
  [Businesscolvalues] [varchar](max) NULL,
  [ChangeFields] [varchar](100) NULL,
  [Remarks] [varchar](100) NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL,
  PRIMARY KEY CLUSTERED ([Entitykey])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO