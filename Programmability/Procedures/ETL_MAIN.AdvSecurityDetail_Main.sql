SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvSecurityDetail_Main]
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
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvSecurityDetail A
Where Not Exists(Select 1 from DBO.AdvSecurityDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId And A.SecurityEntityID=B.SecurityEntityID)


UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'
FROM DBO.AdvSecurityDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvSecurityDetail AS T
ON O.AccountEntityID=T.AccountEntityID
AND O.SecurityEntityID=T.SecurityEntityID
AND O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(
   o.CustomerEntityId <> T.CustomerEntityId 
OR o.SecurityType <> T.SecurityType 
OR o.CollateralType <> T.CollateralType 
OR o.SecurityAlt_Key <> T.SecurityAlt_Key 
OR o.Security_RefNo <> T.Security_RefNo 
OR o.SecurityNature <> T.SecurityNature 
OR o.SecurityChargeTypeAlt_Key <> T.SecurityChargeTypeAlt_Key 
OR o.CurrencyAlt_Key <> T.CurrencyAlt_Key 
OR o.EntryType <> T.EntryType 
OR o.ScrCrError <> T.ScrCrError 
OR o.InwardNo <> T.InwardNo 
OR o.Limitnode_Flag <> T.Limitnode_Flag 
OR o.RefCustomerId <> T.RefCustomerId 
OR o.RefSystemAcId <> T.RefSystemAcId 
OR o.SecurityParticular <> T.SecurityParticular 
OR o.OwnerTypeAlt_Key <> T.OwnerTypeAlt_Key 
OR o.AssetOwnerName <> T.AssetOwnerName 
OR o.ValueAtSanctionTime <> T.ValueAtSanctionTime 
OR o.BranchLastInspecDate <> T.BranchLastInspecDate 
OR o.SatisfactionNo <> T.SatisfactionNo 
OR o.SatisfactionDate <> T.SatisfactionDate 
OR o.BankShare <> T.BankShare 
OR o.ActionTakenRemark <> T.ActionTakenRemark 
OR o.SecCharge <> T.SecCharge 


)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvSecurityDetail A
INNER JOIN DBO.AdvSecurityDetail B 
ON B.AccountEntityId=A.AccountEntityId And A.SecurityEntityID=B.SecurityEntityID --and b.collateralid= a.collateralid
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE			AA
SET				EffectiveToTimeKey = @vEffectiveto,
				DateModified=CONVERT(DATE,GETDATE(),103),
				ModifiedBy='SSISUSER' 
FROM			DBO.AdvSecurityDetail AA
WHERE			AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (	SELECT	1 
					FROM	IBL_ENPA_TEMPDB_V2.DBO.TempAdvSecurityDetail BB
					WHERE	AA.AccountEntityID=BB.AccountEntityID And AA.SecurityEntityID=BB.SecurityEntityID
					--and		aa.collateralid=bb.collateralid
					AND		BB.EffectiveToTimeKey =49999
				 )

		/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvSecurityDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvSecurityDetail] TEMP
INNER JOIN (SELECT AccountEntityId,	  collateralid,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvSecurityDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON ISNULL(TEMP.AccountEntityId,0)=ISNULL(ACCT.AccountEntityId,0)
				--and  TEMP.collateralid=ACCT.collateralid
Where Temp.IsChanged in ('N','C')
------------------------------


INSERT INTO DBO.AdvSecurityDetail
     (	ENTITYKEY
,AccountEntityId
,CustomerEntityId
,SecurityType
,CollateralType
,SecurityAlt_Key
,SecurityEntityID
,Security_RefNo
,SecurityNature
,SecurityChargeTypeAlt_Key
,CurrencyAlt_Key
,EntryType
,ScrCrError
,InwardNo
,Limitnode_Flag
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
,MocTypeAlt_Key
,MocStatus
,MocDate
,SecurityParticular
,OwnerTypeAlt_Key
,AssetOwnerName
,ValueAtSanctionTime
,BranchLastInspecDate
,SatisfactionNo
,SatisfactionDate
,BankShare
,ActionTakenRemark
,SecCharge
,CollateralID
,UCICID
,CustomerName
,TaggingAlt_Key
,DistributionAlt_Key
,CollateralCode
,CollateralSubTypeAlt_Key
,CollateralOwnerShipTypeAlt_Key
,ChargeNatureAlt_Key
,ShareAvailabletoBankAlt_Key
,CollateralShareamount
,IfPercentagevalue_or_Absolutevalue
,CollateralValueatSanctioninRs
,CollateralValueasonNPAdateinRs
,ApprovedByFirstLevel
,DateApprovedFirstLevel
,ChangeField
,AccountID
,ChargeType
,ChargeNature
,RefCustomerId

		   )
SELECT
ENTITYKEY
,AccountEntityId
,CustomerEntityId
,SecurityType
,CollateralType
,SecurityAlt_Key
,SecurityEntityID
,Security_RefNo
,SecurityNature
,SecurityChargeTypeAlt_Key
,CurrencyAlt_Key
,EntryType
,ScrCrError
,InwardNo
,Limitnode_Flag
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
,MocTypeAlt_Key
,MocStatus
,MocDate
,SecurityParticular
,OwnerTypeAlt_Key
,AssetOwnerName
,ValueAtSanctionTime
,BranchLastInspecDate
,SatisfactionNo
,SatisfactionDate
,BankShare
,ActionTakenRemark
,SecCharge
,CollateralID
,NULL UCICID
,NULL CustomerName
,NULL TaggingAlt_Key
,NULL DistributionAlt_Key
,NULL CollateralCode
,NULL CollateralSubTypeAlt_Key
,NULL CollateralOwnerShipTypeAlt_Key
,NULL ChargeNatureAlt_Key
,NULL ShareAvailabletoBankAlt_Key
,NULL CollateralShareamount
,NULL IfPercentagevalue_or_Absolutevalue
,NULL CollateralValueatSanctioninRs
,NULL CollateralValueasonNPAdateinRs
,NULL ApprovedByFirstLevel
,NULL DateApprovedFirstLevel
,NULL ChangeField
,NULL AccountID
,NULL ChargeType
,NULL ChargeNature
,RefCustomerId
FROM IBL_ENPA_TEMPDB_V2.dbo.TempAdvSecurityDetail T 
Where ISNULL(T.IsChanged,'U') IN ('N','C')


END


GO