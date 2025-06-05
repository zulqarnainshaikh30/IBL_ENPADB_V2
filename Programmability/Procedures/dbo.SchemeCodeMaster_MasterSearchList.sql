SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



--USE YES_MISDB
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[SchemeCodeMaster_MasterSearchList]
--Declare
													
													--@PageNo         INT         = 1, 
													--@PageSize       INT         = 10, 
													  @OperationFlag  INT         = 20
													 ,@MenuID  INT  =14551

AS
----select AuthLevel,* from SysCRisMacMenu where Menuid=14551 Caption like '%Product%'
--update SysCRisMacMenu set AuthLevel=2 where Menuid=14551
     
	BEGIN 

SET NOCOUNT ON;
Declare @TimeKey AS INT
	SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C')

Declare @Authlevel InT
 
select @Authlevel=AuthLevel from SysCRisMacMenu  
 where MenuId=@MenuID	
 
 				

BEGIN TRY
/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			  PRINT 'SachinTest'
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT			A.SchemeCodeAltKey,
							A.SchemeCodeDescription,
							A.SchemeCode,
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
							A.ModAppDate,
							A.ModAppByFirst,
							A.ModAppDateFirst
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							A.SchemeCodeAltKey,
							A.SchemeCodeDescription,
							A.SchemeCode,
						
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
							,ISNULL(A.ModifiedBy,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.DateModified,A.DateCreated) as ModAppDateFirst
							--select *
                     FROM DimBuyoutSchemeCode A
				
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
--select * into DimGLProduct_Mod from DimGLProduct
--alter table DimGLProduct_Mod
--add  Remark varchar(max)
--,Change varchar(max)

                     UNION
                     SELECT 	A.SchemeCodeAltKey,
							A.SchemeCodeDescription,
							A.SchemeCode,
							
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
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as ModAppDateFirst
                     FROM DimBuyoutSchemeCode_Mod A
				 
									 WHERE A.EffectiveFromTimeKey <= @TimeKey  AND A.EffectiveToTimeKey >= @TimeKey
					     

                                  AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimBuyoutSchemeCode_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY A.SchemeCodeAltKey,
							A.SchemeCodeDescription,
							A.SchemeCode,
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
							A.ModAppDate,
							A.ModAppByFirst,
							A.ModAppDateFirst

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY SchemeCodeAltKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SchemecodeTypeMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 Order By DataPointOwner.DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF(@OperationFlag  in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT A.SchemeCodeAltKey,
							A.SchemeCodeDescription,
							A.SchemeCode,
							
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
							A.ModAppDate,
							A.ModAppByFirst,
							A.ModAppDateFirst
                 INTO #temp16
                 FROM 
                 (
                     SELECT A.SchemeCodeAltKey,
							A.SchemeCodeDescription,
							A.SchemeCode,
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
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as ModAppDateFirst
                     FROM DimBuyoutSchemeCode_Mod A
					
				
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                     AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimBuyoutSchemeCode_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY A.SchemeCodeAltKey,
							A.SchemeCodeDescription,
							A.SchemeCode,
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
							A.ModAppDate,
							A.ModAppByFirst,
							A.ModAppDateFirst
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY SchemeCodeAltKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SchemecodeTypeMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 Order By DataPointOwner.DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)

   END;

   IF(@OperationFlag  in (20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT A.SchemeCodeAltKey,
							A.SchemeCodeDescription,
						A.SchemeCode,
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
							A.ModAppDate,
							A.ModAppByFirst,
							A.ModAppDateFirst
                 INTO #temp20
                 FROM 
                 (
         SELECT A.SchemeCodeAltKey,
							A.SchemeCodeDescription,
						A.SchemeCode,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
              A.CreatedBy, 
                            A.DateCreated as DateCreated, 
                            A.ApprovedBy as ApprovedBy, 
                            A.DateApproved, 
                  A.ModifiedBy, 
                            A.DateModified
							,IsNull(A.ModifiedBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.FirstLevelApprovedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.FirstLevelDateApproved) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifiedBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
							,ISNULL(A.FirstLevelApprovedBy,A.CreatedBy) as ModAppByFirst
							,ISNULL(A.FirstLevelDateApproved,A.DateCreated) as ModAppDateFirst
                     FROM DimBuyoutSchemeCode_Mod A
					
					 WHERE A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP')
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimBuyoutSchemeCode_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
							   AND ISNULL(AuthorisationStatus, 'A') IN('1A','D1')
         --                      AND (case when @AuthLevel =2  AND ISNULL(AuthorisationStatus, 'A') IN('1A')
									--	THEN 1 
							  --         when @AuthLevel =1 AND ISNULL(AuthorisationStatus,'A') IN ('NP','MP','DP')
									--	THEN 1
									--	ELSE 0									
									--	END
									--)=1
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY A.SchemeCodeAltKey,
							A.SchemeCodeDescription,
							A.SchemeCode,
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
							A.ModAppDate,
							A.ModAppByFirst,
							A.ModAppDateFirst
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY SchemeCodeAltKey) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, 
                            'SchemecodeTypeMaster' TableName, 
                            *
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 Order By DataPointOwner.DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize)
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


  SELECT *, 'SchemeCodeMaster' AS TableName FROM  MetaScreenFieldDetail where ScreenName = 'Scheme Master'
  
    END;





GO