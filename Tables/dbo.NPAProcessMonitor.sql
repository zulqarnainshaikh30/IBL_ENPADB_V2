CREATE TABLE [dbo].[NPAProcessMonitor] (
  [IdentityKey] [int] IDENTITY,
  [UserID] [varchar](50) NULL,
  [Description] [varchar](100) NULL,
  [Mode] [varchar](15) NULL,
  [StartTime] [datetime] NULL,
  [EndTime] [datetime] NULL,
  [TimeTaken_Min] [int] NULL,
  [TimeKey] [smallint] NULL,
  [SetID] [int] NULL,
  [Proc_Loc] [varchar](50) NULL
)
ON [PRIMARY]
GO