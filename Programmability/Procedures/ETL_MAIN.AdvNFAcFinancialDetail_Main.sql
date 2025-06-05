SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvNFAcFinancialDetail_Main]
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
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvNFAcFinancialDetail A
Where Not Exists(Select 1 from DBO.AdvNFAcFinancialDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId= A.AccountEntityId) 

--------------------------------------------------------------------------------
UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.AdvNFAcFinancialDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvNFAcFinancialDetail AS T
ON O.AccountEntityID=T.AccountEntityID
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
( 
	ISNULL(O.Ac_ReviewTypeAlt_key,0) <> ISNULL(T.Ac_ReviewTypeAlt_key,0) 
 OR ISNULL(O.Ac_ReviewAuthAlt_Key,0) <> ISNULL(T.Ac_ReviewAuthAlt_Key,0) 
 OR ISNULL(O.Ac_NextReviewDueDt,'1990-01-01')	<> ISNULL(T.Ac_NextReviewDueDt,'1990-01-01')
OR ISNULL(O.DrawingPower,0)						<> ISNULL(T.DrawingPower,0)
OR ISNULL(O.InttRate,0)							<> ISNULL(T.InttRate,0)
OR ISNULL(O.NPADt,'1990-01-01')	<> ISNULL(T.NPADt,'1990-01-01')
 OR ISNULL(O.Balance,0) <> ISNULL(T.Balance,0)
 OR ISNULL(O.BalanceInCurrency,0) <> ISNULL(T.BalanceInCurrency,0)
 OR ISNULL(O.SignBalance,0) <> ISNULL(T.SignBalance,0)
 OR ISNULL(O.OverDue,0) <> ISNULL(T.OverDue,0)
 OR ISNULL(O.UnDrawnAmt,0) <> ISNULL(T.UnDrawnAmt,0)
 OR ISNULL(O.ProvSecured,0) <> ISNULL(T.ProvSecured,0)
 OR ISNULL(O.ProvUnSecured,0) <> ISNULL(T.ProvUnSecured,0)
 OR ISNULL(O.AdditionalProv,0) <> ISNULL(T.AdditionalProv,0)
 OR ISNULL(O.TotalProv,0) <> ISNULL(T.TotalProv,0)
 OR ISNULL(O.SecTangAst,0) <> ISNULL(T.SecTangAst,0)
 OR ISNULL(O.CoverGovGur,0) <> ISNULL(T.CoverGovGur,0)
 OR ISNULL(O.Unsecured,0) <> ISNULL(T.Unsecured,0)
 OR ISNULL(O.MocDate,'1900-01-01') <> ISNULL(T.MocDate,'1900-01-01')
 OR ISNULL(O.MocStatus,0) <> ISNULL(T.MocStatus,0)
 OR ISNULL(O.MocTypeAlt_Key,0) <> ISNULL(T.MocTypeAlt_Key,0)
 OR ISNULL(O.Ac_ReviewAuthLevelAlt_Key,0) <> ISNULL(T.Ac_ReviewAuthLevelAlt_Key,0)
  )
  

  ----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvNFAcFinancialDetail A
INNER JOIN DBO.AdvNFAcFinancialDetail B 
ON B.AccountEntityId=A.AccountEntityId            --And A.SourceAlt_Key=B.SourceAlt_Key
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvNFAcFinancialDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvNFAcFinancialDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    --And AA.SourceAlt_Key=BB.SourceAlt_Key
    AND BB.EffectiveToTimeKey =49999
    )

	
	-------------------------------

/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvNFAcFinancialDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvNFAcFinancialDetail] TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvNFAcFinancialDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
Where Temp.IsChanged in ('N','C')
------------------------------





INSERT INTO DBO.AdvNFAcFinancialDetail
(	CustomerEntityId
,AccountEntityId
,Ac_ReviewTypeAlt_key
,Ac_ReviewAuthAlt_Key
,Ac_NextReviewDueDt
,DrawingPower
,InttRate
,NpaDt
,BalanceInCurrency
,Balance
,SignBalance
,OverDue
,UnDrawnAmt
,ProvSecured
,ProvUnSecured
,AdditionalProv
,TotalProv
,SecTangAst
,CoverGovGur
,Unsecured
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
--,D2Ktimestamp
,MocDate
,MocStatus
,MocTypeAlt_Key
,Ac_ReviewAuthLevelAlt_Key
	
         )
SELECT
	
CustomerEntityId
,AccountEntityId
,Ac_ReviewTypeAlt_key
,Ac_ReviewAuthAlt_Key
,Ac_NextReviewDueDt
,DrawingPower
,InttRate
,NpaDt
,BalanceInCurrency
,Balance
,SignBalance
,OverDue
,UnDrawnAmt
,ProvSecured
,ProvUnSecured
,AdditionalProv
,TotalProv
,SecTangAst
,CoverGovGur
,Unsecured
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
--,GETDATE() D2Ktimestamp
,MocDate
,MocStatus
,MocTypeAlt_Key
,Ac_ReviewAuthLevelAlt_Key
		
	FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvNFAcFinancialDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')
 
END



GO