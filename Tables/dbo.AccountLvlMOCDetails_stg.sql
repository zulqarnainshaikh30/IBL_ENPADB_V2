CREATE TABLE [dbo].[AccountLvlMOCDetails_stg] (
  [SlNo] [varchar](max) NULL,
  [AccountID] [varchar](max) NULL,
  [AdditionalProvisionAbsoluteinRs] [varchar](max) NULL,
  [AdditionalProvision] [varchar](max) NULL,
  [SourceSystem] [varchar](max) NULL,
  [MOCType] [varchar](max) NULL,
  [MOCSource] [varchar](max) NULL,
  [MOCReason] [varchar](max) NULL,
  [MOCReasonRemark] [varchar](max) NULL,
  [filname] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO