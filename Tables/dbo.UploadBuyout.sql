CREATE TABLE [dbo].[UploadBuyout] (
  [Entity_Key] [int] IDENTITY,
  [SlNo] [varchar](max) NULL,
  [CIFID] [varchar](max) NULL,
  [UTKSAcNo] [varchar](max) NULL,
  [BuyoutPartyLoanNo] [varchar](max) NULL,
  [PartnerDPD] [varchar](max) NULL,
  [PartnerDPDasonDate] [varchar](max) NULL,
  [PartnerAssetClass] [varchar](max) NULL,
  [PartnerNPADate] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [SummaryID] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO