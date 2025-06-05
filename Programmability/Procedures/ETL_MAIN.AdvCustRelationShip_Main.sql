SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvCustRelationShip_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @VEFFECTIVETO INT
	SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')


    
 ----------For New Records
UPDATE A SET A.IsChanged='N'
FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustRelationship A
Where Not Exists(Select 1 from DBO.AdvCustRelationship B Where B.EffectiveToTimeKey=49999
And B.CustomerEntityId=A.CustomerEntityId AND B.RelationEntityId=A.RelationEntityId)

UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'
FROM DBO.AdvCustRelationship AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustRelationship AS T
ON O.CustomerEntityId=T.CustomerEntityId
AND O.RelationEntityId=T.RelationEntityId
AND O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(
   O.[CustomerEntityId]						<>	T.[CustomerEntityId]
OR O.[RelationEntityId]						<>	T.[RelationEntityId]
OR O.[SalutationAlt_Key]					<>	T.[SalutationAlt_Key]
OR O.[Name]									<>	T.[Name]
OR O.[ConstitutionAlt_Key]					<>	T.[ConstitutionAlt_Key]
OR O.[OccupationAlt_Key]					<>	T.[OccupationAlt_Key]
OR O.[ReligionAlt_Key]						<>	T.[ReligionAlt_Key]
OR O.[CasteAlt_Key]							<>	T.[CasteAlt_Key]
OR O.[FarmerCatAlt_Key]						<>	T.[FarmerCatAlt_Key]
OR O.[MaritalStatusAlt_Key]					<>	T.[MaritalStatusAlt_Key]
OR O.[NetWorth]								<>	T.[NetWorth]
OR O.[DateofBirth]							<>	T.[DateofBirth]
OR O.[Qualification1Alt_Key]				<>	T.[Qualification1Alt_Key]
OR O.[Qualification2Alt_Key]				<>	T.[Qualification2Alt_Key]
OR O.[Qualification3Alt_Key]				<>	T.[Qualification3Alt_Key]
OR O.[Qualification4Alt_Key]				<>	T.[Qualification4Alt_Key]
OR O.[MobileNo]								<>	T.[MobileNo]
OR O.[Email]								<>	T.[Email]
OR O.[VoterID]								<>	T.[VoterID]
OR O.[RationCardNo]							<>	T.[RationCardNo]
OR O.[AadhaarId]							<>	T.[AadhaarId]
OR O.[NPR_Id]								<>	T.[NPR_Id]
OR O.[PassportNo]							<>	T.[PassportNo]
OR O.[PassportIssueDt]						<>	T.[PassportIssueDt]
OR O.[PassportExpiryDt]						<>	T.[PassportExpiryDt]
OR O.[PassportIssueLocation]				<>	T.[PassportIssueLocation]
OR O.[DL_No]								<>	T.[DL_No]
OR O.[DL_IssueDate]							<>	T.[DL_IssueDate]
OR O.[DL_ExpiryDate]						<>	T.[DL_ExpiryDate]
OR O.[DL_IssueLocation]						<>	T.[DL_IssueLocation]
OR O.[BusiEntity_NationalityTypeAlt_Key]	<>	T.[BusiEntity_NationalityTypeAlt_Key]
OR O.[NationalityCountryAlt_Key]			<>	T.[NationalityCountryAlt_Key]
OR O.[PAN]									<>	T.[PAN]
OR O.[TAN]									<>	T.[TAN]
OR O.[TIN]									<>	T.[TIN]
OR O.[RegistrationNo]						<>	T.[RegistrationNo]
OR O.[DIN]									<>	T.[DIN]
OR O.[CIN]									<>	T.[CIN]
OR O.[ServiceTax]							<>	T.[ServiceTax]
OR O.[OtherID]								<>	T.[OtherID]
OR O.[OtherIdType]							<>	T.[OtherIdType]
OR O.[RegistrationAuth]						<>	T.[RegistrationAuth]
OR O.[RegistrationAuthLocation]				<>	T.[RegistrationAuthLocation]
OR O.[PrevFinYearSales]						<>	T.[PrevFinYearSales]
OR O.[EmployeeCount]						<>	T.[EmployeeCount]
OR O.[SalesFigFinYr]						<>	T.[SalesFigFinYr]
OR O.[Designation_ContactPeroson]			<>	T.[Designation_ContactPeroson]
OR O.[IncorporationDate]					<>	T.[IncorporationDate]
OR O.[BusinessCategoryAlt_Key]				<>	T.[BusinessCategoryAlt_Key]
OR O.[BusinessIndustryTypeAlt_Key]			<>	T.[BusinessIndustryTypeAlt_Key]
OR O.[SharePercent]							<>	T.[SharePercent]
OR O.[RetirementDate]						<>	T.[RetirementDate]
OR O.[ProfessionArea]						<>	T.[ProfessionArea]
OR O.[ExistingCustomer]						<>	T.[ExistingCustomer]
OR O.[RefCustomerId]						<>	T.[RefCustomerId]
OR O.[BecomNRI_Dt]							<>	T.[BecomNRI_Dt]
OR O.[AuthSignStartDt]						<>	T.[AuthSignStartDt]
OR O.[AuthSignEndDt]						<>	T.[AuthSignEndDt]
OR O.[ScrCrErrorSeq]						<>	T.[ScrCrErrorSeq]
OR O.[NetWorthDate]							<>	T.[NetWorthDate]
OR O.[AdvNetWorth]							<>	T.[AdvNetWorth]
OR O.[DefendentExpire]						<>	T.[DefendentExpire]
OR O.[DefendentExpireDt]					<>	T.[DefendentExpireDt]
OR O.[PPhoto]								<>	T.[PPhoto]
OR O.[PPhotoDt]								<>	T.[PPhotoDt]
OR O.[PPhotoURL]							<>	T.[PPhotoURL]
OR O.[ActionStatus]							<>	T.[ActionStatus]
OR O.[DirectorDebarred]						<>	T.[DirectorDebarred]
OR O.[LEI]						<>	T.[LEI]

)


----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustRelationship A
INNER JOIN DBO.AdvCustRelationship B 
ON B.CustomerEntityId=A.CustomerEntityId 
Where B.EffectiveToTimeKey= @vEffectiveto


-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvCustRelationship AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustRelationship BB
    WHERE AA.CustomerEntityId=BB.CustomerEntityId  AND AA.RelationEntityId=BB.RelationEntityId
    AND BB.EffectiveToTimeKey =49999
    )

/********************************************************************************************************/
Declare @IntNo int 
set @IntNo=(Select isnull(Max(EntityKey),0) from DBO.AdvCustRelationship)

INSERT INTO DBO.AdvCustRelationship

  (	   [EntityKey]
      ,[CustomerEntityId]
      ,[RelationEntityId]
      ,[SalutationAlt_Key]
      ,[Name]
      ,[ConstitutionAlt_Key]
      ,[OccupationAlt_Key]
      ,[ReligionAlt_Key]
      ,[CasteAlt_Key]
      ,[FarmerCatAlt_Key]
      ,[MaritalStatusAlt_Key]
      ,[NetWorth]
      ,[DateofBirth]
      ,[Qualification1Alt_Key]
      ,[Qualification2Alt_Key]
      ,[Qualification3Alt_Key]
      ,[Qualification4Alt_Key]
      ,[MobileNo]
      ,[Email]
      ,[VoterID]
      ,[RationCardNo]
      ,[AadhaarId]
      ,[NPR_Id]
      ,[PassportNo]
      ,[PassportIssueDt]
      ,[PassportExpiryDt]
      ,[PassportIssueLocation]
      ,[DL_No]
      ,[DL_IssueDate]
      ,[DL_ExpiryDate]
      ,[DL_IssueLocation]
      ,[BusiEntity_NationalityTypeAlt_Key]
      ,[NationalityCountryAlt_Key]
      ,[PAN]
      ,[TAN]
      ,[TIN]
      ,[RegistrationNo]
      ,[DIN]
      ,[CIN]
      ,[ServiceTax]
      ,[OtherID]
      ,[OtherIdType]
      ,[RegistrationAuth]
      ,[RegistrationAuthLocation]
      ,[PrevFinYearSales]
      ,[EmployeeCount]
      ,[SalesFigFinYr]
      ,[Designation_ContactPeroson]
      ,[IncorporationDate]
      ,[BusinessCategoryAlt_Key]
      ,[BusinessIndustryTypeAlt_Key]
      ,[SharePercent]
      ,[RetirementDate]
      ,[ProfessionArea]
      ,[ExistingCustomer]
      ,[ScrCrError]
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
      ,[CIBILPGId]
      ,[Initial]
      ,[BecomNRI_Dt]
      ,[AuthSignStartDt]
      ,[AuthSignEndDt]
      ,[ScrCrErrorSeq]
      ,[NetWorthDate]
      ,[AdvNetWorth]
      ,[DefendentExpire]
      ,[DefendentExpireDt]
      ,[PPhoto]
      ,[PPhotoDt]
      ,[PPhotoURL]
      ,[ActionStatus]
      ,[DirectorDebarred]
      ,[LEI]
	  ,UCIF_ID                 ----Newly Added on date 23/02/2024
	  ,UCIFEntityID             ----Newly Added on date 23/02/2024

				)					
	
	SELECT
	
	   @IntNo+EntityKey
      ,CustomerEntityId
      ,RelationEntityId
      ,SalutationAlt_Key
      ,left(Ltrim(Name),80) Name
      ,ConstitutionAlt_Key
      ,OccupationAlt_Key
      ,ReligionAlt_Key
      ,CasteAlt_Key
      ,FarmerCatAlt_Key
      ,MaritalStatusAlt_Key
      ,NetWorth
      ,DateofBirth
      ,Qualification1Alt_Key
      ,Qualification2Alt_Key
      ,Qualification3Alt_Key
      ,Qualification4Alt_Key
      ,MobileNo
      ,Email
      ,VoterID
      ,RationCardNo
      ,AadhaarId
      ,NPR_Id
      ,PassportNo
      ,PassportIssueDt
      ,PassportExpiryDt
      ,PassportIssueLocation
      ,DL_No
      ,DL_IssueDate
      ,DL_ExpiryDate
      ,DL_IssueLocation
      ,BusiEntity_NationalityTypeAlt_Key
      ,NationalityCountryAlt_Key
      ,PAN
      ,TAN
      ,TIN
      ,RegistrationNo
      ,DIN
      ,CIN
      ,ServiceTax
      ,OtherID
      ,OtherIdType
      ,RegistrationAuth
      ,RegistrationAuthLocation
      ,PrevFinYearSales
      ,EmployeeCount
      ,SalesFigFinYr
      ,Designation_ContactPeroson
      ,IncorporationDate
      ,BusinessCategoryAlt_Key
      ,BusinessIndustryTypeAlt_Key
      ,SharePercent
      ,RetirementDate
      ,ProfessionArea
      ,ExistingCustomer
      ,ScrCrError
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
       ,Getdate()--,D2Ktimestamp    previously it was D2Ktimestamp changed on 23/01/2024
      ,CIBILPGId
      ,Initial
      ,BecomNRI_Dt
      ,AuthSignStartDt
      ,AuthSignEndDt
      ,ScrCrErrorSeq
      ,NetWorthDate
      ,AdvNetWorth
      ,DefendentExpire
      ,DefendentExpireDt
      ,PPhoto
      ,PPhotoDt
      ,PPhotoURL
      ,ActionStatus
      ,DirectorDebarred
      ,LEI
	  ,Null UCIF_ID                    ----Newly Added on date 23/02/2024
	  ,Null UCIFEntityID                ----Newly Added on date 23/02/2024

FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustRelationship T Where ISNULL(T.IsChanged,'U') IN ('N','C') 
		

END


GO