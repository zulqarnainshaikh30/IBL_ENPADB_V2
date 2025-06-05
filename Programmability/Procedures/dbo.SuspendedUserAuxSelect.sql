SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Select Timekey from SysDayMatrix where Cast([Date] as date)=Cast(Getdate() as date)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--UserParameterParameterisedMasterData 16
--USE YES_MISDB
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[SuspendedUserAuxSelect]
--Declare 										
			  @UserLoginID varchar(20) ,
			  @TimeKey INT ,
			  @OperationFlag  INT = 20

AS
----select AuthLevel,* from SysCRisMacMenu where Menuid=14551 Caption like '%Product%'
--update SysCRisMacMenu set AuthLevel=2 where Menuid=14551
     
	BEGIN 

SET NOCOUNT ON;
--Declare @TimeKey AS INT
Declare @DeptGroupCode Varchar(10)=''
	Select @TimeKey= Timekey from SysDayMatrix where Cast([Date] as date)=Cast(Getdate() as date)

	Select @DeptGroupCode=DeptGroupCode from DimUserInfo where UserLoginID=@UserLoginID
 
 	--select DeptGroupCode,* from DimUserInfo			

BEGIN TRY
/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			  PRINT 'SachinTest'
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.UserLoginID,
							A.UserName,
							A.UserLocation,
							A.UserLocationCode,
							A.RoleDescription,
							A.UserRole_Key,
							A.DepartmentName,
							A.ApplicableSOL,
							A.SuspensionDate,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
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
                      
							  
						  SELECT UserLoginID,UserName,UserLocation,UserLocationCode,B.UserRoleShortNameEnum as RoleDescription, B.UserRole_Key 
		 ,D.DeptGroupCode as DepartmentName ,ApplicableSolIds ApplicableSOL,
		 Convert(varchar(10), K.SuspensionDate,103) SuspensionDate,
		 --Convert(Date,Getdate()) SuspensionDate,
		 	isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified
							,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.CreatedBy) as CrAppBy
							,ISNULL(A.DateApproved,A.DateCreated) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifyBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
		 from dimuserinfo A
		 INNER JOIN DimUserRole B ON A.UserRoleAlt_Key = B.UserRoleAlt_Key
		 --inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey
		 inner join DimUserDeptGroup D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey
		 AND D.DeptGroupID=A.DeptGroupCode
		  Left join 
		 (

		   Select
		   MAX(loginTime) as SuspensionDate,Userid
		   from UserLoginHistory
		   where LoginSucceeded='W'
		   Group by Userid
		 ) K on K.UserID=A.UserLoginID 
				
					 WHERE 
					 A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   	 AND SuspendedUser='Y'
						   --AND ShortNameEnum in('NONUSE','UNLOGON')
                           AND ISNULL(A.AuthorisationStatus, 'A') = 'A'
						   AND A.DeptGroupCode=@DeptGroupCode
					 AND UserLoginID NOT IN (Select UserLoginID from DimUserInfo_mod A
					 WHERE 
					 A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey AND ISNULL(A.AuthorisationStatus, 'A') IN( 'MP','1A'))

                     UNION
                     SELECT UserLoginID,UserName,UserLocation,UserLocationCode,B.UserRoleShortNameEnum as RoleDescription, B.UserRole_Key 
		 ,D.DeptGroupCode as DepartmentName ,ApplicableSolIds ApplicableSOL,
		 Convert(varchar(10), K.SuspensionDate,103) SuspensionDate,
		 --Convert(Date,Getdate()) SuspensionDate,
		 	isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified
							,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.ApprovedByFirstLevel) as CrAppBy
							,ISNULL(A.DateApproved,A.DateApprovedFirstLevel) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifyBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
		 from DimUserInfo_mod A
		 INNER JOIN DimUserRole B ON A.UserRoleAlt_Key = B.UserRoleAlt_Key
		 --inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey
		 inner join DimUserDeptGroup D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey
		 AND D.DeptGroupID=A.DeptGroupCode
		  Left join 
		 ( 
		   Select
		   MAX(loginTime) as SuspensionDate,Userid
		   from UserLoginHistory
		   where LoginSucceeded='W'
		   Group by Userid
		 ) K on K.UserID=A.UserLoginID 

					 WHERE 
					 A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   	 AND SuspendedUser='Y'
						   --AND ShortNameEnum in('NONUSE','UNLOGON')
                            AND A.DeptGroupCode=@DeptGroupCode

              AND ISNULL(A.AuthorisationStatus, 'A') IN( 'DP', 'RM')
			  		
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserInfo_mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
				             
                               AND ISNULL(AuthorisationStatus, 'A') IN( 'DP', 'RM')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY A.UserLoginID,
								A.UserName,
								A.UserLocation,
								A.UserLocationCode,
								A.RoleDescription,
								A.UserRole_Key,
								A.DepartmentName,
								A.ApplicableSOL,
								A.SuspensionDate,
								A.AuthorisationStatus, 
                                A.EffectiveFromTimeKey, 
                                A.EffectiveToTimeKey, 
                                A.CreatedBy, 
                                A.DateCreated, 
                                A.ApprovedBy, 
                                A.DateApproved, 
                                A.ModifyBy, 
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
                     SELECT ROW_NUMBER() OVER(ORDER BY UserLoginID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount,    *
                            --'UserPolicyTable' TableName, 
                         
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				-- Order By DataPointOwner.DateCreated Desc

				                  --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF(@OperationFlag  in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
				 PRINT 'Sac16'
                 SELECT 	A.UserLoginID,
								A.UserName,
								A.UserLocation,
								A.UserLocationCode,
								A.RoleDescription,
								A.UserRole_Key,
								A.DepartmentName,
								A.ApplicableSOL,
								A.SuspensionDate,
								A.AuthorisationStatus, 
                                A.EffectiveFromTimeKey, 
                                A.EffectiveToTimeKey, 
                                A.CreatedBy, 
                                A.DateCreated, 
                                A.ApprovedBy, 
                                A.DateApproved, 
                                A.ModifyBy, 
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
                            SELECT UserLoginID,UserName,UserLocation,UserLocationCode,B.UserRoleShortNameEnum as RoleDescription, B.UserRole_Key 
							,D.DeptGroupCode as DepartmentName ,ApplicableSolIds ApplicableSOL,
							Convert(varchar(10), K.SuspensionDate,103) SuspensionDate,
						  --Convert(Date,Getdate()) SuspensionDate,
							isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified
							,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
							,ISNULL(A.ApprovedBy,A.ApprovedByFirstLevel) as CrAppBy
							,ISNULL(A.DateApproved,A.DateApprovedFirstLevel) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifyBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
		 from DimUserInfo_mod A
		 INNER JOIN DimUserRole B ON A.UserRoleAlt_Key = B.UserRoleAlt_Key
		 --inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey
		 inner join DimUserDeptGroup D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey
		 AND D.DeptGroupID=A.DeptGroupCode
		  Left join 
		 (

		   Select
		   MAX(loginTime) as SuspensionDate,Userid
		   from UserLoginHistory
		   where LoginSucceeded='W'
		   Group by Userid
		 ) K on K.UserID=A.UserLoginID
		 
					 WHERE 
					 A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
						   	 AND SuspendedUser='Y'
              AND ISNULL(A.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
			  		  AND A.DeptGroupCode=@DeptGroupCode
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserInfo_mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                      AND EffectiveToTimeKey >= @TimeKey
				
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY EntityKey
                     )
                 ) A 
           
                 GROUP BY 	A.UserLoginID,
								A.UserName,
								A.UserLocation,
								A.UserLocationCode,
								A.RoleDescription,
								A.UserRole_Key,
								A.DepartmentName,
								A.ApplicableSOL,
								A.SuspensionDate,
								A.AuthorisationStatus, 
                                A.EffectiveFromTimeKey, 
                                A.EffectiveToTimeKey, 
                                A.CreatedBy, 
                                A.DateCreated, 
                                A.ApprovedBy, 
                                A.DateApproved, 
                                A.ModifyBy, 
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
                     SELECT ROW_NUMBER() OVER(ORDER BY UserLoginID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount,  *
                            --'UserPolicyTable' TableName, 
                           
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 Order By DataPointOwner.DateCreated Desc

				 
   END;

   IF(@OperationFlag  in (20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT 	A.UserLoginID,
								A.UserName,
								A.UserLocation,
								A.UserLocationCode,
								A.RoleDescription,
								A.UserRole_Key,
								A.DepartmentName,
								A.ApplicableSOL,
								A.SuspensionDate,
								A.AuthorisationStatus, 
                                A.EffectiveFromTimeKey, 
                                A.EffectiveToTimeKey, 
                                A.CreatedBy, 
                                A.DateCreated, 
                                A.ApprovedBy, 
                                A.DateApproved, 
                                A.ModifyBy, 
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
                        
							  
						           SELECT UserLoginID,UserName,UserLocation,UserLocationCode,B.UserRoleShortNameEnum as RoleDescription, B.UserRole_Key 
		 ,D.DeptGroupCode as DepartmentName ,ApplicableSolIds ApplicableSOL,
		 Convert(varchar(10), K.SuspensionDate,103) SuspensionDate,
		  --Convert(Date,Getdate()) SuspensionDate,
		 	isnull(A.AuthorisationStatus, 'A') AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
                            A.DateModified
							,IsNull(A.ModifyBy,A.CreatedBy)as CrModBy
							,IsNull(A.DateModified,A.DateCreated)as CrModDate
								,ISNULL(A.ApprovedBy,A.ApprovedByFirstLevel) as CrAppBy
							,ISNULL(A.DateApproved,A.DateApprovedFirstLevel) as CrAppDate
							,ISNULL(A.ApprovedBy,A.ModifyBy) as ModAppBy
							,ISNULL(A.DateApproved,A.DateModified) as ModAppDate
		 from DimUserInfo_mod A
		 INNER JOIN DimUserRole B ON A.UserRoleAlt_Key = B.UserRoleAlt_Key
		 --inner join DimDepartment D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey
		 inner join DimUserDeptGroup D On D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey
		 AND D.DeptGroupID=A.DeptGroupCode
		   Left join 
		 (

		   Select
		   MAX(loginTime) as SuspensionDate,Userid
		   from UserLoginHistory
		   where LoginSucceeded='W'
		   Group by Userid
		 ) K on K.UserID=A.UserLoginID
		 
					 WHERE 
					 A.EffectiveFromTimeKey <= @TimeKey
                           AND A.EffectiveToTimeKey >= @TimeKey
                       AND ISNULL(A.AuthorisationStatus, 'A') IN('1A')
			  		 AND SuspendedUser='Y'
					  AND A.DeptGroupCode=@DeptGroupCode
                           AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserInfo_mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
				
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY 	A.UserLoginID,
							A.UserName,
							A.UserLocation,
							A.UserLocationCode,
							A.RoleDescription,
							A.UserRole_Key,
							A.DepartmentName,
							A.ApplicableSOL,
							A.SuspensionDate,
							A.AuthorisationStatus, 
                            A.EffectiveFromTimeKey, 
                            A.EffectiveToTimeKey, 
                            A.CreatedBy, 
                            A.DateCreated, 
                            A.ApprovedBy, 
                            A.DateApproved, 
                            A.ModifyBy, 
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
                     SELECT ROW_NUMBER() OVER(ORDER BY UserLoginID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, *
                            --'UserPolicyTable' TableName, 
                            
                     FROM
                     (
                         SELECT *
                         FROM #temp20 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 Order By DataPointOwner.DateCreated Desc

				 
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