SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[DimSchemeMaster_SearchList]


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

			IF(@OperationFlag not in (16,17))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.SchemeMappingAlt_Key,
						    A.SchemeName,
							A.SchemeAlt_Key,
							A.SourceAlt_Key,
							A.SrcsysSchemecode,
							A.SrcsysSchemeName, 
							A.SchemeGroup,
							A.SchemeSubGroup,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.SchemeMappingAlt_Key, --as Code,
						    A.SchemeName ,--as SchemeName,
							A.SchemeAlt_Key,
						    S.SourceAlt_Key
							,A.SrcsysSchemecode
							,A.SrcsysSchemeName
							,A.SchemeGroup
							,A.SchemeSubGroup
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie
                  FROM DimSchemeMapping A
				  left JOIN DIMsourceDB S ON S.sourceAlt_Key=A.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT 
							A.SchemeMappingAlt_Key, --as Code,
						    A.SchemeName, --as SchemeName,
							A.SchemeAlt_Key,
							S.SourceAlt_Key
							,A.SrcsysSchemecode
							,A.SrcsysSchemeName
							,A.SchemeGroup
							,A.SchemeSubGroup
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie
                     FROM DimSchemeMapping_Mod A
					 left JOIN DIMsourceDB S ON S.sourceAlt_Key=A.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Scheme_Key IN
                     (
                         SELECT MAX(Scheme_Key)
                         FROM DimSchemeMapping_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY Scheme_Key
                     )
                 ) A 
                      
                 
                 GROUP BY   A.SchemeMappingAlt_Key
						    ,A.SchemeName
							,A.SchemeAlt_Key
							,A.SourceAlt_Key
							,A.SrcsysSchemecode
							,A.SrcsysSchemeName
							,A.SchemeGroup
							,A.SchemeSubGroup
							,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy 
                           , A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved 
                           , A.ModifiedBy 
                            ,A.DateModifie;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY SchemeMappingAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SchemeMaster' TableName, 
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
			 IF(@OperationFlag in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT     A.SchemeMappingAlt_Key 
						    ,A.SchemeName 
							,A.SchemeAlt_Key
						    ,A.SourceAlt_Key
							,A.SrcsysSchemecode
							,A.SrcsysSchemeName
							,A.SchemeGroup
							,A.SchemeSubGroup
							,A.AuthorisationStatus
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy 
                            ,A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved
                            ,A.ModifiedBy 
                            ,A.DateModifie
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.SchemeMappingAlt_Key 
						    ,A.SchemeName 
							,A.SchemeAlt_Key
						    ,S.SourceAlt_Key
							,A.SrcsysSchemecode
							,A.SrcsysSchemeName
							,A.SchemeGroup
							,A.SchemeSubGroup

							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus 
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy 
                            ,A.DateCreated 
                            ,A.ApprovedBy
                            ,A.DateApproved
                            ,A.ModifiedBy 
                            ,A.DateModifie
                     FROM DimSchemeMapping_Mod  A
					 left JOIN DIMsourceDB S ON S.sourceAlt_Key=A.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Scheme_Key IN
                     (
                         SELECT MAX(Scheme_Key)
                         FROM DimSchemeMapping_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY Scheme_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.SchemeMappingAlt_Key
						    ,A.SchemeName 
							,A.SchemeAlt_Key
						    ,A.SourceAlt_Key
							,A.SrcsysSchemecode
							,A.SrcsysSchemeName
							,A.SchemeGroup
							,A.SchemeSubGroup
						
							,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved 
                            ,A.ModifiedBy 
                            ,A.DateModifie
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY SchemeMappingAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SchemeMaster' TableName, 
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