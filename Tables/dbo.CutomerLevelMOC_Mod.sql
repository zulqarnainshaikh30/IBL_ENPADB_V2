CREATE TABLE [dbo].[CutomerLevelMOC_Mod] (
  [Entity_Key] [int] IDENTITY,
  [CustomerID] [varchar](50) NULL,
  [CustomerEntityID] [int] NULL,
  [AssetClass] [varchar](20) NULL,
  [NPADate] [date] NULL,
  [SecurityValue] [decimal](18, 2) NULL,
  [AdditionalProvision] [decimal](16, 2) NULL,
  [FraudAccountFlag] [varchar](250) NULL,
  [FraudDate] [date] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [date] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [date] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [date] NULL
)
ON [PRIMARY]
GO