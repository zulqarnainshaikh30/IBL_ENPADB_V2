SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--USE YES_MISDB
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[UserGroupsAuxSelect]
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

 	IF OBJECT_ID('Tempdb..#TmpGroupDtl') IS NOT NULL
		DROP TABLE #TmpGroupDtl

SELECT EntityKey,DeptGroupId,REPLACE(DeptGroupCode,'#','') AS DeptGroupName,DeptGroupName AS DeptGroupDesc,Menus,AuthorisationStatus,CreatedBy,DateCreated,
ModifiedBy,DateModified,ApprovedBy,
DateApproved,EffectiveFromTimeKey,EffectiveToTimeKey 
		INTO #TmpGroupDtl	
	FROM DimUserDeptGroup
	WHERE EffectiveFromTimeKey <=@timekey and EffectiveToTimeKey>=@timekey

	SELECT EntityKey,DeptGroupId,REPLACE(DeptGroupCode,'#','') AS DeptGroupName,DeptGroupName AS DeptGroupDesc,Menus,AuthorisationStatus,CreatedBy,DateCreated,
ModifiedBy,DateModified,ApprovedBy,
DateApproved,EffectiveFromTimeKey,EffectiveToTimeKey,ApprovedByFirstLevel,DateApprovedFirstLevel 
		INTO #TmpGroupDtl1	
	FROM DimUserDeptGroup_Mod
	WHERE EffectiveFromTimeKey <=@timekey and EffectiveToTimeKey>=@timekey

	
	IF OBJECT_ID('Tempdb..#TmpGroupMenuParent') IS NOT NULL
			DROP TABLE #TmpGroupMenuParent


		SELECT DeptGroupId,	B.ParentId 
			INTO #TmpGroupMenuParent		
		FROM  (
					SELECT DeptGroupId,	DeptGroupName,	DeptGroupDesc, --,B.ParentId,
								Split.a.value('.', 'VARCHAR(100)') AS Menus  
				
					FROM  (SELECT DeptGroupId,	DeptGroupName,	DeptGroupDesc,
							CAST ('<M>' + REPLACE(Menus, ',', '</M><M>') + '</M>' AS XML) AS Menus  
							FROM  #TmpGroupDtl 
						) AS A CROSS APPLY Menus.nodes ('/M') AS Split(a) 
				) A
		INNER JOIN SysCRisMacMenu B
					ON CAST(A.Menus AS int)=B.MenuId
		GROUP BY  DeptGroupId,	B.ParentId 


	IF OBJECT_ID('Tempdb..#TmpGroupMenuParent1') IS NOT NULL
			DROP TABLE #TmpGroupMenuParent1


		SELECT DeptGroupId,	B.ParentId 
			INTO #TmpGroupMenuParent1		
		FROM  (
					SELECT DeptGroupId,	DeptGroupName,	DeptGroupDesc, --,B.ParentId,
								Split.a.value('.', 'VARCHAR(100)') AS Menus  
				
					FROM  (SELECT DeptGroupId,	DeptGroupName,	DeptGroupDesc,
							CAST ('<M>' + REPLACE(Menus, ',', '</M><M>') + '</M>' AS XML) AS Menus  
							FROM  #TmpGroupDtl1	 
						) AS A CROSS APPLY Menus.nodes ('/M') AS Split(a) 
				) A
		INNER JOIN SysCRisMacMenu B
					ON CAST(A.Menus AS int)=B.MenuId
		GROUP BY  DeptGroupId,	B.ParentId 
 
 				

BEGIN TRY
/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			  PRINT 'SachinTest'
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT			A.EntityKey,
							A.DeptGroupId,
							A.DeptGroupName,
							A.DeptGroupDesc,
							A.Menus,
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
                 INTO #temp
                 FROM 
                 (
                     
	                   SELECT EntityKey ,
					   T.DeptGroupId, 
					   T.DeptGroupName,
					   DeptGroupDesc,
					    Menus+'|'+ParentID As Menus,
					   	isnull(T.AuthorisationStatus, 'A') AuthorisationStatus, 
	                 EffectiveFromTimeKey ,
						   EffectiveToTimeKey,
						  'Y' IsMainTable	,
	                       T.CreatedBy,
                           T.DateCreated,
                            T.ApprovedBy,
                            T.DateApproved ,
                            T.ModifiedBy ,
                            T.DateModified,
							IsNull(T.ModifiedBy,T.CreatedBy)as CrModBy,
							IsNull(T.DateModified,T.DateCreated)as CrModDate,
							ISNULL(T.ApprovedBy,T.CreatedBy) as CrAppBy,
							ISNULL(T.DateApproved,T.DateCreated) as CrAppDate,
							ISNULL(T.ApprovedBy,T.ModifiedBy) as ModAppBy,
							ISNULL(T.DateApproved,T.DateModified) as ModAppDate     
	                  
							--select *
                  FROM 
		#TmpGroupDtl T
	LEFT JOIN (
				select DeptGroupId,ParentID
					from(
							SELECT DeptGroupId,
										STUFF((SELECT ',' +CAST(ParentId AS VARCHAR(10)) 
									FROM #TmpGroupMenuParent M1
											WHERE M2.DeptGroupId = M1.DeptGroupId
									FOR XML PATH('')),1,1,'')  AS ParentID
									FROM #TmpGroupMenuParent M2
						) B
						group by DeptGroupId,ParentID
				)B
			ON T.DeptGroupId=B.DeptGroupId
				 WHERE T.EffectiveFromTimeKey <= @TimeKey
                           AND T.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(T.AuthorisationStatus, 'A') = 'A'
--select * into DimGLProduct_Mod from DimGLProduct
--alter table DimGLProduct_Mod
--add  Remark varchar(max)
--,Change varchar(max)

                     UNION


                     SELECT EntityKey ,
					   T.DeptGroupId, 
					   DeptGroupName,
					   DeptGroupDesc,
					   Menus+'|'+ParentID As Menus,
					    	isnull(T.AuthorisationStatus, 'A') AuthorisationStatus,
	                       EffectiveFromTimeKey ,
						   EffectiveToTimeKey,
						  'Y' IsMainTable	,
	                       T.CreatedBy,
                           T.DateCreated,
                            T.ApprovedBy,
                            T.DateApproved ,
                            T.ModifiedBy ,
                            T.DateModified,
							IsNull(T.ModifiedBy,T.CreatedBy)as CrModBy,
							IsNull(T.DateModified,T.DateCreated)as CrModDate,
						    ISNULL(T.ApprovedBy,T.ApprovedByFirstLevel) as CrAppBy,
							ISNULL(T.DateApproved,T.DateApprovedFirstLevel) as CrAppDate,
							ISNULL(T.ApprovedBy,T.ModifiedBy) as ModAppBy,
							ISNULL(T.DateApproved,T.DateModified) as ModAppDate     
	                  
							--select *
                  FROM 
		#TmpGroupDtl1 T
	LEFT JOIN (
				select DeptGroupId,ParentID
					from(
							SELECT DeptGroupId,
										STUFF((SELECT ',' +CAST(ParentId AS VARCHAR(10)) 
									FROM #TmpGroupMenuParent1 M1
											WHERE M2.DeptGroupId = M1.DeptGroupId
									FOR XML PATH('')),1,1,'')  AS ParentID
									FROM #TmpGroupMenuParent1 M2
						) B
						group by DeptGroupId,ParentID
				)B
			ON T.DeptGroupId=B.DeptGroupId
				 WHERE T.EffectiveFromTimeKey <= @TimeKey
                           AND T.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(T.AuthorisationStatus, 'A') = 'A'
					     

                                  AND ISNULL(T.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                           AND T.DeptGroupId IN
                     (
                         SELECT MAX(DeptGroupId)
                         FROM DimUserDeptGroup_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY DeptGroupId
                     )
                 ) A 
                      
                 
                 GROUP BY A.EntityKey,
							A.DeptGroupId,
							A.DeptGroupName,
							A.DeptGroupDesc,
							A.Menus,
							A.AuthorisationStatus,
							
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
                     SELECT ROW_NUMBER() OVER(ORDER BY DeptGroupId) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, *
                            --'GROUPTypeMaster' TableName, 
                            
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
                 SELECT A.EntityKey,
							A.DeptGroupId,
							A.DeptGroupName,
							A.DeptGroupDesc,
							A.Menus,
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
                 INTO #temp16
                 FROM 
                 (
                      SELECT EntityKey ,
					   T.DeptGroupId, 
					   DeptGroupName,
					   DeptGroupDesc,
					   Menus+'|'+ParentID As Menus,
					    	isnull(T.AuthorisationStatus, 'A') AuthorisationStatus,
	                       EffectiveFromTimeKey ,
						   EffectiveToTimeKey,
						  'Y' IsMainTable	,
	                       T.CreatedBy,
                           T.DateCreated,
                            T.ApprovedBy,
                            T.DateApproved ,
                            T.ModifiedBy ,
                            T.DateModified,
							IsNull(T.ModifiedBy,T.CreatedBy)as CrModBy,
							IsNull(T.DateModified,T.DateCreated)as CrModDate,
							  ISNULL(T.ApprovedBy,T.ApprovedByFirstLevel) as CrAppBy,
							ISNULL(T.DateApproved,T.DateApprovedFirstLevel) as CrAppDate,
							ISNULL(T.ApprovedBy,T.ModifiedBy) as ModAppBy,
							ISNULL(T.DateApproved,T.DateModified) as ModAppDate     
	                  
							--select *
                  FROM 
		#TmpGroupDtl1 T
	LEFT JOIN (
				select DeptGroupId,ParentID
					from(
							SELECT DeptGroupId,
										STUFF((SELECT ',' +CAST(ParentId AS VARCHAR(10)) 
									FROM #TmpGroupMenuParent1 M1
											WHERE M2.DeptGroupId = M1.DeptGroupId
									FOR XML PATH('')),1,1,'')  AS ParentID
									FROM #TmpGroupMenuParent1 M2
						) B
						group by DeptGroupId,ParentID
				)B
			ON T.DeptGroupId=B.DeptGroupId
				 WHERE T.EffectiveFromTimeKey <= @TimeKey
                           AND T.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(T.AuthorisationStatus, 'A') = 'A'
					     

               AND ISNULL(T.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                           AND T.DeptGroupId IN
                     (
                         SELECT MAX(DeptGroupId)
                         FROM DimUserDeptGroup_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY DeptGroupId
                     )
                 ) A 
                      
                 
                 GROUP BY A.EntityKey,
							A.DeptGroupId,
							A.DeptGroupName,
							A.DeptGroupDesc,
							A.Menus,
							A.AuthorisationStatus,
							
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
                     SELECT ROW_NUMBER() OVER(ORDER BY DeptGroupId) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, *
                            --'GROUPTypeMaster' TableName, 
                           
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
                                 SELECT A.EntityKey,
							A.DeptGroupId,
							A.DeptGroupName,
							A.DeptGroupDesc,
							A.Menus,
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
                 (
                      SELECT EntityKey ,
					   T.DeptGroupId, 
					   DeptGroupName,
					   DeptGroupDesc,
					 Menus+'|'+ParentID As Menus,
					    	isnull(T.AuthorisationStatus, 'A') AuthorisationStatus,
	                       EffectiveFromTimeKey ,
						   EffectiveToTimeKey,
						  'Y' IsMainTable	,
	                       T.CreatedBy,
                           T.DateCreated,
                            T.ApprovedBy,
                            T.DateApproved ,
                            T.ModifiedBy ,
                            T.DateModified,
							IsNull(T.ModifiedBy,T.CreatedBy)as CrModBy,
							IsNull(T.DateModified,T.DateCreated)as CrModDate,
							ISNULL(T.ApprovedBy,T.ApprovedByFirstLevel) as CrAppBy,
							ISNULL(T.DateApproved,T.DateApprovedFirstLevel) as CrAppDate,
							ISNULL(T.ApprovedBy,T.ModifiedBy) as ModAppBy,
							ISNULL(T.DateApproved,T.DateModified) as ModAppDate  
	                  
							--select *
                  FROM 
		#TmpGroupDtl1 T
	LEFT JOIN (
				select DeptGroupId,ParentID
					from(
							SELECT DeptGroupId,
										STUFF((SELECT ',' +CAST(ParentId AS VARCHAR(10)) 
									FROM #TmpGroupMenuParent1 M1
											WHERE M2.DeptGroupId = M1.DeptGroupId
									FOR XML PATH('')),1,1,'')  AS ParentID
									FROM #TmpGroupMenuParent1 M2
						) B
						group by DeptGroupId,ParentID
				)B
			ON T.DeptGroupId=B.DeptGroupId
				 WHERE T.EffectiveFromTimeKey <= @TimeKey
                           AND T.EffectiveToTimeKey >= @TimeKey
                           --AND ISNULL(T.AuthorisationStatus, 'A') = 'A'
					     

                                  AND ISNULL(T.AuthorisationStatus, 'A') IN('1A')
                           AND T.DeptGroupId IN
                     (
                         SELECT MAX(DeptGroupId)
                         FROM DimUserDeptGroup_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                         GROUP BY DeptGroupId
                     )
                 ) A 
                      
                 
                 GROUP BY A.EntityKey,
							A.DeptGroupId,
							A.DeptGroupName,
							A.DeptGroupDesc,
							A.Menus,
							A.AuthorisationStatus,
							
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
                     SELECT ROW_NUMBER() OVER(ORDER BY DeptGroupId) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, *
                            --'CollateralSubTypeMaster' TableName, 
                            
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


  
  
    END;

GO