CREATE TABLE [dbo].[BuyoutDetails] (
  [Entity_Key] [int] IDENTITY,
  [SlNo] [int] NULL,
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
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [datetime] NULL,
  [SummaryID] [int] NULL,
  [Action] [char](1) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO