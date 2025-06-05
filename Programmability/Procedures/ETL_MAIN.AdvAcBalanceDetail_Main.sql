SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvAcBalanceDetail_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')

----------For New Records
UPDATE A SET A.IsChanged='N'
from IBL_ENPA_TEMPDB_V2.DBO.TempAdVAcBalanceDetail A
Where Not Exists(Select 1 from DBO.AdvAcBalanceDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId) 



UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.AdvAcBalanceDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdVAcBalanceDetail AS T
ON O.AccountEntityID=T.AccountEntityID
AND T.EffectiveToTimeKey=49999
and O.EffectiveToTimeKey=49999

WHERE 
(  
   ISNULL(O.AssetClassAlt_Key,0)   <> ISNULL(T.AssetClassAlt_Key,0)
OR ISNULL(O.BalanceInCurrency,0)   <> ISNULL(T.BalanceInCurrency,0)
OR ISNULL(O.Balance,0)             <> ISNULL(T.Balance,0)
OR ISNULL(O.SignBalance,0)         <> ISNULL(T.SignBalance,0)
OR ISNULL(O.LastCrDt,'1990-01-01') <> ISNULL(T.LastCrDt,'1990-01-01')
OR ISNULL(O.PS_Balance,0)		   <> ISNULL(T.PS_Balance,0)
OR ISNULL(O.NPS_Balance,0)		   <> ISNULL(T.NPS_Balance,0)
OR ISNULL(O.OverDue,0)			   <> ISNULL(T.OverDue,0)
OR ISNULL(O.RefCustomerId,'AA')    <> ISNULL(T.RefCustomerId,'AA')
OR ISNULL(O.PS_NPS_FLAG,'AA')	   <> ISNULL(T.PS_NPS_FLAG,'AA')
OR ISNULL(O.PrincipalBalance,0)	   <> ISNULL(T.PrincipalBalance,0)
OR ISNULL(O.OverDueSinceDt,'1990-01-01') <> ISNULL(T.OverDueSinceDt,'1990-01-01')
OR ISNULL(O.UnAppliedIntAmount,0)	   <> ISNULL(T.UnAppliedIntAmount,0)
OR ISNULL(O.OverduePrincipal,0)	   <> ISNULL(T.OverduePrincipal,0)
OR ISNULL(O.Overdueinterest,0)	   <> ISNULL(T.Overdueinterest,0)
OR ISNULL(O.OverduePrincipalDt,'1990-01-01') <> ISNULL(T.OverduePrincipalDt,'1990-01-01')
OR ISNULL(O.OverdueIntDt,'1990-01-01') <> ISNULL(T.OverdueIntDt,'1990-01-01')
OR ISNULL(O.SourceAssetClass,'AA')	   <> ISNULL(T.SourceAssetClass,'AA')
OR ISNULL(O.SourceNpaDate,'1990-01-01') <> ISNULL(T.SourceNpaDate,'1990-01-01')


)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
from IBL_ENPA_TEMPDB_V2.DBO.TempAdVAcBalanceDetail A
INNER JOIN DBO.AdvAcBalanceDetail B 
ON B.AccountEntityId=A.AccountEntityId            
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvAcBalanceDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdVAcBalanceDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    
    AND BB.EffectiveToTimeKey =49999
    )

-------------------------------

/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvAcBalanceDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvAcBalanceDetail] TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvAcBalanceDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
Where Temp.IsChanged in ('N','C')
------------------------------

--------------REMOVE DUPLICATE----------------------
;With Remove_Duplicate As 
(
Select 
ROW_NUMBER() over (partition by AccountEntityId order by AccountEntityId) ACID ,
*
From IBL_ENPA_TEMPDB_V2.dbo.TempAdvAcBalanceDetail
)
Delete Remove_Duplicate where ACID >1
----------------------------------------------------

INSERT INTO DBO.AdvAcBalanceDetail
     (	EntityKey
			,AccountEntityId
			,AssetClassAlt_Key
			,BalanceInCurrency
			,Balance
			,SignBalance
			,LastCrDt
			,OverDue
			,TotalProv
			,RefCustomerId
			,RefSystemAcId
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,OverDueSinceDt
			,MocStatus
			,MocDate
			,MocTypeAlt_Key
			,Old_OverDueSinceDt
			,Old_OverDue
			,ORG_TotalProv
			,IntReverseAmt
			,UnAppliedIntAmount
			,PS_Balance
			,NPS_Balance
			,DateCreated
			,ModifiedBy
			,DateModified
			,ApprovedBy
			,DateApproved
			,CreatedBy
			,UpgradeDate
			,OverduePrincipal
			,NotionalInttAmt
			,PrincipalBalance
			,Overdueinterest
			,AdvanceRecovery
			,PS_NPS_FLAG
			,DFVAmt
			,InterestReceivable
			,OverduePrincipalDt
			,OverdueIntDt
			,OverOtherdue
			,OverdueOtherDt
			,SourceAssetClass
			,SourceNpaDate
			,DPD_Bank
		   )
SELECT
				
		    EntityKey
			,AccountEntityId
			,AssetClassAlt_Key
			,BalanceInCurrency
			,Balance
			,SignBalance
			,LastCrDt
			,OverDue
			,TotalProv
			,RefCustomerId
			,RefSystemAcId
			,AuthorisationStatus
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,OverDueSinceDt
			,MocStatus
			,MocDate
			,MocTypeAlt_Key
			,Old_OverDueSinceDt
			,Old_OverDue
			,ORG_TotalProv
			,IntReverseAmt
			,UnAppliedIntAmount
			,PS_Balance
			,NPS_Balance
			,DateCreated
			,ModifiedBy
			,DateModified
			,ApprovedBy
			,DateApproved
			,CreatedBy
			,UpgradeDate
			,OverduePrincipal
			,NotionalInttAmt
			,PrincipalBalance
			,Overdueinterest
			,AdvanceRecovery
			,PS_NPS_FLAG
			,DFVAmt
			,InterestReceivable
			,OverduePrincipalDt
			,OverdueIntDt
			,OverOtherdue
			,OverdueOtherDt
			,SourceAssetClass
			,SourceNpaDate,
			DPD_BANK
		   FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdVAcBalanceDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')


END



GO