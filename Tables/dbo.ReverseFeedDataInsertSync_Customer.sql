CREATE TABLE [dbo].[ReverseFeedDataInsertSync_Customer] (
  [EntityKey] [int] IDENTITY,
  [ProcessDate] [date] NULL,
  [RunDate] [date] NULL,
  [SourceName] [varchar](50) NULL,
  [CustomerID] [varchar](30) NULL,
  [FinalAssetClassAlt_Key] [int] NULL,
  [FinalNpaDt] [date] NULL,
  [UpgradeDate] [date] NULL
)
ON [PRIMARY]
GO