CREATE TABLE [dbo].[ExceptionalDegrationDetail] (
  [Entity_Key] [int] IDENTITY,
  [DegrationAlt_Key] [int] NULL,
  [SourceAlt_Key] [int] NULL,
  [AccountID] [varchar](30) NULL,
  [CustomerID] [varchar](30) NULL,
  [FlagAlt_Key] [varchar](30) NULL,
  [Date] [date] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  [MarkingAlt_Key] [int] NULL,
  [Amount] [decimal](18, 2) NULL
)
ON [PRIMARY]
GO