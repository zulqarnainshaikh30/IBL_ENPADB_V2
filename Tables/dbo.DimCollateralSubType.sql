CREATE TABLE [dbo].[DimCollateralSubType] (
  [EntityKey] [int] IDENTITY,
  [CollateralSubTypeAltKey] [int] NULL,
  [CollateralTypeAltKey] [int] NULL,
  [CollateralSubTypeID] [varchar](50) NULL,
  [CollateralSubType] [varchar](50) NULL,
  [CollateralSubTypeDescription] [varchar](500) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL,
  [SrcSecurityCode] [varchar](50) NULL,
  [Valid] [char](1) NULL,
  [SourceAlt_Key] [int] NULL,
  [SrcSecurityName] [varchar](30) NULL
)
ON [PRIMARY]
GO