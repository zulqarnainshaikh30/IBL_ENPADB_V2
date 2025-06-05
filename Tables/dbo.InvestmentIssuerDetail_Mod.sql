CREATE TABLE [dbo].[InvestmentIssuerDetail_Mod] (
  [EntityKey] [bigint] IDENTITY,
  [BranchCode] [varchar](100) NULL,
  [IssuerEntityId] [int] NOT NULL,
  [IssuerID] [varchar](100) NULL,
  [IssuerName] [varchar](100) NULL,
  [IssuerAccpRating] [varchar](10) NULL,
  [IssuerAccpRatingDt] [date] NULL,
  [IssuerRatingAgency] [tinyint] NULL,
  [Ref_Txn_Sys_Cust_ID] [varchar](25) NULL,
  [Issuer_Category_Code] [varchar](3) NULL,
  [GrpEntityOfBank] [varchar](1) NULL,
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
  [InvestmentIssuerDetail_ChangeFields] [varchar](10) NULL
)
ON [PRIMARY]
GO