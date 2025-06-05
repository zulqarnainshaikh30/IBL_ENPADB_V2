CREATE TABLE [CurDat].[InvestmentBasicDetail] (
  [EntityKey] [bigint] NOT NULL,
  [BranchCode] [varchar](10) NULL,
  [InvEntityId] [int] NOT NULL,
  [InvID] [varchar](30) NULL,
  [IssuerEntityId] [int] NOT NULL,
  [RefIssuerID] [varchar](30) NULL,
  [ISIN] [varchar](12) NULL,
  [InstrTypeAlt_Key] [tinyint] NULL,
  [InstrName] [varchar](100) NULL,
  [InvestmentNature] [varchar](25) NULL,
  [InternalRating] [tinyint] NULL,
  [InRatingDate] [date] NULL,
  [InRatingExpiryDate] [date] NULL,
  [ExRating] [tinyint] NULL,
  [ExRatingAgency] [tinyint] NULL,
  [ExRatingDate] [date] NULL,
  [ExRatingExpiryDate] [date] NULL,
  [Sector] [varchar](25) NULL,
  [Industry_AltKey] [tinyint] NULL,
  [ListedStkExchange] [char](1) NULL,
  [ExposureType] [varchar](25) NULL,
  [SecurityValue] [decimal](18, 2) NULL,
  [MaturityDt] [date] NULL,
  [ReStructureDate] [date] NULL,
  [MortgageStatus] [char](1) NULL,
  [NHBStatus] [char](1) NULL,
  [ResiPurpose] [char](1) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](100) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [smalldatetime] NULL,
  CONSTRAINT [InvestmentBasicDetail_InvEntityId] PRIMARY KEY NONCLUSTERED ([InvEntityId], [EffectiveFromTimeKey], [EffectiveToTimeKey]),
  CHECK ([EffectiveToTimeKey]=(49999))
)
ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [InvestmentBasicDetail_ClsIdx]
  ON [CurDat].[InvestmentBasicDetail] ([EntityKey])
  ON [PRIMARY]
GO