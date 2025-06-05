CREATE TABLE [dbo].[DimBusinessRuleCol] (
  [BusinessRuleCol_Key] [int] IDENTITY,
  [BusinessRuleColAlt_Key] [int] NULL,
  [BusinessRuleColDesc] [varchar](200) NULL,
  [BusinessRuleColumn] [varchar](100) NULL,
  [BusinessRuleColShortName] [varchar](50) NULL,
  [BusinessRuleColShortNameEnum] [varchar](50) NULL,
  [BusinessRuleColGroup] [varchar](50) NULL,
  [BusinessRuleColSubGroup] [varchar](50) NULL,
  [BusinessRuleColSegment] [varchar](50) NULL,
  [BusinessRuleColValidCode] [char](1) NULL,
  [BusinessRuleColOrder_Key] [int] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp]
)
ON [PRIMARY]
GO