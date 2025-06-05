CREATE TABLE [dbo].[MetaExpertNavigationWizard] (
  [SrNo] [int] IDENTITY,
  [Category] [varchar](50) NULL,
  [Category_Type] [varchar](50) NULL,
  [Criteria] [varchar](100) NULL,
  [MasterSelect] [varchar](100) NULL,
  [MasterSelectValue] [varchar](100) NULL,
  [MasterData] [varchar](100) NULL,
  [SubCriteria] [varchar](100) NULL,
  [SubMasterSelect] [varchar](100) NULL,
  [SubMasterSelectValue] [varchar](100) NULL,
  [SubMasterData] [varchar](100) NULL,
  [SelectRange] [varchar](20) NULL,
  [ReportId] [varchar](20) NULL
)
ON [PRIMARY]
GO