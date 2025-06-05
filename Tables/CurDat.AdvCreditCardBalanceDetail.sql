CREATE TABLE [CurDat].[AdvCreditCardBalanceDetail] (
  [EntityKey] [bigint] NOT NULL,
  [AccountEntityId] [int] NOT NULL,
  [CreditCardEntityId] [int] NOT NULL,
  [Balance_POS] [decimal](18, 2) NULL,
  [Balance_LOAN] [decimal](18, 2) NULL,
  [Balance_INT] [decimal](18, 2) NULL,
  [Balance_GST] [decimal](18, 2) NULL,
  [Balance_FEES] [decimal](18, 2) NULL,
  [RefSystemAcId] [varchar](30) NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [datetime] NOT NULL,
  [MocStatus] [char](1) NULL,
  [MocDate] [smalldatetime] NULL,
  CONSTRAINT [AdvCreditCardBalanceDetail_CreditCardEntityId] PRIMARY KEY NONCLUSTERED ([AccountEntityId], [CreditCardEntityId], [EffectiveFromTimeKey], [EffectiveToTimeKey]),
  CHECK ([EffectiveToTimeKey]=(49999))
)
ON [PRIMARY]
GO