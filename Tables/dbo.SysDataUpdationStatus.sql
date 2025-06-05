CREATE TABLE [dbo].[SysDataUpdationStatus] (
  [Entity_Key] [int] IDENTITY,
  [BranchCode] [varchar](10) NULL,
  [ID] [varchar](30) NULL,
  [Name] [varchar](100) NULL,
  [Type] [varchar](50) NULL,
  [CaseNo] [varchar](150) NULL,
  [CaseType] [varchar](30) NULL,
  [CustomerACID] [varchar](250) NULL,
  [RecordType] [varchar](50) NULL,
  [CurrentStageAlt_key] [smallint] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [CrModBy] [varchar](20) NULL,
  [CrModDate] [datetime] NULL,
  [ParentEntityID] [int] NULL,
  [CustomerID] [varchar](20) NULL,
  [CaseStatus] [varchar](4) NULL,
  [CustomerEntityId] [int] NULL,
  [NextStageAlt_Key] [int] NULL
)
ON [PRIMARY]
GO