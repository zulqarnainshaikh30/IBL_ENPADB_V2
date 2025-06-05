﻿CREATE TABLE [dbo].[SysUserActivityLog_Attendence] (
  [EntityKey] [int] IDENTITY,
  [BranchCode] [varchar](10) NOT NULL,
  [MenuID] [int] NOT NULL,
  [ReferenceID] [varchar](50) NULL,
  [LogCreationStatus] [varchar](2) NULL,
  [LogCreatedBy] [varchar](50) NULL,
  [LogCreatedDt] [datetime] NULL,
  [LogStatus] [varchar](1) NULL,
  [LogCheckedBy] [varchar](50) NULL,
  [LogCheckedDt] [datetime] NULL,
  [Remark] [varchar](200) NULL,
  [ScreenEntityAlt_Key] [int] NULL,
  [ScreenType] [varchar](100) NULL,
  [EditCount] [int] NULL,
  [DeleteCount] [int] NULL,
  [AuthoriseCount] [int] NULL,
  [RejectCount] [int] NULL
)
ON [PRIMARY]
GO