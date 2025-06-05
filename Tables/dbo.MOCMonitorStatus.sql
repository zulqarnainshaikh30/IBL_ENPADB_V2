CREATE TABLE [dbo].[MOCMonitorStatus] (
  [EntityKey] [int] IDENTITY,
  [UserID] [varchar](50) NULL,
  [MocMainSP] [varchar](200) NULL,
  [MocStatus] [varchar](100) NULL,
  [MocSubSP] [varchar](200) NULL,
  [MocStatusSub] [varchar](100) NULL,
  [TimeKey] [int] NULL,
  PRIMARY KEY CLUSTERED ([EntityKey])
)
ON [PRIMARY]
GO