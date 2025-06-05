CREATE TABLE [dbo].[DimSMAParameter] (
  [EntityKey] [int] IDENTITY,
  [SMAParameterAlt_Key] [int] NULL,
  [ParameterName] [varchar](5000) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL
)
ON [PRIMARY]
GO