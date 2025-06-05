CREATE TABLE [dbo].[StockStatement] (
  [Entity_Key] [int] IDENTITY,
  [SrNo] [varchar](10) NULL,
  [CIF] [varchar](30) NULL,
  [AccountID] [varchar](50) NULL,
  [CustomerLimitSuffix] [varchar](30) NULL,
  [StockStamentDt] [date] NULL,
  [AccountEntityID] [int] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL
)
ON [PRIMARY]
GO