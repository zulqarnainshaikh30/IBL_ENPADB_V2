CREATE TABLE [dbo].[DimMiscSuit] (
  [LegalMiscSuit_Key] [smallint] NOT NULL,
  [LegalMiscSuitAlt_Key] [smallint] NULL,
  [LegalMiscSuitName] [nvarchar](30) NULL,
  [LegalMiscSuitShortName] [varchar](20) NULL,
  [LegalMiscSuitShortNameEnum] [varchar](20) NULL,
  [LegalMiscSuitGroup] [varchar](50) NULL,
  [LegalMiscSuitGroupOrderKey] [tinyint] NULL,
  [LegalMiscSuitSubGroup] [varchar](50) NULL,
  [LegalMiscSuitSubGroupOrderKey] [tinyint] NULL,
  [LegalMiscSuitSegment] [varchar](50) NULL,
  [LegalMiscSuitValidCode] [char](1) NULL,
  [SrcSysClassCode] [varchar](10) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [DateCreated] [datetime] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [ApprovedBy] [varchar](20) NULL,
  [D2Ktimestamp] [timestamp] NULL
)
ON [PRIMARY]
GO