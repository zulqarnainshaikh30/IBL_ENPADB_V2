CREATE TABLE [dbo].[sysssislog] (
  [id] [int] IDENTITY,
  [event] [sysname] NOT NULL,
  [computer] [nvarchar](128) NOT NULL,
  [operator] [nvarchar](128) NOT NULL,
  [source] [nvarchar](1024) NOT NULL,
  [sourceid] [uniqueidentifier] NOT NULL,
  [executionid] [uniqueidentifier] NOT NULL,
  [starttime] [datetime] NOT NULL,
  [endtime] [datetime] NOT NULL,
  [datacode] [int] NOT NULL,
  [databytes] [image] NULL,
  [message] [nvarchar](2048) NOT NULL,
  PRIMARY KEY CLUSTERED ([id])
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO