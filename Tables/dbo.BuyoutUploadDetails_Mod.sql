CREATE TABLE [dbo].[BuyoutUploadDetails_Mod] (
  [EntityKey] [int] IDENTITY,
  [SlNo] [int] NULL,
  [UploadID] [int] NULL,
  [DateofData] [date] NULL,
  [ReportDate] [date] NULL,
  [CustomerAcID] [varchar](30) NULL,
  [SchemeCode] [varchar](10) NULL,
  [NPA_ClassSeller] [varchar](4) NULL,
  [NPA_DateSeller] [date] NULL,
  [DPD_Seller] [smallint] NULL,
  [PeakDPD] [smallint] NULL,
  [PeakDPD_Date] [date] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [date] NULL,
  [ModifyBy] [varchar](100) NULL,
  [DateModified] [date] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [date] NULL,
  [ChangeFields] [varchar](max) NULL,
  [ApprovedByFirstLevel] [varchar](100) NULL,
  [DateApprovedFirstLevel] [datetime] NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO