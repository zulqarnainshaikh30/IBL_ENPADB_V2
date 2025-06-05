CREATE TABLE [dbo].[DimBankRP_Mod] (
  [EntityKey] [int] IDENTITY,
  [BankRPAlt_Key] [int] NULL,
  [BankCode] [varchar](30) NULL,
  [BankName] [varchar](100) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [ChangeFields] [varchar](100) NULL,
  [Remarks] [varchar](100) NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL
)
ON [PRIMARY]
GO