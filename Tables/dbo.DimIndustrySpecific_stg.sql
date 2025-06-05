CREATE TABLE [dbo].[DimIndustrySpecific_stg] (
  [Entity_Key] [int] IDENTITY,
  [SlNo] [varchar](max) NULL,
  [CIF] [int] NULL,
  [BSRActivityCode] [int] NULL,
  [ProvisionRate] [decimal](18, 2) NULL,
  [filname] [varchar](max) NULL,
  [SummaryID] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO