CREATE TABLE [dbo].[UploadAccMOCPool] (
  [SlNo] [varchar](max) NULL,
  [AccountID] [varchar](max) NULL,
  [AdditionalProvisionAbsoluteinRs] [varchar](max) NULL,
  [AdditionalProvision] [varchar](max) NULL,
  [SourceSystem] [varchar](max) NULL,
  [MOCType] [varchar](max) NULL,
  [MOCSource] [varchar](max) NULL,
  [MOCReason] [varchar](max) NULL,
  [MOCReasonRemark] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [SourceAlt_Key] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO