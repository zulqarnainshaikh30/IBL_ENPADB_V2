CREATE TABLE [dbo].[DimReturnDirectory] (
  [entityKey] [int] IDENTITY,
  [returnId] [varchar](3) NULL,
  [returnName] [varchar](50) NULL,
  [createdModifyBy] [varchar](50) NULL,
  [createDate] [datetime] NULL,
  [ReturnAlt_Key] [int] NULL,
  [ReportGenType] [varchar](20) NULL
)
ON [PRIMARY]
GO