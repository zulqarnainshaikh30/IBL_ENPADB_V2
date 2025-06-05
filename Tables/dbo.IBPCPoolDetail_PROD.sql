CREATE TABLE [dbo].[IBPCPoolDetail_PROD] (
  [SummaryID] [int] NULL,
  [PoolID] [varchar](max) NULL,
  [PoolName] [varchar](max) NULL,
  [CustomerID] [varchar](max) NULL,
  [AccountID] [varchar](max) NULL,
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
  [EntityKey] [int] IDENTITY,
  [POS] [decimal](18, 2) NULL,
  [InterestReceivable] [decimal](18, 2) NULL,
  [IBPCExposureAmt] [decimal](18, 2) NULL,
  [OSBalance] [decimal](18, 2) NULL,
  [IBPCExposureinRs] [decimal](16, 2) NULL,
  [DateofIBPCreckoning] [date] NULL,
  [DateofIBPCmarking] [date] NULL,
  [MaturityDate] [date] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO