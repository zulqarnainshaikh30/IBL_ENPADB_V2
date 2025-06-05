CREATE TABLE [dbo].[dimdepartment] (
  [Department_Key] [int] IDENTITY,
  [DepartmentAlt_Key] [int] NULL,
  [DepartmentCode] [nvarchar](255) NULL,
  [DepartmentName] [nvarchar](255) NULL,
  [DepartmentShortName] [nvarchar](255) NULL,
  [DepartmentShortNameEnum] [nvarchar](255) NULL,
  [DepartmentGroup] [nvarchar](255) NULL,
  [DepartmentSubGroup] [nvarchar](255) NULL,
  [DepartmentSegment] [nvarchar](255) NULL,
  [ApplicableBACID] [nvarchar](max) NULL,
  [ContactPersonUserID] [nvarchar](255) NULL,
  [AuthorisationStatus] [nvarchar](255) NULL,
  [EffectiveFromTimeKey] [int] NULL,
  [EffectiveToTimeKey] [int] NULL,
  [CreatedBy] [nvarchar](255) NULL,
  [DateCreated] [datetime] NULL,
  [ModifiedBy] [nvarchar](255) NULL,
  [DateModified] [datetime] NULL,
  [ApprovedBy] [nvarchar](255) NULL,
  [DateApproved] [datetime] NULL,
  [D2Ktimestamp] [timestamp],
  [ChangeFields] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO