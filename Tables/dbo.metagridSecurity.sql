CREATE TABLE [dbo].[metagridSecurity] (
  [Date_of_Data] [date] NULL,
  [Source_System_Name] [varchar](30) NULL,
  [Customer_ID] [varchar](30) NULL,
  [Account_ID] [varchar](30) NULL,
  [Security_ID] [varchar](20) NULL,
  [Collateral_Type] [varchar](20) NULL,
  [Security_Code] [varchar](10) NULL,
  [Charge_Type_Code] [varchar](10) NULL,
  [Security_Value] [decimal](16, 2) NULL,
  [Valuation_Source] [varchar](30) NULL,
  [Valuation_date] [date] NULL,
  [Valuation_expiry_date] [date] NULL,
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