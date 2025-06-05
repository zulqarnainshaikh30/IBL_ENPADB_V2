CREATE TABLE [dbo].[DimBSRActivityMaster] (
  [BSR_Activity_Key] [smallint] IDENTITY,
  [BSR_ActivityAlt_Key] [smallint] NULL,
  [BSR_ActivityCode] [varchar](10) NULL,
  [BSR_ActivityName] [nvarchar](4000) NULL,
  [BSR_ActivityDivision] [varchar](100) NULL,
  [BSR_ActivitySubDivision] [varchar](100) NULL,
  [BSR_ActivityGroup] [nvarchar](100) NULL,
  [BSR_ActivitySubGroup] [nvarchar](100) NULL,
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