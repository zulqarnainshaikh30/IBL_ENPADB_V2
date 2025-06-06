﻿CREATE TABLE [PRO].[PUI_CAL] (
  [CustomerEntityID] [int] NULL,
  [AccountEntityId] [int] NULL,
  [ProjectCategoryAlt_Key] [int] NULL,
  [ProjectSubCategoryAlt_key] [int] NULL,
  [DelayReasonChangeinOwnership] [char](1) NULL,
  [ProjectAuthorityAlt_key] [int] NULL,
  [OriginalDCCO] [date] NULL,
  [OriginalProjectCost] [decimal](16, 2) NULL,
  [OriginalDebt] [decimal](16, 2) NULL,
  [Debt_EquityRatio] [decimal](16, 2) NULL,
  [ChangeinProjectScope] [char](1) NULL,
  [FreshOriginalDCCO] [date] NULL,
  [RevisedDCCO] [date] NULL,
  [CourtCaseArbitration] [char](1) NULL,
  [CIOReferenceDate] [date] NULL,
  [CIODCCO] [date] NULL,
  [TakeOutFinance] [char](1) NULL,
  [AssetClassSellerBookAlt_key] [int] NULL,
  [NPADateSellerBook] [date] NULL,
  [Restructuring] [char](1) NULL,
  [InitialExtension] [char](1) NULL,
  [BeyonControlofPromoters] [char](1) NULL,
  [DelayReasonOther] [char](1) NULL,
  [FLG_UPG] [varchar](1) NOT NULL,
  [FLG_DEG] [varchar](1) NOT NULL,
  [DEFAULT_REASON] [varchar](50) NULL,
  [ProjCategory] [varchar](20) NULL,
  [NPA_DATE] [date] NULL,
  [PUI_ProvPer] [decimal](5, 2) NULL,
  [RestructureDate] [date] NULL,
  [ActualDCCO] [char](1) NULL,
  [ActualDCCO_Date] [date] NULL,
  [UpgradeDate] [date] NULL,
  [FinalAssetClassAlt_Key] [int] NULL,
  [DPD_Max] [int] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [EntityKey] [int] IDENTITY,
  [SecuredProvision] [decimal](22, 2) NULL,
  [UnSecuredProvision] [decimal](22, 2) NULL,
  [RevisedDebt] [decimal](16, 2) NULL,
  [CostOverrun] [char](1) NULL,
  [RevisedProjectCost] [decimal](16, 2) NULL,
  [CostOverRunPer] [decimal](5, 2) NULL,
  [FinnalDCCO_Date] [date] NULL,
  [IsChanged] [char](1) NULL,
  [ProjectOwnerShipAlt_Key] [smallint] NULL
)
ON [PRIMARY]
GO