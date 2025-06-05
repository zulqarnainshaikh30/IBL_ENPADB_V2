SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvFacDLDetail_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @VEFFECTIVETO INT =(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')

----------For New Records
UPDATE A SET A.IsChanged='N'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacDLDetail A
Where Not Exists(Select 1 from DBO.ADVFACDLDETAIL B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId) -- And A.SourceAlt_Key=B.SourceAlt_Key)



UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.ADVFACDLDETAIL AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacDLDetail AS T
ON O.AccountEntityID=T.AccountEntityID
--AND O.SourceAlt_Key=T.SourceAlt_Key
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(
   ISNULL(O.Principal,0)					<>	ISNULL(T.Principal,0)
OR ISNULL(O.RepayModeAlt_Key,0)				<>	ISNULL(T.RepayModeAlt_Key,0)
OR ISNULL(O.NoOfInstall,0)					<>	ISNULL(T.NoOfInstall,0)
OR ISNULL(O.InstallAmt,0)					<>	ISNULL(T.InstallAmt,0)
OR ISNULL(O.FstInstallDt,'1900-01-01')      <>	ISNULL(T.FstInstallDt,'1900-01-01')
OR ISNULL(O.LastInstallDt,'1900-01-01')     <>	ISNULL(T.LastInstallDt,'1900-01-01')
OR ISNULL(O.Tenure_Months,0)				<>	ISNULL(T.Tenure_Months,0)
OR ISNULL(O.MarginAmt,0)					<>	ISNULL(T.MarginAmt,0)
OR ISNULL(O.CommodityAlt_Key,0)				<>	ISNULL(T.CommodityAlt_Key,0)
OR ISNULL(O.RephaseAlt_Key,0)				<>	ISNULL(T.RephaseAlt_Key,0)
OR ISNULL(O.RephaseDt,'1900-01-01')			<>	ISNULL(T.RephaseDt,'1900-01-01')
OR ISNULL(O.IntServiced,0)					<>	ISNULL(T.IntServiced,0)
OR ISNULL(O.SuspendedInterest,0)			<>	ISNULL(T.SuspendedInterest,0)
OR ISNULL(O.DerecognisedInterest1,0)		<>	ISNULL(T.DerecognisedInterest1,0)
OR ISNULL(O.DerecognisedInterest2,0)		<>	ISNULL(T.DerecognisedInterest2,0)
OR ISNULL(O.AdjReasonAlt_Key,0)				<>	ISNULL(T.AdjReasonAlt_Key,0)
OR ISNULL(O.LcNo,'AA')						<>	ISNULL(T.LcNo,'AA')
OR ISNULL(O.LcAmt,0)						<>	ISNULL(T.LcAmt,0)
OR ISNULL(O.LcIssuingBankAlt_Key,0)			<>	ISNULL(T.LcIssuingBankAlt_Key,0)
OR ISNULL(O.ResetFrequency,0)				<>	ISNULL(T.ResetFrequency,0)
OR ISNULL(O.ResetDt,'1900-01-01')			<>	ISNULL(T.ResetDt,'1900-01-01')
OR ISNULL(O.Moratorium,0)					<>	ISNULL(T.Moratorium,0)
OR ISNULL(O.FirstInstallDtInt,'1900-01-01') <>	ISNULL(T.FirstInstallDtInt,'1900-01-01')
OR ISNULL(O.ContExcsSinceDt,'1900-01-01')   <>	ISNULL(T.ContExcsSinceDt,'1900-01-01')
OR ISNULL(O.loanPeriod,0)					<>	ISNULL(T.loanPeriod,0)
OR ISNULL(O.ClaimType,'AA')					<>	ISNULL(T.ClaimType,'AA')
OR ISNULL(O.ClaimCoverAmt,0)				<>	ISNULL(T.ClaimCoverAmt,0)
OR ISNULL(O.ClaimLodgedDt,'1900-01-01')		<>	ISNULL(T.ClaimLodgedDt,'1900-01-01')
OR ISNULL(O.ClaimLodgedAmt,0)				<>	ISNULL(T.ClaimLodgedAmt,0)
OR ISNULL(O.ClaimRecvDt,'1900-01-01')		<>	ISNULL(T.ClaimRecvDt,'1900-01-01')
OR ISNULL(O.ClaimReceivedAmt,0)				<>	ISNULL(T.ClaimReceivedAmt,0)
OR ISNULL(O.ClaimRate,0)					<>	ISNULL(T.ClaimRate,0)
OR ISNULL(O.InttRepaymentDt,'1900-01-01')	<>	ISNULL(T.InttRepaymentDt,'1900-01-01')
OR ISNULL(O.ScheDuleNo,0)					<>	ISNULL(T.ScheDuleNo,0)
OR ISNULL(O.NxtInstDay,0)					<>	ISNULL(T.NxtInstDay,0)
OR ISNULL(O.PrplOvduAftrMth,0)				<>	ISNULL(T.PrplOvduAftrMth,0)
OR ISNULL(O.PrplOvduAftrDay,0)				<>	ISNULL(T.PrplOvduAftrDay,0)
OR ISNULL(O.InttOvduAftrDay,0)				<>	ISNULL(T.InttOvduAftrDay,0)
OR ISNULL(O.InttOvduAftrMth,0)				<>	ISNULL(T.InttOvduAftrMth,0)
OR ISNULL(O.PrinOvduEndMth,'A')				<>	ISNULL(T.PrinOvduEndMth,'A')
 

) 



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacDLDetail A
INNER JOIN DBO.ADVFACDLDETAIL B 
ON B.AccountEntityId=A.AccountEntityId            --And A.SourceAlt_Key=B.SourceAlt_Key
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.ADVFACDLDETAIL AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacDLDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    --And AA.SourceAlt_Key=BB.SourceAlt_Key
    AND BB.EffectiveToTimeKey =49999
    )

	/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvFacDLDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacDLDetail] TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacDLDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
