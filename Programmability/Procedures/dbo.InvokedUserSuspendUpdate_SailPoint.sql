SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[InvokedUserSuspendUpdate_SailPoint]



--Declare
					@UserLoginID varchar(20)
	                 ,@LoginPassword varchar(50)
						
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
						,@IsAvailable				 varchar(max) = 'Y'
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL

				SET @ScreenName = 'GLProductCodeMaster'
				DECLARE @UserRole_Key INT
				DECLARE @UserLocationCode varchar(10)
				DECLARE @UserLocation VARCHAR(10)
				DECLARE @DepartmentCode VARCHAR(20)
				DECLARE  @DepartmentAlt_Key int 
				DECLARE @UserName VARCHAR(20)
	-------------------------------------------------------------

 --SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 	Select @TimeKey= Timekey from SysDayMatrix where Cast([Date] as date)=Cast(Getdate() as date)

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


		IF EXISTS(				                
					SELECT  1 FROM DimUserInfo WHERE  UserLoginID=@UserLoginID
					--AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
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
			  IF (@UserLoginID = '' OR @LoginPassword = '')
			  BEGIN
			  PRINT 9
			  SET @Result=-10
					RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END
					

			END
	
			
	 SET @UserRole_Key=(SELECT UserRoleAlt_Key FROM dimuserinfo 
						WHERE UserLoginID=@UserLoginID  
                     AND (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey))

		 SET @UserName =(SELECT UserName  FROM dimuserinfo 
						WHERE UserLoginID=@UserLoginID  
                     AND (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey))


	SELECT @DepartmentCode= DEP.DeptGroupCode, @DepartmentAlt_Key=DEP.DeptGroupID FROM DimUserInfo	INFO
	--INNER JOIN DimDepartment	DEP
	INNER JOIN Dimuserdeptgroup	DEP
		ON INFO.EffectiveFromTimeKey <= @Timekey AND INFO.EffectiveToTimeKey >= @Timekey
		AND DEP.EffectiveFromTimeKey <= @Timekey AND DEP.EffectiveToTimeKey >= @Timekey
		AND UserLoginID = @UserLoginId
		AND INFO.DeptGroupCode = DEP.DeptGroupID
		Print '@DepartmentCode'
		Print @DepartmentCode

		Print '@UserRole_Key'
		Print @UserRole_Key

		Print '@DepartmentAlt_Key'
		Print @DepartmentAlt_Key

			INSERT INTO DimUserInfo         
					(
						UserLoginID
						,UserName
						,EffectiveFromTimeKey                          
						,EffectiveToTimeKey   
						 ,LoginPassword  
						 ,UserRoleAlt_Key
						 ,DeptGroupCode
						 ,SuspendedUser
						 ,PasswordChanged
						 ,Activate
						 ,CurrentLoginDate
					
					
						,MenuId
						,AuthorisationStatus
						,CreatedBy
						,DateCreated
						,ModifyBy
						,DateModified
						,ChangePwdCnt
						,EmployeeID
						,IsEmployee
						,IsChecker
						,Email_ID
						,DepartmentID
						,ScreenFlag
						,IsChecker2
						
					)        
				SELECT		
						@UserLoginID
						,@UserName
						,@EffectiveFromTimeKey                       
						,@EffectiveToTimeKey                
						 
						,@LoginPassword 
						,@UserRole_Key
						,@DepartmentAlt_Key
						--------------
						,'N'
						,'N'
						,'Y'
						,GETDATE()
						,@MenuId
						,'A'
						,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifyBy ELSE NULL END
						,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
						,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
						,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL  END
						,ChangePwdCnt
						,EmployeeID
						,IsEmployee
						,IsChecker
						,Email_ID
						,DepartmentID
						,ScreenFlag
						,IsChecker2
						from DimUserInfo
					 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					AND UserLoginID=@UserLoginID


						
						  UPDATE UserLoginHistory SET LoginSucceeded='Y'
										WHERE  UserID=@UserLoginID
										AND LoginSucceeded='W'
					UPDATE DimUserInfo
						SET EffectiveToTimeKey=@EffectiveFromTimeKey -1
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND EffectiveFromTimeKey<@EffectiveFromTimeKey 
						AND UserLoginID=@UserLoginID

														
													
												 
						
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
	IF @OperationFlag =1 AND @AuthMode ='Y' -- ADD
		BEGIN
				     PRINT 'Add'
					 SET @CreatedBy =@CrModApBy 
					 SET @DateCreated = GETDATE()
					 SET @AuthorisationStatus='NP'

					
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				SET @DateCreated = GETDATE()
				Set @ModifyBy=@CrModApBy   
				Set @DateModified =GETDATE() 

					PRINT 5

					IF @OperationFlag = 2
						BEGIN
							PRINT 'Edit'
							IF (@UserLoginID = '' OR @LoginPassword = '')
							BEGIN
							PRINT 9
							SET @Result=-11
							ROLLBACK TRAN
							RETURN @Result -- Keeping Mandatory Columns blank while User Creation
							END
							SET @AuthorisationStatus ='A'
							IF EXISTS(SELECT 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												 AND UserLoginID=@UserLoginID)
									BEGIN
											PRINT 'BBBB'

											


										UPDATE DimUserInfo SET
												
													SuspendedUser='N'
													,ScreenFlag='S'
												,ApprovedBy				= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved			= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus	= 'A'
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												 AND UserLoginID=@UserLoginID
									END	

									ELSE
										BEGIN
											BEGIN
										PRINT 93
										SET @Result=-12
										ROLLBACK TRAN
										RETURN @Result -- -- Keeping Mandatory Columns blank while User Modification
										END
										END
						END

					ELSE
						BEGIN
							PRINT 'DELETE'
							SET @AuthorisationStatus ='DP'
							SET @ModifyBy   = @CrModApBy 
						SET @DateModified = GETDATE() 

						IF EXISTS(SELECT 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												 AND UserLoginID=@UserLoginID)
									BEGIN

						UPDATE DimUserInfo SET
									ModifyBy =@ModifyBy 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND UserLoginID=@UserLoginID

								END

								ELSE
										BEGIN
											BEGIN
										PRINT 93
										SET @Result=-13
										ROLLBACK TRAN
										RETURN @Result -- -- Keeping Mandatory Columns blank while User Modification
										END
										END
						END

						
				
				
	END



	

	-------------------
PRINT 7
		COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimGL WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND GLAlt_Key=@GLAlt_Key

			IF @OperationFlag =3
			BEGIN
				SET @Result=0
			END
		ELSE IF @OperationFlag =2
			BEGIN
				SET @Result=2
			END
			ELSE IF @OperationFlag =1
			BEGIN
				SET @Result=1
			END
		ELSE 
			BEGIN
				SET @Result=-1
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