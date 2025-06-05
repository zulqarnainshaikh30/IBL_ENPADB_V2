CREATE TABLE [dbo].[DimOccupation] (
  [Occupation_Key] [smallint] NOT NULL,
  [OccupationAlt_Key] [smallint] NOT NULL,
  [OccupationOrderKey] [tinyint] NULL,
  [OccupationName] [varchar](50) NULL,
  [OccupationShortName] [varchar](20) NULL,
  [OccupationShortNameEnum] [varchar](20) NULL,
  [OccupationGroup] [varchar](50) NULL,
  [OccupationSubGroup] [varchar](50) NULL,
  [OccupationSegment] [varchar](50) NULL,
  [OccupationValidCode] [char](1) NULL,
  [VillageOccupation] [char](1) NULL,
  [SrcSysOccupationCode] [varchar](50) NULL,
  [SrcSysOccupationName] [varchar](50) NULL,
  [DestSysOccupationCode] [varchar](10) NULL,
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