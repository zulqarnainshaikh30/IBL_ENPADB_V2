SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[ValidateExcel_Upload] 
	--@XmlData XML=''  
	--,@MenuID INT=NULL  
 --   ,@TimeKey int   
 --   ,@Result int=0 output    
		@TypeOfUpload VARCHAR(30) ='' 
     , @XmlData XML=''                      
     ,@OperationFlag  INT=1       
     ,@D2Ktimestamp INT=0 OUTPUT      
     ,@AuthMode char(2) = null                                          
     ,@MenuID INT=NULL  
     ,@TimeKey int  =0 
	 ,@UserLoginId varchar(20)='hradmin'
     ,@Result int=0 output                    
AS 
--DECLARE 
--	@TypeOfUpload VARCHAR(30) ='NULL' 
--     , @XmlData XML='<DataSet><GridData><SrNo>2</SrNo><UserID>RAGL</UserID><UserName>RAGL</UserName><UserRole>operator</UserRole><UserDepartment>RAGL</UserDepartment><ApplicableBACID>2300195,2300196,2300197,2300198,23001AC,23001AE,23001AG,23001AH</ApplicableBACID><UserEmailId>PPPPPPPP@axisbank.com</UserEmailId><UserMobileNumber>9833333333</UserMobileNumber><UserExtensionNumber>777</UserExtensionNumber><IsCheckerYN>y</IsCheckerYN><IsActiveYN>y</IsActiveYN><ActionAU>a</ActionAU></GridData></DataSet>'     

       
--     ,@OperationFlag  INT=1       
--     ,@AuthMode char(2) = 'N'                                          
--     ,@MenuID INT=58  
--     ,@TimeKey int  =24957 
--	 ,@UserLoginId varchar(20)='fnasuperadmin'
                  
BEGIN

  DECLARE @APPBACIDS VARCHAR(MAX) 

  IF OBJECT_ID('tempdb..#OAOLMasterUploadData') IS NOT NULL  
  BEGIN  
   DROP TABLE #OAOLMasterUploadData  
  END  
   
  CREATE TABLE #OAOLMasterUploadData   
  (  
   SR_No  SMALLINT  
   
   ,ColumnName VARCHAR(50)  
   ,ErrorData VARCHAR(100)  
   ,ErrorType VARCHAR(100)  
   ,UserId Varchar(100)
   ,EntityId int identity(1,1)
  )   
  
  IF ISNULL(@TimeKey,0)=0
	 BEGIN
	   Select @TimeKey=Timekey from SysDayMatrix where [Date]=Cast(getdate() as date)
  END


	-- Select @Timekey=Max(Timekey) from SysProcessingCycle
	--where Extracted='Y' and ProcessType='Full' and PreMOC_CycleFrozenDate IS NULL

	PRINT @TimeKey 

	  DECLARE @DepartmentCode VARCHAR(50),
	  @DepartmentAlt_Key int ,
	  @UserRole int
	SELECT 
			@DepartmentCode = DEP.DeptGroupCode,
			@DepartmentAlt_Key=DEP.DeptGroupId,
			@UserRole=UserRoleAlt_Key 
	FROM DimUserInfo INFO
	--INNER JOIN DimDepartment	DEP   --select * from DimUserDeptGroup --update DimUserDeptGroup set EffectiveToTimeKey =25999 where DeptGroupCode='FNA_1'
	INNER JOIN DimUserDeptGroup  DEP
		ON INFO.EffectiveFromTimeKey <= @Timekey AND INFO.EffectiveToTimeKey >= @Timekey
		AND DEP.EffectiveFromTimeKey <= @Timekey AND DEP.EffectiveToTimeKey >= @Timekey
		AND UserLoginID = @UserLoginId
		AND INFO.DepartmentId = DEP.DeptGroupId

		print @DepartmentCode
  IF @MenuID=58
  BEGIN
      IF OBJECT_ID('TEMPDB..#UserMasterUploadData')IS NOT NULL
			DROP TABLE #UserMasterUploadData 
	 SELECT 
				
				c.value('./SrNo[1]','int')SrNo
				--c.value('./SrNo[1]','varchar(max)')SrNo
				,c.value('./UserID[1]','varchar(max)' )UserID  
				,c.value('./UserName[1]','varchar(max)')UserName
				,c.value('./UserRole[1]','varchar(max)')UserRole
				,c.value('./Designation[1]','varchar(max)')Designation
				,c.value('./UserDepartment[1]','nvarchar(510)')UserDepartment				
				--,c.value('./ApplicableSolID[1]','varchar(max)')ApplicableSolID
				--,c.value('./ApplicableBACID[1]','varchar(max)')ApplicableBACID
				,c.value('./UserEmailId[1]','varchar(max)')UserEmailId
				,c.value('./UserMobileNumber[1]','varchar(max)')UserMobileNumber
				,c.value('./UserExtensionNumber [1]','varchar(max)')UserExtensionNumber
				,c.value('./IsCheckerYN[1]','varchar(max)')IsChecker
				,c.value('./IsChecker2YN[1]','varchar(max)')IsChecker2 ---Added By Sachin
				,c.value('./IsActiveYN [1]','varchar(max)')IsActive
				,c.value('./ActionAU[1]','varchar(max)')Perform						
				
				INTO #UserMasterUploadData
				FROM @XmlData.nodes('/DataSet/GridData') AS t(c)







	INSERT INTO #OAOLMasterUploadData    
    SELECT    SrNo  
     -- ,RowNo  
      ,'Sr No' ColumnName  
      ,NULL ErrorData  
      ,'Please enter serial no ' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  	 
		WHERE ISNULL(T.SrNo,0)=0

		  INSERT INTO #OAOLMasterUploadData 
	   Select
		Distinct   SrNo  
		 -- ,RowNo  
		  ,'SrNo' ColumnName  
		  ,T.SrNo ErrorData  
		  ,'Duplicate SrNo in Upload Sheet' ErrorType  
		  ,T.SrNo
		FROM #UserMasterUploadData T  
		WHERE T.SrNo IN 
		(
		   Select SrNo from #UserMasterUploadData
		   group by SrNo
		   having COUNT(SrNo) > 1

		) 



	INSERT INTO #OAOLMasterUploadData    
    SELECT    
	SrNo  
    -- ,RowNo  
    ,'User ID' ColumnName  
    ,NULL ErrorData  
    ,'is Mandatory Field' ErrorType  
	,T.UserID
    FROM #UserMasterUploadData T  WHERE ISNULL(T.UserID,'')=''  ---------UPDATE BY VINIT


	UNION
	 SELECT    SrNo  
     -- ,RowNo  
      ,'User Name' ColumnName  
      ,NULL ErrorData  
      ,'is Mandatory Field' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  	 
		WHERE ISNULL(T.UserName,'')=''
    UNION
	SELECT    SrNo  
     -- ,RowNo  
      ,'User Role' ColumnName  
      ,NULL ErrorData  
      ,'is Mandatory Field' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  	 
		WHERE ISNULL(T.UserRole,'')=''
----------------------------------------------------
		 UNION
	SELECT    SrNo  
     -- ,RowNo  
      ,'Designation' ColumnName  
      ,NULL ErrorData  
      ,'is Mandatory Field' ErrorType  
	  ,T.Designation
    FROM #UserMasterUploadData T  	 
		WHERE ISNULL(T.Designation,'')=''
