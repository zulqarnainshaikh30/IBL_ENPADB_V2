﻿CREATE TABLE [CurDat].[InvestmentFinancialDetail] (
  [EntityKey] [bigint] NOT NULL,
  [InvEntityId] [int] NOT NULL,
  [RefInvID] [varchar](100) NULL,
  [HoldingNature] [char](3) NULL,
  [CurrencyAlt_Key] [tinyint] NULL,
  [CurrencyConvRate] [decimal](12, 4) NULL,
  [BookType] [varchar](25) NULL,
  [BookValue] [decimal](18, 2) NULL,
  [BookValueINR] [decimal](18, 2) NULL,
  [MTMValue] [decimal](18, 2) NULL,
  [MTMValueINR] [decimal](18, 2) NULL,
  [EncumberedMTM] [decimal](18, 2) NULL,
  [AssetClass_AltKey] [tinyint] NULL,
  [NPIDt] [date] NULL,
  [TotalProvison] [decimal](18, 2) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](100) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [smalldatetime] NULL,
  [DBTDate] [date] NULL,
  [LatestBSDate] [date] NULL,
  [Interest_DividendDueDate] [date] NULL,
  [Interest_DividendDueAmount] [decimal](16, 2) NULL,
  [PartialRedumptionDueDate] [date] NULL,
  [PartialRedumptionSettledY_N] [char](1) NULL,
  [FLGDEG] [char](1) NULL,
  [DEGREASON] [varchar](500) NULL,
  [DPD] [int] NULL,
  [FLGUPG] [char](1) NULL,
  [UpgDate] [date] NULL,
  [PROVISIONALT_KEY] [int] NULL,
  [InitialAssetAlt_Key] [int] NULL,
  [InitialNPIDt] [date] NULL,
  [RefIssuerID] [varchar](100) NULL,
  [DPD_Maturity] [smallint] NULL,
  [DPD_DivOverdue] [int] NULL,
  [FinalAssetClassAlt_Key] [int] NULL,
  [PartialRedumptionDPD] [smallint] NULL,
  [Asset_Norm] [varchar](10) NULL,
  [ISIN] [varchar](30) NULL,
  [AssetClass] [varchar](30) NULL,
  [GL_Code] [varchar](50) NULL,
  [GL_Description] [varchar](200) NULL,
  [OVERDUE_AMOUNT] [decimal](10, 2) NULL,
  [FlgSMA] [char](1) NULL,
  [SMA_Dt] [date] NULL,
  [SMA_Class] [varchar](5) NULL,
  [SMA_Reason] [varchar](1000) NULL,
  [AddlProvision] [decimal](18, 2) NULL,
  [AddlProvisionPer] [decimal](5, 2) NULL,
  [MocBy] [varchar](20) NULL,
  [MOC_Date] [date] NULL,
  [FlgMoc] [char](1) NULL,
  [MOC_Reason] [varchar](100) NULL,
  CONSTRAINT [InvestmentFinancialDetail_InvEntityId] PRIMARY KEY NONCLUSTERED ([InvEntityId], [EffectiveFromTimeKey], [EffectiveToTimeKey]),
  CHECK ([EffectiveToTimeKey]=(49999))
)
ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [InvestmentFinancialDetail_ClsIdx]
  ON [CurDat].[InvestmentFinancialDetail] ([EntityKey])
  ON [PRIMARY]
GO