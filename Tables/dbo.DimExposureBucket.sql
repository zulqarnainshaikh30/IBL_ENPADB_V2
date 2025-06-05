﻿CREATE TABLE [dbo].[DimExposureBucket] (
  [EntityKey] [int] IDENTITY,
  [ExposureBucketAlt_Key] [smallint] NULL,
  [BucketName] [varchar](100) NULL,
  [BucketLowerValue] [varchar](30) NULL,
  [BucketUpperValue] [varchar](30) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL
)
ON [PRIMARY]
GO