-----------------------------------------------------
	UNION
	SELECT  SrNo  
     -- ,RowNo  
      ,'User Department' ColumnName  
      ,NULL ErrorData  
      ,'is Mandatory Field' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  	 
		WHERE ISNULL(T.UserDepartment,'')=''
	----UNION                           COMMENTED BY DIPTI
	----SELECT  SrNo  
 ----    -- ,RowNo  
 ----     ,'Applicable Sol ID' ColumnName  
 ----     ,NULL ErrorData  
 ----     ,'is Mandatory Field For Departments other than  FNA AND BBOG' ErrorType  
	----  ,T.UserID
 ----   FROM #UserMasterUploadData T  	 
	----	WHERE ISNULL(T.ApplicableBACID,'')=''
	----	AND T.UserDepartment NOT IN ('FNA','BBOG')
	--UNION
	--SELECT  SrNo  
 --    -- ,RowNo  
 --     ,'Applicable BAC ID' ColumnName  
 --     ,NULL ErrorData  
 --     ,'is Mandatory Field For Departments other than  FNA,BBOG' ErrorType  
	--  ,T.UserID
 --   FROM #UserMasterUploadData T  	 
	--	WHERE ISNULL(T.ApplicableBACID,'')=''
	--	AND T.UserDepartment NOT IN ('FNA','BBOG')

	---uncomment by vinit----
	--UNION
	--SELECT  SrNo  
 --    -- ,RowNo  
 --     ,'User Email Id' ColumnName  
 --     ,NULL ErrorData  
 --     ,'is Mandatory Field' ErrorType  
	--  ,T.UserID
 --   FROM #UserMasterUploadData T  	 
	--	WHERE ISNULL(T.UserEmailId,'')=''

	UNION
	SELECT  SrNo  
     -- ,RowNo  
      ,'User Email Id' ColumnName  
      ,NULL ErrorData  
      ,'is Mandatory Field' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  	 
		WHERE ISNULL(T.UserEmailId,'')=''
	UNION
	SELECT  SrNo  
 --    -- ,RowNo  
   ,'User Mobile Number' ColumnName  
     ,NULL ErrorData  
     ,'is Mandatory Field' ErrorType  
   ,T.UserID
    FROM #UserMasterUploadData T  	 
	 	WHERE ISNULL(T.UserMobileNumber,'')=''
	--UNION
	--SELECT  SrNo  
 --    -- ,RowNo  
 --     ,'User Extension Number' ColumnName  
 --     ,NULL ErrorData  
 --     ,'is Mandatory Field' ErrorType 
	--  ,T.UserID 
 --   FROM #UserMasterUploadData T  	 
	--	WHERE ISNULL(T.UserExtensionNumber,'')=''
 --   UNION
	--SELECT  SrNo  
 --    -- ,RowNo  
 --     ,'Is Checker' ColumnName  
 --     ,NULL ErrorData  
 --     ,'is Mandatory Field' ErrorType  
	--  ,T.UserID
 --   FROM #UserMasterUploadData T  	 
	--	WHERE ISNULL(T.IsChecker,'')=''
	--Added By Sachin
	--UNION
	--SELECT  SrNo  
 --    -- ,RowNo  
 --     ,'Is Checker' ColumnName  
 --     ,NULL ErrorData  
 --     ,'is Mandatory Field' ErrorType  
	--  ,T.UserID
 --   FROM #UserMasterUploadData T  	 
	--	WHERE ISNULL(T.IsChecker2 ,'')=''
	--Till Here
	UNION
	SELECT  SrNo  
     -- ,RowNo  
      ,'Is Active' ColumnName  
      ,NULL ErrorData  
      ,'is Mandatory Field' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  	 
		WHERE ISNULL(T.IsActive,'')=''
	UNION
	SELECT  SrNo  
     -- ,RowNo  
      ,'Is Active' ColumnName  
      ,NULL ErrorData  
      ,'is Mandatory Field' ErrorType
	  ,T.UserID  
    FROM #UserMasterUploadData T  	 
		WHERE ISNULL(T.IsActive,'')=''
	UNION
	SELECT  SrNo  
     -- ,RowNo  
      ,'Perform' ColumnName  
      ,NULL ErrorData  
      ,'is Mandatory Field' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  	 
		WHERE ISNULL(T.Perform,'')=''
    
PRINT 'SNEHAL'


	IF EXISTS(Select 1 from #OAOLMasterUploadData)
	BEGIN
	 print '11'
	 --GOTO RETURNDATA
	
	END 


	IF EXISTS (Select
				1
				FROM #UserMasterUploadData T  
				WHERE T.UserID IN 
				(
				   Select UserID from #UserMasterUploadData
				   group by UserID
				   having COUNT(UserId) > 1 
				)
				UNION
				Select
				1
				FROM #UserMasterUploadData T  
				WHERE T.UserMobileNumber IN 
				(
				   Select UserMobileNumber from #UserMasterUploadData
				   group by UserMobileNumber
				   having COUNT(UserMobileNumber) > 1

				) AND ISNULL(T.UserMobileNumber,'') <> ''
				UNION
				Select
				1
				FROM #UserMasterUploadData T  
				WHERE T.UserExtensionNumber IN 
				(
				   Select UserExtensionNumber from #UserMasterUploadData
				   group by UserExtensionNumber,UserMobileNumber      -----------------Adde by Kapil on 11/01/2024 
				   having COUNT(UserExtensionNumber) > 1

				) 
				AND ISNULL(T.UserExtensionNumber,'') <> ''-- updated by vinit
				
				UNION
				Select
				1
				FROM #UserMasterUploadData T  
				WHERE T.UserEmailId IN 
				(
				   Select UserEmailId from #UserMasterUploadData
				   group by UserEmailId
				   having COUNT(UserEmailId) > 1

				) AND ISNULL(T.UserEmailId,'') <> ''

		)
	BEGIN
	  INSERT INTO #OAOLMasterUploadData 
	   Select
		Distinct   SrNo  
		 -- ,RowNo  
		  ,'User Id' ColumnName  
		  ,T.UserID ErrorData  
		  ,'Duplicate User Id In Upload Sheet' ErrorType  
		  ,T.UserID
		FROM #UserMasterUploadData T  
		WHERE T.UserID IN 
		(
		   Select UserID from #UserMasterUploadData
		   group by UserID
		   having COUNT(UserId) > 1

		) 
		UNION
		Select
		Distinct   SrNo  
		 -- ,RowNo  
		  ,'User Mobile No' ColumnName  
		  ,T.UserMobileNumber ErrorData  
		  ,'Duplicate User Mobile Number In Upload Sheet' ErrorType  
		  ,T.UserID
		FROM #UserMasterUploadData T  
		WHERE T.UserMobileNumber IN 
		(
		   Select UserMobileNumber from #UserMasterUploadData
		   group by UserMobileNumber
		   having COUNT(UserMobileNumber) > 1

		) AND ISNULL(T.UserMobileNumber,'') <> ''
		----------------Update By Vinit
		UNION
		Select
		Distinct   SrNo  
		 -- ,RowNo  
		  ,'User Email Id' ColumnName  
		  ,T.UserEmailId ErrorData  
		  ,'Duplicate User Email Id In Upload Sheet' ErrorType  
		  ,T.UserID
		FROM #UserMasterUploadData T  
		WHERE T.UserEmailId IN 
		(
		    Select UserEmailId from #UserMasterUploadData group by UserEmailId  
			having COUNT(UserEmailId) > 1  
		) AND ISNULL(T.UserEmailId,'') <> ''
------------------Update By Vinit

----------------Update By Vinit
		UNION
		Select
		Distinct   SrNo  
		 -- ,RowNo  
		  ,'Sr No' ColumnName  
		  --,T.SrNo ErrorData  
		  ,null ErrorData 
		  ,'Duplicate Sr No In Upload Sheet' ErrorType  
		  ,T.UserID
		FROM #UserMasterUploadData T  
		WHERE T.SrNo IN 
		(
		    Select SrNo from #UserMasterUploadData group by SrNo  having COUNT(SrNo) > 1  
		) 
		--AND ISNULL(T.SrNo,'') <> ''  --update by vinit
------------------Update By Vinit



		--UNION
		--		Select
		--		Distinct   SrNo  
		--		 -- ,RowNo  
		--		  ,'User Extension Number' ColumnName  
		--		  ,T.UserExtensionNumber ErrorData  
		--		  ,'Duplicate Extension Number In Upload Sheet' ErrorType  
		--		  ,T.UserID
		--		FROM #UserMasterUploadData T  
		--		WHERE T.UserExtensionNumber IN 
		--		(
		--		   Select UserExtensionNumber from #UserMasterUploadData
		--		   group by UserExtensionNumber
		--		   having COUNT(UserExtensionNumber) > 1

		--		) AND ISNULL(T.UserExtensionNumber,'') <> ''

-------------------------------------------------------------------
		--GOTO RETURNDATA
	END

	---- 
	IF OBJECT_ID('TEMPDB..#TempAlreadyExists') IS NOT NULL
	DROP TABLE #TempAlreadyExists

	SELECT 	* INTO #TempAlreadyExists
	FROM
   (
     
	 SELECT 
	 DISTINCT
	 SUBSTRING(ISNULL(U.MobileNo,''),1,10) as MobileNo
	 --,SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,'')))  ExtensionNo
	 --,SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,'')))  ExtensionNo
	 ,Extension ExtensionNo
	 ,U.Email_ID
	 ,U.UserLoginID
	 FROM DimUserInfo U
	 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey) And isnull(AuthorisationStatus,'A')='A'

	 Union  ---------------------------------Newly added by kapil for duplicate no not allowed. 11/01/2024
	 	 SELECT 
	 DISTINCT
	 SUBSTRING(ISNULL(U.MobileNo,''),1,10) as MobileNo
	 --,SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,'')))  ExtensionNo
	 --,SUBSTRING(ISNULL(U.MobileNo,''),12,LEN(ISNULL(U.MobileNo,'')))  ExtensionNo
	  ,Extension ExtensionNo
	 ,U.Email_ID
	 ,U.UserLoginID
	 FROM DimUserInfo_mod U
	 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey) And isnull(AuthorisationStatus,'')in('NP','MP''DP','D1','1A')
   ) K

     
	 ---INSERT INTO #OAOLMasterUploadData    
IF EXISTS
	  (	SELECT  
		1
		FROM #UserMasterUploadData T  
		inner join DimUserInfo ON T.UserID=DimUserInfo.UserLoginID	 
			WHERE ISNULL(T.UserID,'') <> ''
			AND ISNULL(T.Perform,'')='A'
	    UNION
		
		Select
		1
		FROM #UserMasterUploadData T  
		inner join #TempAlreadyExists E ON E.Email_ID=T.UserEmailId
		AND T.Perform='A'
		AND ISNULL(T.UserEmailId,'') <> ''

		UNION
		--INSERT INTO #OAOLMasterUploadData    
		Select
		1
		FROM #UserMasterUploadData T  
		inner join #TempAlreadyExists E ON E.Email_ID=T.UserEmailId
		AND T.UserID NOT IN (Select UserLoginID from #TempAlreadyExists)
		AND T.Perform='U'
		AND ISNULL(T.UserEmailId,'') <> ''
		UNION

		
		Select
		1
		FROM #UserMasterUploadData T  
		inner join #TempAlreadyExists E ON E.MobileNo=T.UserMobileNumber
		AND T.Perform='A'
		AND ISNULL(T.UserMobileNumber,'') <> ''
		UNION
		--INSERT INTO #OAOLMasterUploadData    
		Select
		1
		FROM #UserMasterUploadData T  
		inner join #TempAlreadyExists E ON E.MobileNo=T.UserMobileNumber
		AND T.UserID NOT IN (Select UserLoginID from #TempAlreadyExists)
		AND T.Perform='U'
		AND ISNULL(T.UserMobileNumber,'') <> ''
		UNION
		Select
		1
		FROM #UserMasterUploadData T  
		inner join #TempAlreadyExists E ON E.ExtensionNo=T.UserExtensionNumber
		AND T.Perform='A'
		AND ISNULL(T.UserExtensionNumber,'') <> ''
		UNION
		--INSERT INTO #OAOLMasterUploadData    
		Select
		1
		FROM #UserMasterUploadData T  
		inner join #TempAlreadyExists E ON E.ExtensionNo=T.UserExtensionNumber
		AND T.UserID NOT IN (Select UserLoginID from #TempAlreadyExists)
		AND T.Perform='U'
		AND ISNULL(T.UserExtensionNumber,'') <> ''
		)
		BEGIN
		  INSERT INTO #OAOLMasterUploadData
		  
		      
			  SELECT  
		  SrNo  
		 
		  ,'User  Id' ColumnName  
		  ,T.UserID ErrorData  
		  ,'User Id Already Exists' ErrorType  
		  ,T.UserID
		FROM #UserMasterUploadData T  
		inner join DimUserInfo ON T.UserID=DimUserInfo.UserLoginID	 
			WHERE ISNULL(T.UserID,'') <> ''
			AND ISNULL(T.Perform,'')='A'
	    UNION
		
		Select
		   SrNo   
		  ,'User Email Id' ColumnName  
		  ,T.UserEmailId ErrorData  
		  ,'User Email Id Already Exists' ErrorType  
		  ,T.UserID
		FROM #UserMasterUploadData T  
		inner join #TempAlreadyExists E ON E.Email_ID=T.UserEmailId
		AND T.Perform='A'
		AND ISNULL(T.UserEmailId,'') <> ''
		UNION
		
		Select
		   SrNo   
		  ,'User Email Id' ColumnName  
		  ,T.UserEmailId ErrorData  
		  ,'User Email Id Already Exists' ErrorType  
		  ,T.UserID
		FROM #UserMasterUploadData T  
		inner join #TempAlreadyExists E ON E.Email_ID=T.UserEmailId
		AND T.UserID NOT IN (Select UserLoginID from #TempAlreadyExists)
		AND T.Perform='U'
		AND ISNULL(T.UserEmailId,'') <> ''
		UNION 
		
		Select
		SrNo   
		  ,'User Mobile Number' ColumnName  
		  ,T.UserMobileNumber ErrorData  
		  ,'User Mobile Number Already Exists' ErrorType  
		  ,T.UserID
		FROM #UserMasterUploadData T  
		inner join #TempAlreadyExists E ON E.MobileNo=T.UserMobileNumber
		AND T.Perform='A'
		AND ISNULL(T.UserMobileNumber,'') <> ''
		UNION
		--INSERT INTO #OAOLMasterUploadData    
		Select
		  SrNo  
		 
		  ,'User Mobile Number' ColumnName  
		  ,T.UserMobileNumber ErrorData  
		  ,'User Mobile Number Already Exists' ErrorType  
		  ,T.UserID
		FROM #UserMasterUploadData T  
		inner join #TempAlreadyExists E ON E.MobileNo=T.UserMobileNumber
		AND T.UserID NOT IN (Select UserLoginID from #TempAlreadyExists)
		AND T.Perform='U'
		AND ISNULL(T.UserMobileNumber,'') <> ''
		--UNION
		--Select
		--SrNo  
		 
		--  ,'User Extension Number' ColumnName  
		--  ,T.UserExtensionNumber ErrorData  
		--  ,'User Extension Number Already Exists' ErrorType  
		--  ,T.UserID
		--FROM #UserMasterUploadData T  
		--inner join #TempAlreadyExists E ON E.ExtensionNo=T.UserExtensionNumber
		--AND T.Perform='A'
		--AND ISNULL(T.UserExtensionNumber,'') <> ''
		--UNION
		----INSERT INTO #OAOLMasterUploadData 
		--Select
		--SrNo  
		 
		--  ,'User Extension Number' ColumnName  
		--  ,T.UserExtensionNumber ErrorData  
		--  ,'User Extension Number Already Exists' ErrorType  
		--  ,T.UserID
		--FROM #UserMasterUploadData T  
		--inner join #TempAlreadyExists E ON E.ExtensionNo=T.UserExtensionNumber
		--AND T.UserID NOT IN (Select UserLoginID from #TempAlreadyExists)
		--AND T.Perform='U'
		--AND ISNULL(T.UserExtensionNumber,'') <> ''


		  

		 -- GOTO RETURNDATA 
		END
	-----
	-----

	---- Validations of UserId
	     
		
	    
		--select UserLoginID,* from DimUserInfo
		
	INSERT INTO #OAOLMasterUploadData    
	SELECT  SrNo  
     -- ,RowNo  
      ,'User ID' ColumnName  
      ,T.UserID ErrorData  
      ,'User Id Does not Exists' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	left join DimUserInfo ON T.UserID=DimUserInfo.UserLoginID	 
		WHERE ISNULL(T.UserID,'') <> ''
		AND ISNULL(T.Perform,'')='U'
		AND DimUserInfo.UserLoginID IS NULL  --- invalid user id entered


	----------------------------------------Added condition for (should not Accept UserId length less than 5 Characters) //08-07-2019
	INSERT INTO #OAOLMasterUploadData    
		Select
		Distinct  SrNo  
	     -- ,RowNo  
	      ,'User ID' ColumnName  
	      ,T.UserID ErrorData  
	      ,'Invalid User ID ,User ID should be greater than 3 Digits' ErrorType  
		  ,T.UserID
	    FROM #UserMasterUploadData T  
		where len(T.UserID) < 3
		AND ISNULL(T.UserID,'') <> ''
	-----

	--- Validations of User Role
	  INSERT INTO #OAOLMasterUploadData    
	SELECT  SrNo  
     -- ,RowNo  
      ,'User Role' ColumnName  
      ,T.UserRole ErrorData  
      ,CASE WHEN ISNULL(T.UserDepartment,'')='FNA ' THEN 'Invalid User Role,User Role Should be one of Super Admin, Admin, Operator, Viewer ' 
	        ELSE 'Invalid User Role,User Role Should be one of Admin, Operator, Viewer ' END
	  
	  ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	left join DimUserRole R ON R.RoleDescription=T.UserRole
	where R.UserRoleAlt_Key IS NULL 
	and ISNULL(T.UserRole,'')<>''       

	 	INSERT INTO #OAOLMasterUploadData    
	SELECT  SrNo  
     -- ,RowNo  
      ,'User Role' ColumnName  
      ,T.UserRole ErrorData  
      ,'Only Super Admin Can  Create Super Admin User' ErrorType
	  ,T.UserID  
    FROM #UserMasterUploadData T  
	inner join DimUserRole R ON R.RoleDescription=T.UserRole
	 and R.UserRoleAlt_Key=1
	 AND @UserRole <> 1

   INSERT INTO #OAOLMasterUploadData    
		SELECT  SrNo  
		 -- ,RowNo  
		  ,'User Department' ColumnName  
		  ,T.UserDepartment ErrorData  
		  ,'Invalid Department' ErrorType  
		  ,T.UserID
		FROM #UserMasterUploadData T  
		left join DimDepartment D ON D.DepartmentCode=T.UserDepartment
		and (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey)
		left join DimUserDeptGroup Df ON Df.DeptGroupCode=T.UserDepartment
		and (Df.EffectiveFromTimeKey<=@TimeKey AND Df.EffectiveToTimeKey>=@TimeKey)
		where Df.DeptGroupId IS NULL   ---Comment By Vinit 




-------------comment by vinit--------- 
	 -- INSERT INTO #OAOLMasterUploadData    
		--SELECT  SrNo  
		-- -- ,RowNo  
		--  ,'Designation' ColumnName  
		--  ,T.Designation ErrorData  
		--  ,'Invalid Designation' ErrorType  
		--  ,T.Designation
		--FROM #UserMasterUploadData T  
		
		--where --D.DeptGroupId IS NULL 
		--isnull(T.Designation,'') NOT IN  (select ParameterName from DimParameter  where DimParameterName = 'DimUserDesignation')
------------									

	-- INSERT INTO #OAOLMasterUploadData    
	----SELECT  SrNo  
 ----    -- ,RowNo  
 ----     ,'User Role' ColumnName  
 ----     ,T.UserRole ErrorData  
 ----     ,'Super Admin Role is Available only For FNA Department' ErrorType  
	----  ,T.UserID
 ----   FROM #UserMasterUploadData T  
	----inner join DimUserRole R ON R.RoleDescription=T.UserRole
	---- and R.UserRoleAlt_Key=1
	---- AND T.UserDepartment <> 'FNA'


	--------

	------ User Department
	   
	 --  INSERT INTO #OAOLMasterUploadData    
		--SELECT  SrNo  
		--  ,RowNo  
		--  ,'User Department' ColumnName  
		--  ,T.UserDepartment ErrorData  
		--  ,'Invalid Department' ErrorType  
		--  ,T.UserID
		--FROM #UserMasterUploadData T  
		--left join DimDepartment D ON D.DepartmentCode=T.UserDepartment
		--left join DimUserDeptGroup D ON D.DeptGroupCode=T.UserDepartment
		--and (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey)
		--where D.DeptGroupId IS NULL   ---Comment By Vinit 

----------update by Vinit---------select * from DimDepartment
	 --  IF @DepartmentCode <> 'FNA'
		--BEGIN
		--  INSERT INTO #OAOLMasterUploadData   
		-- SELECT  SrNo  
		--  -- ,RowNo  
		--   ,'User Department' ColumnName  
		--   ,T.UserDepartment ErrorData  
		--   ,'You can not  Create or Update Users of Other Department' ErrorType 
		--   ,T.UserID 
		-- FROM #UserMasterUploadData T  	 
		-- 	WHERE  T.UserDepartment  <> @DepartmentCode
		--	AND ISNULL(T.UserDepartment,'') <> ''
		-- END	

	----------
	---- Applicable Sol ID -----
	/****COMMENTED BY DIPTI ON 071119 AS APPLICABLE SOLID IS REMOVED**********************/
	
   ---- Applicable Sol Id
 ----        INSERT INTO #OAOLMasterUploadData   
	----SELECT  SrNo  
 ----    -- ,RowNo  
 ----     ,'Applicable Sol ID' ColumnName  
 ----     ,T.ApplicableBACID ErrorData  
 ----     ,'Should be blank For Department  FNA AND BBOG' ErrorType  
	----  ,T.UserID
 ----   FROM #UserMasterUploadData T  	 
	----	WHERE ISNULL(T.ApplicableBACID,'')<> ''
	----	AND T.UserDepartment  IN ('FNA','BBOG')

	----IF OBJECT_ID('TEMPDB..#TempDepartmentWiseSolIds')IS NOT NULL
	----		DROP TABLE #TempDepartmentWiseSolIds
	----Select * into #TempDepartmentWiseSolIds
	----from
	----(
	----    SELECT DepartmentAlt_Key,DepartmentCode,
	----	LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS BranchCode
	----	FROM
	----	(
	----	SELECT DepartmentAlt_Key,DepartmentCode,CAST('<XMLRoot><RowData>' + REPLACE(d.ApplicableBACID,',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
	----	FROM   DimDepartment D
	----	inner join #UserMasterUploadData U ON U.UserDepartment=D.DepartmentCode
	----    AND U.UserDepartment NOT IN ('BBOG','FNA')  --- Get only those department which are available in sheet
	----	where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
	----	AND DepartmentCode NOT IN ('FNA')
	----	)t
	----	CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)

	----)K  --- Department wise Sol Id allocated

	----IF OBJECT_ID('TEMPDB..#TempSelectedSolIdsUserWise')IS NOT NULL
	----		DROP TABLE #TempSelectedSolIdsUserWise
	----Select * into #TempSelectedSolIdsUserWise
	----from
	----(
	----    SELECT UserID,SrNo,
	----	LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS BranchCode
	----	FROM
	----	(
	----	SELECT UserID,SrNo,CAST('<XMLRoot><RowData>' + REPLACE(ApplicableBACID,',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
	----	FROM   #UserMasterUploadData
	----	where UserDepartment NOT IN ('BBOG','FNA')
	----	and ISNULL(ApplicableBACID,'') <> ''
		
	----	)t
	----	CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)

	----)K  ---- User wise sol id allocated 
	 


	----INSERT INTO #OAOLMasterUploadData    
	----SELECT Distinct  t.SrNo  
 ----    -- ,RowNo  
 ----     ,'Applicable Sol Id' ColumnName  
 ----     ,U.ApplicableBACID ErrorData  
 ----     ,'Applicable SOL id  is invalid' ErrorType  
	----  ,T.UserID
 ----   FROM #TempSelectedSolIdsUserWise T  
	----inner join #UserMasterUploadData U ON U.UserID=T.UserID
	---- AND U.UserDepartment NOT IN ('BBOG','FNA')
	----left join DimBranch D ON D.BranchCode=T.BranchCode
	----and (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey)
	----where D.BranchCode IS NULL --- invalid sol id Selected

	
	
	----INSERT INTO #OAOLMasterUploadData    
	----SELECT Distinct  t.SrNo  
 ----    -- ,RowNo  
 ----     ,'Applicable Sol ID' ColumnName  
 ----     ,U.ApplicableBACID ErrorData  
 ----     ,'Invalid Branch Code,Branch Code Should belong to Department' ErrorType  
	----  ,T.UserID
 ----   FROM #TempSelectedSolIdsUserWise T  
	----inner join #UserMasterUploadData U ON U.UserID=T.UserID
	---- AND U.UserDepartment NOT IN ('BBOG','FNA')
	----left join #TempDepartmentWiseSolIds D ON D.BranchCode=T.BranchCode
	----AND U.UserDepartment=D.DepartmentCode
	------and (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey)
	----where D.BranchCode IS NULL --- Sol id isnot one of Sols Selected in Department

 ----  -----
   ---- Applicabel BACID

   	

	
	

	


	
	
		
	
	--INSERT INTO #OAOLMasterUploadData   
	--SELECT  SrNo  
 --    -- ,RowNo  
 --     ,'Applicable BAC ID' ColumnName  
 --     ,T.ApplicableBACID ErrorData  
 --     ,'Should be blank For Department FNA' ErrorType  
	--  ,T.UserID
 --   FROM #UserMasterUploadData T  	 
	--	WHERE ISNULL(T.ApplicableBACID,'')<> ''
	--	AND T.UserDepartment  IN ('FNA')
	

	--IF OBJECT_ID('TEMPDB..#TempSelectedBACIDsUserWise')IS NOT NULL
	--		DROP TABLE #TempSelectedBACIDsUserWise
	--Select * into #TempSelectedBACIDsUserWise
	--from
	--(
	--    SELECT UserID,SrNo,
	--	LTRIM(RTRIM(m.n.value('.[1]','varchar(8000)'))) AS BACID
	--	FROM
	--	(
	--	SELECT UserID,SrNo,CAST('<XMLRoot><RowData>' + REPLACE(ApplicableBACID,',','</RowData><RowData>') + '</RowData></XMLRoot>' AS XML) AS x
	--	FROM   #UserMasterUploadData
	--	where 
	--	--UserDepartment NOT IN ('BBOG','FNA')
	--	UserDepartment NOT IN ('FNA')
	--	and ISNULL(ApplicableBACID,'') <> ''
		
	--	)t
	--	CROSS APPLY x.nodes('/XMLRoot/RowData')m(n)

	--)K

	--Select * from #TempSelectedBACIDsUserWise

	

	------SELECT * FROM #TempSelectedBACIDsUserWise
	------SELECT * FROM #OAOLMasterUploadData

	--INSERT INTO #OAOLMasterUploadData    
	--SELECT Distinct  t.SrNo  
 --    -- ,RowNo  
 --     ,'Applicable BAC ID' ColumnName  
 --     ,U.ApplicableBACID ErrorData  
 --     ,'One of BAC Id Entered Is not Available' ErrorType  
	--  ,T.UserID
	--  --,D.BACID
	--  --,T.BACID
 --   FROM #TempSelectedBACIDsUserWise T  
	--INNER JOIN #UserMasterUploadData U ON U.UserID=T.UserID
	-- --AND U.UserDepartment NOT IN ('BBOG','FNA')
	-- AND U.UserDepartment NOT IN ('FNA')
	--  AND ISNULL(U.ApplicableBACID,'') <> ''
	--LEFT JOIN DimOfficeAccountBACID D ON 
	--LTRIM(RTRIM(D.BACID)) =LTRIM (RTRIM(T.BACID))
	--AND 
	--(D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey>=@TimeKey)
	-------AND LTRIM(RTRIM(T.BACID))=LTRIM(RTRIM(D.BACID))
	
	--where D.BACID IS NULL --- invalid BAC id Selected


	--IF OBJECT_ID('TEMPDB..#TempDepartmentBACID')IS NOT NULL
	--		DROP TABLE #TempDepartmentBACID

	--Select * into #TempDepartmentBACID
	--from
	--(
	 --  Select
	 --     B.OAAlt_Key BACID-----OAALTKEY AS BACID
		-- ,B.DepartmentAlt_Key
		--,U.UserID
		----,B.BranchCode
	 --   from DimDepartmentBACID B
		--inner join #UserMasterUploadData U ON 
		----U.UserID=T.UserID
		----AND 
		--U.UserDepartment NOT IN ('BBOG','FNA')
		--AND ISNULL(U.ApplicableBACID,'') <> ''
	 --   --AND ISNULL(U.ApplicableSolID,'') <> ''
		--inner join DimDepartment D ON (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey)
	 --   AND U.UserDepartment=D.DepartmentCode -- Joins department with Users
		--AND B.DepartmentAlt_Key=D.DepartmentAlt_Key
		--AND (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey >=@TimeKey)

		  /***** FOR REMOVING DimDepartmentBACID TABLE *****/
		  -- SELECT  A.ApplicableBACID BACID,A.DepartmentAlt_Key,A.EffectiveFromTimeKey,A.EffectiveToTimeKey ,B.UserID
		  --  INTO #TempDepartmentBACID
		  -- FROM 
		  -- (
				--SELECT  Split.a.value('.', 'VARCHAR(MAX)') AS ApplicableBACID  ,DepartmentAlt_Key,DepartmentCode,EffectiveFromTimeKey,EffectiveToTimeKey
				--					FROM  (SELECT 
				--							CAST ('<M>' + REPLACE(ApplicableBACID, ',', '</M><M>') + '</M>' AS XML) AS ControlName
				--							,DepartmentAlt_Key,DepartmentCode,EffectiveFromTimeKey,EffectiveToTimeKey
				--							FROM DimDepartment
				--						) AS A CROSS APPLY ControlName.nodes ('/M') AS Split(a) 
			
		  -- )
		  -- A 
		  -- INNER JOIN #UserMasterUploadData B 
		  -- ON B.UserDepartment NOT IN ('FNA')
		  --  AND ISNULL(B.ApplicableBACID,'')<>''
		  -- AND B.UserDepartment=A.DepartmentCode
		  -- AND A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey
		  -- WHERE  EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey
		  
		  --------BACIDS NEEDS TO BE TAKEN FROM DEPARTMENT TABLE

	--) K  --- find BACID Allocated to Department 

	--Select  Items AS BACID INTO #TempDepartmentBACID 
	--from Split(@APPBACIDS,',')

	----Insert into #TempDepartmentBACID
	----(
	----  BACID

	----)
	----(
	----    Select
	----			OAAlt_Key
				
	----			from DimOfficeAccountBACID BAC
				
	----			where (BAC.EffectiveFromTimeKey<=@TimeKey AND BAC.EffectiveToTimeKey >=@TimeKey)
	----			AND ISNULL(BAC.AuthorisationStatus,'A')='A'
	----			AND ISNULL(BAC.BACIDscope,1)=1
	----)--- insert Bacid with generic type

	--Update #TempDepartmentBACID

	--SET #TempDepartmentBACID.DepartmentAlt_Key=K.DepartmentAlt_Key
	
	--from
	--(
	--  Select Distinct DepartmentAlt_Key from #TempDepartmentBACID
	--  WHERE DepartmentAlt_Key IS NOT NULL
	--)K
	--where #TempDepartmentBACID.DepartmentAlt_Key IS NULL  --- Update Department for Generic BAC ID

	--Update #TempDepartmentBACID

	--SET #TempDepartmentBACID.UserID=K.UserID
	
	--from
	--(
	--  Select Distinct UserID from #TempDepartmentBACID
	--  WHERE UserID IS NOT NULL
	--)K
	--where #TempDepartmentBACID.UserID IS NULL  --- Update UserId for Generic BAC ID

	--SELECT * FROM #TempSelectedBACIDsUserWise
	--SELECT * FROM #UserMasterUploadData
	--SELECT * FROM #TempDepartmentBACID

	--Insert into #OAOLMasterUploadData
	
	--Select
	-- U.SrNo
	-- ,'Applicable BAC ID'
	--,U.ApplicableBACID
	--,'Invalid BACID,BAC Id not belong to Department'
	--,T.UserID

	--from #TempSelectedBACIDsUserWise T
	--	inner join #UserMasterUploadData U ON U.UserID=T.UserID
	-- --AND U.UserDepartment NOT IN ('BBOG','FNA')
	-- AND U.UserDepartment NOT IN ('FNA')
	-- -- AND ISNULL(U.ApplicableBACID,'') <> ''
	--  -- AND ISNULL(U.ApplicableSolID,'') <> ''
	--left join #TempDepartmentBACID D ON D.BACID=T.BACID
	--where D.BACID IS NULL

	--INSERT INTO #OAOLMasterUploadData    
	--SELECT Distinct  t.SrNo  
 --    -- ,RowNo  
 --     ,'Applicable BACID' ColumnName  
 --     ,U.ApplicableBACID ErrorData  
 --     ,'Invalid BACID,BACID not belong to Department' ErrorType  
	--  ,T.UserID
 --   FROM #TempSelectedBACIDsUserWise T  
	--inner join #UserMasterUploadData U ON U.UserID=T.UserID
	-- AND U.UserDepartment NOT IN ('BBOG','FNA')
	--  AND ISNULL(U.ApplicableBACID,'') <> ''
	--   AND ISNULL(U.ApplicableSolID,'') <> ''
	--inner join DimDepartment D ON (D.EffectiveFromTimeKey<=@TimeKey AND D.EffectiveToTimeKey >=@TimeKey)
	--AND U.UserDepartment=D.DepartmentCode -- Joins department with Users
	--inner join DimOfficeAccountBACID BA ON (BA.EffectiveFromTimeKey<=@TimeKey AND BA.EffectiveToTimeKey >=@TimeKey)
	--AND BA.BACID=T.BACID

	--left join DimDepartmentBACID B ON (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey >=@TimeKey)
	--AND B.DepartmentAlt_Key=D.DepartmentAlt_Key-- join Department with Department BACID
	--AND B.BACID=BA.BACID

	--where B.DepartmentAlt_Key IS NULL

	

	--------
	 
	

	----- Email Id





	INSERT INTO #OAOLMasterUploadData    

	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Email Id' ColumnName  
      ,T.UserEmailId ErrorData  
      ,'Invalid Email id ,Email Id should contain  @ only once ' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  

	 where 
	  ((
            LEN(UserEmailId)
            - LEN( REPLACE ( UserEmailId, '@', '') ) 
        ) /LEN('@')   
	  ) > 1

     -- AND ISNULL(T.UserEmailId,'') <> ''	 

	INSERT INTO #OAOLMasterUploadData    

	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Email Id' ColumnName  
      ,T.UserEmailId ErrorData  
      ,'Invalid Email id ,Email Id should end with @utkarsh.bank' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	where T.UserEmailId not  like '%@utkarsh.bank'   AND ISNULL(T.UserEmailId,'') <> ''

	-----------Update By Vinit 1 nov 2023-------------
	INSERT INTO #OAOLMasterUploadData     
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'User ID' ColumnName  
      ,T.UserID ErrorData  
      ,'Invalid User ID ,User ID should not have special charecter' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	--where T.UserID  NOT LIKE '%P%' 
	--where T.UserID  NOT LIKE '%[A-Z]%' or T.UserID  NOT LIKE '%[a-z]%' or  T.UserID NOT like '%[0-9]%' OR T.UserID like '%!"#$%&()*+,-./:;<=>?@[\]^_`{|}~%' 
	--where  T.UserID like '%!"#$%&()*+,-./:;<=>?@[\]^_`{|}~%' 
	where  T.UserID LIKE '%[!"#$%&()*+,-./:;<=>?@\^_`{|}~]%'  
	--------------------------------------------------------------------------------------------------

-----------Update By Vinit 1 nov 2023-------------------------------------------------- 
	INSERT INTO #OAOLMasterUploadData     
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'User Name' ColumnName  
      ,T.UserName ErrorData  
      ,'Invalid User Name ,User Name should not have number or Special charecter' ErrorType  
	  ,T.UserName
    FROM #UserMasterUploadData T   
	--where T.UserName  like '%[0-9]%' OR T.UserName  LIKE '%@%'  OR T.UserName  LIKE '%#%' OR T.UserName  LIKE '%$%'
	where T.UserName  like '%[0-9]%' OR   T.UserName  LIKE '%[!"#$%&()*+,-./:;<=>?@\^_`{|}~]%'  
	 
------------------------------------------------------------------------------------------
/*
--------------------Updated by vinit 1 nov 2023--------------------------------------
INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'User Mobile No' ColumnName  
      ,T.UserMobileNumber ErrorData  
      ,'Invalid Mobile No ,Mobile No Should Contains 10 Digit only' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	where  T.UserMobileNumber
	-ISNUMERIC(T.UserMobileNumber) <> 1 AND ISNULL(T.UserMobileNumber,'') <> ''  

*/
-----------------------Update By Vinit-----------------------------------------------
	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'User Extension No' ColumnName  
      ,T.UserExtensionNumber ErrorData  
      ,'Invalid Extension No ,Extension No Should Not Contains Alphabets' ErrorType 
	  ,T.UserExtensionNumber 
    FROM #UserMasterUploadData T  
	where   T.UserExtensionNumber  like '%[A-Z]%' or  T.UserExtensionNumber  like '%[a-z]%' 
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------Update By Vinit-----------------------------------------------
	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'User Extension No' ColumnName  
      ,T.UserExtensionNumber ErrorData  
      ,'Invalid Extension No ,Extension No Should Not Special Charecter' ErrorType 
	  ,T.UserExtensionNumber 
    FROM #UserMasterUploadData T  
	where   T.UserExtensionNumber like '%[!"#$%&()*+,-./:;<=>?@\^_`{|}~]%'  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------Update By Vinit----------------------------------------------------------------------------------
--- Comment by akshay as per renuka suggest 
--INSERT INTO #OAOLMasterUploadData    
--	Select
--	Distinct  t.SrNo  
--     -- ,RowNo  
--      ,'User Extension No' ColumnName  
--      ,T.UserExtensionNumber ErrorData  
--      ,'Invalid Extension No ,Extension No should be 15 Digits' ErrorType  
--	  ,T.UserExtensionNumber
--    FROM #UserMasterUploadData T  
--	where  ISNULL(T.UserExtensionNumber,'') <> '' and len(T.UserExtensionNumber) <> 15 
--	--where len(T.UserExtensionNumber) > 15 --or len(T.UserExtensionNumber) < 15  
--	--where len(T.UserExtensionNumber) = 15  
-------------------------------------------------------------------------------------------------------------------------------
--select len(null)
	--INSERT INTO #OAOLMasterUploadData    

	--Select
	--Distinct  t.SrNo  
 --    -- ,RowNo  
 --     ,'User Email Id' ColumnName  
 --     ,T.UserEmailId ErrorData  
 --     ,'Invalid Email id ,enter minimum 3 char before @' ErrorType 
	--  ,T.UserID 
 --   FROM #UserMasterUploadData T  
	------where len(SUBSTRING(T.UserEmailId,1,CHARINDEX('@axisbank.com',T.UserEmailId,1))) < 5
	-- where len(SUBSTRING(T.UserEmailId,1,CHARINDEX('@',T.UserEmailId,1)-1)) < 3
	--AND ISNULL(T.UserEmailId,'') <> ''
	
	
	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'User Email Id' ColumnName  
      ,T.UserEmailId ErrorData  
      ,'Invalid Email id ,Email Id should start with character' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	where  Left(ISNULL(T.UserEmailId,''),1)   IN ('0','1','2','3','4','5','6','7','8','9')
	--AND ISNULL(T.UserEmailId,'') <> ''
-- 



-----User Mobile No
	Print 'A5'
----------Updated By VInit-----------
	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'User Mobile No' ColumnName  
      ,T.UserMobileNumber ErrorData  
      ,'Invalid Mobile No ,Mobile No should be 10 Digits' ErrorType
	  ,T.UserID  
    FROM #UserMasterUploadData T  
	where 
	--AND 
	len(T.UserMobileNumber) > 10 or len(T.UserMobileNumber) <10
---------------------------------------------------------
---------------Update by Vinit-------------------------- --select * from UserDetail_stg   select * from DimUserInfo_mod
INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Is Checker2 ' ColumnName  
      ,T.IsChecker2 ErrorData  
      ,'Invalid Value Provided for Is Checker,It Should be One of Y And N' ErrorType  
	  ,T.IsChecker2
FROM #UserMasterUploadData T  where  T.IsChecker2 NOT  IN ('Y','N') or  T.IsChecker2   like '%[!"#$%&()*+,-./:;<=>?@\^_`{|}~]%'  
---------------------------------------------------------------------------
---------------Update by Vinit-------------------------- --select * from UserDetail_stg   select * from DimUserInfo_mod
INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Is Checker ' ColumnName  
      ,T.IsChecker ErrorData  
      ,'Invalid Value Provided for Is Checker,It Should be One of Y And N' ErrorType  
	  ,T.IsChecker
FROM #UserMasterUploadData T  where  T.IsChecker NOT  IN ('Y','N') or T.IsChecker  like '%[!"#$%&()*+,-./:;<=>?@\^_`{|}~]%'  
	--------------------------------------------------------------"Invalid Record present in Excel sheet" 

	---------------Update by Vinit-------------------------- --select * from UserDetail_stg   select * from DimUserInfo_mod
--INSERT INTO #OAOLMasterUploadData    
--	Select
--	Distinct  t.SrNo  
--     -- ,RowNo  
--      ,'Is Checker2 ' ColumnName  
--      ,T.IsChecker2 ErrorData  
--      ,'Invalid Record present in Excel sheet' ErrorType  
--	  ,T.IsChecker2
--FROM #UserMasterUploadData T  where  T.IsChecker2 like '%[0-9]%' or  T.IsChecker2   like '%[!"#$%&()*+,-./:;<=>?@\^_`{|}~]%'  or T.IsChecker2 =''
--------------------------------------------------------------
---------------Update by Vinit-------------------------- --select * from UserDetail_stg   select * from DimUserInfo_mod
--INSERT INTO #OAOLMasterUploadData    
--	Select
--	Distinct  t.SrNo  
--     -- ,RowNo  
--      ,'Is Checker ' ColumnName  
--      ,T.IsChecker ErrorData  
--      ,'Invalid Record present in Excel sheet' ErrorType  
--	  ,T.IsChecker
--FROM #UserMasterUploadData T  where  T.IsChecker like '%[0-9]%'or T.IsChecker   like '%[!"#$%&()*+,-./:;<=>?@\^_`{|}~]%' or T.IsChecker =''
--------------------------------------------------------------------------------------------------------------------------


	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'User Mobile No' ColumnName  
      ,T.UserMobileNumber ErrorData  
      ,'Invalid Mobile No ,Mobile No should be Mandatory' ErrorType
	  ,T.UserID  
    FROM #UserMasterUploadData T  
	where 
	--AND 
	ISNULL(T.UserMobileNumber,'') = ''  
   
   	Print 'A4'

	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'User Mobile No' ColumnName  
      ,T.UserMobileNumber ErrorData  
      ,'Invalid Mobile No ,Mobile No Should Contains Numbers only' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	where  ISNUMERIC(T.UserMobileNumber) <> 1
	AND ISNULL(T.UserMobileNumber,'') <> ''

	--INSERT INTO #OAOLMasterUploadData    
	--Select
	--Distinct  t.SrNo  
 --    -- ,RowNo  
 --     ,'User Mobile No' ColumnName  
 --     ,T.UserMobileNumber ErrorData  
 --     ,'Invalid Mobile No ,Mobile No Should Start from 6,7,8,9' ErrorType  
	--  ,T.UserID
 --   FROM #UserMasterUploadData T  
	--where  Left(ISNULL(T.UserMobileNumber,''),1)  NOT IN ('6','7','8','9')
	--AND ISNULL(T.UserMobileNumber,'') <> ''

	
	
	----

	---- USer Extension No
	--INSERT INTO #OAOLMasterUploadData    
	--Select
	--Distinct  t.SrNo  
 --    -- ,RowNo  
 --     ,'User Extension No' ColumnName  
 --     ,T.UserExtensionNumber ErrorData  
 --     ,'Invalid Extension No ,Extension No should be Upto 15 Digits' ErrorType  
	--  ,T.UserID
 --   FROM #UserMasterUploadData T  
	--where len(T.UserMobileNumber) > 15
	--AND ISNULL(T.UserMobileNumber,'') <> ''

	--INSERT INTO #OAOLMasterUploadData    
	--Select
	--Distinct  t.SrNo  
 --    -- ,RowNo  
 --     ,'User ExtensionNo' ColumnName  
 --     ,T.UserExtensionNumber ErrorData  
 --     ,'Invalid Extension No ,Extension No Should Contains Numbers only' ErrorType 
	--  ,T.UserID 
 --   FROM #UserMasterUploadData T  
	--where  ISNUMERIC(T.UserExtensionNumber) <> 1
	--AND ISNULL(T.UserExtensionNumber,'') <> ''

	
	--INSERT INTO #OAOLMasterUploadData    
	--Select
	--Distinct  t.SrNo  
 --    -- ,RowNo  
 --     ,'User ExtensionNo' ColumnName  
 --     ,T.UserExtensionNumber ErrorData  
 --     ,'Invalid Extension No ,Extension No Can not be zero' ErrorType 
	--  ,T.UserID 
 --   FROM #UserMasterUploadData T  
	--where  (CASE WHEN ISNUMERIC(T.UserExtensionNumber) <> 1 THEN 0
	--        ELSE 
	--		    CASE WHEN CAST(T.UserExtensionNumber as decimal(15,0))=0 THEN 1 END
	--		END
	--       )=1
	--	   AND ISNULL(T.UserExtensionNumber,'') <> ''
	--INSERT INTO #OAOLMasterUploadData    
	


	
	

	------- 

	----- Is Checker

	


/*	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Is Checker ' ColumnName  
      ,T.IsChecker ErrorData  
      ,'Invalid Value Provided for Is Checker,It Should be One of Y And N' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	where  T.IsChecker NOT  IN ('Y','N') */
	Print 'A3'
	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Is Checker ' ColumnName  
      ,T.IsChecker ErrorData  
      ,'User role as Viewer will not have checker rights' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	where  T.IsChecker='Y' AND
	T.UserRole='Viewer'
	Print 'A2'
------Updated By Vinit----------
	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Is Checker2 ' ColumnName  
      ,T.IsChecker2 ErrorData  
      ,'User role as Viewer will not have checker rights' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	where  T.IsChecker2='Y' AND
	T.UserRole='Viewer'
	-----------------

	------Updated By Vinit----------
	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Is Checker2 ' ColumnName  
      ,T.IsChecker2 ErrorData  
      ,'User role as Operator will not have checker rights' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	where  T.IsChecker2='Y' AND
	T.UserRole='Operator'
	-----------------
	--------Updated By Vinit----------
	--INSERT INTO #OAOLMasterUploadData    
	--Select
	--Distinct  t.SrNo  
 --    -- ,RowNo  
 --     ,'Is Checker2 ' ColumnName  
 --     ,T.IsChecker2 ErrorData  
 --     ,'User role as Admin will not have checker rights' ErrorType  
	--  ,T.UserID
 --   FROM #UserMasterUploadData T  
	--where  T.IsChecker2='Y' AND
	--T.UserRole='Admin'
	-----------------

	---Added By Sachin
  /* INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Is Checker2 ' ColumnName  
      ,T.IsChecker ErrorData  
      ,'Invalid Value Provided for Is Checker,It Should be One of Y And N' ErrorType  
	  ,T.UserID
FROM #UserMasterUploadData T  
	where  T.IsChecker NOT  IN ('Y','N') */


	---Uncomment By Vinit ----
	--INSERT INTO #OAOLMasterUploadData    
	--Select
	--Distinct  t.SrNo  
 --    -- ,RowNo  
 --     ,'Is Checker2 ' ColumnName  
 --     ,T.IsChecker ErrorData  
 --     ,'User role as Viewer will not have checker rights' ErrorType  
	--  ,T.UserID
 --   FROM #UserMasterUploadData T  
	--where  T.IsChecker='Y' AND
	--T.UserRole='Viewer'
--Till Here

	Print 'A1'

	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Is Active ' ColumnName  
      ,T.IsActive ErrorData  
      ,'Invalid Value Provided for Is ActiveIt Should be One of Y And N' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	where  T.IsActive NOT  IN ('Y','N')

	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
     -- ,RowNo  
      ,'Action' ColumnName  
      ,T.Perform ErrorData  
      ,'Invalid Value Provided for Action, It Should be One of A And U' ErrorType  
	  ,T.UserID
    FROM #UserMasterUploadData T  
	where  T.Perform NOT  IN ('A','U')


	Print 'A'
---------------------------------------------------------------------
	INSERT INTO #OAOLMasterUploadData    
	Select
	Distinct  t.SrNo  
      --,RowNo  
      ,'Is Checker2 ' ColumnName  
      ,T.IsChecker2 ErrorData  
     -- ,'Invalid Value Provided for Is Checker,It Should be One of Y And N' ErrorType  
	  --,'Invalid Record present in Excel sheet' ErrorType 
	 , 'IsChecker should be Y if user is admin and IsChecker2 selected as Y' ErrorType 
	  ,T.IsChecker2
FROM #UserMasterUploadData T  where  T.IsChecker  = 'N' AND   T.IsChecker2  = 'Y' AND T.UserRole ='ADMIN'
------------------------------------------------------------------------------------------------------------
------------VINIT--------------------
	--INSERT INTO #OAOLMasterUploadData    
	 --update O  
	 --set  O.UserID =   U.UserID
	 --from #OAOLMasterUploadData  O join #UserMasterUploadData U 
	 --on O.Perform =U.Perform
--------------------------------------


  END

    RETURNDATA:
	SELECT * FROM #OAOLMasterUploadData order by  UserId,EntityId--order by SR_No
END







GO