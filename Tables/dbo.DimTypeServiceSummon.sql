CREATE TABLE [dbo].[DimTypeServiceSummon] (
  [ServiceSummon_Key] [smallint] IDENTITY,
  [ServiceSummonAlt_Key] [smallint] NOT NULL,
  [ServiceSummonName] [nvarchar](30) NULL,
  [ServiceSummonShortName] [varchar](20) NULL,
  [ServiceSummonShortNameEnum] [varchar](20) NULL,
  [ServiceSummonGroup] [varchar](50) NULL,
  [ServiceSummonGroupOrderKey] [tinyint] NULL,
  [ServiceSummonSubGroup] [varchar](50) NULL,
  [ServiceSummonSubGroupOrderKey] [tinyint] NULL,
  [ServiceSummonSegment] [varchar](50) NULL,
  [ServiceSummonValidCode] [char](1) NULL,
  [SrcSysClassnName] [varchar](10) NULL,
  [SrcSysClassCode] [varchar](10) NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [DateCreated] [datetime] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO