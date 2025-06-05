CREATE TABLE [dbo].[MOCInitializeDetails_Mod] (
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
  [ChangeFields] [varchar](100) NULL,
  [ApprovedByFirstLevel] [varchar](50) NULL,
  [DateApprovedFirstLevel] [datetime] NULL,
  [MOC_Freeze] [varchar](3) NULL,
  [MOC_Freeze_Date] [date] NULL
)
ON [PRIMARY]
GO