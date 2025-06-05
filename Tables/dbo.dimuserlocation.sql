CREATE TABLE [dbo].[dimuserlocation] (
  [UserLocation_Key] [smallint] NOT NULL,
  [UserLocationAlt_Key] [smallint] NULL,
  [LocationName] [varchar](50) NULL,
  [LocationShortName] [varchar](20) NULL,
  [LocationShortNameEnum] [varchar](20) NULL,
  [UserLocationGroup] [varchar](50) NULL,
  [UserLocationSubGroup] [varchar](50) NULL,
  [UserLocationSegment] [varchar](50) NULL,
  [UserLocationValidCode] [char](1) NULL,
  [SrcSysUserLocationCode] [varchar](50) NULL,
  [SrcSysUserLocationName] [varchar](50) NULL,
  [DestSysUserLocationCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
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