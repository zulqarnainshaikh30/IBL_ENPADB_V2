CREATE TABLE [dbo].[DimCaste] (
  [Caste_Key] [smallint] NOT NULL,
  [CasteAlt_Key] [smallint] NULL,
  [CasteOrderKey] [tinyint] NULL,
  [CasteName] [varchar](50) NULL,
  [CasteShortName] [varchar](20) NULL,
  [CasteShortNameEnum] [varchar](20) NULL,
  [CasteGroup] [varchar](50) NULL,
  [CasteSubGroup] [varchar](50) NULL,
  [CasteSegment] [varchar](50) NULL,
  [CasteValidCode] [char](1) NULL,
  [SrcSysCasteCode] [varchar](10) NULL,
  [SrcSysCasteName] [varchar](50) NULL,
  [DestSysCasteCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO