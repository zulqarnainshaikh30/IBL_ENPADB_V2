CREATE TABLE [dbo].[SolutionGlobalParameter_Mod] (
  [EntityKey] [int] IDENTITY,
  [ParameterAlt_Key] [int] NULL,
  [ParameterName] [varchar](500) NULL,
  [ParameterValueAlt_Key] [int] NULL,
  [ParameterNatureAlt_Key] [int] NULL,
  [From_Date] [datetime] NULL,
  [To_Date] [datetime] NULL,
  [ParameterStatusAlt_Key] [int] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [Changes] [varchar](100) NULL,
  [Remark] [varchar](100) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [smalldatetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [smalldatetime] NULL
)
ON [PRIMARY]
GO