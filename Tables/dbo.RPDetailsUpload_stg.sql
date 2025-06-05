CREATE TABLE [dbo].[RPDetailsUpload_stg] (
  [Entity_Key] [int] IDENTITY,
  [SrNo] [varchar](max) NULL,
  [UCICID] [varchar](max) NULL,
  [CustomerID] [varchar](max) NULL,
  [1stReportingBankLenderCode] [varchar](max) NULL,
  [BankingArrangement] [varchar](max) NULL,
  [Nameofleadbank] [varchar](max) NULL,
  [Exposurebucket] [varchar](max) NULL,
  [ReferenceDate] [varchar](max) NULL,
  [ICAStatus] [varchar](max) NULL,
  [ReasonfornotsigningICA] [varchar](max) NULL,
  [ICAExecutionDate] [varchar](max) NULL,
  [ApproveddateofResolutionPlan] [varchar](max) NULL,
  [NatureofRP] [varchar](max) NULL,
  [IfOtherRPDescription] [varchar](max) NULL,
  [IBCFilingDate] [varchar](max) NULL,
  [IBCAdmissiondate] [varchar](max) NULL,
  [ImplementationStatus] [varchar](max) NULL,
  [ActualRPImplDate] [varchar](max) NULL,
  [RevisedRPDeadline] [varchar](max) NULL,
  [OutofdefaultdateallbankspostinitialRPdeadline] [varchar](max) NULL,
  [IfRPisRectificationthenRiskReviewTimeline] [varchar](max) NULL,
  [filname] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO