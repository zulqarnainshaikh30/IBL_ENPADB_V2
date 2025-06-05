CREATE TABLE [dbo].[ACMOCUpload] (
  [Sl# No#] [nvarchar](255) NULL,
  [Account ID] [nvarchar](255) NULL,
  [POS in Rs#] [float] NULL,
  [Interest Receivable in Rs#] [nvarchar](255) NULL,
  [Additional Provision - Absolute in Rs#] [nvarchar](255) NULL,
  [Restructure Flag(Y/N)] [nvarchar](255) NULL,
  [Restructure Date] [nvarchar](255) NULL,
  [FITL Flag (Y/N)] [nvarchar](255) NULL,
  [DFV Amount] [nvarchar](255) NULL,
  [Fraud Flag] [nvarchar](255) NULL,
  [Fraud Date] [nvarchar](255) NULL,
  [MOC Source] [nvarchar](255) NULL,
  [MOC Reason] [nvarchar](255) NULL,
  [Source System] [nvarchar](255) NULL
)
ON [PRIMARY]
GO