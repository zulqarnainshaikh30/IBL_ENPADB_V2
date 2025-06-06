﻿CREATE TABLE [CurDat].[AdvCustCommunicationDetail] (
  [EntityKey] [bigint] NOT NULL,
  [CustomerEntityId] [int] NOT NULL,
  [RelationEntityId] [int] NOT NULL,
  [RelationAddEntityId] [int] NOT NULL,
  [AddressCategoryAlt_Key] [int] NULL,
  [AddressTypeAlt_Key] [int] NULL,
  [Add1] [varchar](100) NULL,
  [Add2] [varchar](100) NULL,
  [Add3] [varchar](100) NULL,
  [CountryAlt_Key] [smallint] NULL,
  [DistrictAlt_Key] [smallint] NULL,
  [CityAlt_Key] [smallint] NULL,
  [PinCode] [varchar](10) NULL,
  [CustLocationCode] [varchar](16) NULL,
  [STD_Code_Res] [varchar](10) NULL,
  [PhoneNo_Res] [varchar](26) NULL,
  [STD_Code_Off] [varchar](10) NULL,
  [PhoneNo_Off] [varchar](26) NULL,
  [FaxNo] [varchar](26) NULL,
  [ExtensionNo] [varchar](10) NULL,
  [ScrCrError] [varchar](100) NULL,
  [RefCustomerId] [varchar](20) NULL,
  [IsMainAddress] [char](1) NULL,
  [AuthorisationStatus] [varchar](2) NULL,
  [EffectiveFromTimeKey] [int] NOT NULL,
  [EffectiveToTimeKey] [int] NOT NULL,
  [CreatedBy] [varchar](20) NULL,
  [DateCreated] [smalldatetime] NULL,
  [ModifiedBy] [varchar](20) NULL,
  [DateModified] [smalldatetime] NULL,
  [ApprovedBy] [varchar](20) NULL,
  [DateApproved] [smalldatetime] NULL,
  [D2Ktimestamp] [datetime] NOT NULL,
  [DUNSNo] [varchar](20) NULL,
  [CIBILPGId] [varchar](30) NULL,
  [CityName] [varchar](60) NULL,
  [ScrCrErrorSeq] [varchar](200) NULL,
  [UCIF_ID] [varchar](30) NULL,
  [UCIFEntityID] [int] NULL,
  CONSTRAINT [AdvCustCommunicationDetail_CustomerEntityId] PRIMARY KEY NONCLUSTERED ([RelationAddEntityId], [CustomerEntityId], [EffectiveFromTimeKey], [EffectiveToTimeKey]),
  CHECK ([EffectiveToTimeKey]=(49999)),
  CHECK ([EffectiveToTimeKey]=(49999))
)
ON [PRIMARY]
GO