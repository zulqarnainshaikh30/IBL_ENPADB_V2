CREATE TABLE [dbo].[SecuritizedDetail_stg] (
  [EntityKey] [int] IDENTITY,
  [SrNo] [varchar](max) NULL,
  [UploadID] [int] NULL,
  [SummaryID] [int] NULL,
  [PoolID] [varchar](max) NULL,
  [PoolName] [varchar](max) NULL,
  [PoolType] [varchar](max) NULL,
  [AccountID] [varchar](max) NULL,
  [InterestAccruedinRs] [varchar](max) NULL,
  [SecuritisationExposureinRs] [varchar](max) NULL,
  [DateofSecuritisationmarking] [varchar](max) NULL,
  [MaturityDate] [varchar](max) NULL,
  [Action] [varchar](max) NULL,
  [filname] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO