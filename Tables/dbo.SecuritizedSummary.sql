CREATE TABLE [dbo].[SecuritizedSummary] (
  [EntityKey] [int] IDENTITY,
  [SummaryID] [int] NULL,
  [PoolID] [varchar](max) NULL,
  [PoolName] [varchar](max) NULL,
  [PoolType] [int] NULL,
  [POS] [decimal](18, 2) NULL,
  [SecuritisationExposureAmt] [decimal](18, 2) NULL,
  [SecuritisationReckoningDate] [date] NULL,
  [SecuritisationMarkingDate] [date] NULL,
  [SecuritisationPortfolio] [decimal](18, 2) NULL,
  [DateofRemoval] [date] NULL,
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
  [SecuritisationType] [varchar](50) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO