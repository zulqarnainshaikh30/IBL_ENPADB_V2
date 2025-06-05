CREATE TABLE [dbo].[DimMaxLoginAllow] (
  [EntityKey] [smallint] NOT NULL,
  [UserLocationCode] [varchar](10) NULL,
  [UserLocation] [varchar](4) NULL,
  [UserLocationName] [varchar](50) NULL,
  [MaxUserLogin] [smallint] NULL,
  [UserLoginCount] [smallint] NULL,
  [MaxUserCustom] [char](1) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO