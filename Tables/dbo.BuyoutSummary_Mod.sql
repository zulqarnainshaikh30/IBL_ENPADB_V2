CREATE TABLE [dbo].[BuyoutSummary_Mod] (
  [Entity_Key] [int] IDENTITY,
  [CIFId] [varchar](max) NULL,
  [ENBDAcNo] [varchar](max) NULL,
  [BuyoutPartyLoanNo] [varchar](max) NULL,
  [PartnerDPD] [varchar](max) NULL,
  [PartnerDPDAsOnDate] [datetime] NULL,
  [PartnerAssetClass] [varchar](max) NULL,
  [PartnerNPADate] [datetime] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [Changes] [varchar](200) NULL,
  [Remark] [varchar](200) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](100) NULL,
  [DateModified] [date] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [date] NULL,
  [SummaryID] [int] NULL,
  [UploadID] [int] NULL,
  [NoOfAccount] [int] NULL,
  [ApprovedByFirstLevel] [varchar](100) NULL,
  [DateApprovedFirstLevel] [date] NULL,
  [Action] [char](1) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO