CREATE TABLE [dbo].[DimReasonForWillfulDefault] (
  [ReasonAlt_Key] [int] NOT NULL,
  [Description] [nvarchar](100) NULL,
  [DelSta] [nvarchar](7) NULL,
  [EditFlag] [nvarchar](1) NULL,
  [Reason_Key] [smallint] NOT NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [DateCreated] [datetime] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ModifyBy] [varchar](20) NULL,
  [ApprovedBy] [varchar](20) NULL,
  [D2Ktimestamp] [timestamp] NULL,
  [RecordStatus] [char](1) NULL
)
ON [PRIMARY]
GO