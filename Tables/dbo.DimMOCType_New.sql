CREATE TABLE [dbo].[DimMOCType_New] (
  [MOCType_Key] [smallint] NOT NULL,
  [MOCTypeAlt_Key] [smallint] NULL,
  [MOCTypeName] [varchar](50) NULL,
  [MOCTypeShortName] [varchar](20) NULL,
  [MOCTypeShortNameEnum] [varchar](20) NULL,
  [MOCTypeGroup] [varchar](50) NULL,
  [MOCTypeSubGroup] [varchar](50) NULL,
  [MOCTypeSegment] [varchar](50) NULL,
  [MOCTypeValidCode] [char](1) NULL,
  [SrcSysMOCTypeCode] [varchar](50) NULL,
  [SrcSysMOCTypeName] [varchar](50) NULL,
  [DestSysMOCTypeCode] [varchar](10) NULL,
  [DestSysMOCTypeValidCode`] [char](1) NULL,
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