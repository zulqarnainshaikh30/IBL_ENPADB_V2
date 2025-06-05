CREATE TABLE [dbo].[DimNPAAgeingMaster_Mod] (
  [EntityKey] [int] IDENTITY,
  [NPAAlt_Key] [int] NULL,
  [BusinessRule] [varchar](1000) NULL,
  [RefValue] [varchar](1000) NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [Changes] [varchar](500) NULL,
  [Remark] [varchar](500) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [Changefields] [varchar](100) NULL,
  [DateApprovedFirstLevel] [datetime] NULL,
  [ApprovedByFirstLevel] [varchar](20) NULL
)
ON [PRIMARY]
GO