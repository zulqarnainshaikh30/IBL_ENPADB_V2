CREATE TABLE [dbo].[OTP_CRISMAC] (
  [EntityKey] [int] IDENTITY,
  [USERId] [varchar](50) NULL,
  [MobileNo] [varchar](20) NULL,
  [EmailId] [varchar](50) NULL,
  [OTP] [varchar](50) NULL,
  [StartTime] [time] NULL,
  [EndTime] [time] NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](250) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [LoginCount] [varchar](10) NULL
)
ON [PRIMARY]
GO