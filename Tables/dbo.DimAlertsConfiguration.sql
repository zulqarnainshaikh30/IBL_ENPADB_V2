CREATE TABLE [dbo].[DimAlertsConfiguration] (
  [AlertId] [int] IDENTITY,
  [Email_Host] [varchar](100) NULL,
  [Email_PORT] [int] NULL,
  [Email_mailFrom] [varchar](100) NULL,
  [AlertType] [varchar](10) NULL,
  [SMSVersion] [varchar](5) NULL,
  [SMSAppID] [varchar](20) NULL,
  [SMSTopicName] [varchar](255) NULL,
  [SMSCustomerID] [varchar](20) NULL,
  [SMSAccountNo] [varchar](30) NULL,
  [SMSStringContent] [varchar](255) NULL,
  [SMSHost] [varchar](100) NULL,
  [SMSEndPoint] [varchar](255) NULL
)
ON [PRIMARY]
GO