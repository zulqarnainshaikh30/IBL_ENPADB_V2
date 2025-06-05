CREATE TABLE [dbo].[SaletoARCSummary_Mod] (
  [Entity_Key] [int] IDENTITY,
  [UploadID] [int] NULL,
  [SummaryID] [int] NULL,
  [NoofAccounts] [int] NULL,
  [TotalPOSinRs] [decimal](18, 2) NULL,
  [TotalInttReceivableinRs] [decimal](18, 2) NULL,
  [TotaloutstandingBalanceinRs] [decimal](18, 2) NULL,
  [ExposuretoARCinRs] [decimal](18, 2) NULL,
  [DateOfSaletoARC] [date] NULL,
  [DateOfApproval] [date] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifyBy] [varchar](100) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [smalldatetime] NULL,
  [ApprovedByFirstLevel] [varchar](100) NULL,
  [DateApprovedFirstLevel] [smalldatetime] NULL,
  [Action] [char](1) NULL
)
ON [PRIMARY]
GO