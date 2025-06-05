CREATE TABLE [dbo].[AlertRecipient] (
  [AlertId] [int] IDENTITY,
  [RecipientEmailIDs] [varchar](max) NULL,
  [RecipientMobileNumber] [varchar](100) NULL,
  [SourceType] [varchar](100) NULL,
  [AlertType] [varchar](100) NULL,
  [Recipient_CC_EmailIDs] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO