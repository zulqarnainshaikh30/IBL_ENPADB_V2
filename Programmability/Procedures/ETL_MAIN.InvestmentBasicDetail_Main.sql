SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[InvestmentBasicDetail_Main]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @VEFFECTIVETO INT SET @VEFFECTIVETO=(SELECT TIMEKEY-1 FROM UTKS_MISDB.DBO.AUTOMATE_ADVANCES WHERE EXT_FLG='Y')

----------For New Records
UPDATE A SET A.IsChanged='N'
----Select * 
from UTKS_TEMPDB.DBO.TempInvestmentBasicDetail A
Where Not Exists(Select 1 from DBO.InvestmentBasicDetail B Where B.EffectiveToTimeKey=49999
And A.InvEntityId=B.InvEntityId) -- And A.SourceAlt_Key=B.SourceAlt_Key)



UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.InvestmentBasicDetail AS O
INNER JOIN UTKS_TEMPDB.DBO.TempInvestmentBasicDetail AS T
ON O.InvEntityId=T.InvEntityId

and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE 
(   O.BranchCode <> T.BranchCode 
OR O.InvID <> T.InvID 
OR O.IssuerEntityId <> T.InvEntityId
OR O.InstrTypeAlt_Key <> T.InstrTypeAlt_Key 
OR O.InstrName <> T.InstrName 
OR O.InvestmentNature <> T.InvestmentNature 
OR O.InternalRating <> T.InternalRating 
OR O.InRatingDate <> T.InRatingDate 
OR O.InRatingExpiryDate <> T.InRatingExpiryDate 
OR O.ExRating <> T.ExRating 
OR O.ExRatingAgency <> T.ExRatingAgency 
OR O.ExRatingDate <> T.ExRatingDate 
OR O.ExRatingExpiryDate <> T.ExRatingExpiryDate 
OR O.Sector <> T.Sector 	
OR O.Industry_AltKey <> T.Industry_AltKey 
OR O.ListedStkExchange <> T.ListedStkExchange 
OR O.ExposureType <> T.ExposureType 
OR O.SecurityValue <> T.SecurityValue 
OR O.MaturityDt <> T.MaturityDt 
OR O.ReStructureDate <> T.ReStructureDate 
OR O.MortgageStatus <> T.MortgageStatus 
OR O.NHBStatus <> T.NHBStatus 
OR O.ResiPurpose <> T.ResiPurpose 



)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from UTKS_TEMPDB.DBO.TempInvestmentBasicDetail A
INNER JOIN DBO.InvestmentBasicDetail B 
ON  A.InvEntityId=B.InvEntityId
Where B.EffectiveToTimeKey= @vEffectiveto


---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.InvestmentBasicDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM UTKS_TEMPDB.DBO.TempInvestmentBasicDetail BB
    WHERE  AA.InvEntityId=BB.InvEntityId
    AND BB.EffectiveToTimeKey =49999
    )
	


/*  New Customers EntityKey ID Update  */
DECLARE @EntityKey BIGINT=0 
SELECT @EntityKey=MAX(EntityKey) FROM  UTKS_MISDB.[dbo].[InvestmentBasicDetail] 
IF @EntityKey IS NULL  
BEGIN
SET @EntityKey=0
END
 
UPDATE TEMP 
SET TEMP.EntityKey=ACCT.EntityKey
 FROM UTKS_TEMPDB.DBO.[TempInvestmentBasicDetail] TEMP
INNER JOIN (SELECT InvEntityId,(@EntityKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) EntityKey
			FROM UTKS_TEMPDB.DBO.[TempInvestmentBasicDetail]
			WHERE EntityKey=0 OR EntityKey IS NULL)ACCT ON  Temp.InvEntityId=ACCT.InvEntityId
Where Temp.IsChanged in ('N','C')


	--IF (SELECT COUNT(1) FROM   UTKS_TEMPDB.dbo.TempInvestmentBasicDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C')) > 0
	--BEGIN
INSERT INTO dbo.InvestmentBasicDetail
     (	
       [BranchCode]
      ,[EntityKey]
	  ,InvEntityId
	  ,IssuerEntityId
      ,[InvID]
	  ,[RefIssuerID]
      ,[ISIN]
      ,[InstrTypeAlt_Key]
      ,[InstrName]
      ,[InvestmentNature]
      ,[InternalRating]
      ,[InRatingDate]
      ,[InRatingExpiryDate]
      ,[ExRating]
      ,[ExRatingAgency]
      ,[ExRatingDate]
      ,[ExRatingExpiryDate]
      ,[Sector]
      ,[Industry_AltKey]
      ,[ListedStkExchange]
      ,[ExposureType]
      ,[SecurityValue]
      ,[MaturityDt]
      ,[ReStructureDate]
      ,[MortgageStatus]
      ,[NHBStatus]
      ,[ResiPurpose]
      ,[AuthorisationStatus]
      ,[EffectiveFromTimeKey]
      ,[EffectiveToTimeKey]
      ,[CreatedBy]
      ,[DateCreated]
      ,[ModifiedBy]
      ,[DateModified]
      ,[ApprovedBy]
      ,[DateApproved]
		   ) 
SELECT
				
		[BranchCode]
      ,[EntityKey]
	  ,InvEntityId
	  ,IssuerEntityId
      ,[InvID]
      ,[IssuerID]
      --,NULL --update by vinit
	  ,''
      ,[InstrTypeAlt_Key]
      ,[InstrName]
      ,[InvestmentNature]
      ,[InternalRating]
      ,[InRatingDate]
      ,[InRatingExpiryDate]
      ,[ExRating]
      ,[ExRatingAgency]
      ,[ExRatingDate]
      ,[ExRatingExpiryDate]
      ,[Sector]
      ,[Industry_AltKey]
      ,[ListedStkExchange]
      ,[ExposureType]
      ,[SecurityValue]
      ,[MaturityDt]
      ,[ReStructureDate]
      ,[MortgageStatus]
      ,[NHBStatus]
      ,[ResiPurpose]
      ,[AuthorisationStatus]
      ,[EffectiveFromTimeKey]
      ,[EffectiveToTimeKey]
      ,[CreatedBy]
      ,[DateCreated]
      ,[ModifiedBy]
      ,[DateModified]
      ,[ApprovedBy]
      ,[DateApproved]
	FROM UTKS_TEMPDB.dbo.TempInvestmentBasicDetail T 
		Where ISNULL(T.IsChanged,'U') IN ('N','C')
--end

END


GO