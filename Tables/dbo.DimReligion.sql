CREATE TABLE [dbo].[DimReligion] (
  [Religion_Key] [smallint] NOT NULL,
  [ReligionAlt_Key] [smallint] NULL,
  [ReligionOrderKey] [tinyint] NULL,
  [ReligionName] [varchar](50) NOT NULL,
  [ReligionShortName] [varchar](20) NULL,
  [ReligionShortNameEnum] [varchar](20) NULL,
  [ReligionGroup] [varchar](50) NULL,
  [ReligionSubGroup] [varchar](50) NULL,
  [ReligionSegment] [varchar](50) NULL,
  [ReligionValidCode] [char](1) NULL,
  [SrcSysReligionCode] [varchar](10) NULL,
  [SrcSysReligionName] [varchar](50) NULL,
  [DestSysReligionCode] [varchar](10) NULL,
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