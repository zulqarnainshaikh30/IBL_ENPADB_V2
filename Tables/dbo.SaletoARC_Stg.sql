CREATE TABLE [dbo].[SaletoARC_Stg] (
  [EntityKey] [int] IDENTITY,
  [SrNo] [varchar](max) NULL,
  [UploadID] [int] NULL,
  [AccountID] [varchar](max) NULL,
  [ExposuretoARCinRs] [varchar](max) NULL,
  [DateOfSaletoARC] [varchar](max) NULL,
  [DateOfApproval] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [Action] [varchar](10) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO