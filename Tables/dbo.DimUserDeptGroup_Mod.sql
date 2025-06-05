CREATE TABLE [dbo].[DimUserDeptGroup_Mod] (
  [EntityKey] [smallint] IDENTITY,
  [DeptGroupId] [smallint] NULL,
  [DeptGroupCode] [varchar](12) NULL,
  [DeptGroupName] [varchar](200) NULL,
  [Menus] [varchar](1000) NULL,
  [IsUniversal] [char](1) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [ChangeFields] [varchar](100) NULL,
  [ApprovedByFirstLevel] [varchar](100) NULL,
  [DateApprovedFirstLevel] [datetime] NULL
)
ON [PRIMARY]
GO