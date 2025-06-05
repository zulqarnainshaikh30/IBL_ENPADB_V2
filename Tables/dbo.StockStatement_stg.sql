CREATE TABLE [dbo].[StockStatement_stg] (
  [Entity_Key] [int] IDENTITY,
  [SrNo] [varchar](max) NULL,
  [CIF] [varchar](max) NULL,
  [CustomerLimitSuffix] [varchar](max) NULL,
  [StockStatementDate] [varchar](max) NULL,
  [filname] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO