CREATE TABLE [dbo].[SecuritizedSummary_stg] (
  [EntityKey] [int] IDENTITY,
  [UploadID] [varchar](max) NULL,
  [SummaryID] [varchar](max) NULL,
  [PoolID] [varchar](max) NULL,
  [PoolName] [varchar](max) NULL,
  [SecuritisationType] [varchar](max) NULL,
  [POS] [varchar](max) NULL,
  [SecuritisationExposureAmt] [varchar](max) NULL,
  [SecuritisationReckoningDate] [varchar](max) NULL,
  [SecuritisationMarkingDate] [varchar](max) NULL,
  [MaturityDate] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [NoOfAccount] [varchar](max) NULL,
  [TotalPosBalance] [varchar](max) NULL,
  [TotalInttReceivable] [varchar](max) NULL,
  [Action] [char](1) NULL,
  [InterestAccruedinRs] [decimal](16, 2) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO