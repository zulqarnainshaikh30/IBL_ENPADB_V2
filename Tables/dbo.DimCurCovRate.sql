CREATE TABLE [dbo].[DimCurCovRate] (
  [Currency_Key] [int] IDENTITY,
  [CurrencyAlt_Key] [smallint] NULL,
  [CurrencyCode] [varchar](10) NULL,
  [CurrencyName] [varchar](50) NULL,
  [ConvRate] [decimal](18, 8) NULL,
  [ReguConvRate] [float] NULL,
  [ConvDate] [date] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO