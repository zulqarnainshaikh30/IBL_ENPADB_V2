CREATE TABLE [dbo].[ReverseFeedData] (
  [DateofData] [date] NULL,
  [BranchCode] [varchar](20) NULL,
  [CustomerID] [varchar](30) NULL,
  [AccountID] [varchar](30) NULL,
  [AssetClass] [varchar](20) NULL,
  [AssetSubClass] [varchar](20) NULL,
  [NPADate] [date] NULL,
  [NPAReason] [varchar](max) NULL,
  [LoanSeries] [smallint] NULL,
  [LoanRefNo] [smallint] NULL,
  [FundID] [varchar](40) NULL,
  [NPAStatus] [varchar](10) NULL,
  [LoanRating] [varchar](10) NULL,
  [OrgNPAStatus] [varchar](10) NULL,
  [OrgLoanRating] [varchar](10) NULL,
  [SourceAlt_Key] [int] NULL,
  [SourceSystemName] [varchar](30) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [UpgradeDate] [date] NULL,
  [UCIF_ID] [varchar](30) NULL,
  [ProductName] [varchar](200) NULL,
  [DPD] [int] NULL,
  [CustomerName] [varchar](100) NULL,
  [DEGREASON] [varchar](200) NULL,
  [FinalAssetClassAlt_Key] [int] NULL,
  [InitialAssetClassAlt_Key] [int] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO