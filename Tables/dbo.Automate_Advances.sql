CREATE TABLE [dbo].[Automate_Advances] (
  [Id] [int] NOT NULL,
  [Timekey] [varchar](20) NULL,
  [Date] [datetime] NULL,
  [EffectiveFromTimekey] [varchar](20) NULL,
  [DataEffectiveFromDate] [datetime] NULL,
  [EffectiveToTimekey] [varchar](20) NULL,
  [DataEffectiveToDate] [datetime] NULL,
  [MonthEndDate] [datetime] NULL,
  [MonthStartDate] [datetime] NULL,
  [EXT_FLG] [varchar](10) NULL,
  [FridayYN] [char](1) NULL
)
ON [PRIMARY]
GO