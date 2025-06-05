SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[AdvAcExposureFunction](@TimeKey SMALLINT)
RETURNS @EXPOSURE TABLE
(AccountEntityId INT
, EXPOSURE Decimal(18,2)
 )
AS
BEGIN

insert into @EXPOSURE (AccountEntityId, EXPOSURE)
SELECT A.AccountEntityId
,CASE WHEN b.FacilityType in ('TL','DL')
                       THEN (CASE WHEN DAC.AssetClassGroup='STD'
                                  THEN ((ISNULL(CurrentLimit,0) - ISNULL(LimitDisbursed,0)) + ISNULL(a.Balance,0))
                                         ELSE ISNULL(a.Balance,0) 
										                      END)
                   ElSE (CASE WHEN DAC.AssetClassGroup='STD'
                      THEN (CASE WHEN (ISNULL(b.CurrentLimit,0) > ISNULL(a.Balance,0))
                                 THEN ISNULL(b.CurrentLimit,0)
                                      ELSE ISNULL(a.Balance,0) 
									                        END)
             ELSE ISNULL(a.Balance,0) 
			     END) 
			 END AS EXPOSURE
FROM AdvAcBalanceDetail a WITH (NOLOCK) 
INNER JOIN AdvAcBasicDetail b WITH (NOLOCK) ON b.EffectiveFromTimeKey<=@TimeKey
                            AND b.EffectiveToTimeKey>= @TIMEKEY
                            AND a.EffectiveFromTimeKey<= @TIMEKEY
                            AND a.EffectiveToTimeKey>= @TIMEKEY
							AND A.AccountEntityId = b.AccountEntityId
INNER JOIN AdvAcFinancialDetail C WITH (NOLOCK) ON C.EffectiveFromTimeKey<= @TIMEKEY
                            AND C.EffectiveToTimeKey>= @TIMEKEY
                            AND A.AccountEntityId=C.AccountEntityId
LEFT JOIN DimAssetClass DAC ON A.AssetClassAlt_Key=DAC.AssetClassAlt_Key                                        

RETURN  

END




GO