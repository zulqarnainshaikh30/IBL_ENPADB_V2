CREATE TABLE [dbo].[IBPCCustMocUpload_stg] (
  [SrNo] [varchar](1) NULL,
  [UploadID] [int] NULL,
  [SummaryID] [int] NULL,
  [Sl.No.] [varchar](max) NULL,
  [Customer ID] [varchar](max) NULL,
  [Asset Class] [varchar](max) NULL,
  [NPA Date] [varchar](max) NULL,
  [Security Value] [varchar](max) NULL,
  [Additional Provision %] [varchar](max) NULL,
  [MOC Source] [varchar](max) NULL,
  [MOC Type] [varchar](max) NULL,
  [MOC Reason] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO