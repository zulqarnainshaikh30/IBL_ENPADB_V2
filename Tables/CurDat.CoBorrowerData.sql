CREATE TABLE [CurDat].[CoBorrowerData] (
  [AsOnDate] [date] NULL,
  [SourceSystemName_PrimaryAccount] [varchar](40) NULL,
  [NCIFID_PrimaryAccount] [varchar](40) NULL,
  [CustomerId_PrimaryAccount] [varchar](40) NULL,
  [CustomerACID_PrimaryAccount] [varchar](4000) NULL,
  [NCIFID_COBORROWER] [varchar](40) NULL,
  [AcDegFlg] [varchar](1) NULL,
  [AcDegDate] [date] NULL,
  [AcUpgFlg] [varchar](1) NULL,
  [AcUpgDate] [date] NULL,
  [Flag] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [binary](8) NOT NULL
)
ON [PRIMARY]
GO