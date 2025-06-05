SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[InvestmentBasicSearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 1
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,
                            A.RefIssuerID,
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                            A.ApprovedBy,
                            A.DateApproved
							
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,
                            A.RefIssuerID,
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            isnull(A.AuthorisationStatus,'A') AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
							A.ApprovedBy,
                            A.DateApproved
							
                     FROM curdat.InvestmentBasicDetail A 
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,
                            A.RefIssuerID,
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            isnull(A.AuthorisationStatus,'A') AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
							A.ApprovedBy,
                            A.DateApproved
							
                     FROM InvestmentBasicDetail_Mod A 
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.InvEntityId IN
                     (
                         SELECT MAX(EntityKey)
                         FROM InvestmentBasicDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,
                            A.RefIssuerID,
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                            A.ApprovedBy,
                            A.DateApproved

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'IssuerBasicMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF (@OperationFlag in(16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT IssuerMaster
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,
                            A.RefIssuerID,
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                            A.ApprovedBy,
                            A.DateApproved
							
                     FROM InvestmentBasicDetail_Mod A 
					 
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.InvEntityId IN
                     (
                         SELECT MAX(EntityKey)
                         FROM curdat.InvestmentBasicDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
							    GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,
                            A.RefIssuerID,
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                            A.ApprovedBy,
                            A.DateApproved
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'IssuerBasicMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   Else

   IF (@OperationFlag =20)
             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,
                            A.RefIssuerID,
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                            A.ApprovedBy,
                            A.DateApproved
                 INTO #temp20
                 FROM 
                 (
                     SELECT A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,
                            A.RefIssuerID,
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                            A.ApprovedBy,
                            A.DateApproved
                     FROM InvestmentBasicDetail_Mod A 
					 
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                           AND A.InvEntityId IN
                     (
                         SELECT MAX(EntityKey)
                         FROM curdat.InvestmentBasicDetail_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND AuthorisationStatus IN('1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY A.EntityKey,
                            A.BranchCode,
                            A.InvEntityId,
                            A.IssuerEntityId,
                            A.RefIssuerID,
                            A.ISIN,
                            A.InstrTypeAlt_Key,
                            A.InstrName,
                            A.InvestmentNature,
                            A.InternalRating,
                            A.InRatingDate,
                            A.InRatingExpiryDate,
                            A.ExRating,
                            A.ExRatingAgency,
                            A.ExRatingDate,
                            A.ExRatingExpiryDate,
                            A.Sector,
                            A.Industry_AltKey,
                            A.ListedStkExchange,
                            A.ExposureType,
                            A.SecurityValue,
                            A.MaturityDt,
                            A.ReStructureDate,
                            A.MortgageStatus,
                            A.NHBStatus,
                            A.ResiPurpose,
                            A.AuthorisationStatus,
                            A.EffectiveFromTimeKey,
                            A.EffectiveToTimeKey,
                            A.CreatedBy,
                            A.DateCreated,
                            A.ModifiedBy,
                            A.DateModified,
                            A.ApprovedBy,
                            A.DateApproved
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY EntityKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'IssuerBasicMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;


   END TRY
	BEGIN CATCH
	
	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	--RETURN -1
   
	END CATCH


  
  
    END;
GO