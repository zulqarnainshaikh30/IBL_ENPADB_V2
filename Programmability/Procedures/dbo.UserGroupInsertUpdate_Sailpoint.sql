SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[UserGroupInsertUpdate_Sailpoint] -- -- select * from DimUserDeptGroup_Mod
 --@EntityKey int,        
 @DeptGroupId int = 1,        
 @DeptGroupName varchar(12)= 'test department',        
 @DeptGroupDesc varchar(200)= 'test',        
 @MenuId Varchar(MAX)= '1,2,3,4,5,6,7',          
 @IsUniversal char(1)='Y',
 @AssignedReturns varchar(max)='',
 @AssignedSLBC varchar(max)='',
 --@CreatedBy varchar(20),        
 @timekey int = 0,        

 @EffectiveFromTimeKey INT  = 0
,@EffectiveToTimeKey INT  = 49999
,@DateCreatedModifiedApproved Varchar(10)        = null
,@CreateModifyApprovedBy VARCHAR(20)            = null
,@OperationFlag  INT =2
,@AuthMode char(2) = 'N'-- null		
,@Remark varchar(200)=NULL
,@D2Ktimestamp INT=0 OUTPUT  
,@Result INT=0 OUTPUT
AS     
BEGIN  


SET NOCOUNT ON;	  
SET DATEFORMAT DMY

