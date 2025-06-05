CREATE TABLE [dbo].[MetaCerDescription] (
  [EntityKey] [int] IDENTITY,
  [ScreenName] [varchar](50) NULL,
  [ClientName] [varchar](10) NULL,
  [ScreenFieldNo] [smallint] NULL,
  [ScrCrErrorSeq] [varchar](5) NULL,
  [ScreenFldName] [varchar](50) NULL,
  [ColumnName] [varchar](50) NULL,
  [CerDescription] [varchar](4000) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [ValidCode] [char](1) NULL,
  [XmlTableName] [varchar](50) NULL
)
ON [PRIMARY]
GO