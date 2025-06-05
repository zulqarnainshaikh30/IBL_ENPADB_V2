CREATE TABLE [dbo].[ExcelTemplateDirectory] (
  [EntityKey] [int] IDENTITY,
  [ExcelId] [int] NULL,
  [ExcelName] [varchar](500) NULL,
  [ExcelFilePath] [varchar](1000) NULL,
  [StateAlt_Key] [int] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ExcelSheetName] [varchar](max) NULL,
  [FrequencyAlt_Key] [varchar](5) NULL,
  [ReportAmountIn] [int] NULL,
  [NumberUnit] [int] NULL,
  [Scope] [varchar](100) NULL,
  [BankReportNo] [varchar](200) NULL,
  [ReturnShortName] [varchar](500) NULL,
  [ReportDay] [int] NULL,
  [ReportSource] [int] NULL,
  [Uploads] [varchar](3) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO