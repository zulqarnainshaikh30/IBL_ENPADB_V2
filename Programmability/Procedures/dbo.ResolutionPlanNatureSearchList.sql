﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ResolutionPlanNatureSearchList] 
									        @Description VARCHAR (200)='',
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


			IF(@OperationFlag not in (16,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT A.RPNatureAlt_Key,
							A.RPDescription,
							RTRIM(A.AuthorisationStatus) as AuthorisationStatus , 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.RPNatureAlt_Key,
							A.RPDescription,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                     FROM DimResolutionPlanNature A
					                          
                     WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT A.RPNatureAlt_Key,
							A.RPDescription,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                     FROM DimResolutionPlanNature_Mod A
					 
                     WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimResolutionPlanNature_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY RPNatureAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.RPNatureAlt_Key,
							A.RPDescription,
                            A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RPNatureAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ResolutionPlanMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         WHERE ISNULL(RPDescription, '') LIKE '%'+@Description+'%'
							   
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 
			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 if(@operationflag in(16))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT A.RPNatureAlt_Key,
							A.RPDescription,
                           RTRIM(A.AuthorisationStatus) as AuthorisationStatus , 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.RPNatureAlt_Key,
							A.RPDescription,
                            isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                     FROM DimResolutionPlanNature_Mod A
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimResolutionPlanNature_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY RPNatureAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.RPNatureAlt_Key,
							A.RPDescription,
                            A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate;
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RPNatureAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ResolutionPlanMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         WHERE ISNULL(RPDescription, '') LIKE '%'+@Description+'%'
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
                 SELECT A.RPNatureAlt_Key,
							A.RPDescription,
                            A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
                 INTO #temp20
                 FROM 
                 (SELECT
							A.RPNatureAlt_Key
							,A.RPDescription
                            --,isnull(A.AuthorisationStatus, 'A') 
							,A.AuthorisationStatus
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy 
                            ,A.DateApproved
                            ,A.ModifiedBy
                            ,A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                     FROM DimResolutionPlanNature_Mod A

					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimResolutionPlanNature_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND AuthorisationStatus IN('1A')
                         GROUP BY RPNatureAlt_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.RPNatureAlt_Key,
							A.RPDescription,
                            A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY RPNatureAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ResolutionPlanMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         WHERE ISNULL(RPDescription, '') LIKE '%'+@Description+'%'
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

  select *,'ResolutionPlanNatureMaster' AS tableName from MetaScreenFieldDetail where ScreenName='Resolution Plan Nature Master'
  
     END;
GO