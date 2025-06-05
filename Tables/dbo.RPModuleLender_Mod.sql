CREATE TABLE [dbo].[RPModuleLender_Mod] (
  [Entity_Key] [int] IDENTITY,
  [SrNo] [int] NULL,
  [UploadID] [int] NULL,
  [UCICID] [varchar](16) NULL,
  [CustomerID] [varchar](20) NULL,
  [BorrowerPAN] [varchar](10) NULL,
  [BorrowerName] [varchar](80) NULL,
  [LenderName] [varchar](250) NULL,
  [InDefaultDate] [date] NULL,
  [OutDefaultDate] [date] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [Changes] [varchar](200) NULL,
  [Remark] [varchar](200) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL,
  [ApprovedByFirstLevel] [varchar](100) NULL,
  [DateApprovedFirstLevel] [datetime] NULL,
  [ChangeField] [varchar](max) NULL,
  [LenderName_altkey] [int] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO