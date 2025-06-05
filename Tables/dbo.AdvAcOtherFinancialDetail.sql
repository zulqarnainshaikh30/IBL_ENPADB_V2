CREATE TABLE [dbo].[AdvAcOtherFinancialDetail] (
  [ENTITYKEY] [bigint] NULL,
  [AccountEntityId] [int] NOT NULL,
  [RefSystemAcId] [varchar](30) NULL,
  [int_receivable_adv] [decimal](16, 2) NULL,
  [penal_int_receivable] [decimal](16, 2) NULL,
  [Accrued_interest] [decimal](16, 2) NULL,
  [penal_due] [decimal](16, 2) NULL,
  [Interest_due] [decimal](16, 2) NULL,
  [other_dues] [decimal](16, 2) NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [datetime] NOT NULL,
  [Overdueinterest] [decimal](18, 2) NULL,
  [PenalOverdueinterest] [decimal](18, 2) NULL,
  [UnAppliedIntAmount] [decimal](18, 2) NULL,
  [PenalUnAppliedIntAmount] [decimal](18, 2) NULL,
  [PenalInterestOverDueSinceDt] [date] NULL
)
ON [PRIMARY]
GO