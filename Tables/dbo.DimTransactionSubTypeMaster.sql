CREATE TABLE [dbo].[DimTransactionSubTypeMaster] (
  [EntityKey] [int] IDENTITY,
  [Transaction_Sub_TypeAlt_Key] [int] NULL,
  [Transaction_Sub_Type] [varchar](30) NULL,
  [Transaction_Sub_Type_Code] [varchar](30) NULL,
  [Transaction_Sub_Type_Description] [varchar](200) NULL,
  [SourceAlt_Key] [int] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [TxnType] [varchar](30) NULL
)
ON [PRIMARY]
GO