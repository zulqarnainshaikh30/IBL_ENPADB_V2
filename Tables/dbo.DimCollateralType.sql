CREATE TABLE [dbo].[DimCollateralType] (
  [EntityKey] [int] IDENTITY,
  [CollateralTypeAltKey] [int] NULL,
  [CollateralTypeID] [varchar](20) NULL,
  [CollateralType] [varchar](50) NULL,
  [CollateralTypeDescription] [varchar](500) NULL,
  [ValueExpirationAltKey] [int] NULL,
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