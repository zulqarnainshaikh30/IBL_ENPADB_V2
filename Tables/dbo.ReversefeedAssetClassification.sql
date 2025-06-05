CREATE TABLE [dbo].[ReversefeedAssetClassification] (
  [DATE_OF_DATA] [date] NULL,
  [SOURCE_SYSTEM] [varchar](7) NULL,
  [CIF_ID] [varchar](50) NULL,
  [FORACID] [varchar](16) NULL,
  [SOL_ID] [varchar](5) NULL,
  [CURR_ASST_MAIN_CLS] [varchar](5) NULL,
  [CURR_ASST_SUB_CLS] [varchar](30) NULL,
  [REV_ASST_MAIN_CLS] [varchar](5) NULL,
  [REV_ASST_SUB_CLS] [varchar](30) NULL,
  [NPA_DATE] [date] NULL,
  [DPD] [int] NULL,
  [FREE_TEXT_1] [varchar](100) NULL,
  [FREE_TEXT_2] [varchar](100) NULL,
  [FREE_TEXT_3] [varchar](100) NULL,
  [BANK_ID] [varchar](10) NULL
)
ON [PRIMARY]
GO