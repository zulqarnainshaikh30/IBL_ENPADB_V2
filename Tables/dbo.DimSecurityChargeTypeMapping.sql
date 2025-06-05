CREATE TABLE [dbo].[DimSecurityChargeTypeMapping] (
  [EntityKey] [int] IDENTITY,
  [SecurityMappingAlt_Key] [int] NULL,
  [SecurityChargeTypeAlt_Key] [int] NULL,
  [SecurityChargeTypeCode] [varchar](10) NULL,
  [SecurityChargeTypeName] [varchar](100) NULL,
  [SecurityChargeTypeShortName] [varchar](20) NULL,
  [SecurityChargeTypeShortNameEnum] [varchar](20) NULL,
  [SecurityChargeTypeGroup] [varchar](20) NULL,
  [SecurityChargeTypeSubGroup] [varchar](20) NULL,
  [SecurityChargeTypeSegment] [varchar](50) NULL,
  [SecurityChargeTypeValidCode] [varchar](1) NULL,
  [SrcSysSecurityChargeTypeCode] [varchar](50) NULL,
  [SrcSysSecurityChargeTypeName] [varchar](50) NULL,
  [DestSysSecurityChargeTypeCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO