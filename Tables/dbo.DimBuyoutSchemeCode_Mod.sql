CREATE TABLE [dbo].[DimBuyoutSchemeCode_Mod] (
  [EntityKey] [int] IDENTITY,
  [SchemeCodeAltKey] [int] NULL,
  [SchemeCode] [varchar](50) NULL,
  [SchemeCodeDescription] [varchar](500) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL,
  [changeFields] [varchar](100) NULL,
  [FirstLevelApprovedBy] [varchar](100) NULL,
  [FirstLevelDateApproved] [datetime] NULL
)
ON [PRIMARY]
GO