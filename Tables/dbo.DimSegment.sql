CREATE TABLE [dbo].[DimSegment] (
  [EWS_Segment_Key] [smallint] IDENTITY,
  [EWS_SegmentAlt_Key] [smallint] NOT NULL,
  [EWS_SegmentName] [varchar](50) NULL,
  [EWS_SegmentShortName] [varchar](20) NULL,
  [EWS_SegmentShortNameEnum] [varchar](20) NULL,
  [EWS_SegmentGroup] [varchar](50) NULL,
  [EWS_SegmentSubGroup] [varchar](50) NULL,
  [EWS_SegmentValidCode] [char](1) NULL,
  [SegmentOrder] [smallint] NULL,
  [Green] [smallint] NULL,
  [Amber] [smallint] NULL,
  [Red] [smallint] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO