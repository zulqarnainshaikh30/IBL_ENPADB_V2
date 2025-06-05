SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvAcFinancialOtherDetail_Main]
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
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcOtherFinancialDetail A
Where Not Exists(Select 1 from DBO.AdvAcOtherFinancialDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId= A.AccountEntityId) 

--------------------------------------------------------------------------------
UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.AdvAcOtherFinancialDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcOtherFinancialDetail AS T
ON O.AccountEntityID=T.AccountEntityID
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
( 

 ISNULL(O.Interest_due,0)						<> ISNULL(T.Interest_due,0)
OR ISNULL(O.other_dues,0)						<> ISNULL(T.other_dues,0)
OR ISNULL(O.penal_due,0)						<> ISNULL(T.penal_due,0)
OR ISNULL(O.int_receivable_adv,0)						<> ISNULL(T.int_receivable_adv,0)
OR ISNULL(O.penal_int_receivable,0)						<> ISNULL(T.penal_int_receivable,0)
OR ISNULL(O.Accrued_interest,0)						<> ISNULL(T.Accrued_interest,0)
OR ISNULL(O.Overdueinterest,0)						<> ISNULL(T.Overdueinterest,0)
OR ISNULL(O.PenalOverdueinterest,0)						<> ISNULL(T.PenalOverdueinterest,0)
OR ISNULL(O.UnAppliedIntAmount,0)						<> ISNULL(T.UnAppliedIntAmount,0)
OR ISNULL(O.PenalUnAppliedIntAmount,0)						<> ISNULL(T.PenalUnAppliedIntAmount,0)
OR ISNULL(O.PenalInterestOverDueSInceDt,'1900-01-01')				<> ISNULL(T.PenalInterestOverDueSInceDt,'1900-01-01')
  )
  






  ----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcOtherFinancialDetail A
INNER JOIN DBO.AdvAcOtherFinancialDetail B 
ON B.AccountEntityId=A.AccountEntityId            --And A.SourceAlt_Key=B.SourceAlt_Key
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvAcOtherFinancialDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcOtherFinancialDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    --And AA.SourceAlt_Key=BB.SourceAlt_Key
    AND BB.EffectiveToTimeKey =49999
    )

	
	-------------------------------

/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvAcOtherFinancialDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvAcOtherFinancialDetail] TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvAcOtherFinancialDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
Where Temp.IsChanged in ('N','C')
------------------------------





INSERT INTO DBO.AdvAcOtherFinancialDetail
(	AccountEntityId
,RefSystemAcId
,int_receivable_adv
,penal_int_receivable
,Accrued_interest
,penal_due
,Interest_due
,other_dues
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
,[D2Ktimestamp]
,Overdueinterest
,PenalOverdueinterest
,UnAppliedIntAmount
,PenalUnAppliedIntAmount
,PenalInterestOverDueSInceDt	
		

		  )
SELECT
	
	  AccountEntityId
,RefSystemAcId
,int_receivable_adv
,penal_int_receivable
,Accrued_interest
,penal_due
,Interest_due
,other_dues
,AuthorisationStatus
,EffectiveFromTimeKey
,EffectiveToTimeKey
,CreatedBy
,DateCreated
,ModifiedBy
,DateModified
,ApprovedBy
,DateApproved
, getdate() D2Ktimestamp
,Overdueinterest
,PenalOverdueinterest
,UnAppliedIntAmount
,PenalUnAppliedIntAmount
,PenalInterestOverDueSInceDt
	FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcOtherFinancialDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')
 
END



GO