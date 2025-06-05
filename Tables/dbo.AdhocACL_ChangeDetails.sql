CREATE TABLE [dbo].[AdhocACL_ChangeDetails] (
  [EntityKey] [int] IDENTITY,
  [UCIF_ID] [varchar](20) NULL,
  [UcifEntityID] [int] NULL,
  [CustomerId] [varchar](20) NULL,
  [CustomerEntityId] [int] NULL,
  [PrevAssetClassAlt_Key] [smallint] NULL,
  [PrevNPA_Date] [date] NULL,
  [AssetClassAlt_Key] [smallint] NULL,
  [NPA_Date] [date] NULL,
  [AuthorisationStatus] [char](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [DateCreated] [datetime] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [D2Ktimestamp] [timestamp] NULL,
  [Reason] [varchar](100) NULL,
  [FirstLevelDateApproved] [datetime] NULL,
  [FirstLevelApprovedBy] [varchar](20) NULL,
  [ChangeField] [varchar](max) NULL,
  [CustomerName] [varchar](225) NULL,
  [ChangeType] [varchar](20) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO