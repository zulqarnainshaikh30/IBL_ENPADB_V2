CREATE TABLE [dbo].[DimInstrumentType] (
  [InstrumentType_Key] [smallint] NOT NULL,
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
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  [SrcSysCode] [varchar](20) NULL,
  [SrcSysName] [varchar](50) NULL
)
ON [PRIMARY]
GO