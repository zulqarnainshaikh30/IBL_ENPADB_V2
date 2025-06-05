CREATE TABLE [dbo].[DimSubGLBACIDMapping] (
  [BACID_Key] [smallint] IDENTITY,
  [BACIDAlt_Key] [smallint] NOT NULL,
  [OfficeGL_BACID] [varchar](10) NULL,
  [CurrencyCode] [varchar](10) NULL,
  [OfficeGL_AccountNumber] [varchar](50) NULL,
  [OfficeGL_SubGL] [varchar](100) NULL,
  [OfficeGL_BACIDDesc] [varchar](100) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO