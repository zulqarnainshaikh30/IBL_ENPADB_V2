CREATE TABLE [dbo].[ProvisionMovement] (
  [ProvisionProcessDate] [datetime] NULL,
  [Timekey] [int] NULL,
  [SourceAlt_Key] [int] NULL,
  [BranchCode] [varchar](10) NULL,
  [CustomerID] [varchar](15) NULL,
  [CustomerEntityID] [int] NULL,
  [CustomerAcid] [varchar](20) NULL,
  [AccountEntityID] [int] NULL,
  [CustomerName] [varchar](100) NULL,
  [MovementNature] [varchar](100) NULL,
  [InitialAssetClassAlt_Key] [int] NULL,
  [InitialProvision] [decimal](18, 2) NULL,
  [ExistingProvision_Addition] [decimal](18, 2) NULL,
  [FreshProvision_Addition] [decimal](18, 2) NULL,
  [ReductionDuetoUpgradeProvision] [decimal](18, 2) NULL,
  [ReductionProvisionDuetoWrite_Off] [decimal](18, 2) NULL,
  [ReductionDuetoRecovery_ExistingProvision] [decimal](18, 2) NULL,
  [ReductionProvisionDuetoRecovery_Arcs] [decimal](18, 2) NULL,
  [FinalAssetClassAlt_Key] [int] NULL,
  [FinalProvision] [decimal](18, 2) NULL,
  [TotalAddition_Provision] [decimal](18, 2) NULL,
  [TotalReduction_Provision] [decimal](18, 2) NULL,
  [MovementStatus] [varchar](200) NULL,
  [ProvisionReason] [varchar](200) NULL,
  [Movement_Flag] [char](1) NULL
)
ON [PRIMARY]
GO