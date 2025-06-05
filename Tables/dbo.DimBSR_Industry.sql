CREATE TABLE [dbo].[DimBSR_Industry] (
  [BSR_Industry_Key] [smallint] NOT NULL,
  [BSR_IndustryAlt_Key] [smallint] NULL,
  [BSR_IndustryCode] [varchar](10) NULL,
  [BSR_IndustryOrderKey] [tinyint] NULL,
  [BSR_IndustryName] [nvarchar](4000) NULL,
  [BSR_IndustryShortName] [varchar](100) NULL,
  [BSR_IndustryShortNameEnum] [varchar](100) NULL,
  [BSR_IndustryGroup] [nvarchar](100) NULL,
  [BSR_IndustrySubGroup] [nvarchar](100) NULL,
  [BSR_IndustrySegment] [varchar](50) NULL,
  [BSR_IndustryValidCode] [char](1) NULL,
  [SrcSysBSR_IndustryCode] [varchar](50) NULL,
  [SrcSysBSR_IndustryName] [varchar](50) NULL,
  [DestSysBSR_IndustryCode] [varchar](10) NULL,
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