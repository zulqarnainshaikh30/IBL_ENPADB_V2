CREATE TABLE [PRO].[LastCreditDtAccountCal] (
  [EntityKey] [bigint] IDENTITY,
  [CustomerAcID] [varchar](30) NULL,
  [AccountEntityId] [int] NULL,
  [LastCrDate] [datetime] NULL,
  [LasttoLastCrDate] [datetime] NULL,
  [ReturnedAmt] [decimal](18, 2) NULL,
  [CreditAmt] [decimal](18, 2) NULL,
  [DebitAmt] [decimal](18, 2) NULL,
  [Status] [varchar](1) NULL,
  [Credit_Flg] [varchar](1) NULL,
  [Acc_SrNo] [int] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
GO