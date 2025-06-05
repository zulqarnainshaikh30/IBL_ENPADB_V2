CREATE TABLE [dbo].[SaletoARCFinalACFlagging] (
  [EntityKey] [int] IDENTITY,
  [SourceSystem] [varchar](30) NULL,
  [CustomerID] [varchar](max) NULL,
  [CustomerName] [varchar](max) NULL,
  [AccountID] [varchar](16) NULL,
  [BalanceOutstanding] [decimal](18, 2) NULL,
  [POS] [decimal](18, 2) NULL,
  [InterestReceivable] [decimal](18, 2) NULL,
  [DtofsaletoARC] [date] NULL,
  [DateofApproval] [date] NULL,
  [ExposureAmount] [decimal](18, 2) NULL,
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
  [PoolID] [varchar](max) NULL,
  [PoolName] [varchar](max) NULL,
  [SourceAlt_Key] [int] NULL,
  [FlagAlt_Key] [varchar](30) NULL,
  [AccountBalance] [decimal](18, 2) NULL,
  [Remark] [varchar](250) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO