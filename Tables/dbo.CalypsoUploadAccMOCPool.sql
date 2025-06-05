CREATE TABLE [dbo].[CalypsoUploadAccMOCPool] (
  [SlNo] [varchar](max) NULL,
  [InvestmentIDDerivativeRefNo] [varchar](max) NULL,
  [BookValueINRMTMValue] [varchar](max) NULL,
  [UnservicedInterest] [varchar](max) NULL,
  [AdditionalProvisionAbsolute] [varchar](max) NULL,
  [MOCSource] [varchar](max) NULL,
  [MOCReason] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO