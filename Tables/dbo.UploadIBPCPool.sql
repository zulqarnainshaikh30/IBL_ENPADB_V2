CREATE TABLE [dbo].[UploadIBPCPool] (
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
  [Action] [varchar](10) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO