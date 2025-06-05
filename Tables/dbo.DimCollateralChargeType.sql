CREATE TABLE [dbo].[DimCollateralChargeType] (
  [EntityKey] [int] IDENTITY,
  [CollateralChargeTypeAltKey] [int] NULL,
  [ChargeTypeID] [varchar](20) NULL,
  [ChargeType] [varchar](25) NULL,
  [CollChargeDescription] [varchar](500) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL
)
ON [PRIMARY]
GO