Where Temp.IsChanged in ('N','C')
------------------------------
------------------REMOVE DUPLICATE---------------------------------------
;With Remove_Duplicate As 
(
Select 
ROW_NUMBER() over (partition by AccountEntityId order by AccountEntityId) ACID ,
*
From IBL_ENPA_TEMPDB_V2.dbo.TempAdvFacDLDetail
)
Delete Remove_Duplicate where ACID >1
-----------------------------------------------------------------------------

INSERT INTO DBO.ADVFACDLDETAIL
     (	 [ENTITYKEY]
      ,[AccountEntityId]
      ,[Principal]
      ,[RepayModeAlt_Key]
      ,[NoOfInstall]
      ,[InstallAmt]
      ,[FstInstallDt]
      ,[LastInstallDt]
      ,[Tenure_Months]
      ,[MarginAmt]
      ,[CommodityAlt_Key]
      ,[RephaseAlt_Key]
      ,[RephaseDt]
      ,[IntServiced]
      ,[SuspendedInterest]
      ,[DerecognisedInterest1]
      ,[DerecognisedInterest2]
      ,[AdjReasonAlt_Key]
      ,[LcNo]
      ,[LcAmt]
      ,[LcIssuingBankAlt_Key]
      ,[ResetFrequency]
      ,[ResetDt]
      ,[Moratorium]
      ,[FirstInstallDtInt]
      ,[ContExcsSinceDt]
      ,[loanPeriod]
      ,[ClaimType]
      ,[ClaimCoverAmt]
      ,[ClaimLodgedDt]
      ,[ClaimLodgedAmt]
      ,[ClaimRecvDt]
      ,[ClaimReceivedAmt]
      ,[ClaimRate]
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
      ,[InstRepaymentDt]
      ,[ScrCrError]
      ,[InttRepaymentDt]
      ,[ScheDuleNo]
      ,[MocStatus]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[UnAppliedIntt]
      ,[NxtInstDay]
      ,[PrplOvduAftrMth]
      ,[PrplOvduAftrDay]
      ,[InttOvduAftrDay]
      ,[InttOvduAftrMth]
      ,[PrinOvduEndMth]
      ,[InttOvduEndMth]
      ,[ScrCrErrorSeq]
      ,[CoverExpiryDt]
		   )
SELECT
				
		     [ENTITYKEY]
      ,[AccountEntityId]
      ,[Principal]
      ,[RepayModeAlt_Key]
      ,[NoOfInstall]
      ,[InstallAmt]
      ,[FstInstallDt]
      ,[LastInstallDt]
      ,[Tenure_Months]
      ,[MarginAmt]
      ,[CommodityAlt_Key]
      ,[RephaseAlt_Key]
      ,[RephaseDt]
      ,[IntServiced]
      ,[SuspendedInterest]
      ,[DerecognisedInterest1]
      ,[DerecognisedInterest2]
      ,[AdjReasonAlt_Key]
      ,[LcNo]
      ,[LcAmt]
      ,[LcIssuingBankAlt_Key]
      ,[ResetFrequency]
      ,[ResetDt]
      ,[Moratorium]
      ,[FirstInstallDtInt]
      ,[ContExcsSinceDt]
      ,[loanPeriod]
      ,[ClaimType]
      ,[ClaimCoverAmt]
      ,[ClaimLodgedDt]
      ,[ClaimLodgedAmt]
      ,[ClaimRecvDt]
      ,[ClaimReceivedAmt]
      ,[ClaimRate]
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
      ,NULL AS D2Ktimestamp
      ,[InstRepaymentDt]
      ,[ScrCrError]
      ,[InttRepaymentDt]
      ,[ScheDuleNo]
      ,[MocStatus]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[UnAppliedIntt]
      ,[NxtInstDay]
      ,[PrplOvduAftrMth]
      ,[PrplOvduAftrDay]
      ,[InttOvduAftrDay]
      ,[InttOvduAftrMth]
      ,[PrinOvduEndMth]
      ,[InttOvduEndMth]
      ,[ScrCrErrorSeq]
      ,[CoverExpiryDt]
		   FROM IBL_ENPA_TEMPDB_V2.dbo.TempAdvFacDLDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')


END




GO