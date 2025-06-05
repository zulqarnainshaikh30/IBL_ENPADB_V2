CREATE TABLE [dbo].[DimUserParameters_mod] (
  [EntityKey] [smallint] IDENTITY,
  [SeqNo] [smallint] NOT NULL,
  [ParameterType] [varchar](500) NULL,
  [ShortNameEnum] [varchar](20) NOT NULL,
  [ParameterValue] [int] NULL,
  [MinValue] [smallint] NULL,
  [MaxValue] [smallint] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [Remark] [varchar](max) NULL,
  [ApprovedByFirstLevel] [varchar](100) NULL,
  [DateApprovedFirstLevel] [datetime] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO