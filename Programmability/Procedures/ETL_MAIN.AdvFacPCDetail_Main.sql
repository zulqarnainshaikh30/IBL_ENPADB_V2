SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvFacPCDetail_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')

----------For New Records
UPDATE A SET A.IsChanged='N'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacPCDetail A
Where Not Exists(Select 1 from DBO.AdvFacPCDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId) -- And A.SourceAlt_Key=B.SourceAlt_Key)



UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.AdvFacPCDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacPCDetail AS T
ON O.AccountEntityID=T.AccountEntityID
--AND O.SourceAlt_Key=T.SourceAlt_Key
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(  ISNULL(O.PCAdvDt,'1990-01-01')<>ISNULL(T.PCAdvDt,'1990-01-01')
OR ISNULL(O.PCAmt,0)<>ISNULL(T.PCAmt,0)
OR ISNULL(O.PCDueDt,'1990-01-01')<>ISNULL(T.PCDueDt,'1990-01-01')
OR ISNULL(O.PCDurationDays,0)<>ISNULL(T.PCDurationDays,0)
OR ISNULL(O.PCExtendedDueDt,'1990-01-01')<>ISNULL(T.PCExtendedDueDt,'1990-01-01')
OR ISNULL(O.ExtensionReason,0)<>ISNULL(T.ExtensionReason,0)
OR ISNULL(O.CurrencyAlt_Key,0)<>ISNULL(T.CurrencyAlt_Key,0)
OR ISNULL(O.LcNo,0)<> ISNULL(T.LcNo,0)
OR ISNULL(O.LcAmt,0)<>ISNULL(T.LcAmt,0)
OR ISNULL(O.LcIssueDt,'1990-01-01')<>ISNULL(T.LcIssueDt,'1990-01-01')
OR ISNULL(O.LcIssuingBank_FirmOrder,0)<>ISNULL(T.LcIssuingBank_FirmOrder,0)
OR ISNULL(O.Balance,0)<>ISNULL(T.Balance,0)
OR ISNULL(O.BalanceInCurrency,0)<>ISNULL(T.BalanceInCurrency,0)
OR ISNULL(O.BalanceInUSD,0)<>ISNULL(T.BalanceInUSD,0)
OR ISNULL(O.Overdue,0)<>ISNULL(T.Overdue,0)
OR ISNULL(O.CommodityAlt_Key,0)<>ISNULL(T.CommodityAlt_Key,0)
OR ISNULL(O.CommodityValue,0)<>ISNULL(T.CommodityValue,0)
OR ISNULL(O.CommodityMarketValue,0)<>isnull(T.CommodityMarketValue,0)
OR ISNULL(O.ShipmentDt,'1990-01-01')<>ISNULL(T.ShipmentDt,'1990-01-01')
OR ISNULL(O.CommercialisationDt,'1990-01-01')<>ISNULL(T.CommercialisationDt,'1990-01-01')
OR isnull(O.EcgcPolicyNo,0)<>ISNULL(T.EcgcPolicyNo,0)
OR isnull(O.CAD,0)<>ISNULL(T.CAD,0)
OR isnull(O.CADU,0)<>ISNULL(T.CADU,0)
OR ISNULL(O.OverDueSinceDt,'1990-01-01')<>ISNULL(T.OverDueSinceDt,'1990-01-01')
OR ISNULL(O.TotalProv,0)<>ISNULL(T.TotalProv,0)
OR ISNULL(O.Secured,0)<>ISNULL(T.Secured,0)
OR ISNULL(O.Unsecured,0)<>ISNULL(T.Unsecured,0)
OR ISNULL(O.Provsecured,0)<>ISNULL(T.Provsecured,0)
OR ISNULL(O.ProvUnsecured,0)<>ISNULL(T.ProvUnsecured,0)
OR ISNULL(O.ProvDicgc,0)<>ISNULL(T.ProvDicgc,0)
OR ISNULL(O.npadt,'1990-01-01')<>ISNULL(T.npadt,'1990-01-01')
OR ISNULL(O.CoverGovGur,0)<>ISNULL(T.CoverGovGur,0)
OR ISNULL(O.DerecognisedInterest1,0)<>ISNULL(T.DerecognisedInterest1,0)
OR ISNULL(O.DerecognisedInterest2,0)<>ISNULL(T.DerecognisedInterest2,0)
OR ISNULL(O.ClaimType,'AA')<>ISNULL(T.ClaimType,'AA')
OR ISNULL(O.ClaimCoverAmt,0)<>ISNULL(T.ClaimCoverAmt,0)
OR ISNULL(O.ClaimLodgedDt,'1990-01-01')<>ISNULL(T.ClaimLodgedDt,'1990-01-01')
OR ISNULL(O.ClaimLodgedAmt,0)<>ISNULL(T.ClaimLodgedAmt,0)
OR ISNULL(O.ClaimRecvDt,'1990-01-01')<>ISNULL(T.ClaimRecvDt,'1990-01-01')
OR ISNULL(O.ClaimReceivedAmt,0)<>ISNULL(T.ClaimReceivedAmt,0)
OR ISNULL(O.ClaimRate,0)<>ISNULL(T.ClaimRate,0)
OR ISNULL(O.AdjDt,'1990-01-01')<>ISNULL(T.AdjDt,'1990-01-01')
OR ISNULL(O.EntityClosureDate,'1990-01-01')<>ISNULL(T.EntityClosureDate,'1990-01-01')
OR ISNULL(O.EntityClosureReasonAlt_Key,0)<>ISNULL(T.EntityClosureReasonAlt_Key,0)

)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacPCDetail A
INNER JOIN DBO.AdvFacPCDetail B 
ON B.AccountEntityId=A.AccountEntityId            --And A.SourceAlt_Key=B.SourceAlt_Key
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvFacPCDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacPCDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    --And AA.SourceAlt_Key=BB.SourceAlt_Key
    AND BB.EffectiveToTimeKey =49999
    )

	
	/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvFacPCDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacPCDetail] TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacPCDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
Where Temp.IsChanged in ('N','C')
------------------------------

INSERT INTO DBO.AdvFacPCDetail
     (	[EntityKey]
      ,[AccountEntityId]
      ,[PCRefNo]
      ,[PCAdvDt]
      ,[PCAmt]
      ,[PCDueDt]
      ,[PCDurationDays]
      ,[PCExtendedDueDt]
      ,[ExtensionReason]
      ,[CurrencyAlt_Key]
      ,[LcNo]
      ,[LcAmt]
      ,[LcIssueDt]
      ,[LcIssuingBank_FirmOrder]
      ,[Balance]
      ,[BalanceInCurrency]
      ,[BalanceInUSD]
      ,[Overdue]
      ,[CommodityAlt_Key]
      ,[CommodityValue]
      ,[CommodityMarketValue]
      ,[ShipmentDt]
      ,[CommercialisationDt]
      ,[EcgcPolicyNo]
      ,[CAD]
      ,[CADU]
      ,[OverDueSinceDt]
      ,[TotalProv]
      ,[Secured]
      ,[Unsecured]
      ,[Provsecured]
      ,[ProvUnsecured]
      ,[ProvDicgc]
      ,[npadt]
      ,[CoverGovGur]
      ,[DerecognisedInterest1]
      ,[DerecognisedInterest2]
      ,[ClaimType]
      ,[ClaimCoverAmt]
      ,[ClaimLodgedDt]
      ,[ClaimLodgedAmt]
      ,[ClaimRecvDt]
      ,[ClaimReceivedAmt]
      ,[ClaimRate]
      ,[AdjDt]
      ,[EntityClosureDate]
      ,[EntityClosureReasonAlt_Key]
      ,[RefSystemAcid]
      ,[AuthorisationStatus]
      ,[EffectiveFromTimeKey]
      ,[EffectiveToTimeKey]
      ,[CreatedBy]
      ,[DateCreated]
      ,[ModifiedBy]
      ,[DateModified]
      ,[ApprovedBy]
      ,[DateApproved]
      ,[D2Ktimestamp]
      ,[UnAppliedIntt]
      ,[MocTypeAlt_Key]
      ,[MocStatus]
      ,[MocDate]
      ,[RBI_ExtnPermRefNo]
      ,[LC_OrderAlt_Key]
      ,[OrderLC_CurrencyAlt_Key]
      ,[CountryAlt_Key]
      ,[LcAmtInCurrenc]
	  --,PcEntityId
		   )
SELECT
				
		    [EntityKey]
      ,[AccountEntityId]
      ,[PCRefNo]
      ,[PCAdvDt]
      ,[PCAmt]
      ,[PCDueDt]
      ,[PCDurationDays]
      ,[PCExtendedDueDt]
      ,[ExtensionReason]
      ,[CurrencyAlt_Key]
      ,[LcNo]
      ,[LcAmt]
      ,[LcIssueDt]
      ,[LcIssuingBank_FirmOrder]
      ,[Balance]
      ,[BalanceInCurrency]
      ,[BalanceInUSD]
      ,[Overdue]
      ,[CommodityAlt_Key]
      ,[CommodityValue]
      ,[CommodityMarketValue]
      ,[ShipmentDt]
      ,[CommercialisationDt]
      ,[EcgcPolicyNo]
      ,[CAD]
      ,[CADU]
      ,[OverDueSinceDt]
      ,[TotalProv]
      ,[Secured]
      ,[Unsecured]
      ,[Provsecured]
      ,[ProvUnsecured]
      ,[ProvDicgc]
      ,[npadt]
      ,[CoverGovGur]
      ,[DerecognisedInterest1]
      ,[DerecognisedInterest2]
      ,[ClaimType]
      ,[ClaimCoverAmt]
      ,[ClaimLodgedDt]
      ,[ClaimLodgedAmt]
      ,[ClaimRecvDt]
      ,[ClaimReceivedAmt]
      ,[ClaimRate]
      ,[AdjDt]
      ,[EntityClosureDate]
      ,[EntityClosureReasonAlt_Key]
      ,[RefSystemAcid]
      ,[AuthorisationStatus]
      ,[EffectiveFromTimeKey]
      ,[EffectiveToTimeKey]
      ,[CreatedBy]
      ,[DateCreated]
      ,[ModifiedBy]
      ,[DateModified]
      ,[ApprovedBy]
      ,[DateApproved]
      ,getdate() [D2Ktimestamp]
      ,[UnAppliedIntt]
      ,[MocTypeAlt_Key]
      ,[MocStatus]
      ,[MocDate]
      ,[RBI_ExtnPermRefNo]
      ,[LC_OrderAlt_Key]
      ,[OrderLC_CurrencyAlt_Key]
      ,[CountryAlt_Key]
      ,[LcAmtInCurrenc]
	  --,PcEntityId
		   FROM IBL_ENPA_TEMPDB_V2.dbo.TempAdvFacPCDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')


END


GO