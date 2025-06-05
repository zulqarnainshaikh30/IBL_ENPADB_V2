CREATE TABLE [dbo].[DimReportFrequency] (
  [ReportFrequency_Key] [smallint] NOT NULL,
  [ReportFrequencyAlt_Key] [smallint] NOT NULL,
  [ReportFrequencyName] [varchar](100) NULL,
  [ReportFrequencyShortName] [varchar](20) NULL,
  [ReportFrequencyShortNameEnum] [varchar](20) NULL,
  [ReportFrequencyGroup] [varchar](50) NULL,
  [ReportFrequencySubGroup] [varchar](50) NULL,
  [NoofDays] [smallint] NULL,
  [ReportingDay] [varchar](30) NULL,
  [Remark] [varchar](max) NULL,
  [Maxdaystogenerate] [smallint] NULL,
  [MaxAdvReminderindays] [smallint] NULL,
  [MaxdaystosubmitRbi] [smallint] NULL,
  [ReportFrequencyValidCode] [char](1) NULL,
  [DestSysRephaseCode] [varchar](10) NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO