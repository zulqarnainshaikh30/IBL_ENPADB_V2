CREATE TABLE [dbo].[BuyoutUploadDetails_stg] (
  [EntityKey] [int] IDENTITY,
  [SlNo] [varchar](max) NULL,
  [AccountNo] [varchar](max) NULL,
  [SchemeCode] [varchar](max) NULL,
  [NPAClassificationwithSeller] [varchar](max) NULL,
  [DateofNPAwithSeller] [varchar](max) NULL,
  [DPDwithSeller] [varchar](max) NULL,
  [PeakDPDwithSeller] [varchar](max) NULL,
  [PeakDPDDate] [varchar](max) NULL,
  [ReportDate] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [DateofData] [date] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO