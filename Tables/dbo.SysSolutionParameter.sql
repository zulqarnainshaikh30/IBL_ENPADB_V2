﻿CREATE TABLE [dbo].[SysSolutionParameter] (
  [Parameter_Key] [smallint] NOT NULL,
  [ParameterAlt_Key] [smallint] NOT NULL,
  [ParameterName] [varchar](50) NULL,
  [ParameterValue] [varchar](500) NULL,
  [Remark] [varchar](800) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  [AllowScreen] [char](1) NULL,
  [ChangeEffectiveFromDt] [date] NULL,
  [DataType] [varchar](10) NULL,
  [AllowChar] [varchar](50) NULL,
  [NonAllowChar] [varchar](50) NULL
)
ON [PRIMARY]
GO