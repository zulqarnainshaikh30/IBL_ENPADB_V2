CREATE TABLE [PRO].[PROCESSMONITOR_MOC] (
  [IdentityKey] [int] IDENTITY,
  [UserID] [varchar](50) NULL,
  [Description] [varchar](100) NULL,
  [Mode] [varchar](15) NULL,
  [StartTime] [datetime] NULL,
  [EndTime] [datetime] NULL,
  [TimeTaken_Sec] [int] NULL,
  [TimeKey] [int] NULL,
  [SetID] [int] NULL,
  [Proc_Loc] [varchar](50) NULL,
  [StatusFlag] [varchar](100) NULL,
  [CurrentTimeKey] [int] NULL
)
ON [PRIMARY]
GO