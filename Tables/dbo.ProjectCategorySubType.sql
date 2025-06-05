﻿CREATE TABLE [dbo].[ProjectCategorySubType] (
  [EntityKey] [int] IDENTITY,
  [ProjectCategorySubTypeAltKey] [int] NULL,
  [ProjectCategoryTypeAltKey] [int] NULL,
  [ProjectCategorySubTypeID] [varchar](20) NULL,
  [ProjectCategorySubType] [varchar](20) NULL,
  [ProjectCategorySubTypeDescription] [varchar](500) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [AuthorisationStatus] [varchar](5) NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [smalldatetime] NULL
)
ON [PRIMARY]
GO