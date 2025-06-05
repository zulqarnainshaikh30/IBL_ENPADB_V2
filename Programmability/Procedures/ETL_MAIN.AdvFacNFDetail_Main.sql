SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvFacNFDetail_Main]
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
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacNFDetail A
Where Not Exists(Select 1 from DBO.AdvFacNFDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId)


UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'
FROM DBO.AdvFacNFDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacNFDetail AS T
ON O.AccountEntityID=T.AccountEntityID
--AND O.SourceAlt_Key=T.SourceAlt_Key
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(
 ISNULL(O.GLAlt_key,0)							<>	ISNULL(T.GLAlt_key,0) 
OR ISNULL(O.Operative_Acid,0)					<>	ISNULL(T.Operative_Acid,0)				
OR ISNULL(O.LCBG_TYPE,0) 						<>	ISNULL(T.LCBG_TYPE,0) 					
OR ISNULL(O.LCBGNo,0)							<>	ISNULL(T.LCBGNo,0)					
OR ISNULL(O.LcBgAmt,0) 							<>	ISNULL(T.LcBgAmt,0) 					
OR ISNULL(O.OriginDt,'1900-01-01') 				<>	ISNULL(T.OriginDt,'1900-01-01') 		
OR ISNULL(O.EffectiveDt,'1900-01-01') 			<>	ISNULL(T.EffectiveDt,'1900-01-01') 	
OR ISNULL(O.ExpiryDt,'1900-01-01') 				<>	ISNULL(T.ExpiryDt,'1900-01-01') 		
OR ISNULL(O.ExtensionDt,'1900-01-01') 			<>	ISNULL(T.ExtensionDt,'1900-01-01') 	
OR ISNULL(O.TypeAlt_Key,0) 						<>	ISNULL(T.TypeAlt_Key,0) 				
OR ISNULL(O.NatureAlt_Key,0) 					<>	ISNULL(T.NatureAlt_Key,0) 			
OR ISNULL(O.BeneficiaryType,0) 					<>	ISNULL(T.BeneficiaryType,0) 			
OR ISNULL(O.BeneficiaryName,0) 					<>	ISNULL(T.BeneficiaryName,0) 			
OR ISNULL(O.Balance,0) 							<>	ISNULL(T.Balance,0) 					
OR ISNULL(O.BalanceInCurrency,0) 				<>	ISNULL(T.BalanceInCurrency,0) 		
OR ISNULL(O.CurrencyAlt_Key,0) 					<>	ISNULL(T.CurrencyAlt_Key,0) 			
OR ISNULL(O.CountryAlt_Key,0)					<>	ISNULL(T.CountryAlt_Key,0)				
OR ISNULL(O.NegotiatingBank,0)					<>	ISNULL(T.NegotiatingBank,0)				
OR ISNULL(O.MarginType,0)						<>	ISNULL(T.MarginType,0)					
OR ISNULL(O.MarginAmt,0)						<>	ISNULL(T.MarginAmt,0)					
OR ISNULL(O.PurposeAlt_Key,0)					<>	ISNULL(T.PurposeAlt_Key,0)				
OR ISNULL(O.ShipmentDt,'1900-01-01')			<>	ISNULL(T.ShipmentDt,'1900-01-01')		
OR ISNULL(O.CoveredByBank,0)					<>	ISNULL(T.CoveredByBank,0)				
OR ISNULL(O.CoveredByBankAlt_Key,0)				<>	ISNULL(T.CoveredByBankAlt_Key,0)			
OR ISNULL(O.InvocationDt,'1900-01-01')			<>	ISNULL(T.InvocationDt,'1900-01-01')		
OR ISNULL(O.Commission,0)						<>	ISNULL(T.Commission,0)					
OR ISNULL(O.BillReceived,0)						<>	ISNULL(T.BillReceived,0)					
OR ISNULL(O.BillsUnderCollAmt,0)				<>	ISNULL(T.BillsUnderCollAmt,0)			
OR ISNULL(O.FundedConversionDt,'1900-01-01')	<>	ISNULL(T.FundedConversionDt,'1900-01-01')
OR ISNULL(O.Datepaid,'1900-01-01')				<>	ISNULL(T.Datepaid,'1900-01-01')			
OR ISNULL(O.RecoveryDt,'1900-01-01')			<>	ISNULL(T.RecoveryDt,'1900-01-01')		
OR ISNULL(O.CounterGuar,0)						<>	ISNULL(T.CounterGuar,0)					
OR ISNULL(O.CorresBankCode,0)					<>	ISNULL(T.CorresBankCode,0)				
OR ISNULL(O.CorresBrCode,0)						<>	ISNULL(T.CorresBrCode,0)					
OR ISNULL(O.ClaimDt,'1900-01-01')				<>	ISNULL(T.ClaimDt,'1900-01-01')			
OR ISNULL(O.NFFacilityNo,0)						<>	ISNULL(T.NFFacilityNo,0)					
OR ISNULL(O.Periodicity,0)						<>	ISNULL(T.Periodicity,0)					
OR ISNULL(O.CommissionDue,0)					<>	ISNULL(T.CommissionDue,0)				
OR ISNULL(O.DueDateOfRecovery,'1900-01-01')		<>	ISNULL(T.DueDateOfRecovery,'1900-01-01')	
OR ISNULL(O.CommOnDuedateYN,0)					<>	ISNULL(T.CommOnDuedateYN,0)				
OR ISNULL(O.DelayReason,0)						<>	ISNULL(T.DelayReason,0)					
OR ISNULL(O.PresentPosition,0)					<>	ISNULL(T.PresentPosition,0)				
OR ISNULL(O.AmmountRecovered,0)					<>	ISNULL(T.AmmountRecovered,0)				
OR ISNULL(O.ScrCrError,0)						<>	ISNULL(T.ScrCrError,0)					
OR ISNULL(O.AdjDt,'1900-01-01')					<>	ISNULL(T.AdjDt,'1900-01-01')				
OR ISNULL(O.AdjReasonAlt_Key,0)					<>	ISNULL(T.AdjReasonAlt_Key,0)				
OR ISNULL(O.EntityClosureDate,'1900-01-01')		<>	ISNULL(T.EntityClosureDate,'1900-01-01')	
OR ISNULL(O.EntityClosureReasonAlt_Key,0)		<>	ISNULL(T.EntityClosureReasonAlt_Key,0)	
OR ISNULL(O.RefCustomerId,0)					<>	ISNULL(T.RefCustomerId,0)				
OR ISNULL(O.RefSystemAcId,0)					<>	ISNULL(T.RefSystemAcId,0)				
OR ISNULL(O.MocStatus,0)						<>	ISNULL(T.MocStatus,0)					
OR ISNULL(O.MocDate,'1900-01-01')				<>	ISNULL(T.MocDate,'1900-01-01')			
OR ISNULL(O.MocTypeAlt_Key,0)					<>	ISNULL(T.MocTypeAlt_Key,0)				
OR ISNULL(O.GovtGurantee,0)						<>	ISNULL(T.GovtGurantee,0)					
OR ISNULL(O.GovGurAmt,0)						<>	ISNULL(T.GovGurAmt,0)					
OR ISNULL(O.ScrCrErrorSeq,0)					<>	ISNULL(T.ScrCrErrorSeq,0)				
OR ISNULL(O.ApplicationDt,'1900-01-01')			<>	ISNULL(T.ApplicationDt,'1900-01-01')		
OR ISNULL(O.ClaimExpiryDt,'1900-01-01')			<>	ISNULL(T.ClaimExpiryDt,'1900-01-01')		
OR ISNULL(O.InvocationStatusAlt_Key,0)			<>	ISNULL(T.InvocationStatusAlt_Key,0)		
OR ISNULL(O.provision,0)						<>	ISNULL(T.provision,0)					
OR ISNULL(O.MarginAccNo,0)						<>	ISNULL(T.MarginAccNo,0)	
)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacNFDetail A
INNER JOIN DBO.AdvFacNFDetail B 
ON B.AccountEntityId=A.AccountEntityId            --And A.SourceAlt_Key=B.SourceAlt_Key
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvFacNFDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvFacNFDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    --And AA.SourceAlt_Key=BB.SourceAlt_Key
    AND BB.EffectiveToTimeKey =49999
    )

	/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvFacNFDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacNFDetail] TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvFacNFDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
Where Temp.IsChanged in ('N','C')
------------------------------

INSERT INTO DBO.AdvFacNFDetail
     ( 
	 AccountEntityId
,D2KFacilityID
,GLAlt_key
,Operative_Acid
,LCBG_TYPE
,LCBGNo
,LcBgAmt
,OriginDt
,EffectiveDt
,ExpiryDt
,ExtensionDt
,TypeAlt_Key
,NatureAlt_Key
,BeneficiaryType
,BeneficiaryName
,Balance
,BalanceInCurrency
,CurrencyAlt_Key
,CountryAlt_Key
,NegotiatingBank
,MarginType
,MarginAmt
,PurposeAlt_Key
,ShipmentDt
,CoveredByBank
,CoveredByBankAlt_Key
,InvocationDt
,Commission
,BillReceived
,BillsUnderCollAmt
,FundedConversionDt
,Datepaid
,RecoveryDt
,CounterGuar
,CorresBankCode
,CorresBrCode
,ClaimDt
,NFFacilityNo
,Periodicity
,CommissionDue
,DueDateOfRecovery
,CommOnDuedateYN
,DelayReason
,PresentPosition
,AmmountRecovered
,ScrCrError
,AdjDt
,AdjReasonAlt_Key
,EntityClosureDate
,EntityClosureReasonAlt_Key
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
,MocStatus
,MocDate
,MocTypeAlt_Key
,GovtGurantee
,GovGurAmt
,ScrCrErrorSeq
,ApplicationDt
,ClaimExpiryDt
,InvocationStatusAlt_Key
,provision
,MarginAccNo
		   )
SELECT
				
AccountEntityId
,D2KFacilityID
,GLAlt_key
,Operative_Acid
,LCBG_TYPE
,LCBGNo
,LcBgAmt
,OriginDt
,EffectiveDt
,ExpiryDt
,ExtensionDt
,TypeAlt_Key
,NatureAlt_Key
,BeneficiaryType
,BeneficiaryName
,Balance
,BalanceInCurrency
,CurrencyAlt_Key
,CountryAlt_Key
,NegotiatingBank
,MarginType
,MarginAmt
,PurposeAlt_Key
,ShipmentDt
,CoveredByBank
,CoveredByBankAlt_Key
,InvocationDt
,Commission
,BillReceived
,BillsUnderCollAmt
,FundedConversionDt
,Datepaid
,RecoveryDt
,CounterGuar
,CorresBankCode
,CorresBrCode
,ClaimDt
,NFFacilityNo
,Periodicity
,CommissionDue
,DueDateOfRecovery
,CommOnDuedateYN
,DelayReason
,PresentPosition
,AmmountRecovered
,ScrCrError
,AdjDt
,AdjReasonAlt_Key
,EntityClosureDate
,EntityClosureReasonAlt_Key
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
,MocStatus
,MocDate
,MocTypeAlt_Key
,GovtGurantee
,GovGurAmt
,ScrCrErrorSeq
,ApplicationDt
,ClaimExpiryDt
,InvocationStatusAlt_Key
,provision
,MarginAccNo
 FROM IBL_ENPA_TEMPDB_V2.dbo.TempAdvFacNFDetail T 
 Where ISNULL(T.IsChanged,'U') IN ('N','C') 
 


END


GO