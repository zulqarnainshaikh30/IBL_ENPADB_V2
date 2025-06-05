CREATE TABLE [dbo].[SecurisationDataTest] (
  [Pool ID] [nvarchar](255) NULL,
  [Pool Name] [nvarchar](255) NULL,
  [Securitisation Type] [nvarchar](255) NULL,
  [Account ID] [nvarchar](255) NULL,
  [Customer ID] [nvarchar](255) NULL,
  [Principal Outstanding in Rs#] [float] NULL,
  [Interest Receivable in Rs#] [float] NULL,
  [O/S Balance in Rs#] [float] NULL,
  [Securitisation Exposure in Rs#] [float] NULL,
  [Date of Securitisation reckoning] [nvarchar](255) NULL,
  [Date of Securitisation marking] [nvarchar](255) NULL,
  [Maturity Date] [nvarchar](255) NULL
)
ON [PRIMARY]
GO