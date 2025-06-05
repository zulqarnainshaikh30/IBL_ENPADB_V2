CREATE TABLE [CurDat].[AdvAcOtherDetail] (
  [EntityKey] [bigint] NOT NULL,
  [AccountEntityId] [int] NOT NULL,
  [GovGurAmt] [decimal](14) NULL,
  [SplCatg1Alt_Key] [smallint] NULL,
  [SplCatg2Alt_Key] [smallint] NULL,
  [RefinanceAgencyAlt_Key] [smallint] NULL,
  [RefinanceAmount] [decimal](14) NULL,
  [BankAlt_Key] [varchar](10) NULL,
  [TransferAmt] [decimal](14) NULL,
  [ProjectId] [int] NULL,
  [ConsortiumId] [int] NULL,
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
  [SplCatg3Alt_Key] [smallint] NULL,
  [SplCatg4Alt_Key] [smallint] NULL,
  [MocTypeAlt_Key] [int] NULL,
  [GovGurExpDt] [date] NULL,
  [SplFlag] [varchar](250) NULL,
  CONSTRAINT [AdvAcOtherDetail_PK] PRIMARY KEY NONCLUSTERED ([EffectiveFromTimeKey], [EffectiveToTimeKey], [AccountEntityId]) WITH (FILLFACTOR = 90),
  CHECK ([EffectiveToTimeKey]=(49999))
)
ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [AdvAcOtherDetail_ClsIdx]
  ON [CurDat].[AdvAcOtherDetail] ([EntityKey])
  ON [PRIMARY]
GO