SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
 

--USE YES_MISDB
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[UserSearchSelect_new]
--Declare
													
 @UserLoginID		Varchar(50)
,@UserName  Varchar(50)
,@ExtensionNo Varchar(11)
,@ApplicableSOLID varchar(11)
,@UserDepartment	varchar(100)
,@UserRole  varchar(100)
,@Email_ID varchar(200)
,@MobileNo varchar(10)
,@IsChecker Char(1)
--,@IsChecker2 Varchar(1)
,@IsActive  Char(1)
,@TimeKey	INT
,@ApplicableBacid VARCHAR(MAX)=''
,@LoginID  Varchar(50) 
,@OperationFlag  INT         = 20
,@MenuID  INT  =14551

AS
----select AuthLevel,* from SysCRisMacMenu where Menuid=14551 Caption like '%Product%'
--update SysCRisMacMenu set AuthLevel=2 where Menuid=14551
     
	BEGIN 

SET NOCOUNT ON;
--Declare @TimeKey AS INT
	Select @TimeKey=   Timekey from Automate_Advances  where EXT_FLG = 'Y'

--Declare @Authlevel InT
 
--select @Authlevel=AuthLevel from SysCRisMacMenu  
-- where MenuId=@MenuID

IF OBJECT_ID ('TEMPDB..#Dept_ALTKEY') IS NOT NULL
	DROP TABLE #Dept_ALTKEY

CREATE TABLE #Dept_ALTKEY(Dept_ALTKEY VARCHAR(MAX))
print @TimeKey
IF ISNULL(@UserDepartment,'')<>''
BEGIN
	print'Dp'
	INSERT INTO #Dept_ALTKEY
	SELECT Items AS Dept_ALTKEY
	FROM Split(@UserDepartment,',')

	--SELECT * FROM #Dept_ALTKEY
	
END
ELSE
BEGIN
PRINT 'AB'
	INSERT INTO #Dept_ALTKEY
	SELECT DISTINCT deptgroupid AS Dept_ALTKEY
	--FROM dimdepartment A
		FROM Dimuserdeptgroup A
	left JOIN DimUserInfo B ON A.deptgroupid=B.DeptGroupCode
	AND b.EffectiveFromTimeKey<=@TimeKey AND b.EffectiveToTimeKey>=@TimeKey
							
	WHERE B.UserLoginID =@UserLoginID
	AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
	
END

IF OBJECT_ID ('TEMPDB..#BACID') IS NOT NULL
	DROP TABLE #BACID

 CREATE TABLE #BACID(BACID VARCHAR(MAX))  
    PRINT 'TABLE CREATED'  

IF ISNULL(@ApplicableBacid,'')<>''
BEGIN
print 1

	INSERT INTO #BACID
	SELECT Items AS BACID
	
	FROM Split(@ApplicableBacid,',')

	----SELECT * FROM #BACID
	
END
ELSE
BEGIN


	print 2
	INSERT  INTO  #BACID
	SELECT BACID
	FROM DimDepttoBacid
	WHERE DepartmentAlt_Key=10

	
END
 
 		
				

BEGIN TRY
/*  IT IS Used FOR GRID Search which are not Pending for Authorization And also used for Re-Edit    */

			IF(@OperationFlag not in (16,17,20))
             BEGIN
			  PRINT 'SachinTest'
			 IF OBJECT_ID('TempDB..#temp') IS NOT NULL
                 DROP TABLE  #temp;
                 SELECT		A.UserLoginID,
							A.UserName,
							A.UserRole,
							A.RoleDescription,
							A.DepartmentId,
							A.DeptGroupCode,
							A.UserDepartment,
							A.ApplicableSOLID,
							A.ApplicableBACID,
							A.Email_ID,
							A.MobileNo,
							A.ExtensionNo,
							A.MobileNo1,
							A.IsChecker,
							A.IsChecker2,
							A.IsActive, 
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
							A.ModAppDate,
							A.DesignationAlt_Key,
							A.Designation ,
							A.ChangeFields
                 INTO #temp
                 FROM 
                 (
                     SELECT 
							  
						   DISTINCT 
							U.UserLoginID
							,U.UserName
						   ,U.UserRoleAlt_Key as UserRole
						   ,R.RoleDescription 
						   ,U.DepartmentId
						   ,U.DeptGroupCode
						   ,D.DeptGroupCode AS UserDepartment
						   ,Case---- when D.DepartmentCode='BBOG' THEN @ApplicableSolidForBBOG  
								WHEN D.DeptGroupCode='FNA' THEN 'ALL SOL ID' ELSE  U.ApplicableSolIds END AS ApplicableSOLID
						   ----,'' AS ApplicableSOLID
						   ,Case ----when D.DepartmentCode='BBOG' THEN 'ALL BACID OF BBOG DEPARTMENT' 
						   WHEN D.DeptGroupCode='FNA' THEN 'ALL BACID'  ELSE U.ApplicableBACID END ApplicableBACID
						   ,U.Email_ID
						   ,U.MobileNo as MobileNo
						   --,SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,'')))  ExtensionNo
						   ,'' as ExtensionNo
						   ,U.MobileNo as MobileNo1
						   ,U.IsChecker
						   ,U.IsChecker2
						   ,U.Activate AS IsActive
						   --,'QuickSearchTable' as TableName
						
							,isnull(U.AuthorisationStatus, 'A') AuthorisationStatus, 
                            U.EffectiveFromTimeKey, 
                            U.EffectiveToTimeKey, 
                            U.CreatedBy, 
                            U.DateCreated, 
                            U.ApprovedBy, 
                            U.DateApproved, 
                            U.ModifyBy, 
                            U.DateModified
							,IsNull(U.ModifyBy,U.CreatedBy)as CrModBy
							,IsNull(U.DateModified,U.DateCreated)as CrModDate
							,ISNULL(U.ApprovedBy,U.CreatedBy) as CrAppBy
							,ISNULL(U.DateApproved,U.DateCreated) as CrAppDate
							,ISNULL(U.ApprovedBy,U.ModifyBy) as ModAppBy
							,ISNULL(U.DateApproved,U.DateModified) as ModAppDate
							,U.DesignationAlt_Key
                            ,Z.ParameterName as Designation
							,'' as ChangeFields
							--select *
                     from DimUserInfo U
   --LEFT JOIN DimDepartment D ON
				LEFT JOIN Dimuserdeptgroup D ON
				   (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey)
				   and (u.EffectiveFromTimeKey<=@TimeKey AND u.EffectiveToTimeKey >=@TimeKey)
				   AND D.deptgroupid=U.DeptGroupCode
			   LEFT JOIN DimUserRole R ON
				   (R.EffectiveFromTimeKey<=@TimeKey AND R.EffectiveToTimeKey >=@TimeKey)
				   and (u.EffectiveFromTimeKey<=@TimeKey aND U.EffectiveToTimeKey >=@TimeKey)
				   AND R.UserRoleAlt_Key=U.UserRoleAlt_Key
		  LEFT JOIN 	 (select ParameterAlt_Key ,
			 ParameterName 
			 ,'DimUserDesignation' as TableName
			 from DimParameter
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimUserDesignation') Z
			  ON Z.ParameterAlt_Key=U.DesignationAlt_Key
				
					 WHERE ( U.UserLoginID like CASE WHEN @UserLoginID<>'' THEN '%' + @UserLoginID + '%' ELSE U.UserLoginID END)
								AND 
								(ISNULL(U.UserName,'') LIKE CASE WHEN @UserName<>'' THEN '%'+@UserName+'%' ELSE ISNULL(U.UserName,'') END)
								AND (SUBSTRING(ISNULL(U.MobileNo,''),1,10) LIKE CASE WHEN @MobileNo <> '' Then '%' + @MobileNo +'%' ELSE SUBSTRING(ISNULL(U.MobileNo,''),1,10) END )
								AND (SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,''))) LIKE CASE WHEN @ExtensionNo <> '' Then '%' + @ExtensionNo +'%' ELSE SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,''))) END )
								AND (ISNULL(D.deptgroupid,'') IN (SELECT Dept_ALTKEY FROM #Dept_ALTKEY))
								--AND (ISNULL(D.deptgroupid,'') IN (SELECT Dept_ALTKEY FROM #Dept_ALTKEY))
								-------LIKE CASE WHEN @UserDepartment <> '' THEN '%' + @UserDepartment + '%' ELSE ISNULL(D.DepartmentCode,'') END)
								--AND (D.deptgroupid= CASE WHEN  @UserDepartment <> '' THEN @UserDepartment else D.deptgroupid END) --updated by vinit
								AND (U.UserRoleAlt_Key= CASE WHEN  @UserRole <> '' THEN @UserRole else U.UserRoleAlt_Key END)
								AND (ISNULL(U.Email_ID,'')LIKE CASE WHEN @Email_ID <> '' THEN '%' +  @Email_ID + '%' ELSE ISNUll(U.Email_ID,'') END)
								AND (ISNULL(U.IsChecker,'')LIKE CASE WHEN @IsChecker <> '' THEN @IsChecker ELSE U.IsChecker END)
								--AND (ISNULL(U.IsChecker2,'')LIKE CASE WHEN @IsChecker2 <> '' THEN @IsChecker2 ELSE U.IsChecker2 END)
								AND (ISNULL(U.Activate,'')LIKE CASE WHEN @IsActive <> '' THEN @IsActive ELSE U.Activate END)
								----AND U.UserLoginID= CASE WHEN  @ApplicableSOLID <> '' THEN I.UserLoginId else U.UserLoginID  end
								--AND (ISNULL(DB.BACID,'') IN (SELECT BACID FROM #BACID))
		AND U.UserLoginID<>@LoginID AND
					 U.EffectiveFromTimeKey <= @TimeKey
                           AND U.EffectiveToTimeKey >= @TimeKey
                           AND ISNULL(U.AuthorisationStatus, 'A') = 'A'
--select * into DimGLProduct_Mod from DimGLProduct
--alter table DimGLProduct_Mod
--add  Remark varchar(max)
--,Change varchar(max)

                   UNION
                   SELECT 
							  
						   DISTINCT 
							U.UserLoginID
							,U.UserName
						   ,U.UserRoleAlt_Key as UserRole
						   ,R.RoleDescription 
						   ,U.DepartmentId
						   ,U.DeptGroupCode
						   ,D.DeptGroupCode AS UserDepartment
						   ,Case---- when D.DepartmentCode='BBOG' THEN @ApplicableSolidForBBOG  
								WHEN D.DeptGroupCode='FNA' THEN 'ALL SOL ID' ELSE  U.ApplicableSolIds END AS ApplicableSOLID
						   ----,'' AS ApplicableSOLID
						   ,Case ----when D.DepartmentCode='BBOG' THEN 'ALL BACID OF BBOG DEPARTMENT' 
						   WHEN D.DeptGroupCode='FNA' THEN 'ALL BACID'  ELSE U.ApplicableBACID END ApplicableBACID
						   ,U.Email_ID
						   ,U.MobileNo as MobileNo
						   --,SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,'')))  ExtensionNo
						   --,'' as ExtensionNo --update by vinit
						   ,U.Extension as ExtensionNo
						   ,U.MobileNo
						   ,U.IsChecker
						   ,U.IsChecker2
						   ,U.Activate AS IsActive
						   --,'QuickSearchTable' as TableName
						
							,isnull(U.AuthorisationStatus, 'A') AuthorisationStatus, 
                            U.EffectiveFromTimeKey, 
                            U.EffectiveToTimeKey, 
                            U.CreatedBy, 
                            U.DateCreated, 
                            U.ApprovedBy, 
                            U.DateApproved, 
                            U.ModifyBy, 
                            U.DateModified
							,IsNull(U.ModifyBy,U.CreatedBy)as CrModBy
							,IsNull(U.DateModified,U.DateCreated)as CrModDate
							,ISNULL(U.ApprovedBy,U.ApprovedByFirstLevel) as CrAppBy
							,ISNULL(U.DateApproved,U.DateApprovedFirstLevel) as CrAppDate
							,ISNULL(U.ApprovedBy,U.ModifyBy) as ModAppBy
							,ISNULL(U.DateApproved,U.DateModified) as ModAppDate
							,U.DesignationAlt_Key
                            ,Z.ParameterName as Designation 
							,U.ChangeFields
							--select *
                     from DimUserInfo_Mod U
   --LEFT JOIN DimDepartment D ON
				LEFT JOIN Dimuserdeptgroup D ON
				   (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey)
				   and (u.EffectiveFromTimeKey<=@TimeKey AND u.EffectiveToTimeKey >=@TimeKey)
				   AND D.deptgroupid=U.DeptGroupCode
			   LEFT JOIN DimUserRole R ON
				   (R.EffectiveFromTimeKey<=@TimeKey AND R.EffectiveToTimeKey >=@TimeKey)
				   and (u.EffectiveFromTimeKey<=@TimeKey aND U.EffectiveToTimeKey >=@TimeKey)
				   AND R.UserRoleAlt_Key=U.UserRoleAlt_Key
			LEFT JOIN 	 (select ParameterAlt_Key ,
			 ParameterName 
			 ,'DimUserDesignation' as TableName
			 from DimParameter
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimUserDesignation') Z
			  ON Z.ParameterAlt_Key=U.DesignationAlt_Key  

					 WHERE ( U.UserLoginID like CASE WHEN @UserLoginID<>'' THEN '%' + @UserLoginID + '%' ELSE U.UserLoginID END)
								AND 
								(ISNULL(U.UserName,'') LIKE CASE WHEN @UserName<>'' THEN '%'+@UserName+'%' ELSE ISNULL(U.UserName,'') END)
								AND (SUBSTRING(ISNULL(U.MobileNo,''),1,10) LIKE CASE WHEN @MobileNo <> '' Then '%' + @MobileNo +'%' ELSE SUBSTRING(ISNULL(U.MobileNo,''),1,10) END )
								AND (ISNULL(U.Extension,'') LIKE CASE WHEN @ExtensionNo<>'' THEN '%'+@ExtensionNo+'%' ELSE ISNULL(U.Extension,'') END)-- updated by vinit
							--	AND (SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,''))) LIKE CASE WHEN @ExtensionNo <> '' Then '%' + @ExtensionNo +'%' ELSE SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,''))) END )
								
								--AND (ISNULL(D.deptgroupid,'') IN (SELECT Dept_ALTKEY FROM #Dept_ALTKEY))
								-------LIKE CASE WHEN @UserDepartment <> '' THEN '%' + @UserDepartment + '%' ELSE ISNULL(D.DepartmentCode,'') END)
								--AND (U.DepartmentId= CASE WHEN  @UserDepartment <> '' THEN @UserDepartment else u.DepartmentId END) --updated by vinit
								AND (U.UserRoleAlt_Key= CASE WHEN  @UserRole <> '' THEN @UserRole else U.UserRoleAlt_Key END)
								AND (ISNULL(U.Email_ID,'')LIKE CASE WHEN @Email_ID <> '' THEN '%' +  @Email_ID + '%' ELSE ISNUll(U.Email_ID,'') END)
								AND (ISNULL(U.IsChecker,'')LIKE CASE WHEN @IsChecker <> '' THEN @IsChecker ELSE U.IsChecker END)
								--AND (ISNULL(U.IsChecker2,'')LIKE CASE WHEN @IsChecker2 <> '' THEN @IsChecker2 ELSE U.IsChecker2 END)
								AND (ISNULL(U.Activate,'')LIKE CASE WHEN @IsActive <> '' THEN @IsActive ELSE U.Activate END)
								----AND U.UserLoginID= CASE WHEN  @ApplicableSOLID <> '' THEN I.UserLoginId else U.UserLoginID  end
								--AND (ISNULL(DB.BACID,'') IN (SELECT BACID FROM #BACID))
		AND U.UserLoginID<>@LoginID AND
					 U.EffectiveFromTimeKey <= @TimeKey
                           AND U.EffectiveToTimeKey >= @TimeKey
                          
					     

                                  AND ISNULL(U.AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                           AND U.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserInfo_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                         GROUP BY EntityKey
                     )
                 ) A 
                      
                 
                 GROUP BY A.UserLoginID,
							A.UserName,
							A.UserRole,
							A.RoleDescription,
							A.DepartmentId,
							A.DeptGroupCode,
							A.UserDepartment,
							A.ApplicableSOLID,
							A.ApplicableBACID,
							A.Email_ID,
							A.MobileNo,
							A.ExtensionNo,
							A.MobileNo1,
							A.IsChecker,
							A.IsChecker2,
							A.IsActive, 
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
							A.ModAppDate,							
							A.DesignationAlt_Key,
							A.Designation ,
							A.ChangeFields

                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY UserLoginID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, *
                            --'QuickSearchTable' TableName,  
                     FROM
                     (
                         SELECT *
                         FROM #temp A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 --Order By DataPointOwner.DateCreated Desc
				 Order By  DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize);
             END;
             ELSE

			 /*  IT IS Used For GRID Search which are Pending for Authorization    */
			 IF(@OperationFlag  in (16,17))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp16') IS NOT NULL
                 DROP TABLE #temp16;
                 SELECT 	A.UserLoginID,
							A.UserName,
							A.UserRole,
							A.RoleDescription,
							A.DepartmentId,
							A.DeptGroupCode,
							A.UserDepartment,
							A.ApplicableSOLID,
							A.ApplicableBACID,
							A.Email_ID,
							A.MobileNo,
							A.ExtensionNo,
							A.MobileNo1,
							A.IsChecker,
							A.IsChecker2,
							A.IsActive, 
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
							A.ModAppDate,
							A.DesignationAlt_Key,
							A.Designation ,
							A.ChangeFields
                 INTO #temp16
                 FROM 
                 (
                        SELECT  
						   DISTINCT 
							U.UserLoginID
						   ,U.UserName
						   ,U.UserRoleAlt_Key as UserRole
						   ,R.RoleDescription 
						   ,U.DepartmentId
						   ,U.DeptGroupCode
						   ,D.DeptGroupCode AS UserDepartment
						   ,Case---- when D.DepartmentCode='BBOG' THEN @ApplicableSolidForBBOG  
								WHEN D.DeptGroupCode='FNA' THEN 'ALL SOL ID' ELSE  U.ApplicableSolIds END AS ApplicableSOLID
						   ----,'' AS ApplicableSOLID
						   ,Case ----when D.DepartmentCode='BBOG' THEN 'ALL BACID OF BBOG DEPARTMENT' 
						   WHEN D.DeptGroupCode='FNA' THEN 'ALL BACID'  ELSE U.ApplicableBACID END ApplicableBACID
						   ,U.Email_ID
						   ,U.MobileNo as MobileNo
						   --,SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,'')))  ExtensionNo
						   --,'' as ExtensionNo --update by vinit
						   ,U.Extension as ExtensionNo
						   ,U.MobileNo as MobileNo1
						   ,U.IsChecker
						   ,U.IsChecker2
						   ,U.Activate AS IsActive
						   --,'QuickSearchTable' as TableName 
							,isnull(U.AuthorisationStatus, 'A') AuthorisationStatus, 
                            U.EffectiveFromTimeKey, 
                            U.EffectiveToTimeKey, 
                            U.CreatedBy, 
                            U.DateCreated, 
                            U.ApprovedBy, 
                            U.DateApproved, 
                            U.ModifyBy, 
                            U.DateModified
							,IsNull(U.ModifyBy,U.CreatedBy)as CrModBy
							,IsNull(U.DateModified,U.DateCreated)as CrModDate
							,ISNULL(U.ApprovedBy,U.ApprovedByFirstLevel) as CrAppBy
							,ISNULL(U.DateApproved,U.DateApprovedFirstLevel) as CrAppDate
							,ISNULL(U.ApprovedBy,U.ModifyBy) as ModAppBy
							,ISNULL(U.DateApproved,U.DateModified) as ModAppDate
							,U.DesignationAlt_Key
                            ,Z.ParameterName as Designation 
							,U.ChangeFields 
							--select *
                            from DimUserInfo_Mod U
                          --LEFT JOIN DimDepartment D ON
				            LEFT JOIN Dimuserdeptgroup D ON
				             (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey)
				             and (u.EffectiveFromTimeKey<=@TimeKey AND u.EffectiveToTimeKey >=@TimeKey)
				            AND D.deptgroupid=U.DeptGroupCode
			               LEFT JOIN DimUserRole R ON
				   (R.EffectiveFromTimeKey<=@TimeKey AND R.EffectiveToTimeKey >=@TimeKey)
				   and (u.EffectiveFromTimeKey<=@TimeKey aND U.EffectiveToTimeKey >=@TimeKey)
				   AND R.UserRoleAlt_Key=U.UserRoleAlt_Key
				
		LEFT JOIN 	 (select ParameterAlt_Key ,
			 ParameterName 
			 ,'DimUserDesignation' as TableName
			 from DimParameter
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimUserDesignation') Z
			  ON Z.ParameterAlt_Key=U.DesignationAlt_Key	 

					 WHERE ( U.UserLoginID like CASE WHEN @UserLoginID<>'' THEN '%' + @UserLoginID + '%' ELSE U.UserLoginID END)
								AND 
								(ISNULL(U.UserName,'') LIKE CASE WHEN @UserName<>'' THEN '%'+@UserName+'%' ELSE ISNULL(U.UserName,'') END)
								AND (SUBSTRING(ISNULL(U.MobileNo,''),1,10) LIKE CASE WHEN @MobileNo <> '' Then '%' + @MobileNo +'%' ELSE SUBSTRING(ISNULL(U.MobileNo,''),1,10) END )
								AND (ISNULL(U.Extension,'') LIKE CASE WHEN @ExtensionNo<>'' THEN '%'+@ExtensionNo+'%' ELSE ISNULL(U.Extension,'') END) --updated by vinit
								--AND (SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,''))) LIKE CASE WHEN @ExtensionNo <> '' Then '%' + @ExtensionNo +'%' ELSE SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,''))) END )
								
								AND (ISNULL(D.deptgroupid,'') IN (SELECT Dept_ALTKEY FROM #Dept_ALTKEY))
								-------LIKE CASE WHEN @UserDepartment <> '' THEN '%' + @UserDepartment + '%' ELSE ISNULL(D.DepartmentCode,'') END)
								--AND (U.DepartmentId= CASE WHEN  @UserDepartment <> '' THEN @UserDepartment else u.DepartmentId END) --updated by vinit
								AND (U.UserRoleAlt_Key= CASE WHEN  @UserRole <> '' THEN @UserRole else U.UserRoleAlt_Key END)
								AND (ISNULL(U.Email_ID,'')LIKE CASE WHEN @Email_ID <> '' THEN '%' +  @Email_ID + '%' ELSE ISNUll(U.Email_ID,'') END)
								AND (ISNULL(U.IsChecker,'')LIKE CASE WHEN @IsChecker <> '' THEN @IsChecker ELSE U.IsChecker END)
								--AND (ISNULL(U.IsChecker2,'')LIKE CASE WHEN @IsChecker2 <> '' THEN @IsChecker2 ELSE U.IsChecker2 END)
								AND (ISNULL(U.Activate,'')LIKE CASE WHEN @IsActive <> '' THEN @IsActive ELSE U.Activate END)
								----AND U.UserLoginID= CASE WHEN  @ApplicableSOLID <> '' THEN I.UserLoginId else U.UserLoginID  end
								--AND (ISNULL(DB.BACID,'') IN (SELECT BACID FROM #BACID))
		                        AND U.UserLoginID<>@LoginID 
								AND U.EffectiveFromTimeKey <= @TimeKey
                                AND U.EffectiveToTimeKey >= @TimeKey 
                                AND ISNULL(U.AuthorisationStatus, 'A') IN ('NP', 'MP', 'DP', 'RM')
                                AND U.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserInfo_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM')
                         GROUP BY EntityKey
                     )
                 ) A  
                 GROUP BY 	A.UserLoginID,
							A.UserName,
							A.UserRole,
							A.RoleDescription,
							A.DepartmentId,
							A.DeptGroupCode,
							A.UserDepartment,
							A.ApplicableSOLID,
							A.ApplicableBACID,
							A.Email_ID,
							A.MobileNo,
							A.ExtensionNo,
							A.MobileNo1,
							A.IsChecker,
							A.IsChecker2,
							A.IsActive, 
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
							A.ModAppDate,
							A.DesignationAlt_Key,
							A.Designation ,
							A.ChangeFields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY UserLoginID) AS RowNumber, 
                            COUNT(*) OVER() AS TotalCount, *
                            --'QuickSearchTable' TableName,  
                     FROM
                     (
                         SELECT *
                         FROM #temp16 A
                         --WHERE ISNULL(BankCode, '') LIKE '%'+@BankShortName+'%'
                         --      AND ISNULL(BankName, '') LIKE '%'+@BankName+'%'
                     ) AS DataPointOwner
                 ) AS DataPointOwner
				 --Order By DataPointOwner.DateCreated Desc
				 Order By  DateCreated Desc
                 --WHERE RowNumber >= ((@PageNo - 1) * @PageSize) + 1
                 --      AND RowNumber <= (@PageNo * @PageSize) 
   END;

   IF(@OperationFlag  in (20))

             BEGIN
			 IF OBJECT_ID('TempDB..#temp20') IS NOT NULL
                 DROP TABLE #temp20;
                 SELECT 	A.UserLoginID,
							A.UserName,
							A.UserRole,
							A.RoleDescription,
							A.DepartmentId,
							A.DeptGroupCode,
							A.UserDepartment,
							A.ApplicableSOLID,
							A.ApplicableBACID,
							A.Email_ID,
							A.MobileNo,
							A.ExtensionNo,
							A.MobileNo1,
							A.IsChecker,
							A.IsChecker2,
							A.IsActive, 
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
							A.ModAppDate,
							A.DesignationAlt_Key,
							A.Designation ,
							A.ChangeFields
                 INTO #temp20
                 FROM 
                 (
                        SELECT  
						   DISTINCT 
							U.UserLoginID
							,U.UserName
						   ,U.UserRoleAlt_Key as UserRole
						   ,R.RoleDescription 
						   ,U.DepartmentId
						   ,U.DeptGroupCode
						   ,D.DeptGroupCode AS UserDepartment
						   ,Case---- when D.DepartmentCode='BBOG' THEN @ApplicableSolidForBBOG  
								WHEN D.DeptGroupCode='FNA' THEN 'ALL SOL ID' ELSE  U.ApplicableSolIds END AS ApplicableSOLID
						   ----,'' AS ApplicableSOLID
						   ,Case ----when D.DepartmentCode='BBOG' THEN 'ALL BACID OF BBOG DEPARTMENT' 
						   WHEN D.DeptGroupCode='FNA' THEN 'ALL BACID'  ELSE U.ApplicableBACID END ApplicableBACID
						   ,U.Email_ID
						   ,U.MobileNo as MobileNo
						   --,SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,'')))  ExtensionNo
						   ,'' as ExtensionNo
						   ,U.MobileNo as MobileNo1
						   ,U.IsChecker
						   ,U.IsChecker2
						   ,U.Activate AS IsActive
						   --,'QuickSearchTable' as TableName 
							--,isnull(U.AuthorisationStatus, 'A') AuthorisationStatus, 
							,U.AuthorisationStatus AuthorisationStatus, 
                            U.EffectiveFromTimeKey, 
                            U.EffectiveToTimeKey, 
                            U.CreatedBy, 
                            U.DateCreated, 
                            U.ApprovedBy, 
                            U.DateApproved, 
                            U.ModifyBy, 
                            U.DateModified
							,IsNull(U.ModifyBy,U.CreatedBy)as CrModBy
							,IsNull(U.DateModified,U.DateCreated)as CrModDate
							,ISNULL(U.ApprovedBy,U.ApprovedByFirstLevel) as CrAppBy
							,ISNULL(U.DateApproved,U.DateApprovedFirstLevel) as CrAppDate
							,ISNULL(U.ApprovedBy,U.ModifyBy) as ModAppBy
							,ISNULL(U.DateApproved,U.DateModified) as ModAppDate
							,U.DesignationAlt_Key
                            ,Z.ParameterName as Designation  
							,U.ChangeFields
							--select *
                     from DimUserInfo_Mod U
   --LEFT JOIN DimDepartment D ON
				LEFT JOIN Dimuserdeptgroup D ON
				   (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey)
				   and (u.EffectiveFromTimeKey<=@TimeKey AND u.EffectiveToTimeKey >=@TimeKey)
				   AND D.deptgroupid=U.DeptGroupCode
			   LEFT JOIN DimUserRole R ON
				   (R.EffectiveFromTimeKey<=@TimeKey AND R.EffectiveToTimeKey >=@TimeKey)
				   and (u.EffectiveFromTimeKey<=@TimeKey aND U.EffectiveToTimeKey >=@TimeKey)
				   AND R.UserRoleAlt_Key=U.UserRoleAlt_Key
			LEFT JOIN 	 (select ParameterAlt_Key ,
			 ParameterName 
			 ,'DimUserDesignation' as TableName
			 from DimParameter
			 where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
			  DimParameterName	= 'DimUserDesignation') Z
			  ON Z.ParameterAlt_Key=U.DesignationAlt_Key
				
					 WHERE ( U.UserLoginID like CASE WHEN @UserLoginID<>'' THEN '%' + @UserLoginID + '%' ELSE U.UserLoginID END)
								AND 
								(ISNULL(U.UserName,'') LIKE CASE WHEN @UserName<>'' THEN '%'+@UserName+'%' ELSE ISNULL(U.UserName,'') END)
								AND (SUBSTRING(ISNULL(U.MobileNo,''),1,10) LIKE CASE WHEN @MobileNo <> '' Then '%' + @MobileNo +'%' ELSE SUBSTRING(ISNULL(U.MobileNo,''),1,10) END )
								AND (ISNULL(U.Extension,'') LIKE CASE WHEN @ExtensionNo<>'' THEN '%'+@ExtensionNo+'%' ELSE ISNULL(U.Extension,'') END) --updated by vinit
								--AND (SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,''))) LIKE CASE WHEN @ExtensionNo <> '' Then '%' + @ExtensionNo +'%' ELSE SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,''))) END )
								--select * from Dimuserdeptgroup
								--AND (ISNULL(D.deptgroupid,'') IN (SELECT Dept_ALTKEY FROM #Dept_ALTKEY))
								-------LIKE CASE WHEN @UserDepartment <> '' THEN '%' + @UserDepartment + '%' ELSE ISNULL(D.DepartmentCode,'') END)
								--AND (U.DepartmentId= CASE WHEN  @UserDepartment <> '' THEN @UserDepartment else u.DepartmentId END) --updated by vinit
								AND (U.UserRoleAlt_Key= CASE WHEN  @UserRole <> '' THEN @UserRole else U.UserRoleAlt_Key END)
								AND (ISNULL(U.Email_ID,'')LIKE CASE WHEN @Email_ID <> '' THEN '%' +  @Email_ID + '%' ELSE ISNUll(U.Email_ID,'') END)
								AND (ISNULL(U.IsChecker,'')LIKE CASE WHEN @IsChecker <> '' THEN @IsChecker ELSE U.IsChecker END)
								--AND (ISNULL(U.IsChecker2,'')LIKE CASE WHEN @IsChecker2 <> '' THEN @IsChecker2 ELSE U.IsChecker2 END)
								AND (ISNULL(U.Activate,'')LIKE CASE WHEN @IsActive <> '' THEN @IsActive ELSE U.Activate END)
								----AND U.UserLoginID= CASE WHEN  @ApplicableSOLID <> '' THEN I.UserLoginId else U.UserLoginID  end
								--AND (ISNULL(DB.BACID,'') IN (SELECT BACID FROM #BACID))
		                         AND U.UserLoginID<>@LoginID AND  U.EffectiveFromTimeKey <= @TimeKey
                                 AND U.EffectiveToTimeKey >= @TimeKey  
                                 AND ISNULL(U.AuthorisationStatus, 'A') IN('1A')
                                 AND U.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimUserInfo_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND ISNULL(AuthorisationStatus, 'A') IN('1A')
                         GROUP BY EntityKey
                     )
                 ) A  
                 
                 GROUP BY 	A.UserLoginID,
							A.UserName,
							A.UserRole,
							A.RoleDescription,
							A.DepartmentId,
							A.DeptGroupCode,
							A.UserDepartment,
							A.ApplicableSOLID,
							A.ApplicableBACID,
							A.Email_ID,
							A.MobileNo,
							A.ExtensionNo,
							A.MobileNo1,
							A.IsChecker,
							A.IsChecker2,
							A.IsActive,
							
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
							A.ModAppDate,
							A.DesignationAlt_Key,
							A.Designation ,
							A.ChangeFields
                 SELECT *
                 FROM
                 (
                     SELECT ROW_NUMBER() OVER(ORDER BY UserLoginID) AS RowNumber, 
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
				-- Order By DataPointOwner.DateCreated Desc
				Order By  DateCreated Desc
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