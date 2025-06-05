CREATE TABLE [dbo].[UploadIndustrySpecific] (
  [Entity_Key] [int] IDENTITY,
  [SlNo] [varchar](max) NULL,
  [CIF] [int] NULL,
  [BSRActivityCode] [int] NULL,
  [ProvisionRate] [decimal](18, 2) NULL,
  [filname] [varchar](max) NULL,
  [SummaryID] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO