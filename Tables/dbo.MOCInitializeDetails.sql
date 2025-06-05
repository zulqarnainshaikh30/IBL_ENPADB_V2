CREATE TABLE [dbo].[MOCInitializeDetails] (
  [EntityKey] [int] IDENTITY,
  [MOCInitializeDate] [date] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](50) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](50) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](50) NULL,
  [DateApproved] [datetime] NULL,
  [MOC_Freeze_Date] [date] NULL,
  [MOC_Freeze] [varchar](3) NULL
)
ON [PRIMARY]
GO