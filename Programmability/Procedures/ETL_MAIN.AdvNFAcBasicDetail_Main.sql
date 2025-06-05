SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvNFAcBasicDetail_Main]
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
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvNFAcBasicDetail A
Where Not Exists(Select 1 from DBO.AdvNFAcBasicDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId )

UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'
FROM DBO.AdvNFAcBasicDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvNFAcBasicDetail AS T
ON O.AccountEntityID=T.AccountEntityID
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(  
   ISNULL(O.BranchCode,0) <> ISNULL(T.BranchCode,0)
--OR ISNULL(O.GLAlt_Key,0)<> ISNULL(T.GLAlt_Key,0)
OR ISNULL(O.ProductAlt_Key,0)<> ISNULL(T.ProductAlt_Key,0)
OR ISNULL(O.GLProductAlt_Key,0)<> ISNULL(T.GLProductAlt_Key,0)
OR ISNULL(O.FacilityType,0) <> ISNULL(T.FacilityType,0)
OR ISNULL(O.SubSectorAlt_Key,0)<> ISNULL(T.SubSectorAlt_Key,0)
OR ISNULL(O.ActivityAlt_Key,0)<> ISNULL(T.ActivityAlt_Key,0)
OR ISNULL(O.IndustryAlt_Key,0)<> ISNULL(T.IndustryAlt_Key,0)
--OR ISNULL(O.SchemeAlt_Key,0)<> ISNULL(T.SchemeAlt_Key,0)
OR ISNULL(O.DistrictAlt_Key,0)<> ISNULL(T.DistrictAlt_Key,0)
OR ISNULL(O.AreaAlt_Key,0)<> ISNULL(T.AreaAlt_Key,0)
--OR ISNULL(O.VillageAlt_Key,0)<> ISNULL(T.VillageAlt_Key,0)
OR ISNULL(O.StateAlt_Key,0)<> ISNULL(T.StateAlt_Key,0)
OR ISNULL(O.CurrencyAlt_Key,0)<> ISNULL(T.CurrencyAlt_Key,0)
OR ISNULL(O.OriginalSanctionAuthAlt_Key,0)<> ISNULL(T.OriginalSanctionAuthAlt_Key,0)
OR ISNULL(O.OriginalLimitRefNo,0) <> ISNULL(T.OriginalLimitRefNo,0)
OR ISNULL(O.OriginalLimit,0) <> ISNULL(T.OriginalLimit,0)
OR ISNULL(O.OriginalLimitDt,'1990-01-01') <> ISNULL(T.OriginalLimitDt,'1990-01-01')
OR ISNULL(O.DtofFirstDisb,'1990-01-01') <>  ISNULL(T.DtofFirstDisb,'1990-01-01')
OR ISNULL(O.AdjDt,'1990-01-01') <> ISNULL(T.AdjDt,'1990-01-01')
OR ISNULL(O.MarginType,0) <> ISNULL(T.MarginType,0)
OR ISNULL(O.CurrentLimitRefNo,0) <> ISNULL(T.CurrentLimitRefNo,0)
--OR ISNULL(O.AccountName,0) <> ISNULL(T.AccountName,0)
--OR ISNULL(O.LastDisbDt,'1990-01-01') <> ISNULL(T.LastDisbDt,'1990-01-01')
OR ISNULL(O.Ac_LADDt,'1990-01-01') <> ISNULL(T.Ac_LADDt,'1990-01-01')
OR ISNULL(O.Ac_DocumentDt,'1990-01-01') <> ISNULL(T.Ac_DocumentDt,'1990-01-01')
OR ISNULL(O.CurrentLimit,0) <> ISNULL(T.CurrentLimit,0)
--OR ISNULL(O.InttTypeAlt_Key,0)<> ISNULL(T.InttTypeAlt_Key,0)
OR ISNULL(O.CurrentLimitDt,'1990-01-01') <> ISNULL(T.CurrentLimitDt,'1990-01-01')
--OR ISNULL(O.Ac_DueDt,'1990-01-01') <> ISNULL(T.Ac_DueDt,'1990-01-01')
--OR ISNULL(O.DrawingPowerAlt_Key,0) <> ISNULL(T.DrawingPowerAlt_Key,0)
OR ISNULL(O.RefCustomerId,'AA') <> ISNULL(T.RefCustomerId,'AA')
--OR ISNULL(O.FincaleBasedIndustryAlt_key,0) <> ISNULL(T.FincaleBasedIndustryAlt_Key,0)
--OR ISNULL(O.ISLAD,0) <> ISNULL(T.ISLAD,0) 
--or ISNULL(O.ISLAD,0) <> ISNULL(T.ISLAD,0)
--OR ISNULL(O.segmentcode,0) <> ISNULL(T.segmentcode,0)
--OR ISNULL(O.ReferencePeriod,0) <> ISNULL(T.ReferencePeriod,0)
OR ISNULL(O.D2k_OLDAscromID,'AA') <> ISNULL(T.D2k_OLDAscromID,'AA')
OR ISNULL(O.segmentcode,0) <> ISNULL(T.segmentcode,0)

)





