CREATE TABLE [dbo].[DimKaretMaster] (
  [EntityKey] [int] IDENTITY,
  [KaretMasterAlt_Key] [int] NULL,
  [KaretMasterValueName] [varchar](30) NULL,
  [KaretMasterValueDt] [smalldatetime] NULL,
  [KaretMasterValueAmt] [decimal](16, 2) NULL,
  [SrcSysKaretValueCode] [varchar](50) NULL,
  [SrcSysKaretValueName] [varchar](50) NULL,
  [DestSysKaretValueCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
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