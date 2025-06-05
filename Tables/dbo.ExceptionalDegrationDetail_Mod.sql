CREATE TABLE [dbo].[ExceptionalDegrationDetail_Mod] (
  [Entity_Key] [int] IDENTITY,
  [DegrationAlt_Key] [int] NULL,
  [SourceAlt_Key] [int] NULL,
  [AccountID] [varchar](30) NULL,
  [CustomerID] [varchar](30) NULL,
  [FlagAlt_Key] [varchar](30) NULL,
  [Date] [date] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [Remark] [varchar](200) NULL,
  [ChangeFields] [varchar](200) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [MarkingAlt_Key] [int] NULL,
  [Amount] [decimal](18, 2) NULL,
  [DateApprovedFirstLevel] [datetime] NULL,
  [ApprovedByFirstLevel] [varchar](100) NULL
)
ON [PRIMARY]
GO