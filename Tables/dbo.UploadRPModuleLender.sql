CREATE TABLE [dbo].[UploadRPModuleLender] (
  [SrNo] [int] NULL,
  [UCICID] [varchar](max) NULL,
  [CustomerID] [varchar](max) NULL,
  [BorrowerPAN] [varchar](max) NULL,
  [BorrowerName] [varchar](max) NULL,
  [LenderName] [varchar](max) NULL,
  [InDefaultDate] [varchar](max) NULL,
  [OutofDefaultDate] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO