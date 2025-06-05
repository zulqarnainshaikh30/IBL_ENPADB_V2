CREATE TABLE [dbo].[DimUtkarshAssetClass] (
  [AssetClass_Key] [int] IDENTITY,
  [AssetClassAlt_Key] [int] NULL,
  [AssetClassName] [varchar](20) NULL,
  [AssetClassShortName] [varchar](20) NULL,
  [AssetClassShortNameEnum] [varchar](20) NULL,
  [AssetClassGroup] [varchar](20) NULL,
  [AssetClassSubGroup] [varchar](20) NULL,
  [SrcSysClassName] [varchar](20) NULL,
  [SrcSysClassCode] [varchar](20) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [UtkarshAssetClassName] [varchar](30) NULL
)
ON [PRIMARY]
GO