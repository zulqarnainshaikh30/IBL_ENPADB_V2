CREATE TABLE [dbo].[UploadProCategory] (
  [SlNo] [varchar](max) NULL,
  [ACID] [varchar](max) NULL,
  [CustomerID] [varchar](max) NULL,
  [CategoryID] [varchar](max) NULL,
  [Action] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO