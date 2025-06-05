CREATE TABLE [dbo].[DimCollateralSubType_Mod] (
  [EntityKey] [int] IDENTITY,
  [CollateralSubTypeAltKey] [int] NULL,
  [CollateralTypeAltKey] [int] NULL,
  [CollateralSubTypeID] [varchar](50) NULL,
  [CollateralSubType] [varchar](50) NULL,
  [CollateralSubTypeDescription] [varchar](500) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [ChangeFields] [varchar](100) NULL,
  [Remarks] [varchar](100) NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [smalldatetime] NULL,
  [Valid] [char](1) NULL,
  [SrcSecurityCode] [varchar](50) NULL,
  [SourceAlt_Key] [int] NULL,
  [ApprovedByFirstLevel] [varchar](30) NULL,
  [DateApprovedFirstLevel] [datetime] NULL,
  [SrcSecurityName] [varchar](30) NULL
)
ON [PRIMARY]
GO