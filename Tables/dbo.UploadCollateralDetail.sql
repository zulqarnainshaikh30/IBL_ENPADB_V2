CREATE TABLE [dbo].[UploadCollateralDetail] (
  [Entity_Key] [int] IDENTITY,
  [SrNo] [varchar](max) NULL,
  [AccountID] [varchar](max) NULL,
  [CollateralType] [varchar](max) NULL,
  [CollateralSubType] [varchar](max) NULL,
  [ChargeType] [varchar](max) NULL,
  [ChargeNature] [varchar](max) NULL,
  [ValuationDate] [varchar](max) NULL,
  [CurrentCollateralValueinRs] [varchar](max) NULL,
  [ExpiryBusinessRule] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO