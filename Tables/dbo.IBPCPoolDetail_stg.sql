CREATE TABLE [dbo].[IBPCPoolDetail_stg] (
  [SrNo] [varchar](1) NULL,
  [UploadID] [int] NULL,
  [SummaryID] [int] NULL,
  [PoolID] [varchar](max) NULL,
  [PoolName] [varchar](max) NULL,
  [PoolType] [varchar](max) NULL,
  [AccountID] [varchar](max) NULL,
  [IBPCExposureinRs] [varchar](max) NULL,
  [DateofIBPCmarking] [varchar](max) NULL,
  [MaturityDate] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [Action] [varchar](10) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO