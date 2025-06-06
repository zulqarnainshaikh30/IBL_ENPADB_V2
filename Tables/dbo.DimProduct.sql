﻿CREATE TABLE [dbo].[DimProduct] (
  [ProductAlt_Key] [smallint] NOT NULL,
  [ProductCode] [varchar](50) NULL,
  [ProductName] [varchar](200) NULL,
  [ProductShortName] [varchar](20) NULL,
  [ProductShortNameEnum] [varchar](20) NULL,
  [ProductGroup] [varchar](50) NULL,
  [ProductSubGroup] [varchar](50) NULL,
  [ProductSegment] [varchar](50) NULL,
  [ProductValidCode] [char](1) NULL,
  [SrcSysProductCode] [varchar](50) NULL,
  [SrcSysProductName] [varchar](200) NULL,
  [DestSysProductCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [DepositType] [varchar](100) NULL,
  [SourceAlt_Key] [int] NULL,
  [Product_Key] [int] IDENTITY,
  [EffectiveFromDate] [int] NULL,
  [FacilityType] [varchar](20) NULL,
  [NPANorms] [varchar](20) NULL,
  [SchemeType] [varchar](20) NULL,
  [Agrischeme] [char](1) NULL,
  [ReviewFlag] [char](1) NULL,
  [AssetClass] [varchar](20) NULL,
  [ConvFactor] [smallint] NULL,
  [DefaultType] [varchar](100) NULL,
  [DefaultLogic] [nvarchar](1000) NULL,
  [Segment] [varchar](20) NULL,
  [STDProvCATCode] [int] NULL,
  [BankProvPolicyApply] [char](1) NULL
)
ON [PRIMARY]
GO