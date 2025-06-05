SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*************************************
Created by: Liyaqat
Created on: 2022-02-21
EXEC [ETL_Main].[BuyoutDetails_Final]
************************************/
CREATE PROC [ETL_MAIN].[BuyoutDetails_Final] 
AS

BEGIN

SET NOCOUNT ON;



DECLARE  @vEffectivefrom  Int SET @vEffectiveFrom= (select Timekey from IBL_ENPA_DB_V2..Automate_Advances where EXT_FLG='Y')
DECLARE @VEFFECTIVETO INT=(@vEffectivefrom-1)
DECLARE @DATE AS DATE =(SELECT DATE FROM IBL_ENPA_DB_V2.dbo.SysDayMatrix WHERE TimeKey=@vEffectivefrom)

--------------------------------------------------------------------------------------------------------------------------------------------------- 
  
  --TRUNCATE TABLE IBL_ENPA_TEMPDB_V2.DBO.TempBuyoutDetails



 

----------For New Records
UPDATE A SET A.IsChanged='N'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempBuyoutDetails A
Where Not Exists(Select 1 from DBO.[BuyoutDetails_Final] B Where B.EffectiveToTimeKey=49999
And B.BuyOutEntityID=A.BuyOutEntityID )


UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'
----Select * 
FROM IBL_ENPA_DB_V2.DBO.[BuyoutDetails_Final] AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempBuyoutDetails AS T
ON O.BuyOutEntityID=T.BuyOutEntityID
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(  
 
ISNULL(O.PoolName,'')								<> ISNULL(T.PoolName,'')
OR ISNULL(O.Category,'')								<> ISNULL(T.Category,'') 
OR ISNULL(O.CustomerName,'')							<> ISNULL(T.CustomerName,'')
OR ISNULL(O.PAN,'')										<> ISNULL(T.PAN,'')
OR ISNULL(O.AadharNo,'')								<> ISNULL(T.AadharNo,'')
OR ISNULL(O.PrincipalOutstanding,0)						<> ISNULL(T.PrincipalOutstanding,0)	
OR ISNULL(O.InterestReceivable,0)						<> ISNULL(T.InterestReceivable,0)	
OR ISNULL(O.Charges,0)									<> ISNULL(T.Charges,0)
OR ISNULL(O.AccuredInterest,0)							<> ISNULL(T.AccuredInterest,0)
OR ISNULL(O.DPD,0)										<> ISNULL(T.DPD,0)
OR ISNULL(O.AssetClass,'')								<> ISNULL(T.AssetClass,'') 
OR ISNULL(O.SecuredAmt,0)								<> ISNULL(T.SecurityValue,0)
OR ISNULL(O.AccuredInterest,0)							<> ISNULL(T.AccuredInterest,0) 
--OR ISNULL(O.MainCustomer,'')							<> ISNULL(T.MainCustomer,'')
OR ISNULL(O.NPADate,'1990-01-01')						<> ISNULL(T.NPADate,'1990-01-01')
OR ISNULL(O.InterestOverdue,0)							<> ISNULL(T.InterestOverdue,0) 

)


----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempBuyoutDetails A
INNER JOIN DBO.BuyoutDetails_Final B 
ON B.BuyOutEntityID=A.BuyOutEntityID 
Where B.EffectiveToTimeKey= @vEffectiveto


---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.BuyoutDetails_Final AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempBuyoutDetails BB
    WHERE AA.BuyOutEntityID=BB.BuyOutEntityID 
    AND BB.EffectiveToTimeKey =49999
    )
 
 
	-------------------------------

/*  New Customers Ac Key ID Update  */
DECLARE @Entity_Key BIGINT=0 
SELECT @Entity_Key=MAX(Entity_Key) FROM  IBL_ENPA_DB_V2.[dbo].BuyoutDetails_Final 
IF @Entity_Key IS NULL  
BEGIN
SET @Entity_Key=0
END
 
UPDATE TEMP 
SET TEMP.Entity_Key=ACCT.Entity_Key
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempBuyoutDetails] TEMP
INNER JOIN (SELECT BuyoutPartyLoanNo,(@Entity_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) Entity_Key
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempBuyoutDetails]
			WHERE Entity_Key=0 OR Entity_Key IS NULL)ACCT ON TEMP.BuyoutPartyLoanNo=ACCT.BuyoutPartyLoanNo
Where Temp.IsChanged in ('N','C')



INSERT INTO IBL_ENPA_DB_V2.[dbo].[BuyoutDetails_Final]
		(
			 Entity_Key
			,SummaryID
			,SlNo
			,ReferenceNo
			,PoolName
			,Category
			,BuyoutPartyLoanNo
			,CustomerName
			,PAN
			,AadharNo
			,PrincipalOutstanding
			,InterestReceivable
			,Charges
			,AccuredInterest
			,DPD
			,AssetClass
			,AuthorisationStatus
			,Changes
			,Remark
			,EffectiveFromTimeKey
			,EffectiveToTimeKey
			,CreatedBy
			,DateCreated
			,ModifyBy
			,DateModified
			,ApprovedBy
			,DateApproved
			,SecurityValue
			,FinalNpaDt
			,FinalAssetClassAlt_Key
			,ProvisionAlt_Key
			,NetBalance
			,ApprRV
			,SecuredAmt
			,UnSecuredAmt
			,UsedRV
			,Provsecured
			,ProvUnsecured
			,TotalProvision
			,FLGDEG
			,FLGUPG
			,DegReason
			,UpgDate
			,PrevProvPercentage
			,FinalProvPercentage
			,MainCustomer
			,NPADate
			,InterestOverdue
			,DailyInterestAccrualAmount
			,InterestSuspendedAmount
			,SuspendedInterestAmount
			,BuyOutEntityID
			,ModifiedBy
			,CustomerACID
            ,AccountName
			,NPAReason
		)

	select	
		
		 Entity_Key
		,NULL AS SummaryID
		,SlNo
		,ReferenceNo
		,PoolName
		,Category
		,BuyoutPartyLoanNo
		,CustomerName
		,PAN
		,AadharNo
		,PrincipalOutstanding
		,InterestReceivable
		,Charges
		,AccuredInterest
		,DPD
		,AssetClass
		,AuthorisationStatus
		,Changes
		,Remark
		,EffectiveFromTimeKey
		,EffectiveToTimeKey
		,CreatedBy
		,DateCreated
		,ModifyBy
		,DateModified
		,ApprovedBy
		,DateApproved
		,SecurityValue
		,NULL AS FinalNpaDt
		,NULL AS FinalAssetClassAlt_Key
		,NULL AS ProvisionAlt_Key
		,NULL AS NetBalance
		,NULL AS ApprRV
		,NULL AS SecuredAmt
		,NULL AS UnSecuredAmt
		,NULL AS UsedRV
		,NULL AS Provsecured
		,NULL AS ProvUnsecured
		,NULL AS TotalProvision
		,NULL AS FLGDEG
		,NULL AS FLGUPG
		,NULL AS DegReason
		,NULL AS UpgDate
		,NULL AS PrevProvPercentage
		,NULL AS FinalProvPercentage
		,MainCustomer
		,NPADate
		,InterestOverdue
		,DailyInterestAccrualAmount
		,InterestSuspendedAmount
		,SuspendedInterestAmount
		,BuyOutEntityID
		,NULL AS ModifiedBy
		,NULL 
		,NULL
		,NULL
		from IBL_ENPA_TEMPDB_V2.[dbo].[TempBuyoutDetails] t
		Where ISNULL(T.IsChanged,'U') IN ('N','C')

End
GO