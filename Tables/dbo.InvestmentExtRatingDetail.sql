CREATE TABLE [dbo].[InvestmentExtRatingDetail] (
  [EntityKey] [int] IDENTITY,
  [IssuerEntityID] [int] NULL,
  [InstrumentEntityID] [int] NULL,
  [RatingEntityID] [int] NULL,
  [RatingAgencyAlt_Key] [smallint] NULL,
  [RatingAlt_Key] [smallint] NULL,
  [RatingDt] [date] NULL,
  [RatingExpDt] [date] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO