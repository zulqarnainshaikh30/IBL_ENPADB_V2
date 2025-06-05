CREATE TABLE [dbo].[SysDataUpdationDetails] (
  [EntityKey] [int] IDENTITY,
  [BranchCode] [varchar](20) NULL,
  [MenuID] [smallint] NULL,
  [ParentEntityID] [int] NULL,
  [EntityId] [int] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [CrModBy] [varchar](20) NULL,
  [CrModDate] [datetime] NULL,
  [Remark] [varchar](1000) NULL,
  [StageAlt_Key] [smallint] NULL,
  [CaseEntityId] [int] NULL,
  [NextStageAlt_Key] [int] NULL
)
ON [PRIMARY]
GO