CREATE TABLE [dbo].[UploadCustMocPool] (
  [SrNo] [int] NULL,
  [UploadID] [int] NULL,
  [SummaryID] [int] NULL,
  [SlNo] [varchar](max) NULL,
  [CustomerID] [varchar](max) NULL,
  [AssetClass] [varchar](max) NULL,
  [NPADate] [varchar](max) NULL,
  [SecurityValue] [varchar](max) NULL,
  [AdditionalProvision%] [varchar](max) NULL,
  [MOCSource] [varchar](max) NULL,
  [MOCType] [varchar](max) NULL,
  [MOCReason] [varchar](max) NULL,
  [filename] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO