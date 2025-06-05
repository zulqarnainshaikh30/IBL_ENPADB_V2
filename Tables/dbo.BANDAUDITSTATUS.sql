CREATE TABLE [dbo].[BANDAUDITSTATUS] (
  [EntityKey] [bigint] IDENTITY,
  [BandName] [varchar](100) NULL,
  [StartDate] [date] NULL,
  [BandStatus] [varchar](50) NULL,
  [TotalCount] [bigint] NULL,
  [CompletedCount] [bigint] NULL
)
ON [PRIMARY]
GO