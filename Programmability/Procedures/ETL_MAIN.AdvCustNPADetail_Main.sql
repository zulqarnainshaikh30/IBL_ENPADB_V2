SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvCustNPADetail_Main]
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
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustNPAdetail A
Where Not Exists(Select 1 from DBO.AdvCustNPADetail B Where B.EffectiveToTimeKey=49999
And B.CustomerEntityId=A.CustomerEntityId) -- And A.SourceAlt_Key=B.SourceAlt_Key)

----------For New Records
UPDATE A SET A.IsChanged='N'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustNPAdetail A
Where Not Exists(Select 1 from DBO.AdvCustNPADetail B Where B.EffectiveToTimeKey=49999
And B.CustomerEntityId=A.CustomerEntityId) -- And A.SourceAlt_Key=B.SourceAlt_Key)



UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.AdvCustNPADetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustNPAdetail AS T
ON O.CustomerEntityId=T.CustomerEntityId
--AND O.SourceAlt_Key=T.SourceAlt_Key
and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(
		     O.[Cust_AssetClassAlt_Key]		    <>	        T.[Cust_AssetClassAlt_Key]
         OR  O.[NPADt]							<>	        T.[NPADt]
         OR  O.[LastInttChargedDt]				<>	        T.[LastInttChargedDt]
         OR  O.[LosDt]							<>	        T.[LosDt]
         OR  O.[DbtDt]							<>	        T.[DbtDt]
         OR  O.[DefaultReason1Alt_Key]			<>	        T.[DefaultReason1Alt_Key]
         OR  O.[DefaultReason2Alt_Key]			<>	        T.[DefaultReason2Alt_Key]
         OR  O.[StaffAccountability]			<>	        T.[StaffAccountability]
         OR  O.[LastIntBooked]					<>	        T.[LastIntBooked]
         OR  O.[RefCustomerID]					<>	        T.[RefCustomerID]
         OR  O.[MocStatus]						<>	        T.[MocStatus]
         OR  O.[MocDate]						<>	        T.[MocDate]
         OR  O.[MocTypeAlt_Key]					<>	        T.[MocTypeAlt_Key]
         --OR  O.[WillfulDefault]					<>	        T.[WillfulDefault]
         --OR  O.[WillfulDefaultReasonAlt_Key]	<>	        T.[WillfulDefaultReasonAlt_Key]
        -- OR  O.[WillfulRemark]					<>	        T.[WillfulRemark]
        -- OR  O.[WillfulDefaultDate]				<>	        T.[WillfulDefaultDate]
         OR  O.[NPA_Reason]						<>	        T.[NPA_Reason]
)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustNPAdetail A
INNER JOIN DBO.AdvCustNPADetail B 
ON B.CustomerEntityId=A.CustomerEntityId            
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvCustNPADetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustNPAdetail BB
    WHERE AA.CustomerEntityId=BB.CustomerEntityId   
    AND BB.EffectiveToTimeKey =49999
    )

	/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvCustNPADetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvCustNPAdetail] TEMP
INNER JOIN (SELECT CustomerEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvCustNPAdetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.CustomerEntityId=ACCT.CustomerEntityId
Where Temp.IsChanged in ('N','C')


INSERT INTO IBL_ENPA_DB_V2.DBO.AdvCustNPADetail
  (
       [ENTITYKEY]
      ,[CustomerEntityId]
      ,[Cust_AssetClassAlt_Key]
      ,[NPADt]
      ,[LastInttChargedDt]
      ,[DbtDt]
      ,[LosDt]
      ,[DefaultReason1Alt_Key]
      ,[DefaultReason2Alt_Key]
      ,[StaffAccountability]
      ,[LastIntBooked]
      ,[RefCustomerID]
      ,[AuthorisationStatus]
      ,[EffectiveFromTimeKey]
      ,[EffectiveToTimeKey]
      ,[CreatedBy]
      ,[DateCreated]
      ,[ModifiedBy]
      ,[DateModified]
      ,[ApprovedBy]
      ,[DateApproved]
      ,[D2Ktimestamp] --updated by vinit
      ,[MocStatus]
      ,[MocDate]
      ,[MocTypeAlt_Key]
      ,[NPA_Reason]
  )

SELECT 

	   ENTITYKEY
      ,CustomerEntityId
      ,Cust_AssetClassAlt_Key
      ,NPADt
      ,LastInttChargedDt
      ,DbtDt
      ,LosDt
      ,DefaultReason1Alt_Key
      ,DefaultReason2Alt_Key
      ,StaffAccountability
      ,LastIntBooked
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
      ,'' D2Ktimestamp --updated by vinit
      ,MocStatus
      ,MocDate
      ,MocTypeAlt_Key
      ,NPA_Reason
	   FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvCustNPAdetail T Where ISNULL(T.IsChanged,'U') IN ('N','C') 
END


GO