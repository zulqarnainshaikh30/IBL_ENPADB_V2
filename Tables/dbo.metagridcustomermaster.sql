CREATE TABLE [dbo].[metagridcustomermaster] (
  [Date_of_Data] [date] NULL,
  [Source_System] [varchar](50) NULL,
  [UCIC_ID] [varchar](20) NULL,
  [Customer_ID] [varchar](30) NULL,
  [Customer_Name] [varchar](300) NULL,
  [Customer_Constitution] [varchar](100) NULL,
  [Gender] [varchar](10) NULL,
  [Customer_Segment_Code] [varchar](100) NULL,
  [PAN_No] [varchar](50) NULL,
  [Asset_Class] [varchar](10) NULL,
  [NPA_Date] [date] NULL,
  [DBT_LOS_Date] [date] NULL,
  [Always_NPA] [smallint] NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [varchar](100) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](100) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](100) NULL,
  [DateApproved] [smalldatetime] NULL,
  [EntityKey] [int] IDENTITY,
  [MetagridEntityId] [int] NULL
)
ON [PRIMARY]
GO