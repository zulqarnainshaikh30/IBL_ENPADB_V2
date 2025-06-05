SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvFacBillDetail_Main]
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
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacBillDetail A
Where Not Exists(Select 1 from DBO.AdvFacBillDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId) -- And A.SourceAlt_Key=B.SourceAlt_Key)



UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.AdvFacBillDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacBillDetail AS T
ON O.AccountEntityID=T.AccountEntityID
--AND O.SourceAlt_Key=T.SourceAlt_Key
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(   O.npadt				<> T.npadt
 OR O.OverDueSinceDt	<> T.OverDueSinceDt
 --OR O.UnAppliedIntt		<> T.UnAppliedIntt
 OR O.Overdue			<> T.Overdue
 OR O.Balance			<> T.Balance
 OR O.BillDueDt			<> T.BillDueDt
 OR O.BillPurDt			<> T.BillPurDt
 OR O.BillAmt			<> T.BillAmt
 OR O.BillDt			<> T.BillDt


)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacBillDetail A
INNER JOIN DBO.AdvFacBillDetail B 
ON B.AccountEntityId=A.AccountEntityId            --And A.SourceAlt_Key=B.SourceAlt_Key
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvFacBillDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacBillDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    --And AA.SourceAlt_Key=BB.SourceAlt_Key
    AND BB.EffectiveToTimeKey =49999
    )

	
/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvFacBillDetail] 
IF @EntityKey IS NULL  
BEGIN
	SET @EntityKey=0
END

UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacBillDetail] TEMP
INNER JOIN (SELECT AccountEntityid,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacBillDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON  Temp.AccountEntityid=ACCT.AccountEntityid
Where Temp.IsChanged in ('N','C')

INSERT INTO DBO.AdvFacBillDetail
     (	[EntityKey]
      ,[AccountEntityId]
      --[D2KFacilityID]
      ,[BillNo]
      ,[BillDt]
      ,[BillAmt]
	  ,BillEntityId
      ,[BillRefNo]
      ,[BillPurDt]
      ,[AdvAmount]
      ,[BillDueDt] 
      ,[BillExtendedDueDt]
      ,[CrystalisationDt]
      ,[CommercialisationDt]
      ,[BillNatureAlt_Key]
      ,[BillAcceptanceDt]
      ,[UsanceDays]
      ,[DraweeNo]
      ,[DraweeBankName]
      ,[DrawerName]
      ,[PayeeName]
      ,[CollectingBankName]
      ,[CollectingBranchPlace]
      ,[InterestIncome]
      ,[Commission]
      ,[DiscountCharges]
      ,[DelayedInt]
      ,[MarginType]
      ,[MarginAmt]
      ,[CountryAlt_Key]
      ,[BillOsReasonAlt_Key]
      ,[CommodityAlt_Key]
      ,[LcNo]
      ,[LcAmt]
      ,[LcIssuingBankAlt_Key]
      ,[LcIssuingBank]
      ,[CurrencyAlt_Key]
      ,[Balance]
      ,[BalanceInCurrency]
      ,[Overdue]
      ,[DerecognisedInterest1]
      ,[DerecognisedInterest2]
      ,[OverDueSinceDt]
      ,[TotalProv]
      ,[AdditionalProv]
      ,[GenericAddlProv]
      ,[Secured]
      ,[CoverGovGur]
      ,[Unsecured]
      ,[Provsecured]
      ,[ProvUnsecured]
      ,[ProvDicgc]
      ,[npadt]
      ,[ClaimType]
      ,[ClaimCoverAmt]
      ,[ClaimLodgedDt]
      ,[ClaimLodgedAmt]
      ,[ClaimRecvDt]
      ,[ClaimReceivedAmt]
      ,[ClaimRate]
      ,[ScrCrError]
      ,[RefSystemAcid]
      ,[AdjDt]
      ,[AdjReasonAlt_Key]
      ,[EntityClosureDate]
      ,[EntityClosureReasonAlt_Key]
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
      ,[MocStatus]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[ScrCrErrorSeq]
      ,[ConsigmentExport]
		   )
SELECT
				
		    [EntityKey]
      ,[AccountEntityId]
      --[D2KFacilityID]
      ,[BillNo]
      ,[BillDt]
      ,[BillAmt]
	  ,BillEntityId
      ,[BillRefNo]
      ,[BillPurDt]
      ,[AdvAmount]
      ,[BillDueDt]
      ,[BillExtendedDueDt]
      ,[CrystalisationDt]
      ,[CommercialisationDt]
      ,[BillNatureAlt_Key]
      ,[BillAcceptanceDt]
      ,[UsanceDays]
      ,[DraweeNo]
      ,[DraweeBankName]
      ,[DrawerName]
      ,[PayeeName]
      ,[CollectingBankName]
      ,[CollectingBranchPlace]
      ,[InterestIncome]
      ,[Commission]
      ,[DiscountCharges]
      ,[DelayedInt]
      ,[MarginType]
      ,[MarginAmt]
      ,[CountryAlt_Key]
      ,[BillOsReasonAlt_Key]
      ,[CommodityAlt_Key]
      ,[LcNo]
      ,[LcAmt]
      ,[LcIssuingBankAlt_Key]
      ,[LcIssuingBank]
      ,[CurrencyAlt_Key]
      ,[Balance]
      ,[BalanceInCurrency]
      ,[Overdue]
      ,[DerecognisedInterest1]
      ,[DerecognisedInterest2]
      ,[OverDueSinceDt]
      ,[TotalProv]
      ,[AdditionalProv]
      ,[GenericAddlProv]
      ,[Secured]
      ,[CoverGovGur]
      ,[Unsecured]
      ,[Provsecured]
      ,[ProvUnsecured]
      ,[ProvDicgc]
      ,[npadt]
      ,[ClaimType]
      ,[ClaimCoverAmt]
      ,[ClaimLodgedDt]
      ,[ClaimLodgedAmt]
      ,[ClaimRecvDt]
      ,[ClaimReceivedAmt]
      ,[ClaimRate]
      ,[ScrCrError]
      ,[RefSystemAcid]
      ,[AdjDt]
      ,[AdjReasonAlt_Key]
      ,[EntityClosureDate]
      ,[EntityClosureReasonAlt_Key]
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
      ,[MocStatus]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[ScrCrErrorSeq]
      ,[ConsigmentExport]
		   FROM IBL_ENPA_TEMPDB_V2.dbo.TempAdvFacBillDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')


END


GO