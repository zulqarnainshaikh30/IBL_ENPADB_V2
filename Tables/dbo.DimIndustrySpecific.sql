CREATE TABLE [dbo].[DimIndustrySpecific] (
  [Entity_Key] [int] IDENTITY,
  [SlNo] [int] NULL,
  [CIF] [int] NULL,
  [BSRActivityCode] [int] NULL,
  [ProvisionRate] [decimal](18, 2) NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](100) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [datetime] NULL,
  [SummaryID] [int] NULL
)
ON [PRIMARY]
GO