DECLARE		@AuthorisationStatus CHAR(2)=NULL			
			 ,@CreatedBy VARCHAR(20) =NULL
			 ,@DateCreated SMALLDATETIME=NULL
			 ,@Modifiedby VARCHAR(20) =NULL
			 ,@DateModified SMALLDATETIME=NULL
			 ,@ApprovedBy  VARCHAR(20)=NULL
			 ,@DateApproved  SMALLDATETIME=NULL
			 ,@ExEntityKey AS INT=0
			 ,@ErrorHandle int=0
			 ,@IsAvailable CHAR(1)='N'
			 ,@IsSCD2 CHAR(1)='N'
			 
			-- 	set @TimeKey = 
   --      (
   --          SELECT TimeKey
   --          FROM SysDayMatrix
   --          WHERE CONVERT(VARCHAR(10), Date, 103) = CONVERT(VARCHAR(10), GETDATE(), 103)
   --      );
		 --set @EffectiveFromTimeKey = (
   --          SELECT TimeKey
   --          FROM SysDayMatrix
   --          WHERE CONVERT(VARCHAR(10), Date, 103) = CONVERT(VARCHAR(10), GETDATE(), 103)
   --      );
   set @TimeKey = 
   (
   Select TimeKey from SysDataMatrix where CurrentStatus='C'
   );
   set @EffectiveFromTimeKey = 
   (
   Select TimeKey from SysDataMatrix where CurrentStatus='C'
   );
		IF @OperationFlag =1	-- when adding, check whether it already exist or not
		BEGIN				
		
			
				PRINT 'ABC'
					select @DeptGroupId =  max(DeptGroupId)+1 from DimUserDeptGroup
				

			IF @DeptGroupId is NULL
			Begin 
				SET @DeptGroupId = 1
			End
			print 'sb'
			IF EXISTS (
						SELECT  1 FROM dbo.DimUserDeptGroup WHERE  EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey AND DeptGroupCode = @DeptGroupName
							AND ISNULL(AuthorisationStatus,'A') = 'A')				
				BEGIN
						PRINT '@-4'
						SET @D2Ktimestamp = 2
						SET @Result = -4
						RETURN -4
				END

				ELSE
			BEGIN
			   PRINT 3
			  IF (@DeptGroupId = '' OR @DeptGroupName = '' OR @DeptGroupDesc = '' OR @MenuId = '')
			  BEGIN
			  PRINT 9
			  SET @Result=-10
					RETURN @Result
				END
				ELSE IF NOT EXISTS  (SELECT  1 FROM DimUserInfo  WHERE   ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey and UserLoginID = @CreateModifyApprovedBy)
										BEGIN
										PRINT 27
										SET @Result=-27
										RETURN @Result -- Keeping Mandatory Columns blank while User Creation
										END	

			END
		END

		
		

		
		IF @OperationFlag=1 AND @AuthMode ='Y'
		BEGIN
				print '@CreateModifyApprovedBy'
				print @CreateModifyApprovedBy
				SET @CreatedBy =@CreateModifyApprovedBy 
				SET @DateCreated = GETDATE()
				SET @AuthorisationStatus='A'

				INSERT INTO DimUserDeptGroup         
											(
												DeptGroupId
												,DeptGroupCode        
												,DeptGroupName        
												,Menus
												,IsUniversal

												,EffectiveFromTimeKey                          
												,EffectiveToTimeKey               
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy		
												,DateApproved	
												--,AssignedReturns	
												--,AssignedSLBC											
											)        
										SELECT		
												@DeptGroupId
												,@DeptGroupName 
												,@DeptGroupDesc 
												,@MenuId
												,@IsUniversal

												,@EffectiveFromTimeKey                       
												,@EffectiveToTimeKey   												
												,@CreatedBy	--,CASE WHEN @IsAvailable='N' THEN CreatedBy ELSE @CreateModifyApprovedBy END	
												,@DateCreated	--,CASE WHEN @IsAvailable='N' THEN DateCreated ELSE  @DateCreatedModifiedApproved END													
												,CASE WHEN @IsAvailable='Y' THEN  @Modifiedby ELSE NULL END
												,CASE WHEN @IsAvailable='Y' THEN  @DateModified ELSE NULL END
												,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
												,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END	
												--,@AssignedReturns
												--,@AssignedSLBC
										--------- update in sysCrismacMenu		
								--IF (@EffectiveFromTimeKey =(SELECT EffectiveFromTimeKey                                   
									--		    FROM DimUserDeptGroup                                
										--	    WHERE (EffectiveFromTimeKey <=@timekey and EffectiveToTimeKey>=@timekey) and DeptGroupCode=@DeptGroupName ) )       											      
										--BEGIN        

											   print 'same timekey'        
											   BEGIN TRANSACTION          
											        
											 --Update DimUserDeptGroup Set DeptGroupName=@DeptGroupDesc,DateModified=GETDATE(),ModifiedBy=@CreatedBy,Menus=@MenuId where (EffectiveFromTimeKey <=@timekey and EffectiveToTimeKey>=@timekey) and DeptGroupCode=@DeptGroupName        
											 --Update SysCRisMacMenu Set Department=@MenuDept where MenuTitleId in (@Menus)        										         
											          
											 Update SysCRisMacMenu Set DeptGroupCode=replace(DeptGroupCode,  @DeptGroupName+ ',','')        
											  Where DeptGroupCode like '%' + @DeptGroupName + '%'        
											      
											 Update SysCRisMacMenu Set DeptGroupCode=replace(DeptGroupCode, ',' + @DeptGroupName,'')        
											  Where DeptGroupCode like '%' + @DeptGroupName + '%'        
											      
											 Update SysCRisMacMenu Set DeptGroupCode=replace(DeptGroupCode,  @DeptGroupName+ ',','')        
											  Where DeptGroupCode like '%' + @DeptGroupName + '%'        
											      
											 Update SysCRisMacMenu Set DeptGroupCode=replace(DeptGroupCode, @DeptGroupName,'')        
											  Where DeptGroupCode like '%' + @DeptGroupName + '%'        
											             
											   update SysCRisMacMenu set DeptGroupCode= case ISNULL(DeptGroupCode,'') when '' then @DeptGroupName        
											                                       ELSE DeptGroupCode+','+  @DeptGroupName END        
											               where MenuId IN (Select Items from dbo.split(@MenuId,',')) 

														    IF @@ERROR <> 0                 
											 BEGIN                
												  ROLLBACK TRANSACTION    
												  SET @Result  = -1                  
												  RETURN -1                
											 END 
											                
											 COMMIT TRANSACTION    
				

		END



	    ELSE IF (@OperationFlag=2 OR @OperationFlag=3) AND @AuthMode ='Y'
			BEGIN 					
					SET @Modifiedby   = @CreateModifyApprovedBy 
					SET @DateModified = GETDATE() 
				
					IF @AuthMode='Y'
						BEGIN											
								IF @OperationFlag=2
									BEGIN
										SET @AuthorisationStatus='A'	
										 IF (@DeptGroupId = '' OR @DeptGroupName = '' OR @DeptGroupDesc = '' OR @MenuId = '')
										BEGIN
										PRINT 9
										SET @Result=-11
										ROLLBACK TRAN
									 	RETURN @Result -- Keeping Mandatory Columns blank while User Creation
									 	END	
										ELSE IF NOT EXISTS  (SELECT  1 FROM DimUserInfo  WHERE   ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey and UserLoginID = @Modifiedby)
										BEGIN
										PRINT 28
										SET @Result=-28
										RETURN @Result -- Keeping Mandatory Columns blank while User Creation
										END						
									 END
								

									IF EXISTS(SELECT 1 FROM dbo.DimUserDeptGroup  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey ) 
													AND EffectiveFromTimeKey=@EffectiveFromTimeKey  AND DeptGroupId = @DeptGroupId )
										BEGIN
										print 'a7'
										  UPDATE dbo.DimUserDeptGroup
												   SET 	
													DeptGroupId = @DeptGroupId
													,DeptGroupCode =  @DeptGroupName
													,DeptGroupName = @DeptGroupDesc
													,Menus = @MenuId
													,IsUniversal = @IsUniversal													
												   ,ModifiedBy = @Modifiedby
												   ,DateModified = @DateModified
												   ,ApprovedBy=CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												   ,DateApproved= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												   ,AuthorisationStatus= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												WHERE 
													DeptGroupId = @DeptGroupId AND 
													(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND 
													EffectiveFromTimeKey=@EffectiveFromTimeKey 
									END	
									ELSE
										BEGIN
										PRINT 93
										SET @Result=-12
										ROLLBACK TRAN
										RETURN @Result -- -- Keeping Mandatory Columns blank while User Modification
										END
							END

						      ELSE
						BEGIN
							PRINT 'DELETE'
							SET @AuthorisationStatus ='A'
							

							IF EXISTS(SELECT 1 FROM dbo.DimUserDeptGroup  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey ) 
													AND EffectiveFromTimeKey=@EffectiveFromTimeKey  AND DeptGroupId = @DeptGroupId )
							BEGIN
											PRINT 'CCCC'
											PRINT 'Sac22'

								UPDATE dbo.DimUserDeptGroup  SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)
									      AND DeptGroupId = @DeptGroupId
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
							END
		
							ELSE
										BEGIN
										PRINT 93
										SET @Result=-13
										ROLLBACK TRAN
										RETURN @Result -- -- Keeping Mandatory Columns blank while User Modification
										END

							END

											  
											print '@CreateModifyApprovedBy'
											print @CreateModifyApprovedBy

							END

						IF @IsSCD2='Y' 
						BEGIN
                               print 777
						
						END
				END
		 



				SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT)
				from (
						SELECT top(1)  D2Ktimestamp FROM DimUserDeptGroup  WHERE  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey AND DeptGroupId = @DeptGroupId  AND ISNULL(AuthorisationStatus,'A')='A' 								
					 )timestamp1


				SET @D2Ktimestamp =ISNULL(@D2Ktimestamp,1)
					set @Result =ISNULL(@Result,1)
					print @D2Ktimestamp	



				If @OperationFlag=1
					BEGIN
			 			SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT)
						from (
								SELECT top(1)  D2Ktimestamp FROM DimUserDeptGroup  WHERE  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey 
										AND DeptGroupCode = @DeptGroupName AND ISNULL(AuthorisationStatus,'A')='A' 
								UNION 
								SELECT top(1)  D2Ktimestamp FROM DimUserDeptGroup_Mod WHERE   EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey  
										AND DeptGroupCode = @DeptGroupName AND AuthorisationStatus IN ('NP','MP','DP','RM')
							 )timestamp1
print 'timestamp'
print @D2Ktimestamp
						SET @Result = @DeptGroupId				
						RETURN @Result					
						RETURN @D2Ktimestamp
					END
				ELSE
					IF @OperationFlag =3
						BEGIN
print 'aaaaaaaa'						
							SET @Result =0
							IF(@AuthMode='N')
							(
								select @D2Ktimestamp=(SELECT top(1)  D2Ktimestamp FROM DimUserDeptGroup  WHERE  EffectiveFromTimeKey<=@TimeKey 
										AND DeptGroupCode = @DeptGroupName  AND ISNULL(AuthorisationStatus,'A')='A' )
							)
							RETURN @D2Ktimestamp
							RETURN @Result
						END
					ELSE 						
						BEGIN
								SET @Result = @DeptGroupId
	print 	'@Result'
	print 	@Result								
								RETURN @Result						
								RETURN @D2Ktimestamp		
		
						END


GO