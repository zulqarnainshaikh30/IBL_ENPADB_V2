CREATE TABLE [dbo].[UploadOtherOwnerDetail] (
  [Entity_Key] [int] IDENTITY,
  [SrNo] [varchar](max) NULL,
  [SystemCollateralID] [varchar](max) NULL,
  [CustomeroftheBank] [varchar](max) NULL,
  [CustomerID] [varchar](max) NULL,
  [OtherOwnerName] [varchar](max) NULL,
  [OtherOwnerRelationship] [varchar](max) NULL,
  [Ifrelativeentervalue] [varchar](max) NULL,
  [AddressType] [varchar](max) NULL,
  [AddressCategory] [varchar](max) NULL,
  [AddressLine1] [varchar](max) NULL,
  [AddressLine2] [varchar](max) NULL,
  [AddressLine3] [varchar](max) NULL,
  [City] [varchar](max) NULL,
  [PinCode] [varchar](max) NULL,
  [Country] [varchar](max) NULL,
  [District] [varchar](max) NULL,
  [StdCodeO] [varchar](max) NULL,
  [PhoneNoO] [varchar](max) NULL,
  [StdCodeR] [varchar](max) NULL,
  [PhoneNoR] [varchar](max) NULL,
  [MobileNo] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO