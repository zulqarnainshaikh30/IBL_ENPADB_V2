﻿CREATE TABLE [dbo].[UploadCalypsoAccMOCPool] (
  [SlNo] [varchar](max) NULL,
  [AccountID] [varchar](max) NULL,
  [POSinRs] [varchar](max) NULL,
  [InterestReceivableinRs] [varchar](max) NULL,
  [AdditionalProvisionAbsoluteinRs] [varchar](max) NULL,
  [RestructureFlagYN] [varchar](max) NULL,
  [RestructureDate] [varchar](max) NULL,
  [FITLFlagYN] [varchar](max) NULL,
  [DFVAmount] [varchar](max) NULL,
  [RePossesssionFlagYN] [varchar](max) NULL,
  [RePossessionDate] [varchar](max) NULL,
  [InherentWeaknessFlag] [varchar](max) NULL,
  [InherentWeaknessDate] [varchar](max) NULL,
  [SARFAESIFlag] [varchar](max) NULL,
  [SARFAESIDate] [varchar](max) NULL,
  [UnusualBounceFlag] [varchar](max) NULL,
  [UnusualBounceDate] [varchar](max) NULL,
  [UnclearedEffectsFlag] [varchar](max) NULL,
  [UnclearedEffectsDate] [varchar](max) NULL,
  [FraudFlag] [varchar](max) NULL,
  [FraudDate] [varchar](max) NULL,
  [TwoFlag] [varchar](max) NULL,
  [TwoDate] [varchar](max) NULL,
  [TwoAmount] [varchar](max) NULL,
  [SourceSystem] [varchar](max) NULL,
  [MOCSource] [varchar](max) NULL,
  [MOCReason] [varchar](max) NULL,
  [filname] [varchar](max) NULL,
  [SourceAlt_Key] [varchar](max) NULL,
  [ErrorMessage] [varchar](max) NULL,
  [ErrorinColumn] [varchar](max) NULL,
  [Srnooferroneousrows] [varchar](max) NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO