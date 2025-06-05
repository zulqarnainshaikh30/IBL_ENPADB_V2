SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[CollateralOwnerTypeSearchList]
									        @OwnerID					  VARCHAR(20)		= '', 
											@OwnerShipType				  char(25)			= '',
											@CollOwnerDescription		  varchar(500)		= '',
											--@PageNo					  INT				= 1, 
											--@PageSize					  INT				= 10, 
											@OperationFlag				  INT				= 1
AS
     
	 BEGIN


SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
					

BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag <> 16)
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.CollateralOwnerTypeAltKey,
							A.OwnerID,
							A.OwnerShipType,
							A.CollOwnerDescription,
                            A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.CollateralOwnerTypeAltKey,
							A.OwnerID,
							A.OwnerShipType,
							A.CollOwnerDescription,
                            A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
							FROM DimCollateralOwnerType A
					       WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT A.CollateralOwnerTypeAltKey,
							A.OwnerID,
							A.OwnerShipType,
							A.CollOwnerDescription,
                            A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified                     
							FROM DimCollateralOwnerType_Mod A
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimCollateralOwnerType_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CollateralOwnerTypeAltKey

                     )
                 ) A 
                      
                 
                 GROUP BY	A.CollateralOwnerTypeAltKey,
							A.OwnerID,
							A.OwnerShipType,
							A.CollOwnerDescription,
                            A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralOwnerTypeAltKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'CollateralOwnerTypeMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         WHERE ISNULL(OwnerID, '') LIKE '%'+@OwnerID+'%'
                               AND ISNULL(OwnerShipType, '') LIKE '%'+@OwnerShipType+'%'
							  AND ISNULL(CollOwnerDescription, '') LIKE '%'+@CollOwnerDescription+'%'
							   
                     ) AS DataPointOwner
                 ) AS DataPointOwner
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)
             END;
             ELSE

			 
			 /*  IT IS Used For GRID Search which are Pending for Authorization    */


             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT A.CollateralOwnerTypeAltKey,
							A.OwnerID,
							A.OwnerShipType,
							A.CollOwnerDescription,
                            A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.CollateralOwnerTypeAltKey,
							A.OwnerID,
							A.OwnerShipType,
							A.CollOwnerDescription,
                            A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified
	                        FROM DimCollateralOwnerType_Mod A
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimCollateralOwnerType_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CollateralOwnerTypeAltKey
                     )
                 ) A 
                      
                 
                 GROUP BY A.CollateralOwnerTypeAltKey,
							A.OwnerID,
							A.OwnerShipType,
							A.CollOwnerDescription,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModified;
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CollateralOwnerTypeAltKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'CollateralOwnerTypeMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         WHERE ISNULL(OwnerID, '') LIKE '%'+@OwnerID+'%'
                               AND ISNULL(OwnerShipType, '') LIKE '%'+@OwnerShipType+'%'
							   AND ISNULL(CollOwnerDescription,'') LIKE '%' +@CollOwnerDescription+'%'

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