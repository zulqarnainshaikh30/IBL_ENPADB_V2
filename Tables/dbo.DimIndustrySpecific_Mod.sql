CREATE TABLE [dbo].[DimIndustrySpecific_Mod] (
  [Entity_Key] [int] IDENTITY,
  [SlNo] [int] NULL,
  [CIF] [int] NULL,
  [BSRActivityCode] [int] NULL,
  [ProvisionRate] [decimal](18, 2) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](100) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [datetime] NULL,
  [UploadID] [int] NULL,
  [SummaryID] [int] NULL,
  [ApprovedByFirstlevel] [varchar](100) NULL,
  [DateApprovedFirstLevel] [smalldatetime] NULL
)
ON [PRIMARY]
GO