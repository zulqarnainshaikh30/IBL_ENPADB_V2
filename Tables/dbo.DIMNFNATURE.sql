CREATE TABLE [dbo].[DIMNFNATURE] (
  [NfNature_Key] [smallint] NOT NULL,
  [NfNatureAlt_Key] [smallint] NOT NULL,
  [NfNatureName] [varchar](50) NULL,
  [NfNatureShortName] [varchar](20) NULL,
  [NfNatureShortNameEnum] [varchar](20) NULL,
  [NfNatureGroup] [varchar](50) NULL,
  [NfNatureSubGroup] [varchar](50) NULL,
  [NfNatureSegment] [varchar](50) NULL,
  [NfNatureValidCode] [char](1) NULL,
  [ConvFactor] [smallint] NULL,
  [SrcSysNfNatureCode] [varchar](50) NULL,
  [SrcSysNfNatureName] [varchar](50) NULL,
  [DestSysNfNatureCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
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