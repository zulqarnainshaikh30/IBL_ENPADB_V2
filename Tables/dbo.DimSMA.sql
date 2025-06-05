CREATE TABLE [dbo].[DimSMA] (
  [EntityKey] [int] IDENTITY,
  [SMAAlt_Key] [int] NULL,
  [SourceAlt_Key] [int] NULL,
  [CustomerACID] [varchar](16) NULL,
  [CustomerId] [varchar](30) NULL,
  [CustomerName] [varchar](200) NULL,
  [ParameterNameAlt_Key] [int] NULL,
  [ValueAlt_Key] [varchar](100) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
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