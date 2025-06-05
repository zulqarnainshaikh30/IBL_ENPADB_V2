CREATE TABLE [dbo].[StatusReport] (
  [SourceAlt_Key] [int] NULL,
  [SourceName] [varchar](50) NULL,
  [Upgrade_ACL] [int] NULL,
  [Upgrade_RF] [int] NULL,
  [Upgrade_Status] [varchar](10) NULL,
  [Degrade_ACL] [int] NULL,
  [Degrade_RF] [int] NULL,
  [Degrade_Status] [varchar](10) NULL
)
ON [PRIMARY]
GO