CREATE TABLE [dbo].[DimIndustryMapping] (
  [IndustryAlt_Key] [smallint] NULL,
  [IndustryOrderKey] [tinyint] NULL,
  [IndustryName] [varchar](50) NULL,
  [IndustryShortName] [varchar](20) NULL,
  [IndustryShortNameEnum] [varchar](20) NULL,
  [IndustryGroup] [varchar](50) NULL,
  [IndustrySubGroup] [varchar](50) NULL,
  [IndustrySegment] [varchar](50) NULL,
  [IndustryValidCode] [char](1) NULL,
  [SrcSysIndustryCode] [varchar](50) NULL,
  [SrcSysIndustryName] [varchar](50) NULL,
  [DestSysIndustryCode] [varchar](10) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModifie] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [SourceAlt_Key] [int] NULL,
  [Industry_Key] [int] IDENTITY,
  [IndustryMappingAlt_Key] [int] NULL
)
ON [PRIMARY]
GO