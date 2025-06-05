SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[InvokedUserSuspendUpdate]



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


				


					--IF Object_id('Tempdb..#Temp') Is Not Null
					--Drop Table #Temp

					--IF Object_id('Tempdb..#final') Is Not Null
					--Drop Table #final

					--Create table #Temp
					--(ProductCode Varchar(20)
					--,SourceAlt_Key Varchar(20)
					--,ProductDescription Varchar(500)
					--)

	
					--Insert into #Temp values(@ProductCode,@SourceAlt_Key,@ProductDescription)

					--Select A.Businesscolvalues1 as SourceAlt_Key,ProductCode,ProductDescription  into #final From (
					--SELECT ProductCode,ProductDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
					--							FROM  (SELECT 
					--											CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
					--											ProductCode,ProductDescription
					--											from #Temp
					--									) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						
					--)A 

					--ALTER TABLE #FINAL ADD UserLoginID INT

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM DimUserInfo WHERE  UserLoginID=@UserLoginID
					--AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
					AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM DimUserInfo_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND  UserLoginID=@UserLoginID
															--AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
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
			  ROLLBACK TRAN
					RETURN @Result -- Keeping Mandatory Columns blank while User Creation
				END
					

			END
	
	END
	

	IF @OperationFlag=2 
	BEGIN

	PRINT 1

		--UPDATE TEMP 
		--SET TEMP.UserLoginID=@UserLoginID
		--	FROM #final TEMP

	END
	--select * from #final
	--select * from TEMP
	
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

					 ----SET @UserLoginID = (Select ISNULL(Max(UserLoginID),0)+1 from 
						----						(Select UserLoginID from DimUserInfo
						----						 UNION 
						----						 Select UserLoginID from DimUserInfo_Mod
						----						)A)

					 GOTO GLCodeMaster_Insert
					GLCodeMaster_Insert_Add:
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
							SET @AuthorisationStatus ='MP'
							
						END

					ELSE
						BEGIN
							PRINT 'DELETE'
							SET @AuthorisationStatus ='DP'
							
						END

						---FIND CREATED BY FROM MAIN TABLE
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimUserInfo  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND UserLoginID =@UserLoginID

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimUserInfo_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND UserLoginID =@UserLoginID
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimUserInfo
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND UserLoginID =@UserLoginID

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimUserInfo_Mod
							SET AuthorisationStatus='FM'
							,ModifyBy=@ModifyBy
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND UserLoginID =@UserLoginID
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO GLCodeMaster_Insert
					GLCodeMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @ModifyBy   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE DimUserInfo SET
									ModifyBy =@ModifyBy 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND UserLoginID=@UserLoginID
				

		end

		----------------------------------NEW ADD FIRST LVL AUTH------------------
		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimUserInfo_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND UserLoginID =@UserLoginID
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                              AND UserLoginID =@UserLoginID)
				BEGIN
					UPDATE DimUserInfo
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND UserLoginID =@UserLoginID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	


		-------------------------------------------------------------------------
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimUserInfo_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND UserLoginID =@UserLoginID
						AND AuthorisationStatus in('NP','MP','DP','RM')	

---------------Added for Rejection Pop Up Screen  29/06/2020   ----------

		Print 'Sunil'

--		DECLARE @EntityKey as Int 
		--SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
		--					 FROM DimGL_Mod 
		--						WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
		--							AND GLAlt_Key=@GLAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
		
--	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
		

