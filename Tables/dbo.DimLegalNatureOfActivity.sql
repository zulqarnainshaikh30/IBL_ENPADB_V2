CREATE TABLE [dbo].[DimLegalNatureOfActivity] (
  [LegalNatureOfActivity_Key] [smallint] NOT NULL,
  [LegalNatureOfActivityAlt_Key] [smallint] NULL,
  [LegalNatureOfActivityName] [nvarchar](30) NULL,
  [LegalNatureOfActivityShortName] [varchar](20) NULL,
  [LegalNatureOfActivityShortNameEnum] [varchar](20) NULL,
  [LegalNatureOfActivityGroup] [varchar](50) NULL,
  [LegalNatureOfActivityGroupOrderKey] [tinyint] NULL,
  [LegalNatureOfActivitySubGroup] [varchar](50) NULL,
  [LegalNatureOfActivitySubGroupOrderKey] [tinyint] NULL,
  [LegalNatureOfActivitySegment] [varchar](50) NULL,
  [LegalNatureOfActivityValidCode] [char](1) NULL,
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