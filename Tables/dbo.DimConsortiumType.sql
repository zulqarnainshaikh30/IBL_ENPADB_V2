CREATE TABLE [dbo].[DimConsortiumType] (
  [ConsortiumAlt_Key] [int] NOT NULL,
  [Consortium_Key] [smallint] NOT NULL,
  [Consortium_Name] [varchar](250) NULL,
  [ConsortiumShortName] [varchar](20) NULL,
  [ConsortiumShortNameEnum] [varchar](20) NULL,
  [ConsortiumGroup] [varchar](50) NULL,
  [ConsortiumSubGroup] [varchar](50) NULL,
  [ConsortiumSegment] [varchar](50) NULL,
  [SrcSysConsortiumCode] [varchar](10) NULL,
  [SrcSysConsortiumName] [varchar](10) NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [DateCreated] [datetime] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp] NULL
)
ON [PRIMARY]
GO