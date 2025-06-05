CREATE TABLE [dbo].[BuyoutDetails_Mod] (
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
  [Changes] [varchar](200) NULL,
  [Remark] [varchar](200) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](100) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [datetime] NULL,
  [UploadID] [int] NULL,
  [SummaryID] [int] NULL,
  [ApprovedByFirstLevel] [varchar](100) NULL,
  [DateApprovedFirstLevel] [datetime] NULL,
  [Action] [char](1) NULL,
  [ChangeFields] [varchar](100) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO