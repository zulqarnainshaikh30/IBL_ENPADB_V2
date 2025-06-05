SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[ExceptionFinalStatusType_Main]
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
from IBL_ENPA_TEMPDB_V2.DBO.TempExceptionFinalStatusType A
Where Not Exists(Select 1 from DBO.ExceptionFinalStatusType B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId AND A.StatusType=B.StatusType) 

--------------------------------------------------------------------------------
UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifyBy='SSISUSER'

FROM DBO.ExceptionFinalStatusType AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempExceptionFinalStatusType AS T
ON O.AccountEntityID=T.AccountEntityID
AND O.StatusType=T.StatusType
and O.EffectiveToTimeKey=49999
--AND T.EffectiveToTimeKey=49999

WHERE 
( 

	 ISNULL(O.Amount,0)						<> ISNULL(T.Amount,0)
	 OR ISNULL(O.StatusDate,'1900-01-01')	<> ISNULL(T.StatusDate,'1900-01-01')
  )
  

  
  ----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempExceptionFinalStatusType A
INNER JOIN DBO.ExceptionFinalStatusType B 
ON B.AccountEntityId=A.AccountEntityId            --And A.SourceAlt_Key=B.SourceAlt_Key
AND A.StatusType=B.StatusType
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifyBy='SSISUSER' 
FROM DBO.ExceptionFinalStatusType AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempExceptionFinalStatusType BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    --And AA.SourceAlt_Key=BB.SourceAlt_Key
		AND AA.StatusType=BB.StatusType
	AND BB.EffectiveToTimeKey =49999
    )

	
	-------------------------------



INSERT INTO DBO.ExceptionFinalStatusType
	(	
		SourceAlt_Key
		,CustomerID
		,ACID
		,StatusType
		,StatusDate
		,Amount
		,AuthorisationStatus
		,EffectiveFromTimeKey
		,EffectiveToTimeKey
		,CreatedBy
		,DateCreated
		,ModifyBy
		,DateModified
		,ApprovedBy
		,DateApproved
		,IS_ETL
		,AccountEntityId
	)
SELECT
		SourceAlt_Key
		,CustomerID
		,ACID
		,StatusType
		,StatusDate
		,Amount
		,AuthorisationStatus
		,EffectiveFromTimeKey
		,EffectiveToTimeKey
		,'D2K-ETL' CreatedBy
		,GETDATE()DateCreated
		,NULL ModifyBy
		,NULL DateModified
		,NULL ApprovedBy
		,NULL DateApproved
		,IS_ETL
		,AccountEntityId
--SELECT COUNT(1)
	FROM IBL_ENPA_TEMPDB_V2.DBO.TempExceptionFinalStatusType T Where ISNULL(T.IsChanged,'U') IN ('N','C')
 
END

--;WITH CTE_A
--AS
--(
--SELECT   AccountEntityId,EffectiveFromTimeKey,ROW_NUMBER() OVER(PARTITION BY AccountEntityId,EffectiveFromTimeKey ORDER BY AccountEntityId,EffectiveFromTimeKey)RID
--FROM DBO.AdvAcOtherFinancialDetail WHERE EffectiveToTimeKey=49999
----GROUP BY AccountEntityId,EffectiveFromTimeKey HAVING COUNT(1)>1
--)
--SELECT * FROM CTE_A WHERE RID>1


--;WITH CTE_A
--AS
--(
--SELECT   AccountEntityId,ROW_NUMBER() OVER(PARTITION BY AccountEntityId ORDER BY AccountEntityId,EffectiveFromTimeKey)RID
--FROM DBO.AdvAcOtherFinancialDetail WHERE EffectiveToTimeKey=49999
----GROUP BY AccountEntityId,EffectiveFromTimeKey HAVING COUNT(1)>1
--)
--SELECT *  
--FROM CTE_A WHERE RID>1


--SELECT   
--FROM DBO.AdvAcOtherFinancialDetail
GO