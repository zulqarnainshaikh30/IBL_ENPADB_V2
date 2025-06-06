﻿CREATE TABLE [dbo].[DynamicReportDirectory] (
  [EntityKey] [int] IDENTITY,
  [ExcelId] [int] NULL,
  [ExcelSheetName] [varchar](50) NULL,
  [ReportId] [varchar](100) NULL,
  [ReportName] [varchar](500) NULL,
  [ReportType] [varchar](100) NULL,
  [FrequencyAlt_Key] [varchar](5) NULL,
  [ReportAmountIn] [decimal](14, 2) NULL,
  [ExcelRowStartPosition] [int] NULL,
  [ExcelColumnStartPosition] [varchar](2) NULL,
  [SqlSelect] [varchar](500) NULL,
  [SqlFrom] [varchar](max) NULL,
  [SqlWhere] [varchar](max) NULL,
  [SqlGroupBy] [varchar](max) NULL,
  [SqlOrderBy] [varchar](max) NULL,
  [OutputRowBreak] [varchar](max) NULL,
  [IsOutputRowBreakRepeat] [bit] NULL,
  [IsOutputRowBreakTotal] [bit] NULL,
  [IsRowTotal] [bit] NULL,
  [IsColumnTotal] [bit] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [IsCombined] [char](1) NULL,
  [NumberUnit] [int] NULL,
  [tagAltkeys] [varchar](max) NULL,
  [BaseConditionItems] [varchar](200) NULL,
  [IsFreezed] [bit] NULL,
  [FreezedBy] [varchar](100) NULL,
  [DateFreezed] [datetime] NULL,
  [ApplySerialNo] [char](1) NULL,
  [Scope] [varchar](100) NULL,
  [ReportBaseItem] [varchar](300) NULL,
  [AllowMOC] [varchar](1) NULL,
  [ReportTypeRDL] [varchar](50) NULL,
  [ReportRdlFullName] [varchar](max) NULL,
  [ReportUrl] [varchar](max) NULL,
  [ReportMenuId] [int] NULL,
  [ReportFrequency_Key] [int] NULL,
  [ReportRdlName] [varchar](max) NULL,
  [VersionNo] [varchar](10) NULL,
  [ExportReportName] [varchar](250) NULL,
  [ExportReportId] [varchar](100) NULL,
  [Frequency_Period] [varchar](50) NULL,
  [StateAlt_Key] [varchar](max) NULL,
  [ReportSequence] [int] NULL,
  [ReadUptoForCSV] [int] NULL,
  [Block_StatePositionName] [varchar](10) NULL,
  [fromDateRowPosition] [varchar](100) NULL,
  [ToDateRowPosition] [varchar](100) NULL,
  [fromDateColPosition] [varchar](100) NULL,
  [ToDateColPosition] [varchar](100) NULL,
  [BankCodeRowPosition] [varchar](100) NULL,
  [BankNameRowPosition] [varchar](100) NULL,
  [BankCodeColPosition] [varchar](100) NULL,
  [BankNameColPosition] [varchar](100) NULL,
  [ReportDay] [int] NULL,
  [ReportSource] [int] NULL,
  [Uploads] [varchar](3) NULL,
  [GroupApplicableYN] [char](1) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO