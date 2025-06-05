CREATE TABLE [dbo].[RetsructuredAssetsUpload_stg] (
  [SrNo] [varchar](max) NULL,
  [AccountID] [varchar](max) NULL,
  [RestructureFacility] [varchar](max) NULL,
  [EquityConversion] [varchar](10) NULL,
  [DateofConversionintoEquity] [varchar](max) NULL,
  [PrinRpymntStartDate] [varchar](max) NULL,
  [InttRpymntStartDate] [varchar](max) NULL,
  [TypeofRestructuring] [varchar](max) NULL,
  [BankingRelationship] [varchar](max) NULL,
  [DateofRestructuring] [varchar](max) NULL,
  [RestructuringApprovingAuth] [varchar](max) NULL,
  [DateofIstDefaultonCRILIC] [varchar](max) NULL,
  [ReportingBank] [varchar](max) NULL,
  [AmountRstrctr] [varchar](max) NULL,
  [InvestmentGrade] [varchar](max) NULL,
  [StatusofSpecificPeriod] [varchar](max) NULL,
  [DFVProvisionRs] [varchar](max) NULL,
  [MTMProvisionRs] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [Entity_Key] [bigint] IDENTITY
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO