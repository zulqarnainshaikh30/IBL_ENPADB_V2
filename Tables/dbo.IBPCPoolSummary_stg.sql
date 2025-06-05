CREATE TABLE [dbo].[IBPCPoolSummary_stg] (
  [EntityKey] [int] IDENTITY,
  [UploadID] [int] NULL,
  [SummaryID] [int] NULL,
  [PoolID] [varchar](max) NULL,
  [PoolName] [varchar](max) NULL,
  [PoolType] [varchar](max) NULL,
  [BalanceOutstanding] [decimal](18, 2) NULL,
  [IBPCExposureAmt] [decimal](18, 2) NULL,
  [IBPCReckoningDate] [date] NULL,
  [IBPCMarkingDate] [date] NULL,
  [MaturityDate] [date] NULL,
  [filname] [varchar](max) NULL,
  [NoOfAccount] [int] NULL,
  [TotalPosBalance] [decimal](18, 2) NULL,
  [TotalInttReceivable] [decimal](18, 2) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO