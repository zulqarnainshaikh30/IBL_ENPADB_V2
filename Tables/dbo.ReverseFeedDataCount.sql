CREATE TABLE [dbo].[ReverseFeedDataCount] (
  [ProcessDate] [date] NULL,
  [GenerationDate] [datetime] NOT NULL,
  [Name] [varchar](20) NOT NULL,
  [SourceName] [varchar](30) NULL,
  [Count] [int] NULL
)
ON [PRIMARY]
GO