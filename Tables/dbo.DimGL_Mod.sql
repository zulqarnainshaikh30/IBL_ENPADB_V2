﻿CREATE TABLE [dbo].[DimGL_Mod] (
  [GL_Key] [smallint] IDENTITY,
  [GLAlt_Key] [smallint] NOT NULL,
  [GLCode] [varchar](20) NULL,
  [GLName] [varchar](50) NULL,
  [GLShortName] [varchar](20) NULL,
  [GLShortNameEnum] [varchar](20) NULL,
  [GLGroupType] [varchar](50) NULL,
  [GLGroupAlt_Key] [int] NULL,
  [GLGroup] [varchar](50) NULL,
  [GLSubGroupAlt_Key] [int] NULL,
  [GLSubGroup] [varchar](50) NULL,
  [GLSegmentAlt_Key] [int] NULL,
  [GLSegment] [varchar](50) NULL,
  [GLSubSegment] [varchar](50) NULL,
  [GLValidCode] [char](1) NULL,
  [AbstractCat] [varchar](20) NULL,
  [AbstractCode] [varchar](20) NULL,
  [AbstractDescription] [varchar](50) NULL,
  [AdvRefGLAlt_key] [int] NULL,
  [BsDescription] [varchar](100) NULL,
  [BsSchedule] [smallint] NULL,
  [BsScheduleDescription] [varchar](80) NULL,
  [ComputationBusinessLogic] [varchar](5) NULL,
  [WeeklyCode] [int] NULL,
  [WeeklyDescription] [varchar](80) NULL,
  [LfCode] [int] NULL,
  [LfDescription] [varchar](100) NULL,
  [Schd_Head_No] [int] NULL,
  [Schd_No] [int] NULL,
  [Sub_Schd_No] [int] NULL,
  [Sub_Sub_Schd_No] [int] NULL,
  [SrcSysGLCode] [varchar](50) NULL,
  [SrcSysGLName] [varchar](50) NULL,
  [DestSysGLCode] [varchar](10) NULL,
  [GLCode2] [varchar](10) NULL,
  [GLName2] [varchar](50) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [ChangeFields] [varchar](100) NULL,
  [ApprovedByFirstLevel] [varchar](30) NULL,
  [DateApprovedFirstLevel] [datetime] NULL
)
ON [PRIMARY]
GO