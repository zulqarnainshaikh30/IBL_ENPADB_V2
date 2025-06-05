CREATE TABLE [dbo].[DimFarmerCat] (
  [FarmerCat_Key] [smallint] NOT NULL,
  [FarmerCatAlt_Key] [smallint] NULL,
  [FarmerCatOrderKey] [tinyint] NULL,
  [FarmerCatName] [varchar](50) NULL,
  [FarmerCatShortName] [varchar](20) NULL,
  [FarmerCatShortNameEnum] [varchar](20) NULL,
  [FarmerCatGroup] [varchar](50) NULL,
  [FarmerCatSubGroup] [varchar](50) NULL,
  [FarmerCatSegment] [varchar](50) NULL,
  [FarmerCatValidCode] [char](1) NULL,
  [SrcSysFarmerCatCode] [varchar](50) NULL,
  [SrcSysFarmerCatName] [varchar](50) NULL,
  [DestSysFarmerCatCode] [varchar](10) NULL,
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