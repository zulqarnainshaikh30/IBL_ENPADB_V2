CREATE TABLE [CurDat].[AcDailyTxnDetail] (
  [ENTITYKEY] [bigint] NOT NULL,
  [Branchcode] [varchar](10) NULL,
  [CustomerID] [varchar](20) NULL,
  [CustomerAcID] [varchar](20) NOT NULL,
  [AccountEntityId] [int] NULL,
  [TxnDate] [date] NOT NULL,
  [TxnType] [varchar](10) NULL,
  [TxnSubType] [varchar](20) NULL,
  [TxnTime] [varchar](20) NULL,
  [CurrencyAlt_Key] [int] NULL,
  [CurrencyConvRate] [decimal](10, 5) NULL,
  [TxnAmount] [decimal](16, 2) NULL,
  [TxnAmountInCurrency] [decimal](16, 2) NULL,
  [ExtDate] [date] NULL,
  [TxnRefNo] [varchar](50) NULL,
  [TxnValueDate] [date] NULL,
  [MnemonicCode] [varchar](20) NULL,
  [Particular] [varchar](500) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [datetime] NULL,
  [Remark] [varchar](1000) NULL,
  [TrueCredit] [char](1) NULL,
  [IsProcessed] [char](1) NULL,
  [Balance] [decimal](18, 2) NULL,
  CONSTRAINT [AcDailyTxnDetail_EntityKey] PRIMARY KEY NONCLUSTERED ([ENTITYKEY], [TxnDate]),
  CHECK ([TxnDate]>getdate())
)
ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [AcDailyTxnDetail_ClsIdx]
  ON [CurDat].[AcDailyTxnDetail] ([ENTITYKEY])
  ON [PRIMARY]
GO