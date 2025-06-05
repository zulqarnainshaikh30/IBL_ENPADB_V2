CREATE TABLE [dbo].[IBPCPoolSummary_Mod] (
  [EntityKey] [int] IDENTITY,
  [UploadID] [int] NULL,
  [SummaryID] [int] NULL,
  [PoolID] [varchar](max) NULL,
  [PoolName] [varchar](max) NULL,
  [PoolType] [varchar](30) NULL,
  [BalanceOutstanding] [decimal](18, 2) NULL,
  [IBPCExposureAmt] [decimal](18, 2) NULL,
  [IBPCReckoningDate] [date] NULL,
  [IBPCMarkingDate] [date] NULL,
  [MaturityDate] [date] NULL,
  [AuthorisationStatus] [varchar](20) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](100) NULL,
  [DateModified] [date] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [ChangeFields] [varchar](100) NULL,
  [NoOfAccount] [int] NULL,
  [TotalPosBalance] [decimal](18, 2) NULL,
  [TotalInttReceivable] [decimal](18, 2) NULL,
  [ApprovedByFirstLevel] [varchar](100) NULL,
  [DateApprovedFirstLevel] [date] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO