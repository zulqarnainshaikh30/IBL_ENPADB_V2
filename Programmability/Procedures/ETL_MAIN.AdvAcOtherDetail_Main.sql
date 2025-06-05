SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[AdvAcOtherDetail_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM IBL_ENPA_DB_V2.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')

----------For New Records
UPDATE A SET A.IsChanged='N'
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcOtherDetail A
Where Not Exists(Select 1 from DBO.AdvAcOtherDetail B Where B.EffectiveToTimeKey=49999
And B.AccountEntityId=A.AccountEntityId)


UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'
FROM DBO.AdvAcOtherDetail AS O
INNER JOIN IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcOtherDetail AS T
ON O.AccountEntityID=T.AccountEntityID
AND O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
( 
	O.GovGurAmt <> T.GovGurAmt 
OR O.SplCatg1Alt_Key <> T.SplCatg1Alt_Key 
OR O.SplCatg2Alt_Key <> T.SplCatg2Alt_Key 
OR O.RefinanceAgencyAlt_Key <> T.RefinanceAgencyAlt_Key 
OR O.RefinanceAmount <> T.RefinanceAmount 
OR O.BankAlt_Key <> T.BankAlt_Key 
OR O.TransferAmt <> T.TransferAmt 
OR O.ProjectId <> T.ProjectId 
OR O.ConsortiumId <> T.ConsortiumId 
OR O.RefSystemAcId <> T.RefSystemAcId 
OR O.MocStatus <> T.MocStatus 
OR O.MocDate <> T.MocDate 
OR O.SplCatg3Alt_Key <> T.SplCatg3Alt_Key 
OR O.SplCatg4Alt_Key <> T.SplCatg4Alt_Key 
OR O.MocTypeAlt_Key <> T.MocTypeAlt_Key 
OR O.GovGurExpDt <> T.GovGurExpDt 
	)
	
	

----------For Changes Records
UPDATE A SET A.IsChanged='C'
from IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcOtherDetail A
INNER JOIN DBO.AdvAcOtherDetail B 
ON B.AccountEntityId=A.AccountEntityId           
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.AdvAcOtherDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcOtherDetail BB
    WHERE AA.AccountEntityID=BB.AccountEntityID    
    AND BB.EffectiveToTimeKey =49999
    )
	

	/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  IBL_ENPA_DB_V2.[dbo].[AdvAcOtherDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvAcOtherDetail] TEMP
INNER JOIN (SELECT AccountEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM IBL_ENPA_TEMPDB_V2.DBO.[TempAdvAcOtherDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON TEMP.AccountEntityId=ACCT.AccountEntityId
Where Temp.IsChanged in ('N','C')
------------------------------
	------------------REMOVE DUPLICATE---------------------------------------
;With Remove_Duplicate As 
(
Select 
ROW_NUMBER() over (partition by AccountEntityId order by AccountEntityId) ACID ,
*
From IBL_ENPA_TEMPDB_V2.dbo.TempAdvAcOtherDetail
)
Delete Remove_Duplicate where ACID >1
-----------------------------------------------------------------------------
INSERT INTO DBO.AdvAcOtherDetail

	( 
	   [EntityKey]
      ,[AccountEntityId]
      ,[GovGurAmt]
      ,[SplCatg1Alt_Key]
      ,[SplCatg2Alt_Key]
      ,[RefinanceAgencyAlt_Key]
      ,[RefinanceAmount]
      ,[BankAlt_Key]
      ,[TransferAmt]
      ,[ProjectId]
      ,[ConsortiumId]
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
      ,[MocStatus]
      ,[MocDate]
      ,[SplCatg3Alt_Key]
      ,[SplCatg4Alt_Key]
      ,[MocTypeAlt_Key]
      ,[GovGurExpDt] 
	  ,SplFlag
						)

SELECT 

		[EntityKey]
      ,AccountEntityId
      ,GovGurAmt
      ,SplCatg1Alt_Key
      ,SplCatg2Alt_Key
      ,RefinanceAgencyAlt_Key
      ,RefinanceAmount
      ,BankAlt_Key
      ,TransferAmt
      ,ProjectId
      ,ConsortiumId
      ,RefSystemAcId
      ,AuthorisationStatus
      ,EffectiveFromTimeKey
      ,EffectiveToTimeKey
      ,CreatedBy
      ,DateCreated
      ,ModifiedBy
      ,DateModified
      ,ApprovedBY
      ,DateApproved
      ,GETDATE() D2Ktimestamp
      ,MocStatus
      ,MocDate
      ,SplCatg3Alt_Key
      ,SplCatg4Alt_Key
      ,MocTypeAlt_Key
      ,GovGurExpDt
	  ,SplFlag

     FROM IBL_ENPA_TEMPDB_V2.DBO.TempAdvAcOtherDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')

		
END



GO