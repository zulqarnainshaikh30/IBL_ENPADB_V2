SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvCustOtherDetail_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')



----------For New Records
UPDATE A SET A.IsChanged='N'
FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustOtherDetail A
Where Not Exists(Select 1 from DBO.AdvCustOtherDetail B Where B.EffectiveToTimeKey=49999
And B.CustomerEntityId= A.CustomerEntityId) 

--------------------------------------------------------------------------------
UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'
FROM DBO.AdvCustOtherDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustOtherDetail AS T
ON O.CustomerEntityId=T.CustomerEntityId
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
( 
 O.OrgCostOfEquip <> T.OrgCostOfEquip 
OR O.OrgCostOfPlantMech <> T.OrgCostOfPlantMech 
OR O.DepValPlant <> T.DepValPlant 
OR O.ValLand <> T.ValLand 
OR O.IECDno <> T.IECDno 
OR O.GroupAlt_Key <> T.GroupAlt_Key 
OR O.CustomerSwiftCode <> T.CustomerSwiftCode 
OR O.SplCatg1Alt_Key <> T.SplCatg1Alt_Key 
OR O.SplCatg2Alt_Key <> T.SplCatg2Alt_Key 
OR O.SplCatg3Alt_Key <> T.SplCatg3Alt_Key 
OR O.SplCatg4Alt_Key <> T.SplCatg4Alt_Key 
OR O.CmaEligible <> T.CmaEligible 
OR O.PFNo <> T.PFNo 
OR O.SupperAnnuationBenefit <> T.SupperAnnuationBenefit 
OR O.SupperannuationBenefitValuationDt <> T.SupperannuationBenefitValuationDt 
OR O.BusinessCommenceDt <> T.BusinessCommenceDt 
OR O.CancelObtained <> T.CancelObtained 
OR O.TotConsortiumLimitFunded <> T.TotConsortiumLimitFunded 
OR O.TotConsortiumLimitNonFunded <> T.TotConsortiumLimitNonFunded 
OR O.UpgradationDate <> T.UpgradationDate 
OR O.CustomerExpiredYN <> T.CustomerExpiredYN 
OR O.TotWCLimitFunded <> T.TotWCLimitFunded 
OR O.Flagged_SubSector <> T.Flagged_SubSector 
OR O.RefCustomerId <> T.RefCustomerId 
OR O.MocStatus <> T.MocStatus 
OR O.MocDate <> T.MocDate 
OR O.MocTypeAlt_Key <> T.MocTypeAlt_Key 
OR O.AnnualExportTurnover <> T.AnnualExportTurnover 
OR O.FMCNumber <> T.FMCNumber 
OR O.IsEmployee <> T.IsEmployee 
OR O.IsPetitioner <> T.IsPetitioner 
OR O.UnderLitigation <> T.UnderLitigation 
OR O.PermiNatureID <> T.PermiNatureID 
OR O.BorrUnitFunct <> T.BorrUnitFunct 
OR O.DtofClosure <> T.DtofClosure 
OR O.NonCoopBorrower <> T.NonCoopBorrower 
OR O.ArbiAgreement <> T.ArbiAgreement 
OR O.TransThroughUs <> T.TransThroughUs 
OR O.CutBackArrangement <> T.CutBackArrangement 
OR O.BankingArrangement <> T.BankingArrangement 
OR O.MemberBanksNo <> T.MemberBanksNo 
OR O.TotalConsortiumAmt <> T.TotalConsortiumAmt 
OR O.ROC_CFCReportDate <> T.ROC_CFCReportDate 
OR O.ROC_ChargeFV <> T.ROC_ChargeFV 
OR O.ROC_ChargeFVDt <> T.ROC_ChargeFVDt 
OR O.ROC_ChargeRemark <> T.ROC_ChargeRemark 
OR O.ROC_Securities <> T.ROC_Securities 
OR O.ROC_Cover <> T.ROC_Cover 
OR O.ROC_CoveredDt <> T.ROC_CoveredDt 
OR O.ChargeFiledWith <> T.ChargeFiledWith 
OR O.FiledDt <> T.FiledDt 
OR O.EmployeeID <> T.EmployeeID 
OR O.EmployeeType <> T.EmployeeType 
OR O.Designation <> T.Designation 
OR O.Placeofposting <> T.Placeofposting 
OR O.LPersonalConDate <> T.LPersonalConDate 
OR O.LPersonalConDtls <> T.LPersonalConDtls 
OR O.RecallNoticeDate <> T.RecallNoticeDate 
OR O.RecallNoticeModeID <> T.RecallNoticeModeID 
OR O.LegalAuditDate <> T.LegalAuditDate 
OR O.IrregularityPending <> T.IrregularityPending 
OR O.IrregularityRectiDate <> T.IrregularityRectiDate 
OR O.FraudAccoStatus <> T.FraudAccoStatus 
OR O.PreSARFAESINoticeDt <> T.PreSARFAESINoticeDt 
OR O.FMRNO <> T.FMRNO 
OR O.FMRDate <> T.FMRDate 
OR O.GradeScaleAlt_Key <> T.GradeScaleAlt_Key 
OR O.FraudNatureRemark <> T.FraudNatureRemark 
OR O.ROCCoveredCertificateRemark <> T.ROCCoveredCertificateRemark 
OR O.ReasonsNonCoOperativeBorrower <> T.ReasonsNonCoOperativeBorrower 
OR O.StatusNonCoOperativeBorrower <> T.StatusNonCoOperativeBorrower

)


UPDATE A SET A.IsChanged='C'
FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustOtherDetail A
INNER JOIN DBO.AdvCustOtherDetail B 
ON B.CustomerEntityId=A.CustomerEntityId            
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
EffectiveToTimeKey = @vEffectiveto,
DateModified=CONVERT(DATE,GETDATE(),103),
ModifiedBy='SSISUSER' 
FROM DBO.AdvCustOtherDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustOtherDetail BB
    WHERE AA.CustomerEntityId=BB.CustomerEntityId    
    AND BB.EffectiveToTimeKey =49999
    )


	DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvCustOtherDetail] 
IF @EntityKey IS NULL  
BEGIN
	SET @EntityKey=0
END

UPDATE TEMP 
SET TEMP.EntityKey=ACCT.Customer_Key
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvCustOtherDetail] TEMP
INNER JOIN (SELECT CUSTOMERENTITYID,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) Customer_Key
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvCustOtherDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON  Temp.CustomerEntityId=ACCT.CustomerEntityId
Where Temp.IsChanged in ('N','C')

INSERT INTO DBO.AdvCustOtherDetail
(	   [EntityKey]
      ,[CustomerEntityId]
      ,[OrgCostOfEquip]
      ,[OrgCostOfPlantMech]
      ,[DepValPlant]
      ,[ValLand]
      ,[IECDno]
      ,[GroupAlt_Key]
      ,[CustomerSwiftCode]
      ,[SplCatg1Alt_Key]
      ,[SplCatg2Alt_Key]
      ,[SplCatg3Alt_Key]
      ,[SplCatg4Alt_Key]
      ,[CmaEligible]
      ,[PFNo]
      ,[SupperAnnuationBenefit]
      ,[SupperannuationBenefitValuationDt]
      ,[BusinessCommenceDt]
      ,[CancelObtained]
      ,[TotConsortiumLimitFunded]
      ,[TotConsortiumLimitNonFunded]
      ,[UpgradationDate]
      ,[CustomerExpiredYN]
      ,[TotWCLimitFunded]
      ,[Flagged_SubSector]
      ,[RefCustomerId]
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
      ,[AnnualExportTurnover]
      ,[FMCNumber]
      ,[IsEmployee]
      ,[IsPetitioner]
      ,[UnderLitigation]
      ,[PermiNatureID]
      ,[BorrUnitFunct]
      ,[DtofClosure]
      ,[NonCoopBorrower]
      ,[ArbiAgreement]
      ,[TransThroughUs]
      ,[CutBackArrangement]
      ,[BankingArrangement]
      ,[MemberBanksNo]
      ,[TotalConsortiumAmt]
      ,[ROC_CFCReportDate]
      ,[ROC_ChargeFV]
      ,[ROC_ChargeFVDt]
      ,[ROC_ChargeRemark]
      ,[ROC_Securities]
      ,[ROC_Cover]
      ,[ROC_CoveredDt]
      ,[ChargeFiledWith]
      ,[FiledDt]
      ,[EmployeeID]
      ,[EmployeeType]
      ,[Designation]
      ,[Placeofposting]
      ,[LPersonalConDate]
      ,[LPersonalConDtls]
      ,[RecallNoticeDate]
      ,[RecallNoticeModeID]
      ,[LegalAuditDate]
      ,[IrregularityPending]
      ,[IrregularityRectiDate]
      ,[FraudAccoStatus]
      ,[PreSARFAESINoticeDt]
      ,[FMRNO]
      ,[FMRDate]
      ,[GradeScaleAlt_Key]
      ,[FraudNatureRemark]
      ,[ROCCoveredCertificateRemark]
      ,[ReasonsNonCoOperativeBorrower]
      ,[StatusNonCoOperativeBorrower]
           )
SELECT
	
	  EntityKey
      ,CustomerEntityId
      ,OrgCostOfEquip
      ,OrgCostOfPlantMech
      ,DepValPlant
      ,ValLand
      ,IECDno
      ,GroupAlt_Key
      ,CustomerSwiftCode
      ,SplCatg1Alt_Key
      ,SplCatg2Alt_Key
      ,SplCatg3Alt_Key
      ,SplCatg4Alt_Key
      ,CmaEligible
      ,PFNo
      ,SupperAnnuationBenefit
      ,SupperannuationBenefitValuationDt
      ,BusinessCommenceDt
      ,CancelObtained
      ,TotConsortiumLimitFunded
      ,TotConsortiumLimitNonFunded
      ,UpgradationDate
      ,CustomerExpiredYN
      ,TotWCLimitFunded
      ,Flagged_SubSector
      ,RefCustomerId
      ,AuthorisationStatus
      ,EffectiveFromTimeKey
      ,EffectiveToTimeKey
      ,CreatedBy
      ,DateCreated
      ,ModifiedBy
      ,DateModified
      ,ApprovedBy
      ,DateApproved
      ,null as D2Ktimestamp --
      ,MocStatus
      ,MocDate
      ,MocTypeAlt_Key
      ,AnnualExportTurnover
      ,FMCNumber
      ,IsEmployee
      ,IsPetitioner
      ,UnderLitigation
      ,PermiNatureID
      ,BorrUnitFunct
      ,DtofClosure
      ,NonCoopBorrower
      ,ArbiAgreement
      ,TransThroughUs
      ,CutBackArrangement
      ,BankingArrangement
      ,MemberBanksNo
      ,TotalConsortiumAmt
      ,ROC_CFCReportDate
      ,ROC_ChargeFV
      ,ROC_ChargeFVDt
      ,ROC_ChargeRemark
      ,ROC_Securities
      ,ROC_Cover
      ,ROC_CoveredDt
      ,ChargeFiledWith
      ,FiledDt
      ,EmployeeID
      ,EmployeeType
      ,Designation
      ,Placeofposting
      ,LPersonalConDate
      ,LPersonalConDtls
      ,RecallNoticeDate
      ,RecallNoticeModeID
      ,LegalAuditDate
      ,IrregularityPending
      ,IrregularityRectiDate
      ,FraudAccoStatus
      ,PreSARFAESINoticeDt
      ,FMRNO
      ,FMRDate
      ,GradeScaleAlt_Key
      ,FraudNatureRemark
      ,ROCCoveredCertificateRemark
      ,ReasonsNonCoOperativeBorrower
      ,StatusNonCoOperativeBorrower
  FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustOtherDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')

 END


GO