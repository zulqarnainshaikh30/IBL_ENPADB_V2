CREATE TABLE [dbo].[BuyoutSummary] (
  [Entity_Key] [int] IDENTITY,
  [CIFId] [varchar](max) NULL,
  [ENBDAcNo] [varchar](max) NULL,
  [BuyoutPartyLoanNo] [varchar](max) NULL,
  [PartnerDPD] [varchar](max) NULL,
  [PartnerDPDAsOnDate] [datetime] NULL,
  [PartnerAssetClass] [varchar](max) NULL,
  [PartnerNPADate] [datetime] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](100) NULL,
  [DateModified] [date] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [date] NULL,
  [SummaryID] [int] NULL,
  [NoOfAccount] [int] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO