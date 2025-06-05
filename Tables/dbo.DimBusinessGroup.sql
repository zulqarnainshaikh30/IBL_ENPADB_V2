CREATE TABLE [dbo].[DimBusinessGroup] (
  [BusinessGroup_Key] [smallint] NOT NULL,
  [BusinessGroupAlt_Key] [smallint] NULL,
  [BusinessGroupName] [varchar](100) NULL,
  [BusinessGroupShortName] [varchar](20) NULL,
  [BusinessGroupShortNameEnum] [varchar](20) NULL,
  [BusinessGroupGroup] [varchar](50) NULL,
  [BusinessGroupSubGroup] [varchar](50) NULL,
  [BusinessGroupSegment] [varchar](50) NULL,
  [BusinessGroupValidCode] [char](1) NULL,
  [SrcSysBusinessGroupCode] [varchar](50) NULL,
  [SrcSysBusinessGroupName] [varchar](50) NULL,
  [DestSysBusinessGroupCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [RbiGroupCode] [varchar](10) NULL,
  [RbiGroupDesc] [varchar](100) NULL
)
ON [PRIMARY]
GO