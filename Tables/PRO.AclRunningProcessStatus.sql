CREATE TABLE [PRO].[AclRunningProcessStatus] (
  [id] [int] NULL,
  [RunningProcessName] [varchar](255) NULL,
  [Completed] [char](1) NULL,
  [ErrorDescription] [varchar](max) NULL,
  [ErrorDate] [date] NULL,
  [count] [int] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO