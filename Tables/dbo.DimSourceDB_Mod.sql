CREATE TABLE [dbo].[DimSourceDB_Mod] (
  [Source_Key] [int] IDENTITY,
  [SourceAlt_Key] [int] NULL,
  [SourceName] [varchar](50) NULL,
  [SourceShortName] [varchar](20) NULL,
  [SourceShortNameEnum] [varchar](20) NULL,
  [SourceGroup] [varchar](50) NULL,
  [SourceSubGroup] [varchar](50) NULL,
  [SourceSegment] [varchar](50) NULL,
  [SourceDBName] [varchar](100) NULL,
  [Changes] [varchar](100) NULL,
  [Remarks] [varchar](100) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [RecordStatus] [char](1) NULL,
  [DateCreated] [datetime] NULL,
  [CreatedBy] [varchar](20) NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [D2Ktimestamp] [timestamp],
  [AuthorisationStatus] [varchar](2) NULL,
  [DateApproved] [datetime] NULL,
  [ChangeFields] [varchar](100) NULL,
  [ApprovedByFirstLevel] [varchar](30) NULL,
  [DateApprovedFirstLevel] [datetime] NULL
)
ON [PRIMARY]
GO