CREATE TABLE [dbo].[DimInstrumentTypeMapping] (
  [InstrumentTypeAlt_Key] [smallint] NULL,
  [InstrumentTypeName] [varchar](100) NULL,
  [InstrumentTypeShortName] [varchar](50) NULL,
  [InstrumentTypeShortNameEnum] [varchar](50) NULL,
  [InstrumentTypeGroup] [varchar](50) NULL,
  [InstrumentTypeSubGroup] [varchar](50) NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [SourceAlt_Key] [int] NULL,
  [InstrumentTypeMappingAlt_Key] [int] NULL,
  [InstrumentType_Key] [smallint] IDENTITY,
  [SrcSysInstrumentTypeCode] [varchar](10) NULL,
  [SrcSysInstrumentTypeName] [varchar](200) NULL
)
ON [PRIMARY]
GO