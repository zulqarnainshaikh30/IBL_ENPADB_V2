CREATE TABLE [dbo].[MOCFreezeDetails] (
  [EntityKey] [int] IDENTITY,
  [Freeze_MOC_Date] [date] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL,
  [MOC_Initialized_Date] [date] NULL
)
ON [PRIMARY]
GO