SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[CustomerBasicDetail_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')

----------For New Records
UPDATE A SET A.IsChanged='N'
from IBL_ENPA_TEMPDB_V2.DBO.TempCustomerBasicDetail A
Where Not Exists(Select 1 from DBO.CustomerBasicDetail B Where B.EffectiveToTimeKey=49999
And B.CustomerEntityId=A.CustomerEntityId) 



UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'
FROM DBO.CustomerBasicDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempCustomerBasicDetail AS T
ON O.CustomerEntityId=T.CustomerEntityId
AND O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(  ISNULL(O.ParentBranchCode,0)              <>ISNULL(T.ParentBranchCode,0)           OR 
   ISNULL(O.CustomerName,0)                  <>ISNULL(T.CustomerName,0)               OR
   ISNULL(O.ConstitutionAlt_Key,0)           <>ISNULL(T.ConstitutionAlt_Key,0)        OR
   ISNULL(O.CustomerInitial,0)               <>ISNULL(T.CustomerInitial,0)            OR 
   ISNULL(O.OccupationAlt_Key,0)             <>ISNULL(T.OccupationAlt_Key,0)          OR
   ISNULL(O.CustomerSinceDt,'1990-01-01')    <>ISNULL(T.CustomerSinceDt,'1990-01-01') OR 
  -- ISNULL(O.ConsentObtained,0)               <>ISNULL(T.ConsentObtained,0)            OR
   ISNULL(O.ReligionAlt_Key,0)               <>ISNULL(T.ReligionAlt_Key,0)            OR 
   ISNULL(O.CasteAlt_Key,0)                  <>ISNULL(T.CasteAlt_Key,0)               OR
   ISNULL(O.FarmerCatAlt_Key,0)              <>ISNULL(T.FarmerCatAlt_Key,0)           OR 
   ISNULL(O.GaurdianSalutationAlt_Key,0)     <>ISNULL(T.GaurdianSalutationAlt_Key,0)  OR
   ISNULL(O.GaurdianName,0)                  <>ISNULL(T.GaurdianName,0)               OR
   ISNULL(O.GuardianType,0)                  <>ISNULL(T.GuardianType,0)               OR
   ISNULL(O.CustSalutationAlt_Key,0)         <>ISNULL(T.CustSalutationAlt_Key,0)      OR
   ISNULL(O.MaritalStatusAlt_Key,0)          <>ISNULL(T.MaritalStatusAlt_Key,0) 
 )



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempCustomerBasicDetail A
INNER JOIN DBO.CustomerBasicDetail B 
ON B.CustomerEntityId=A.CustomerEntityId --And A.SourceAlt_Key=B.SourceAlt_Key
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.CustomerBasicDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempCustomerBasicDetail BB
    WHERE AA.CustomerEntityId=BB.CustomerEntityId  --And AA.SourceAlt_Key=BB.SourceAlt_Key
    AND BB.EffectiveToTimeKey =49999
    )

	-----------------------------------------

/*  New Customers EntityKey ID Update  */
DECLARE @Customer_Key BIGINT=0 
SELECT @Customer_Key=MAX(Customer_Key) FROM  IBL_ENPA_DB_V2.[dbo].[CustomerBasicDetail] 
IF @Customer_Key IS NULL  
BEGIN
	SET @Customer_Key=0
END

UPDATE TEMP 
SET TEMP.Customer_Key=ACCT.Customer_Key
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempCustomerBasicDetail] TEMP
INNER JOIN (SELECT CustomerId,(@Customer_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) Customer_Key
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempCustomerBasicDetail]
			WHERE Customer_Key=0 OR Customer_Key IS NULL)ACCT ON  Temp.CustomerId=ACCT.CustomerId
Where Temp.IsChanged in ('N','C')
---------------------------------------------------------------------------------
INSERT INTO DBO.CustomerBasicDetail
     ( [Customer_Key]
      ,[CustomerEntityId]
      ,[CustomerId]
      ,[D2kCustomerid]
      ,[UCIF_ID]
      ,[UcifEntityID]
      ,[ParentBranchCode]
      ,[CustomerName]
      ,[CustomerInitial]
      ,[CustomerSinceDt]
      ,[ConstitutionAlt_Key]
      ,[OccupationAlt_Key]
      ,[ReligionAlt_Key]
      ,[CasteAlt_Key]
      ,[FarmerCatAlt_Key]
      ,[GaurdianSalutationAlt_Key]
      ,[GaurdianName]
      ,[GuardianType]
      ,[CustSalutationAlt_Key]
      ,[MaritalStatusAlt_Key]
      ,[AssetClass]
      ,[BIITransactionCode]
      ,[D2K_REF_NO]
      ,[ScrCrError]
      ,[ReferenceAcNo]
      ,[CustCRM_RatingAlt_Key]
      ,[CustCRM_RatingDt]
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
      ,[FLAG]
      ,[MocStatus]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[CommonMocTypeAlt_Key]
      ,[LandHolding]
      ,[ScrCrErrorSeq]
      ,[Remark]
      ,[SourceSystemAlt_Key]
	  ,Internal_Rating
		   )
SELECT 		
	   [Customer_Key]
      ,[CustomerEntityId]
      ,[CustomerId]
      ,[D2kCustomerid]
      ,[UCIF_ID]
      ,[UcifEntityID]
      ,[ParentBranchCode]
      ,[CustomerName]
      ,[CustomerInitial]
      ,[CustomerSinceDt]
      ,[ConstitutionAlt_Key]
      ,[OccupationAlt_Key]
      ,[ReligionAlt_Key]
      ,[CasteAlt_Key]
      ,[FarmerCatAlt_Key]
      ,[GaurdianSalutationAlt_Key]
      ,[GaurdianName]
      ,[GuardianType]
      ,[CustSalutationAlt_Key]
      ,[MaritalStatusAlt_Key]
      ,[AssetClass]
      ,[BIITransactionCode]
      ,[D2K_REF_NO]
      ,[ScrCrError]
      ,[ReferenceAcNo]
      ,[CustCRM_RatingAlt_Key]
      ,[CustCRM_RatingDt]
      ,[AuthorisationStatus]
      ,[EffectiveFromTimeKey]
      ,[EffectiveToTimeKey]
      ,[CreatedBy]
      ,[DateCreated]
      ,[ModifiedBy]
      ,[DateModified]
      ,[ApprovedBy]
      ,[DateApproved]
      ,getdate() [D2Ktimestamp]
      ,[FLAG]
      ,[MocStatus]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[CommonMocTypeAlt_Key]
      ,[LandHolding]
      ,[ScrCrErrorSeq]
      ,[Remark]
      ,[SourceSystemAlt_Key]
	  ,Internal_Rating
	   FROM IBL_ENPA_TEMPDB_V2.dbo.TempCustomerBasicDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C') 

END


GO