--------------------------------

				IF EXISTS(SELECT 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND UserLoginID=@UserLoginID)
				BEGIN
					UPDATE DimUserInfo
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND UserLoginID =@UserLoginID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimUserInfo_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND UserLoginID=@UserLoginID

	END

	--------NEW ADD------------------
	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE DimUserInfo_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedByFirstLevel=@ApprovedBy
							,DateApprovedFirstLevel=Convert(Date,@DateApproved)
							WHERE UserLoginID=@UserLoginID
							AND AuthorisationStatus in('NP','MP','DP','RM')

		END

	------------------------------

	ELSE IF @OperationFlag=20 OR @AuthMode='N'
		BEGIN
			
			Print 'Authorise'
	-------set parameter for  maker checker disabled
			IF @AuthMode='N'
			BEGIN
				IF @OperationFlag=1
					BEGIN
						SET @CreatedBy =@CrModApBy
						SET @DateCreated =GETDATE()
					END
				ELSE
					BEGIN
						SET @ModifyBy  =@CrModApBy
						SET @DateModified =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM DimUserInfo 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND UserLoginID=@UserLoginID
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END
			END	
			
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'
				BEGIN
				    Print 'B'
					DECLARE @DelStatus CHAR(2)=''
					DECLARE @CurrRecordFromTimeKey smallint=0

					Print 'C'
					SELECT @ExEntityKey= MAX(EntityKey) FROM DimUserInfo_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND UserLoginID=@UserLoginID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifyBy=ModifyBy, @DateModified=DateModified
					 FROM DimUserInfo_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DimUserInfo_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND UserLoginID=@UserLoginID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimUserInfo_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE DimUserInfo_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND UserLoginID=@UserLoginID
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimUserInfo_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE UserLoginID=@UserLoginID
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND UserLoginID=@UserLoginID)
						BEGIN
								UPDATE DimUserInfo
									SET AuthorisationStatus ='A'
										,ModifyBy=@ModifyBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND UserLoginID=@UserLoginID

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN

					PRINT 'SAC1'
							UPDATE DimUserInfo_Mod
								SET AuthorisationStatus ='A'
								,SuspendedUser='N' --NIKHIL
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE UserLoginID=@UserLoginID				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

								-----------------------------new addby anuj /Jayadev 26052021 ----
								-- SET @UserLoginID = (Select ISNULL(Max(UserLoginID),0)+1 from 
								--				(Select UserLoginID from DimUserInfo
								--				 UNION 
								--				 Select UserLoginID from DimUserInfo_Mod
								--				)A)

								----------------------------------------------


						IF EXISTS(SELECT 1 FROM DimUserInfo WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND UserLoginID=@UserLoginID)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


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
											SET @IsSCD2='Y'
										END
								END
								--select @IsAvailable,@IsSCD2

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN

									 SET @UserRole_Key=(SELECT UserRoleAlt_Key FROM dimuserinfo 
												WHERE UserLoginID=@UserLoginID  
											 AND (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey))

									
									SELECT @DepartmentCode= DEP.DeptGroupCode, @DepartmentAlt_Key=DEP.DeptGroupID FROM DimUserInfo	INFO
									--INNER JOIN DimDepartment	DEP
									INNER JOIN Dimuserdeptgroup	DEP
										ON INFO.EffectiveFromTimeKey <= @Timekey AND INFO.EffectiveToTimeKey >= @Timekey
										AND DEP.EffectiveFromTimeKey <= @Timekey AND DEP.EffectiveToTimeKey >= @Timekey
										AND UserLoginID = @UserLoginId
										AND INFO.DeptGroupCode = DEP.DeptGroupID

										 SET @UserName =(SELECT UserName  FROM dimuserinfo 
						WHERE UserLoginID=@UserLoginID  
                     AND (EffectiveFromTimeKey < = @TimeKey  AND EffectiveToTimeKey  > = @TimeKey))
									
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


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimUserInfo SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND UserLoginID=@UserLoginID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO GLCodeMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

GLCodeMaster_Insert:
IF @ErrorHandle=0
	BEGIN

-----------------------------------------------------------
--	IF Object_id('Tempdb..#Temp') Is Not Null
--Drop Table #Temp

--	IF Object_id('Tempdb..#final') Is Not Null
--Drop Table #final

--Create table #Temp
--(ProductCode Varchar(20)
--,SourceAlt_Key Varchar(20)
--,ProductDescription Varchar(500)
--)

					
		

--Insert into #Temp values(@ProductCode,@SourceAlt_Key,@ProductDescription)

--Select A.Businesscolvalues1 as SourceAlt_Key,ProductCode,ProductDescription  into #final From (
--SELECT ProductCode,ProductDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
--                            FROM  (SELECT 
--                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
--											ProductCode,ProductDescription
--                                            from #Temp
--                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						
--)A 

--ALTER TABLE #FINAL ADD UserLoginID INT

--IF @OperationFlag=1 

--BEGIN


--UPDATE TEMP 
--SET TEMP.UserLoginID=ACCT.UserLoginID
-- FROM #final TEMP
--INNER JOIN (SELECT SourceAlt_Key,(@UserLoginID + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) UserLoginID
--			FROM #final
--			WHERE UserLoginID=0 OR UserLoginID IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key
--END

--IF @OperationFlag=2 

--BEGIN

--UPDATE TEMP 
--SET TEMP.UserLoginID=@UserLoginID
-- FROM #final TEMP

--END


	--------------------------------------------------


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

			INSERT INTO DimUserInfo_Mod         
							(
								UserLoginID
								,UserName
								,EffectiveFromTimeKey                          
								,EffectiveToTimeKey   
								,LoginPassword
								,UserRoleAlt_Key
								,DeptGroupCode

								,AuthorisationStatus
								,SuspendedUser
								,CurrentLoginDate --Nikhil
								,MenuId
								,CreatedBy
								,DateCreated
								,ModifyBy
								,DateModified
								,ApprovedBy
								,DateApproved
								,ChangePwdCnt
								,EmployeeID
								,IsEmployee
								,IsChecker
								,Email_ID
								,DepartmentID
								,ScreenFlag
								,IsChecker2
								
							)        
						Select		
								@UserLoginID
								,@UserName
								,@EffectiveFromTimeKey                       
								,@EffectiveToTimeKey 
								,@LoginPassword
								,@UserRole_Key
								,@DepartmentAlt_Key
								,@AuthorisationStatus
								,'Y'
								,getdate() --Nikhil
								,@MenuId
								,@CreatedBy
								,@DateCreated
								,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifyBy ELSE NULL END
								,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
								,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
								,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
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
													
												 
						
	
													
										
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO GLCodeMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO GLCodeMaster_Insert_Edit_Delete
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