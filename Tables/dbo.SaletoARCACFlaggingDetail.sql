CREATE TABLE [dbo].[SaletoARCACFlaggingDetail] (
  [Entity_Key] [int] IDENTITY,
  [AccountFlagAlt_Key] [int] NULL,
  [SourceAlt_Key] [int] NULL,
  [AccountID] [varchar](30) NULL,
  [CustomerID] [varchar](30) NULL,
  [CustomerName] [varchar](30) NULL,
  [FlagAlt_Key] [varchar](30) NULL,
  [AccountBalance] [decimal](18, 2) NULL,
  [POS] [decimal](18, 2) NULL,
  [InterestReceivable] [decimal](18, 2) NULL,
  [ExposureAmount] [decimal](18, 2) NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp],
  [Remark] [varchar](250) NULL,
  [SourceName] [varchar](50) NULL,
  [DtofsaletoARC] [date] NULL,
  [DateofApproval] [date] NULL
)
ON [PRIMARY]
GO