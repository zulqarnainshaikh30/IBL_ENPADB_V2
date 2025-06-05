CREATE TABLE [CurDat].[InvestmentIssuerDetail] (
  [EntityKey] [bigint] NOT NULL,
  [BranchCode] [varchar](10) NULL,
  [IssuerEntityId] [int] NOT NULL,
  [IssuerID] [varchar](30) NULL,
  [IssuerName] [varchar](100) NULL,
  [RatingStatus] [char](1) NULL,
  [IssuerAccpRating] [varchar](10) NULL,
  [IssuerAccpRatingDt] [date] NULL,
  [IssuerRatingAgency] [tinyint] NULL,
  [Ref_Txn_Sys_Cust_ID] [varchar](25) NULL,
  [Issuer_Category_Code] [varchar](50) NULL,
  [GrpEntityOfBank] [char](1) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](100) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [smalldatetime] NULL,
  [SourceAlt_key] [int] NULL,
  [UcifId] [varchar](30) NULL,
  [PanNo] [varchar](10) NULL,
  [FlgSMA] [char](1) NULL,
  [SMA_Dt] [date] NULL,
  [SMA_Class] [varchar](5) NULL,
  CONSTRAINT [InvestmentIssuerDetail_IssuerEntityId] PRIMARY KEY NONCLUSTERED ([IssuerEntityId], [EffectiveFromTimeKey], [EffectiveToTimeKey]),
  CHECK ([EffectiveToTimeKey]=(49999))
)
ON [PRIMARY]
GO

CREATE CLUSTERED INDEX [InvestmentIssuerDetail_ClsIdx]
  ON [CurDat].[InvestmentIssuerDetail] ([EntityKey])
  ON [PRIMARY]
GO