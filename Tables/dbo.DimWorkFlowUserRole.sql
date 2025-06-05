CREATE TABLE [dbo].[DimWorkFlowUserRole] (
  [WorkFlowUserRole_Key] [smallint] NOT NULL,
  [WorkFlowUserRoleAlt_Key] [smallint] NULL,
  [WorkFlowUserRoleName] [varchar](100) NULL,
  [WorkFlowUserRoleShortName] [varchar](20) NULL,
  [WorkFlowUserRoleShortNameEnum] [varchar](20) NULL,
  [WorkFlowUserRoleGroup] [varchar](50) NULL,
  [WorkFlowUserRoleSubGroup] [varchar](50) NULL,
  [WorkFlowUserRoleSegment] [varchar](50) NULL,
  [WorkFlowUserRoleValidCode] [char](1) NULL,
  [SrcSysWorkFlowUserRoleCode] [varchar](50) NULL,
  [SrcSysWorkFlowUserRoleName] [varchar](50) NULL,
  [DestSysWorkFlowUserRoleCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO