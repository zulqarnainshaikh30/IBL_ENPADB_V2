CREATE TABLE [PRO].[ContExcsSinceDtDebitAccountCal] (
  [EntityKey] [bigint] IDENTITY,
  [CustomerAcID] [varchar](30) NULL,
  [AccountEntityId] [int] NULL,
  [SanctionAmt] [decimal](18, 2) NULL,
  [SanctionDt] [date] NULL,
  [Balance] [decimal](18, 2) NULL,
  [DrawingPower] [decimal](18, 2) NULL,
  [ContExcsSinceDebitDt] [date] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
GO