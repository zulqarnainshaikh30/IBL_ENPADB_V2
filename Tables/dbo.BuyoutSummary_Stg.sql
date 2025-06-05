CREATE TABLE [dbo].[BuyoutSummary_Stg] (
  [Entity_Key] [int] IDENTITY,
  [AUNo] [varchar](max) NULL,
  [PoolName] [varchar](max) NULL,
  [Category] [varchar](max) NULL,
  [TotalNoofBuyoutParty] [varchar](max) NULL,
  [TotalPrincipalOutstandinginRs] [varchar](max) NULL,
  [TotalInterestReceivableinRs] [varchar](max) NULL,
  [BuyoutOSBalanceinRs] [varchar](max) NULL,
  [TotalChargesinRs] [varchar](max) NULL,
  [TotalAccuredInterestinRs] [varchar](max) NULL,
  [UploadID] [varchar](max) NULL,
  [SummaryID] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO