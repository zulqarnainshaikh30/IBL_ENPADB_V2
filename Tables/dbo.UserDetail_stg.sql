CREATE TABLE [dbo].[UserDetail_stg] (
  [Entity_Key] [int] IDENTITY,
  [SrNo] [varchar](max) NULL,
  [UserID] [varchar](max) NULL,
  [UserName] [varchar](max) NULL,
  [UserRole] [varchar](max) NULL,
  [Designation] [varchar](max) NULL,
  [UserDepartment] [varchar](max) NULL,
  [UserEmailId] [varchar](max) NULL,
  [UserMobileNumber] [varchar](max) NULL,
  [UserExtensionNumber] [varchar](max) NULL,
  [IsChecker] [varchar](max) NULL,
  [IsChecker2] [varchar](max) NULL,
  [IsActive] [varchar](max) NULL,
  [sheetname] [varchar](max) NULL,
  [ActionAU] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO