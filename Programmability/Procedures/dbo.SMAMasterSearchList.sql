SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SMAMasterSearchList]
--Declare
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													@OperationFlag  INT         = 16
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
                 SELECT 
							
							A.SourceAlt_Key,
							A.SourceName,
							A.CustomerACID,
							A.CustomerId,
							A.CustomerName,
							A.CreatedBy,
							A.DateCreated,
							A.AuthorisationStatus,
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
							
							B.SourceAlt_Key,
							B.SourceName,
							A.CustomerACID,
							A.CustomerId,
							A.CustomerName
							,A.CreatedBy
							,A.DateCreated,
							A.AuthorisationStatus
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                     FROM DimSMA A
					 INNER JOIN DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT 
							
							B.SourceAlt_Key,
							B.SourceName,
							A.CustomerACID,
							A.CustomerId,
							A.CustomerName,
							A.CreatedBy,
							A.DateCreated,
							A.AuthorisationStatus
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                     FROM DimSMA_Mod A
					 INNER JOIN DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimSMA_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY CustomerACID
                     )
                 ) A 
                      
                 
                 GROUP BY 
							
							A.SourceAlt_Key,
							A.SourceName,
							A.CustomerACID,
							A.CustomerId,
							A.CustomerName,
							A.CreatedBy,
							A.DateCreated,
							A.AuthorisationStatus,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate;

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerACID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SMAMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 order by len(AuthorisationStatus) desc,DateCreated desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */

			 IF(@OperationFlag in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT 
							
							A.SourceAlt_Key,
							A.SourceName,
							A.CustomerACID,
							A.CustomerId,
							A.CustomerName,
							A.CreatedBy,
							A.DateCreated,
							A.AuthorisationStatus,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate

                 INTO #temp16
                 FROM 
                 (
                     SELECT 
							
							B.SourceAlt_Key,
							B.SourceName,
							A.CustomerACID,
							A.CustomerId,
							A.CustomerName,
							A.CreatedBy,
							A.DateCreated,
							A.AuthorisationStatus
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                     FROM DimSMA_Mod A
					 INNER JOIN DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimSMA_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY CustomerACID
                     )
                 ) A 
                      
                 
                 GROUP BY 
							
							A.SourceAlt_Key,
							A.SourceName,
							A.CustomerACID,
							A.CustomerId,
							A.CustomerName,
							A.CreatedBy,
							A.DateCreated,
							A.AuthorisationStatus,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
				
			 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerACID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SMAMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 order by len(AuthorisationStatus) desc,DateCreated desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;
   ELSE
   IF(@OperationFlag in (20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT 
							
							A.SourceAlt_Key,
							A.SourceName,
							A.CustomerACID,
							A.CustomerId,
							A.CustomerName,
							A.CreatedBy,
							A.DateCreated,
							A.AuthorisationStatus,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate

                 INTO #temp20
                 FROM 
                 (
                     SELECT 
							
							B.SourceAlt_Key,
							B.SourceName,
							A.CustomerACID,
							A.CustomerId,
							A.CustomerName,
							A.CreatedBy,
							A.DateCreated,
							A.AuthorisationStatus
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
                     FROM DimSMA_Mod A
					 INNER JOIN DIMSOURCEDB B
					 ON A.SourceAlt_Key=B.SourceAlt_Key
					 AND B.EffectiveFromTimeKey <= @TimeKey
                           AND B.EffectiveToTimeKey >= @TimeKey
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimSMA_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                         GROUP BY CustomerACID
                     )
                 ) A 
                      
                 
                 GROUP BY 
							
							A.SourceAlt_Key,
							A.SourceName,
							A.CustomerACID,
							A.CustomerId,
							A.CustomerName,
							A.CreatedBy,
							A.DateCreated,
							A.AuthorisationStatus,
							A.CrModBy,
							A.CrModDate,
							A.CrAppBy,
							A.CrAppDate,
							A.ModAppBy,
							A.ModAppDate
				
			 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY CustomerACID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SMAMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 order by len(AuthorisationStatus) desc,DateCreated desc
   END

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