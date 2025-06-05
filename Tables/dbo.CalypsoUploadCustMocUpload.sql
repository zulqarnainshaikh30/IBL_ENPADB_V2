CREATE TABLE [dbo].[CalypsoUploadCustMocUpload] (
  [SlNo] [varchar](max) NULL,
  [UCICID] [varchar](max) NULL,
  [AssetClass] [varchar](max) NULL,
  [NPIDate] [varchar](max) NULL,
  [AdditionalProvision] [varchar](max) NULL,
  [MOCSource] [varchar](max) NULL,
  [MOCType] [varchar](max) NULL,
  [MOCReason] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [Entity_Key] [int] IDENTITY,
  [SourceAlt_Key] [tinyint] NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO