CREATE TABLE [dbo].[DimExtRatingAgency] (
  [RatingAgency_Key] [smallint] NOT NULL,
  [RatingAgencyAlt_Key] [smallint] NULL,
  [RatingAgencyName] [varchar](50) NULL,
  [RatingAgencyShortName] [varchar](20) NULL,
  [RatingAgencyShortNameEnum] [varchar](20) NULL,
  [RatingAgencyGroup] [varchar](50) NULL,
  [SrcSysRatingAgencyCode] [varchar](50) NULL,
  [SrcSysRatingAgencyName] [varchar](50) NULL,
  [DestSysRatingAgencyNameCode] [varchar](10) NULL,
  [CibilAssetmentAgency_Authority] [varchar](2) NULL,
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