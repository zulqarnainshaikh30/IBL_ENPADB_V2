CREATE TABLE [dbo].[UploadCustMocUpload] (
  [SlNo] [varchar](1) NULL,
  [CustomerID] [varchar](max) NULL,
  [AssetClass] [varchar](max) NULL,
  [NPADate] [varchar](max) NULL,
  [SecurityValue] [varchar](max) NULL,
  [MOCSource] [varchar](max) NULL,
  [MOCType] [varchar](max) NULL,
  [MOCReason] [varchar](max) NULL,
  [SourceSystem] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [Entity_Key] [int] IDENTITY,
  [SourceAlt_Key] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO