SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvAcRelation_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')

----------For New Records
UPDATE A SET A.IsChanged='N'
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcRelations A
Where Not Exists(Select 1 from DBO.AdvAcRelations B Where B.EffectiveToTimeKey=49999
And B.CustomerEntityId=A.CustomerEntityId And B.RelationEntityId=A.RelationEntityId)

UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'
FROM DBO.AdvAcRelations AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcRelations AS T
ON O.CustomerEntityId=T.CustomerEntityId
AND O.RelationEntityId=T.RelationEntityId
AND O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(  O.[RelationEntityId]						<> T.[RelationEntityId]
OR O.[CustomerEntityId]						<> T.[CustomerEntityId]
OR O.[RelationTypeAlt_Key]					<> T.[RelationTypeAlt_Key]
OR O.[RelationSrNo]							<> T.[RelationSrNo]
OR O.[GuaranteeValue]						<> T.[GuaranteeValue]
OR O.[RefCustomerID]						<> T.[RefCustomerID]

)

----------For Changes Records
UPDATE A SET A.IsChanged='C'
FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcRelations A
INNER JOIN DBO.AdvAcRelations B 
ON B.CustomerEntityId=A.CustomerEntityId
AND B.[RelationEntityId]= A.[RelationEntityId] 
Where B.EffectiveToTimeKey= @vEffectiveto


-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvAcRelations AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcRelations BB
    WHERE AA.CustomerEntityId=BB.CustomerEntityId  AND AA.[RelationEntityId]=BB.[RelationEntityId]
    AND BB.EffectiveToTimeKey =49999 
    )

/********************************************************************************************************/
Declare @IntNo int 
set @IntNo=(Select isnull(Max(EntityKey),0) from DBO.AdvAcRelations)

INSERT INTO DBO.AdvAcRelations
	(
	   [EntityKey]
      ,[BranchCode]
      ,[RelationEntityId]
      ,[CustomerEntityId]
      ,[AccountEntityId]
      ,[RelationTypeAlt_Key]
      ,[RelationSrNo]
      ,[RelationshipAuthorityCodeAlt_Key]
      ,[InwardNo]
      ,[FacilityNo]
      ,[GuaranteeValue]
      ,[RefCustomerID]
      ,[RefSystemAcId]
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
      ,[StatusActionTaken]
							)

SELECT		

	   @IntNo+EntityKey
      ,BranchCode
      ,RelationEntityId
      ,CustomerEntityId
      ,AccountEntityId
      ,RelationTypeAlt_Key
      ,RelationSrNo
      ,RelationshipAuthorityCodeAlt_Key
      ,InwardNo
      ,FacilityNo
      ,GuaranteeValue
      ,RefCustomerID
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
      ,Getdate()--D2Ktimestamp 
      ,StatusActionTaken
	 FROM  IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcRelations T Where ISNULL(T.IsChanged,'U') IN ('N','C')

END


GO