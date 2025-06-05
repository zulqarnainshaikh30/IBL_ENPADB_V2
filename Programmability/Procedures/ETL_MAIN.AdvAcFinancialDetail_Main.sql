SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvAcFinancialDetail_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	BEGIN TRY
	SET NOCOUNT ON;

    DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')



----------For New Records
UPDATE A SET A.IsChanged='N'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcFinancialDetail A
Where Not Exists(Select 1 from DBO.AdvAcFinancialDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId= A.AccountEntityId) 

--------------------------------------------------------------------------------
UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.AdvAcFinancialDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcFinancialDetail AS T
ON O.AccountEntityID=T.AccountEntityID
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
( 
 ISNULL(O.Ac_LastReviewDueDt,'1990-01-01')	<> ISNULL(T.Ac_LastReviewDueDt,'1990-01-01')
OR ISNULL(O.Ac_ReviewTypeAlt_key,0)				<> ISNULL(T.Ac_ReviewTypeAlt_key,0)
OR ISNULL(O.Ac_ReviewDt,'1990-01-01')			<> ISNULL(T.Ac_ReviewDt,'1990-01-01')
OR ISNULL(O.Ac_ReviewAuthAlt_Key,0)				<> ISNULL(T.Ac_ReviewAuthAlt_Key,0)
OR ISNULL(O.Ac_NextReviewDueDt,'1990-01-01')	<> ISNULL(T.Ac_NextReviewDueDt,'1990-01-01')
OR ISNULL(O.DrawingPower,0)						<> ISNULL(T.DrawingPower,0)
OR ISNULL(O.InttRate,0)							<> ISNULL(T.InttRate,0)
OR ISNULL(O.UnAdjSubSidy,0)						<> ISNULL(T.UnAdjSubSidy,0)
OR ISNULL(O.LastInttRealiseDt,'1990-01-01')		<> ISNULL(T.LastInttRealiseDt,'1990-01-01')
OR ISNULL(O.LimitDisbursed,0)					<> ISNULL(T.LimitDisbursed,0)
OR ISNULL(O.CropDuration,0)						<> ISNULL(T.CropDuration,0)
OR ISNULL(O.RefCustomerId,'AA')					<> ISNULL(T.RefCustomerId,'AA') 

  )
  






  ----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcFinancialDetail A
INNER JOIN DBO.AdvAcFinancialDetail B 
ON B.AccountEntityId=A.AccountEntityId            --And A.SourceAlt_Key=B.SourceAlt_Key
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvAcFinancialDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcFinancialDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    --And AA.SourceAlt_Key=BB.SourceAlt_Key
    AND BB.EffectiveToTimeKey =49999
    )

	
	-------------------------------

/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvAcFinancialDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvAcFinancialDetail] TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvAcFinancialDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
Where Temp.IsChanged in ('N','C')
------------------------------





INSERT INTO DBO.AdvAcFinancialDetail
(	ENTITYKEY
,AccountEntityId
,Ac_LastReviewDueDt
,Ac_ReviewTypeAlt_key
,Ac_ReviewDt
,Ac_ReviewAuthAlt_Key
,Ac_NextReviewDueDt
,DrawingPower
,InttRate
,NpaDt
,BookDebts
,UnDrawnAmt
,UnAdjSubSidy
,LastInttRealiseDt
,MocStatus
,MOCReason
,LimitDisbursed
,RefCustomerId
,RefSystemAcId
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,D2Ktimestamp
,MocDate
,MocTypeAlt_Key
,CropDuration
,Ac_ReviewAuthLevelAlt_Key
,AccountBlkCode2
	
         )
SELECT
	
	  ENTITYKEY
,AccountEntityId
,Ac_LastReviewDueDt
,Ac_ReviewTypeAlt_key
,Ac_ReviewDt
,Ac_ReviewAuthAlt_Key
,Ac_NextReviewDueDt
,DrawingPower
,InttRate
,NpaDt
,BookDebts
,UnDrawnAmt
,UnAdjSubSidy
,LastInttRealiseDt
,MocStatus
,MOCReason
,LimitDisbursed
,RefCustomerId
,RefSystemAcId
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,GETDATE() D2Ktimestamp
,MocDate
,MocTypeAlt_Key
,CropDuration
,Ac_ReviewAuthLevelAlt_Key
,NULL AccountBlkCode2

	FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcFinancialDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')

	END TRY
	BEGIN CATCH
	update BandauditStatus set BandStatus = 'Failed' where BandName = 'TempToMain'
	END CATCH
 
END

GO