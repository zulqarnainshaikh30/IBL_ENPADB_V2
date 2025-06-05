CREATE TABLE [dbo].[UploadSaletoARC] (
  [EntityKey] [int] IDENTITY,
  [SrNo] [varchar](max) NULL,
  [UploadID] [int] NULL,
  [AccountID] [varchar](max) NULL,
  [ExposuretoARCinRs] [varchar](max) NULL,
  [DateOfSaletoARC] [varchar](max) NULL,
  [DateOfApproval] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [Action] [varchar](10) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO