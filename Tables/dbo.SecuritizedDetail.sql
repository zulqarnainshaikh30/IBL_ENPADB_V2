CREATE TABLE [dbo].[SecuritizedDetail] (
  [EntityKey] [int] IDENTITY,
  [SummaryID] [int] NULL,
  [PoolID] [varchar](max) NULL,
  [PoolName] [varchar](max) NULL,
  [CustomerID] [varchar](max) NULL,
  [AccountID] [varchar](max) NULL,
  [AuthorisationStatus] [varchar](20) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifyBy] [varchar](100) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  [ChangeFields] [varchar](100) NULL,
  [POS] [decimal](18, 2) NULL,
  [InterestReceivable] [decimal](18, 2) NULL,
  [SecuritizedExposureAmt] [decimal](18, 2) NULL,
  [SecuritisationType] [varchar](50) NULL,
  [OSBalance] [decimal](18, 2) NULL,
  [SecuritisationExposureinRs] [decimal](16, 2) NULL,
  [DateofSecuritisationreckoning] [date] NULL,
  [DateofSecuritisationmarking] [date] NULL,
  [MaturityDate] [date] NULL,
  [Action] [char](1) NULL,
  [InterestAccruedinRs] [decimal](18, 2) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO