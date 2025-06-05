CREATE TABLE [dbo].[DimCity] (
  [City_Key] [smallint] NOT NULL,
  [CityAlt_Key] [smallint] NOT NULL,
  [CityName] [varchar](50) NULL,
  [CityShortName] [varchar](20) NULL,
  [CityShortNameEnum] [varchar](20) NULL,
  [CityGroup] [varchar](50) NULL,
  [CitySubGroup] [varchar](50) NULL,
  [CitySegment] [varchar](50) NULL,
  [CityValidCode] [char](1) NULL,
  [DistrictAlt_Key] [smallint] NULL,
  [DistrictName] [varchar](50) NULL,
  [SrcSysCityCode] [varchar](50) NULL,
  [SrcSysCityName] [varchar](50) NULL,
  [DestSysCityCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
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
GO