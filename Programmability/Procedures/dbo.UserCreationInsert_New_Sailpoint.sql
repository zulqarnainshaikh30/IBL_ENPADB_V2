SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[UserCreationInsert_New_Sailpoint]



--Declare
						@UserLoginID	varchar(20)=''
						,@EmployeeID varchar(20)=''	
						,@IsEmployee char(1)=''			
						,@UserName	varchar(50)=''
						,@LoginPassword	varchar(max)=''
						,@UserLocation	varchar	(10)=''
						,@UserLocationCode	varchar	(10)=''
						,@UserRoleAlt_Key	smallint=0
						,@DeptGroupCode varchar(10)=''
						,@DepartmentId  VARCHAR(200)=''
						,@ApplicableSolIds varchar(max)=''
						,@ApplicableBACID varchar(max)=''

						,@DateCreatedmodified smalldatetime=NULL
						,@CreatedModifyBy	varchar	(20)=NULL
						,@Activate char(1)=''
						,@IsChecker char(1)=''
						,@IsChecker2 varchar(1)=''
						,@WorkFlowUserRoleAlt_Key smallint=0
						,@DesignationAlt_Key int=0
						,@IsCma char(1)=''
						,@MobileNo varchar(50)=''
						,@Email_ID VARCHAR(200)=''

						,@SecuritQsnAlt_Key SMALLINT
						,@SecurityAns VARCHAR(100)
						,@UserMaster_ChangeFields Varchar(max)=NULL
						
						---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
						--,@MenuID					SMALLINT		= 0  change to Int
						,@MenuID                    Int=0
						,@OperationFlag				TINYINT			= 0
						,@AuthMode					CHAR(1)			= 'N'
						,@EffectiveFromTimeKey		INT		= 0
						,@EffectiveToTimeKey		INT		= 0
						,@TimeKey					INT		= 0
						,@CrModApBy					VARCHAR(20)		=''
						,@ScreenEntityId			INT				=null
						, @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
						,@Result					INT				=0 OUTPUT
						
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
						@AuthorisationStatus		varchar(5)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifyBy				VARCHAR(20)		= NULL
						,@DateModified				SMALLDATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				SMALLDATETIME	= NULL
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL

				SET @ScreenName = 'GLProductCodeMaster'

	-------------------------------------------------------------

 SET @Timekey =(
 
 Select Timekey from SysDataMatrix where CurrentStatus='C'
 
 ) 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
												
	PRINT 'A'
	

			DECLARE @AppAvail CHAR
					SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF(@AppAvail='N')                         
					BEGIN
						SET @Result=-15
						RETURN @Result
					END


				

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM DimUserInfo  WHERE  UserLoginID=@USERLOGINID
					AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		ELSE
			BEGIN
			   PRINT 3
				IF (@UserLoginID = '' OR @UserName = '' OR @DeptGroupCode = '' OR @UserRoleAlt_key = '' OR @DesignationAlt_Key = '' OR @Email_ID = '' OR @MobileNo = '' OR @Activate = '')
				BEGIN
				PRINT 9
				SET @Result=-10
				RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END
				ELSE IF EXISTS (SELECT  1 FROM DimUserInfo  WHERE   ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey and MobileNo = @MobileNo)
				BEGIN
				 PRINT 20
				SET @Result=-20
				RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END
				ELSE IF EXISTS (SELECT  1 FROM DimUserInfo  WHERE   ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey and Email_ID = @Email_ID)
				BEGIN
				PRINT 21
				SET @Result=-21
				RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END
				ELSE IF NOT EXISTS  (SELECT  1 FROM DimUserInfo  WHERE   ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey and UserLoginID = @CreatedModifyBy)
				BEGIN
				PRINT 24
				SET @Result=-24
				RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END
				ELSE IF @Email_ID not like '%@Emiratesnbd.com%'
				BEGIN
				PRINT 26
				SET @Result=-26
				RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END
			END
	
	END
	

	IF @OperationFlag=2 
	BEGIN

	PRINT 1

	END
	
	
	BEGIN TRY
	BEGIN TRANSACTION	
	-----
	
	PRINT 3	
		--np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK 
	IF @OperationFlag =1  -- ADD
		BEGIN
				     PRINT 'Add'
					 SET @CreatedBy =@CreatedModifyBy 
					 SET @DateCreated = GETDATE()
					 SET @AuthorisationStatus='A'

					INSERT INTO DimUserInfo         
							(
								UserLoginID
								,EmployeeID 
								,IsEmployee 
								,UserName
								,LoginPassword 
								,UserLocation 
								,DeptGroupCode 
								,Activate  
								,IsChecker 
								,IsChecker2
								,EffectiveFromTimeKey                          
								,EffectiveToTimeKey               
								----,EntityKey 
								,PasswordChanged
								--------
								,PasswordChangeDate
								,ChangePwdCnt
								,UserLocationCode
								,UserRoleAlt_Key
								,SuspendedUser
								,CurrentLoginDate
								,ResetDate
								,UserLogged
								,UserDeletionReasonAlt_Key
								,SystemLogOut
								,RBIFLAG

								,Email_ID	--ad4
								,MobileNo
								,DesignationAlt_Key
								,IsCma

								,SecuritQsnAlt_Key
								,SecurityAns
								,MenuId
								,CreatedBy
								,DateCreated
								,ModifyBy
								,DateModified
								,MIS_APP_USR_ID
								,MIS_APP_USR_PASS
								,UserLocationExcel
								,WorkFlowUserRoleAlt_Key
								,ApplicableBACID	
								----,ApplicableSolIds
								,DepartmentId	
								,ScreenFlag
								,AuthorisationStatus
								,ApprovedBy
								,DateApproved
							--ChangeFields
							)        
						VALUES
						(		
								@UserLoginID
								,@EmployeeID 
								,@IsEmployee 
								,@UserName
								,@LoginPassword 
								,@UserLocation
								,@DeptGroupCode 
								,@Activate  
								,@IsChecker
								,@IsChecker2 
								,@EffectiveFromTimeKey           
								,@EffectiveToTimeKey                
								----,@Entity_Key 
								,'N'
								,NULL
								,0
								,@UserLocationCode
								,@UserRoleAlt_Key
								,'N'
								,NULL
								,NULL
								,0
								,NULL
								,NULL
								,NULL
								,NULLIF(@Email_ID,'')	--ad4
								,@MobileNo
								,@DesignationAlt_Key
								,@IsCma
								,@SecuritQsnAlt_Key
								,@SecurityAns
								,@MenuId								
								,@CreatedBy
								,@DateCreated
								,@ModifyBy
								,@DateModified
								,NULL
								,NULL
								,NULL
								,@WorkFlowUserRoleAlt_Key
								,@ApplicableBACID	
								----,@ApplicableSolIds
								,@DepartmentId	
								,'S'
								,'A'
								,@ApprovedBy
								,@DateApproved
						)
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3)  --EDIT AND DELETE 
			BEGIN
				Print 4
				SET @CreatedBy= @CreatedModifyBy
				SET @DateCreated = GETDATE()
				Set @ModifyBy=@CreatedModifyBy   
				Set @DateModified =GETDATE() 

					PRINT 5

					IF @OperationFlag = 2
						BEGIN
							PRINT 'Edit'
							SET @AuthorisationStatus ='A'
							 IF (@UserLoginID = '' OR @UserName = '' OR @DeptGroupCode = '' OR @UserRoleAlt_key = '' OR @DesignationAlt_Key = '' OR @Email_ID = '' OR @MobileNo = ''  OR @Activate = '')
							BEGIN
							PRINT 93
							SET @Result=-11
							ROLLBACK TRAN
							RETURN @Result -- -- Keeping Mandatory Columns blank while User Modification
							END
				ELSE IF EXISTS (SELECT  1 FROM DimUserInfo  WHERE   ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey and MobileNo = @MobileNo and UserLoginID!= @UserLoginID)
				BEGIN
				 PRINT 22
				SET @Result=-22
				ROLLBACK TRAN
				RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END
				ELSE IF EXISTS (SELECT  1 FROM DimUserInfo  WHERE   ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey and Email_ID = @Email_ID and UserLoginID!= @UserLoginID )
				BEGIN
				PRINT 23
				SET @Result=-23
				ROLLBACK TRAN
				RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END
				ELSE IF NOT EXISTS  (SELECT  1 FROM DimUserInfo  WHERE   ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey and UserLoginID = @ModifyBy)
				BEGIN
				PRINT 25
				SET @Result=-25
				ROLLBACK TRAN
				RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END
				
				

								IF EXISTS(SELECT Distinct 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
											  AND UserLoginID=@UserLoginID)
									BEGIN
											PRINT 'BBBB'
											PRINT 'Sac2'
										UPDATE DimUserInfo SET
												
													UserLoginID=@UserLoginID,
													UserName=@UserName,
													UserLocation=@UserLocation,
													UserLocationCode=@UserLocationCode,
													UserRoleAlt_Key=@UserRoleAlt_Key	,
      												LoginPassword=@LoginPassword,
      												IsChecker=@IsChecker,
													IsChecker2=@IsChecker2,
      												Activate=@Activate,
													DeptGroupCode=@DeptGroupCode,
													WorkFlowUserRoleAlt_Key=@WorkFlowUserRoleAlt_Key,
													Email_ID=@Email_ID,	--ad4
													MobileNo=@MobileNo,
													DesignationAlt_Key=@DesignationAlt_Key,
													IsCma = @isCma,
													ApplicableBACID	    =@ApplicableBACID,
													----ApplicableSolIds	=@ApplicableSolIds,
													DepartmentId	    =@DepartmentId,
													ScreenFlag='S'
												,ApprovedBy				= CASE WHEN @AuthMode ='Y' THEN @CreatedModifyBy ELSE NULL END
												,DateApproved			= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus	= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
											--ChangeFields=@UserMaster_ChangeFields
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND UserLoginID=@UserLoginID
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
							 IF (@UserLoginID = '' OR @UserName = '' OR @DeptGroupCode = '' OR @UserRoleAlt_key = '' OR @DesignationAlt_Key = '' OR @Email_ID = '' OR @MobileNo = ''  OR @Activate = '')
							BEGIN
							PRINT 93
							SET @Result=-1
							ROLLBACK TRAN
							RETURN @Result -- -- Keeping Mandatory Columns blank while User Modification
							END
							

							IF EXISTS(SELECT Distinct 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
											  AND UserLoginID=@UserLoginID)
									BEGIN
											PRINT 'CCCC'
											PRINT 'Sac22'

							UPDATE DimUserInfo
							SET EffectiveToTimeKey=@EffectiveFromTimeKey -1
							WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND UserLoginID=@UserLoginID
							end
		
							ELSE
										BEGIN
										PRINT 93
										SET @Result=-13
										ROLLBACK TRAN
										RETURN @Result -- -- Keeping Mandatory Columns blank while User Modification
										END

					END

				

					PRINT 6
					SET @ErrorHandle=1

									DECLARE @Parameter2 varchar(50)
									DECLARE @FinalParameter2 varchar(50)
									SET @Parameter2 = (select STUFF((	SELECT Distinct ',' +ChangeFields
																			from DimUserInfo where UserLoginID=@UserLoginID
																			and ISNULL(AuthorisationStatus,'A')  in ( 'A')
																			 for XML PATH('')),1,1,'') )

																			If OBJECT_ID('#A') is not null
																			drop table #A

									select DISTINCT VALUE 
									into #A 
									from (
											SELECT 	CHARINDEX('|',VALUE) CHRIDX,VALUE
											FROM( SELECT VALUE FROM STRING_SPLIT(@Parameter2,',')
									 ) A
									 )X
									 SET @FinalParameter2 = (select STUFF((	SELECT Distinct ',' + Value from #A  for XML PATH('')),1,1,''))
 
																UPDATE		A
																set			a.ChangeFields = @FinalParameter2							 																																	
																from		DimUserInfo   A
																WHERE		(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
																and			UserLoginID=@UserLoginID																																			 				



	END
		



	-------------------
PRINT 7
COMMIT TRANSACTION
				IF @OperationFlag =3
			BEGIN
				SET @Result=0
				ROLLBACK TRAN
			END
		ELSE IF @OperationFlag =2
			BEGIN
				SET @Result=2
				ROLLBACK TRAN
			END
		ELSE 
			BEGIN
				SET @Result=1
			END
END TRY
BEGIN CATCH
	ROLLBACK TRAN

	INSERT INTO dbo.Error_Log
				SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
				,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
				,GETDATE()

	SELECT ERROR_MESSAGE()
	RETURN -1
   
END CATCH
---------
END

GO