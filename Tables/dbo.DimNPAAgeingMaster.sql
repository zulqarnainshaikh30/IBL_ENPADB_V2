CREATE TABLE [dbo].[DimNPAAgeingMaster] (
  [EntityKey] [int] IDENTITY,
  [NPAAlt_Key] [int] NULL,
  [BusinessRule] [varchar](1000) NULL,
  [RefValue] [varchar](1000) NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL
)
ON [PRIMARY]
GO