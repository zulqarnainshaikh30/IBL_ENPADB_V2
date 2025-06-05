CREATE TABLE [dbo].[RestructuredAssetsUpload_stg] (
  [Entity_Key] [int] IDENTITY,
  [SrNo] [varchar](max) NULL,
  [AccountID] [varchar](max) NULL,
  [BankingRelationship] [varchar](max) NULL,
  [InvocationDate] [varchar](max) NULL,
  [DateofRestructuring] [varchar](max) NULL,
  [RestructuringApprovingAuth] [varchar](max) NULL,
  [TypeofRestructuring] [varchar](max) NULL,
  [AssetClassatRstrctr] [varchar](max) NULL,
  [NPADate] [varchar](max) NULL,
  [NPAIdentificationDate] [varchar](max) NULL,
  [PrinRpymntStartDate] [varchar](max) NULL,
  [InttRpymntStartDate] [varchar](max) NULL,
  [DPDasonDateofRestructure] [varchar](max) NULL,
  [OSasonDateofRstrctr] [varchar](max) NULL,
  [POSasonDateofRstrctr] [varchar](max) NULL,
  [DFVProvisionRs] [varchar](max) NULL,
  [filname] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO