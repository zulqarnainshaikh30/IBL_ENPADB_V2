CREATE TABLE [dbo].[CustPreCaseDataStage] (
  [EntityKey] [int] IDENTITY,
  [CustomerEntityId] [int] NULL,
  [CurrentStageAlt_Key] [smallint] NULL,
  [NextStageAlt_Key] [smallint] NULL
)
ON [PRIMARY]
GO