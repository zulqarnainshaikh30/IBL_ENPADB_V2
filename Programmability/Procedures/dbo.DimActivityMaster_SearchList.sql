SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[DimActivityMaster_SearchList]


--Declare
--@PageNo         INT         = 1, 
--@PageSize       INT         = 10, 
@OperationFlag  INT         = 1
,@MenuID  INT  =14559
AS
     
	 BEGIN

SET NOCOUNT ON;
Declare @TimeKey as Int
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')
				
Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID
  --select * from 	SysCRisMacMenu where menucaption like '%Activity%'
BEGIN TRY

/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.ActivityMappingAlt_Key,
						    A.ActivityName,
							A.ActivityAlt_Key,
							A.SourceAlt_Key,
							A.SrcsysActivitycode,
							A.SrcsysActivityName, 
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifiedBy, 
                            A.DateModifie,
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
							A.ActivityMappingAlt_Key --as Code,
						    ,A.ActivityName --as ActivityName,
							,A.ActivityAlt_Key
						    ,S.SourceAlt_Key
							,A.SrcsysActivitycode
							,A.SrcsysActivityName
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy 
                            ,A.DateApproved 
                            ,A.ModifiedBy 
                            ,A.DateModifie
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModifie,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModifie) as ModAppDate
                  FROM DimActivityMapping A
				  left JOIN DIMsourceDB S ON S.sourceAlt_Key=A.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
                     UNION
                     SELECT 
							A.ActivityMappingAlt_Key --as Code,
						    ,A.ActivityName --as ActivityName,
							,A.ActivityAlt_Key
							,S.SourceAlt_Key
							,A.SrcsysActivitycode
							,A.SrcsysActivityName
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated
                            ,A.ApprovedBy 
                            ,A.DateApproved
                            ,A.ModifiedBy
                            ,A.DateModifie
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModifie,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModifie) as ModAppDate
                     FROM DimActivityMapping_Mod A
					 left JOIN DIMsourceDB S ON S.sourceAlt_Key=A.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Activity_Key IN
                     (
                         SELECT MAX(Activity_Key)
                         FROM DimActivityMapping_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY Activity_Key
                     )
                 ) A 
                      
                 
                 GROUP BY   A.ActivityMappingAlt_Key
						    ,A.ActivityName
							,A.ActivityAlt_Key
							,A.SourceAlt_Key
							,A.SrcsysActivitycode
							,A.SrcsysActivityName
							,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy 
                           , A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved 
                           , A.ModifiedBy 
                            ,A.DateModifie
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY ActivityMappingAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ActivityMaster' TableName, 
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

			 IF(@OperationFlag  in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT     A.ActivityMappingAlt_Key 
						    ,A.ActivityName 
							,A.ActivityAlt_Key
						    ,A.SourceAlt_Key
							,A.SrcsysActivitycode
							,A.SrcsysActivityName
							
							,A.AuthorisationStatus
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy 
                            ,A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved
                            ,A.ModifiedBy 
                            ,A.DateModifie
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate

                 INTO #temp16
                 FROM 
                 (
                     SELECT A.ActivityMappingAlt_Key 
						    ,A.ActivityName 
							,A.ActivityAlt_Key
						    ,S.SourceAlt_Key
							,A.SrcsysActivitycode
							,A.SrcsysActivityName
							
							,isnull(A.AuthorisationStatus, 'A') AuthorisationStatus 
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy 
                            ,A.DateCreated 
                            ,A.ApprovedBy
                            ,A.DateApproved
                            ,A.ModifiedBy 
                            ,A.DateModifie
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModifie,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModifie) as ModAppDate
                     FROM DimActivityMapping_Mod  A
					 left JOIN DIMsourceDB S ON S.sourceAlt_Key=A.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.Activity_Key IN
                     (
                         SELECT MAX(Activity_Key)
                         FROM DimActivityMapping_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY Activity_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.ActivityMappingAlt_Key
						    ,A.ActivityName 
							,A.ActivityAlt_Key
						    ,A.SourceAlt_Key
							,A.SrcsysActivitycode
							,A.SrcsysActivityName
						
							,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved 
                            ,A.ModifiedBy 
                            ,A.DateModifie
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY ActivityMappingAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ActivityMaster' TableName, 
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

   ELSE

   IF(@OperationFlag  in (20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT     A.ActivityMappingAlt_Key 
						    ,A.ActivityName 
							,A.ActivityAlt_Key
						    ,A.SourceAlt_Key
							,A.SrcsysActivitycode
							,A.SrcsysActivityName
							
							,A.AuthorisationStatus
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy 
                            ,A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved
                            ,A.ModifiedBy 
                            ,A.DateModifie
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
                 INTO #temp20
                 FROM 
                 (
                     SELECT A.ActivityMappingAlt_Key 
						    ,A.ActivityName 
							,A.ActivityAlt_Key
						    ,S.SourceAlt_Key
							,A.SrcsysActivitycode
							,A.SrcsysActivityName
							
							--,isnull(A.AuthorisationStatus, 'A') 
							,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey 
                            ,A.CreatedBy 
                            ,A.DateCreated 
                            ,A.ApprovedBy
                            ,A.DateApproved
                            ,A.ModifiedBy 
                            ,A.DateModifie
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModifie,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModifie) as ModAppDate
                     FROM DimActivityMapping_Mod  A
					 left JOIN DIMsourceDB S ON S.sourceAlt_Key=A.SourceAlt_Key
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
                           AND A.Activity_Key IN
                     (
                         SELECT MAX(Activity_Key)
                         FROM DimActivityMapping_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               --AND ISNULL(AuthorisationStatus, '1A') IN('1A')
							    AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A')
										THEN 1 
							           when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
										THEN 1
										ELSE 0									
										END
									)=1
                         GROUP BY Activity_Key
                     )
                 ) A 
                      
                 
                 GROUP BY A.ActivityMappingAlt_Key
						    ,A.ActivityName 
							,A.ActivityAlt_Key
						    ,A.SourceAlt_Key
							,A.SrcsysActivitycode
							,A.SrcsysActivityName
						
							,A.AuthorisationStatus 
                            ,A.EffectiveFromTimeKey 
                            ,A.EffectiveToTimeKey
                            ,A.CreatedBy
                            ,A.DateCreated 
                            ,A.ApprovedBy 
                            ,A.DateApproved 
                            ,A.ModifiedBy 
                            ,A.DateModifie
							,A.CrModBy
							,A.CrModDate
							,A.CrAppBy
							,A.CrAppDate
							,A.ModAppBy
							,A.ModAppDate
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY ActivityMappingAlt_Key) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'ActivityMaster' TableName, 
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