----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvNFAcBasicDetail A
INNER JOIN DBO.AdvNFAcBasicDetail B 
ON B.AccountEntityId=A.AccountEntityId --And A.SourceAlt_Key=B.SourceAlt_Key
Where B.EffectiveToTimeKey= @vEffectiveto


---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvNFAcBasicDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvNFAcBasicDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID --And AA.SourceAlt_Key=BB.SourceAlt_Key
    AND BB.EffectiveToTimeKey =49999
    )


	-------------------------------

/*  New Customers Ac Key ID Update  */
DECLARE @Ac_Key BIGINT=0 
SELECT @Ac_Key=MAX(Ac_Key) FROM  IBL_ENPA_DB_V2.[dbo].[AdvNFAcBasicDetail] 
IF @Ac_Key IS NULL  
BEGIN
SET @Ac_Key=0
END
 
UPDATE TEMP 
SET TEMP.Ac_Key=ACCT.Ac_Key
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvNFAcBasicDetail] TEMP
INNER JOIN (SELECT CustomerAcId,(@Ac_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) Ac_Key
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvNFAcBasicDetail]
			WHERE Ac_Key=0 OR Ac_Key IS NULL)ACCT ON TEMP.CustomerAcId=ACCT.CustomerAcId
Where Temp.IsChanged in ('N','C')



/***************************************************************************************************************/
/***************************************************************************************************************/


INSERT INTO DBO.AdvNFAcBasicDetail
(BranchCode
,CustomerEntityId
,AccountEntityId
,SystemACID
,CustomerACID
,D2KAcid
,ProductAlt_Key
,GLProductAlt_Key
,FacilityType
,SectorAlt_Key
,SubSectorAlt_Key
,ActivityAlt_Key
,IndustryAlt_Key
,DistrictAlt_Key
,AreaAlt_Key
,StateAlt_Key
,CurrencyAlt_Key
,OriginalSanctionAuthAlt_Key
,OriginalLimitRefNo
,OriginalLimit
,OriginalLimitDt
,DtofFirstDisb
,ScrCrError
,AdjDt
,AdjReasonAlt_Key
,VillageCode
,SplCatg1Alt_Key
,SplCatg2Alt_Key
,CreditRatingScore
,CreditRatingDt
,SanctionReferenceNo
,GuaranteeCoverAlt_Key
,JointAccount
,ProcessingFeeApplicable
,ProcessingFeeAmt
,ProcessingFeeRecoveryAmt
,LimitRefNo
,Ac_LADDt
,Ac_DocumentDt
,Ac_CreditRatingAlt_Key
,CurrentLimit
,CurrentLimitDt
,AccountOpenDate
,EmpCode
,CurrentLimitRefNo
,MarginType
,Margin
,RefCustomerID
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
,MocStatus
,MocDate
,MocTypeAlt_Key
,SplCatg3Alt_Key
,SplCatg4Alt_Key
,NonFundCategoryAlt_Key
,FacilitiesNo
,BankAlt_Key
,AcCategoryAlt_Key
,OriginalSanctionAuthLevelAlt_Key
,AcTypeAlt_Key
,ScrCrErrorSeq
,Old_Mapkey
,D2k_OLDAscromID
,BSRUNID
,CustomerId
,CustomerName
,segmentcode
,SourceAlt_Key
)
SELECT  
BranchCode
,CustomerEntityId
,AccountEntityId
,SystemACID
,CustomerACID
,D2KAcid
,ProductAlt_Key
,GLProductAlt_Key
,FacilityType
,SectorAlt_Key
,SubSectorAlt_Key
,ActivityAlt_Key
,IndustryAlt_Key
,DistrictAlt_Key
,AreaAlt_Key
,StateAlt_Key
,CurrencyAlt_Key
,OriginalSanctionAuthAlt_Key
,OriginalLimitRefNo
,OriginalLimit
,OriginalLimitDt
,DtofFirstDisb
,ScrCrError
,AdjDt
,AdjReasonAlt_Key
,VillageCode
,SplCatg1Alt_Key
,SplCatg2Alt_Key
,CreditRatingScore
,CreditRatingDt
,SanctionReferenceNo
,GuaranteeCoverAlt_Key
,JointAccount
,ProcessingFeeApplicable
,ProcessingFeeAmt
,ProcessingFeeRecoveryAmt
,LimitRefNo
,Ac_LADDt
,Ac_DocumentDt
,Ac_CreditRatingAlt_Key
,CurrentLimit
,CurrentLimitDt
,AccountOpenDate
,EmpCode
,CurrentLimitRefNo
,MarginType
,Margin
,RefCustomerID
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
,MocStatus
,MocDate
,MocTypeAlt_Key
,SplCatg3Alt_Key
,SplCatg4Alt_Key
,NonFundCategoryAlt_Key
,FacilitiesNo
,BankAlt_Key
,AcCategoryAlt_Key
,OriginalSanctionAuthLevelAlt_Key
,AcTypeAlt_Key
,ScrCrErrorSeq
,Old_Mapkey
,D2k_OLDAscromID
,BSRUNID
,CustomerId
,CustomerName
,segmentcode
,SourceAlt_Key
FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvNFAcBasicDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')




 END


GO