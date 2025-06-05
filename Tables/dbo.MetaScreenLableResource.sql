CREATE TABLE [dbo].[MetaScreenLableResource] (
  [EntityKey] [int] IDENTITY,
  [ControlName] [varchar](50) NULL,
  [Lable] [nvarchar](1000) NULL,
  [LanguageKey] [varchar](10) NULL,
  [MenuID] [int] NULL,
  [ControlID] [int] NULL
)
ON [PRIMARY]
GO