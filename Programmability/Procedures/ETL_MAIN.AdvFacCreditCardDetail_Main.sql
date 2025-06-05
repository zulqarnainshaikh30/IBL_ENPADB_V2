SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 /*=============================================
 Author: Liyaqat
 Create date: 08/10/2021
 Description: Insert AdvFacCreditCardDetail
 EXEC [ETL_MAIN].[AdvFacCreditCardDetail_Main]
 =============================================*/

CREATE PROCEDURE [ETL_MAIN].[AdvFacCreditCardDetail_Main]
AS
BEGIN
	
	SET NOCOUNT ON;

    
	DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2..Automate_Advances WHERE EXT_FLG='Y')

----------For New Records
UPDATE A SET A.IsChanged='N'
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacCreditCardDetail A
Where Not Exists(Select 1 from IBL_ENPA_DB_V2.DBO.AdvFacCreditCardDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId And A.CreditCardEntityId=B.CreditCardEntityId)


UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM IBL_ENPA_DB_V2.DBO.AdvFacCreditCardDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacCreditCardDetail AS T
ON O.AccountEntityID=T.AccountEntityID
AND O.CreditCardEntityId=T.CreditCardEntityId
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(   
ISNULL(O.Liability,0) <> ISNULL(T.Liability,0)
OR ISNULL(O.MinimumAmountDue,0)<> ISNULL(T.MinimumAmountDue,0)
OR ISNULL(O.Bucket,0)<> ISNULL(T.Bucket,0)
OR ISNULL(O.DPD,0)<> ISNULL(T.DPD,0)
OR ISNULL(O.CorporateUCIC_ID,0) <> ISNULL(T.CorporateUCIC_ID,0)
OR ISNULL(O.CorporateCustomerID,0) <> ISNULL(T.CorporateCustomerID,0)
)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacCreditCardDetail A
INNER JOIN IBL_ENPA_DB_V2.DBO.AdvFacCreditCardDetail B 
ON B.AccountEntityId=A.AccountEntityId    And A.CreditCardEntityId=B.CreditCardEntityId
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM IBL_ENPA_DB_V2.DBO.AdvFacCreditCardDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacCreditCardDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID   And AA.CreditCardEntityId=BB.CreditCardEntityId
    AND BB.EffectiveToTimeKey =49999
    )

----------------------

/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvFacCreditCardDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacCreditCardDetail] TEMP
INNER JOIN (SELECT AccountEntityID,CreditCardEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacCreditCardDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityID=ACCT.AccountEntityID and  TEMP.CreditCardEntityId=ACCT.CreditCardEntityId
Where Temp.IsChanged in ('N','C')


INSERT INTO DBO.AdvFacCreditCardDetail
     (	EntityKey
	,AccountEntityId
	,CreditCardEntityId
	,CorporateUCIC_ID
	,CorporateCustomerID
	,Liability
	,MinimumAmountDue
	,CD
	,Bucket
	,DPD
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
	,MocDate
	,AccountStatus
	,AccountBlkCode2
	,AccountBlkCode1
	,ChargeoffY_N
		   )
SELECT
				
	EntityKey
	,AccountEntityId
	,CreditCardEntityId
	,CorporateUCIC_ID
	,CorporateCustomerID
	,Liability
	,MinimumAmountDue
	,CD
	,Bucket
	,DPD
	,RefSystemAcId
	,AuthorisationStatus
	,EffectiveFromTimeKey EffectiveFromTimeKey
	,EffectiveToTimeKey  EffectiveToTimeKey
	,CreatedBy
	,DateCreated
	,NULL ModifiedBy
	,NULL DateModified
	,NULL ApprovedBy
	,NULL DateApproved
	,Getdate() D2Ktimestamp
	,NULL MocStatus
	,NULL MocDate
	,NULL AccountStatus
	,NULL AccountBlkCode2
	,NULL AccountBlkCode1
	,NULL ChargeoffY_N
FROM IBL_ENPA_TEMPDB_V2.dbo.TempAdvFacCreditCardDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')


END
GO