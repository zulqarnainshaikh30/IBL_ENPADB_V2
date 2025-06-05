SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [ETL_MAIN].[InvestmentIssuerDetail_Main]
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
from UTKS_TEMPDB.DBO.TempInvestmentIssuerDetail A
Where Not Exists(Select 1 from DBO.InvestmentIssuerDetail B Where B.EffectiveToTimeKey=49999
And A.IssuerID=B.IssuerID) -- And A.SourceAlt_Key=B.SourceAlt_Key)



UPDATE O SET O.EffectiveToTimeKey=@vEffectiveto,
 O.DateModified=CONVERT(DATE,GETDATE(),103),
 O.ModifiedBy='SSISUSER'

FROM DBO.InvestmentIssuerDetail AS O
INNER JOIN UTKS_TEMPDB.DBO.TempInvestmentIssuerDetail AS T
ON O.IssuerID=T.IssuerID

and O.EffectiveToTimeKey=49999
AND T.EffectiveToTimeKey=49999

WHERE
( 
 O.BranchCode <> T.BranchCode 

OR O.IssuerName <> T.IssuerName 
OR O.RatingStatus <> T.RatingStatus 
OR O.IssuerAccpRating <> T.IssuerAccpRating 
OR O.IssuerAccpRatingDt <> T.IssuerAccpRatingDt 
OR O.IssuerRatingAgency <> T.IssuerRatingAgency 
OR O.Ref_Txn_Sys_Cust_ID <> T.Ref_Txn_Sys_Cust_ID 
OR O.Issuer_Category_Code <> T.Issuer_Category_Code 
OR O.GrpEntityOfBank <> T.GrpEntityOfBank 
)



----------For Changes Records
UPDATE A SET A.IsChanged='C'
----Select * 
from UTKS_TEMPDB.DBO.TempInvestmentIssuerDetail A
INNER JOIN DBO.InvestmentIssuerDetail B 
ON  A.IssuerID=B.IssuerID
Where B.EffectiveToTimeKey= @vEffectiveto

---------------------------------------------------------------------------------------------------------------

-------Expire the records
UPDATE AA
SET 
 EffectiveToTimeKey = @vEffectiveto,
 DateModified=CONVERT(DATE,GETDATE(),103),
 ModifiedBy='SSISUSER' 
FROM DBO.InvestmentIssuerDetail AA
WHERE AA.EffectiveToTimeKey = 49999
AND NOT EXISTS (SELECT 1 FROM UTKS_TEMPDB.DBO.TempInvestmentIssuerDetail BB
    WHERE  AA.IssuerID=BB.IssuerID
    AND BB.EffectiveToTimeKey =49999
    )

INSERT INTO UTKS_MISDB.DBO.InvestmentIssuerDetail
     (	
       EntityKey
	  ,IssuerEntityId
	  ,[BranchCode]   
      ,[IssuerID]
      ,[IssuerName]
      ,[RatingStatus]
      ,[IssuerAccpRating]
      ,[IssuerAccpRatingDt]
      ,[IssuerRatingAgency]
      ,[Ref_Txn_Sys_Cust_ID]
      ,[Issuer_Category_Code]
      ,[GrpEntityOfBank]
      ,[AuthorisationStatus]
      ,[EffectiveFromTimeKey]
      ,[EffectiveToTimeKey]
      ,[CreatedBy]
      ,[DateCreated]
      ,[ModifiedBy]
      ,[DateModified]
      ,[ApprovedBy]
      ,[DateApproved]
	  ,SourceAlt_key
	  ,UcifId
	  ,PanNo
	  ,FlgSMA
	 ,SMA_Dt
	 ,SMA_Class
	)
SELECT 
	   EntityKey
	  ,IssuerEntityId
      ,[BranchCode]
      ,[IssuerID]
      ,[IssuerName]
      ,[RatingStatus]
      ,[IssuerAccpRating]
      ,[IssuerAccpRatingDt]
      ,[IssuerRatingAgency]
      ,[Ref_Txn_Sys_Cust_ID]
      ,[Issuer_Category_Code]
      ,[GrpEntityOfBank]
      ,[AuthorisationStatus]
      ,[EffectiveFromTimeKey]
      ,[EffectiveToTimeKey]
      ,[CreatedBy]
      ,[DateCreated]
      ,[ModifiedBy]
      ,[DateModified]
      ,[ApprovedBy]
      ,[DateApproved]
	  ,SourceAlt_key
	  ,UcifId
	  ,PanNo
	  ,NULL,NULL,NULL  
	  --,'','','' --update by vinit
		   FROM UTKS_TEMPDB.dbo.TempInvestmentIssuerDetail T  
		    Where ISNULL(T.IsChanged,'U') IN ('N','C')  



END


--select IsChanged,* from UTKS_TEMPDB.dbo.TempInvestmentIssuerDetail T Where ISNULL(T.IsChanged,'U') IN ('N','C') 
GO