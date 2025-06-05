SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 /*=============================================
 Author: Liyaqat
 Create date: 08/10/2021
 Description: Insert AdvCreditCardBalanceDetail
 EXEC [ETL_MAIN].[AdvCreditCardBalanceDetail_Main]
 =============================================*/

CREATE PROCEDURE [ETL_MAIN].[AdvCreditCardBalanceDetail_Main]
AS
BEGIN
	
	SET NOCOUNT ON;

    
	DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2..Automate_Advances WHERE EXT_FLG='Y')

----------For New Records
UPDATE A SET A.IsChanged='N'
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvCreditCardBalanceDetail A
Where Not Exists(Select 1 from IBL_ENPA_DB_V2.DBO.AdvCreditCardBalanceDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId And A.CreditCardEntityId=B.CreditCardEntityId)


UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM IBL_ENPA_DB_V2.DBO.AdvCreditCardBalanceDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvCreditCardBalanceDetail AS T
ON O.AccountEntityID=T.AccountEntityID
AND O.CreditCardEntityId=T.CreditCardEntityId
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999
				
WHERE 
(   
ISNULL(O.Balance_POS,0) <> ISNULL(T.Balance_POS,0)
OR ISNULL(O.Balance_LOAN,0)<> ISNULL(T.Balance_LOAN,0)
OR ISNULL(O.Balance_INT,0)<> ISNULL(T.Balance_INT,0)
OR ISNULL(O.Balance_GST,0)<> ISNULL(T.Balance_GST,0)
OR ISNULL(O.Balance_FEES,0) <> ISNULL(T.Balance_FEES,0)
)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvCreditCardBalanceDetail A
INNER JOIN IBL_ENPA_DB_V2.DBO.AdvCreditCardBalanceDetail B 
ON B.AccountEntityId=A.AccountEntityId    And A.CreditCardEntityId=B.CreditCardEntityId
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM IBL_ENPA_DB_V2.DBO.AdvCreditCardBalanceDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvCreditCardBalanceDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID   And AA.CreditCardEntityId=BB.CreditCardEntityId
    AND BB.EffectiveToTimeKey =49999
    )

----------------------

/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvCreditCardBalanceDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvCreditCardBalanceDetail] TEMP
INNER JOIN (SELECT AccountEntityID,CreditCardEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvCreditCardBalanceDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityID=ACCT.AccountEntityID and  TEMP.CreditCardEntityId=ACCT.CreditCardEntityId
Where Temp.IsChanged in ('N','C')


INSERT INTO DBO.AdvCreditCardBalanceDetail
     (	EntityKey
	,AccountEntityId
	,CreditCardEntityId
	,Balance_POS
	,Balance_LOAN
	,Balance_INT
	,Balance_GST
	,Balance_FEES
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
	,MocStatus
	,MocDate )

SELECT	
	 EntityKey
	,AccountEntityId
	,CreditCardEntityId
	,Balance_POS
	,Balance_LOAN
	,Balance_INT
	,Balance_GST
	,Balance_FEES
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
	,Getdate()D2Ktimestamp
	,MocStatus
	,MocDate

FROM IBL_ENPA_TEMPDB_V2.dbo.TempAdvCreditCardBalanceDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')


END
GO