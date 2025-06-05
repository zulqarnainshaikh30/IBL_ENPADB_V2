CREATE TABLE [dbo].[DimUserRole] (
  [UserRole_Key] [smallint] NOT NULL,
  [UserRoleAlt_Key] [smallint] NULL,
  [RoleDescription] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [RecordStatus] [char](1) NULL,
  [UserRoleShortName] [varchar](20) NULL,
  [UserRoleShortNameEnum] [varchar](20) NULL,
  [UserRoleGroup] [varchar](50) NULL,
  [UserRoleSubGroup] [varchar](50) NULL,
  [UserRoleSegment] [varchar](50) NULL,
  [UserRoleValidCode] [char](1) NULL,
  [SrcSysUserRoleCode] [varchar](50) NULL,
  [SrcSysUserRoleName] [varchar](50) NULL,
  [DestSystemUserRoleCode] [varchar](10) NULL
)
ON [PRIMARY]
GO