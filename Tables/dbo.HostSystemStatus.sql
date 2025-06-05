CREATE TABLE [dbo].[HostSystemStatus] (
  [UCIC Code] [varchar](50) NULL,
  [CustomerID] [varchar](50) NULL,
  [CustomerName] [varchar](225) NULL,
  [AccountNo] [varchar](30) NULL,
  [Host System Name] [varchar](50) NULL,
  [OSBalance] [decimal](16, 2) NULL,
  [Report Date] [datetime] NULL,
  [ActSegmentCode] [varchar](30) NULL,
  [Account Level Business Segment] [varchar](20) NULL,
  [Business Seg Desc] [varchar](100) NULL,
  [Base Account Scheme Code] [varchar](20) NULL,
  [Base Account Scheme Owner] [int] NULL,
  [Host System Status] [varchar](5) NULL,
  [Remarks] [varchar](50) NULL,
  [Closed Date] [datetime] NULL,
  [Cr/Dr] [varchar](2) NOT NULL,
  [Main_Classification] [varchar](100) NULL,
  [EffectiveFromTimekey] [int] NULL,
  [EffectiveToTimekey] [int] NULL
)
ON [PRIMARY]
GO