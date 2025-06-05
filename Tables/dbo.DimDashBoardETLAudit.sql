CREATE TABLE [dbo].[DimDashBoardETLAudit] (
  [EntityKey] [int] IDENTITY,
  [BandName] [varchar](100) NULL,
  [TaskName] [varchar](100) NULL,
  [PackageTableName] [varchar](100) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL
)
ON [PRIMARY]
GO