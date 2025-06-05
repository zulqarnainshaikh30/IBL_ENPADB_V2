CREATE TABLE [dbo].[DimCollateralCode_Mod] (
  [EntityKey] [int] IDENTITY,
  [CollateralCodeAltKey] [int] NULL,
  [CollateralCode] [varchar](20) NULL,
  [CollateralDescription] [varchar](500) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [ChangeFields] [varchar](100) NULL,
  [Remarks] [varchar](100) NULL,
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