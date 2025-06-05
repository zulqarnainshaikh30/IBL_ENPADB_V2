CREATE TABLE [PRO].[ContinousExcessSecDtAccountCal] (
  [EntityKey] [bigint] IDENTITY,
  [CustomerAcID] [varchar](30) NULL,
  [AccountEntityId] [int] NULL,
  [Balance] [decimal](18, 2) NULL,
  [SecurityValue] [decimal](18, 2) NULL,
  [ContinousExcessSecDt] [date] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL
)
ON [PRIMARY]
GO