CREATE TABLE [dbo].[DimAcBuSegment] (
  [AcBuSegment_Key] [smallint] NOT NULL,
  [AcBuSegmentAlt_Key] [smallint] NOT NULL,
  [SourceAlt_Key] [smallint] NULL,
  [AcBuSegmentCode] [varchar](20) NULL,
  [AcBuRevisedSegmentCode] [varchar](20) NULL,
  [AcBuSegmentDescription] [varchar](100) NULL,
  [AcBuSegmentShortName] [varchar](20) NULL,
  [AcBuSegmentShortNameEnum] [varchar](20) NULL,
  [AcBuSegmentSubGroup] [varchar](50) NULL,
  [AcBuSegmentGroup] [varchar](50) NULL,
  [AcBuSegmentValidCode] [char](1) NULL,
  [AuthorisationStatus] [varchar](20) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateModified] [date] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO