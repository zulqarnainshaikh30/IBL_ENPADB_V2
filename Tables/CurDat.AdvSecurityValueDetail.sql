﻿CREATE TABLE [CurDat].[AdvSecurityValueDetail] (
  [ENTITYKEY] [bigint] NULL,
  [SecurityEntityID] [bigint] NOT NULL,
  [ValuationSourceAlt_Key] [smallint] NULL,
  [ValuationDate] [datetime] NULL,
  [CurrentValue] [decimal](16, 2) NULL,
  [ValuationExpiryDate] [datetime] NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [datetime] NULL,
  [CurrentValueSource] [decimal](18, 2) NULL,
  [CollateralValueatthetimeoflastreviewinRs] [decimal](18, 2) NULL,
  [CollateralID] [varchar](30) NULL,
  [ExpiryBusinessRule] [varchar](100) NULL,
  [PeriodinMonth] [int] NULL,
  [Prev_ValuationDate] [date] NULL,
  [Prev_Value] [decimal](16, 2) NULL,
  CONSTRAINT [AdvSecurityValueDetail_SecurityEntityID] PRIMARY KEY NONCLUSTERED ([SecurityEntityID], [EffectiveFromTimeKey], [EffectiveToTimeKey]),
  CHECK ([EffectiveToTimeKey]=(49999))
)
ON [PRIMARY]
GO