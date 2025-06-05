SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvFacCCDetail_Main]
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
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacCCDetail A
Where Not Exists(Select 1 from DBO.ADVFACCCDETAIL B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId) -- And A.SourceAlt_Key=B.SourceAlt_Key)



UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.ADVFACCCDETAIL AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacCCDetail AS T
ON O.AccountEntityID=T.AccountEntityID
--AND O.SourceAlt_Key=T.SourceAlt_Key
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(
   ISNULL(O.AdhocDt,'1900-01-01')<>ISNULL(T.AdhocDt,'1900-01-01')
OR ISNULL(O.AdhocAmt,0)<>ISNULL(T.AdhocAmt,0)
OR ISNULL(O.ContExcsSinceDt,'1900-01-01')<>ISNULL(T.ContExcsSinceDt,'1900-01-01')
--OR ISNULL(O.MarginAmt,0)<>ISNULL(T.MarginAmt,0)
OR ISNULL(O.DerecognisedInterest1,0)<>ISNULL(T.DerecognisedInterest1,0)
OR ISNULL(O.DerecognisedInterest2,0)<>ISNULL(T.DerecognisedInterest2,0)
--OR ISNULL(O.AdjReasonAlt_Key,0)<>ISNULL(T.AdjReasonAlt_Key,0)
--OR ISNULL(O.EntityClosureDate,'1900-01-01')<>ISNULL(T.EntityClosureDate,'1900-01-01')
--OR ISNULL(O.EntityClosureReasonAlt_Key,0)<>ISNULL(T.EntityClosureReasonAlt_Key,0)
OR ISNULL(O.ClaimType,'AA')<>ISNULL(T.ClaimType,'AA')
OR ISNULL(O.ClaimCoverAmt,0)<>ISNULL(T.ClaimCoverAmt,0)
OR ISNULL(O.ClaimLodgedDt,'1900-01-01')<>ISNULL(T.ClaimLodgedDt,'1900-01-01')
OR ISNULL(O.ClaimLodgedAmt,0)<>ISNULL(T.ClaimLodgedAmt,0)
OR ISNULL(O.ClaimRecvDt,'1900-01-01')<>ISNULL(T.ClaimRecvDt,'1900-01-01')
OR ISNULL(O.ClaimReceivedAmt,0)<>ISNULL(T.ClaimReceivedAmt,0)
OR ISNULL(O.ClaimRate,0)<>ISNULL(T.ClaimRate,0)
OR ISNULL(O.RefSystemAcid,0)<>ISNULL(T.RefSystemAcid,0)
)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacCCDetail A
INNER JOIN DBO.ADVFACCCDETAIL B 
ON B.AccountEntityId=A.AccountEntityId            --And A.SourceAlt_Key=B.SourceAlt_Key
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.ADVFACCCDETAIL AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacCCDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    --And AA.SourceAlt_Key=BB.SourceAlt_Key
    AND BB.EffectiveToTimeKey =49999
    )

	/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvFacCCDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacCCDetail] TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacCCDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
Where Temp.IsChanged in ('N','C')
------------------------------

INSERT INTO DBO.ADVFACCCDETAIL
     (	[ENTITYKEY]
      ,[AccountEntityId]
      ,[AdhocDt]
      ,[AdhocAmt]
      ,[ContExcsSinceDt]
      ,[DerecognisedInterest1]
      ,[DerecognisedInterest2]
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
      ,[MocStatus]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[AdhocExpiryDate]

	  ,StockStmtDt
		   )
SELECT
				
		    [ENTITYKEY]
      ,[AccountEntityId]
      ,[AdhocDt]
      ,[AdhocAmt]
      ,[ContExcsSinceDt]
      ,[DerecognisedInterest1]
      ,[DerecognisedInterest2]
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
      ,getdate() [D2Ktimestamp]
      ,[MocStatus]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[AdhocExpiryDate]
	  
	  ,StockStmtDt
		   FROM IBL_ENPA_TEMPDB_V2.dbo.TempAdvFacCCDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')  
END


GO