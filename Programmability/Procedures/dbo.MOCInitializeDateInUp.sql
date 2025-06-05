SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROC [dbo].[MOCInitializeDateInUp]

--Declare
						@MOCInitializeDate		   Varchar(20) = '2019-07-31' 
						---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
						--,@MenuID					SMALLINT		= 0  change to Int
						,@MenuID                    Int=0
						,@OperationFlag				TINYINT			= 20
						,@AuthMode					CHAR(1)			= 'Y'
						,@Authlevel					VARCHAR(3)=''
						,@EffectiveFromTimeKey		INT		= 0
						,@EffectiveToTimeKey		INT		= 0
						,@TimeKey					INT		= 0
						,@CrModApBy					VARCHAR(20)		='Admin'
						,@ScreenEntityId			INT				=null
						,@Result					INT				=0 OUTPUT 
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
	
		------------- Security Check--------


				--DECLARE @Parameter varchar(max) = (select 'MOCInitializeDate|' + ISNULL(@MOCInitializeDate,' ') + '}'+ 'GLDescription|' + isnull(@GLDescription,' '))
				----DECLARE		@Result					INT				=0 
				--exec SecurityCheckDataValidation 14550 ,@Parameter,@Result OUTPUT
				
				--IF @Result = -1
				--	return -1 

		DECLARE 
						 @AuthorisationStatus		varchar(5)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				datetime	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				datetime	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				datetime	= NULL
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			 @Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL
						,@MOC_FREEZE_DATE       VARCHAR(20)=NULL
						,@MOC_FREEZE			VARCHAR(2)=''
			       	SET @ScreenName = 'MOCInitializeDateMaster'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)

	SET @MOC_FREEZE_DATE=(SELECT MAX(EXTDATE) FROM SysDataMatrix WHERE MOC_Frozen='Y')
	set @MOC_FREEZE = (	SELECT MOC_Frozen FROM SysDataMatrix WHERE ExtDate=	@MOC_FREEZE_DATE)									
	PRINT 'A'
	

			DECLARE @AppAvail CHAR
					SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF(@AppAvail='N')                         
					BEGIN
						SET @Result=-11
						RETURN @Result
					END

			

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM MOCInitializeDetails WHERE  MOCInitializeDate=@MOCInitializeDate AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM MOCInitializeDetails_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															 AND MOCInitializeDate=@MOCInitializeDate
															 AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM','1A') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		ELSE
			BEGIN
			   PRINT 3
				 --SET @MOCInitializeDate = (Select ISNULL(Max(MOCInitializeDate),0)+1 from 
					--							(Select MOCInitializeDate from MOCInitializeDetails
					--							 UNION 
					--							 Select MOCInitializeDate from MOCInitializeDetails_Mod
					--							)A)
			END

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
					 SET @DateCreated =  GETDATE()  ---select getdate()
					 SET @AuthorisationStatus='NP'

					 --SET @MOCInitializeDate = (Select ISNULL(Max(MOCInitializeDate),0)+1 from 
						--						(Select MOCInitializeDate from MOCInitializeDetails
						--						 UNION 
						--						 Select MOCInitializeDate from MOCInitializeDetails_Mod
						--						)A)

					 GOTO MOCInitializeDateMaster_Insert
					MOCInitializeDateMaster_Insert_Add:
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				SET @DateCreated = GETDATE()
				Set @Modifiedby=@CrModApBy   
				Set @DateModified = GETDATE() --select getdate()

					PRINT 5 
					IF @OperationFlag = 2
						BEGIN
							PRINT 'Edit'
							SET @AuthorisationStatus ='MP' 
						END

					ELSE
						BEGIN
							PRINT 'DELETE'
							SET @AuthorisationStatus ='DP' 
						END

						---FIND CREATED BY FROM MAIN TABLE
					SELECT  
					@CreatedBy		= CreatedBy
				   ,@DateCreated	= DateCreated 
					FROM MOCInitializeDetails  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND MOCInitializeDate =@MOCInitializeDate

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM MOCInitializeDetails_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND MOCInitializeDate =@MOCInitializeDate
							AND AuthorisationStatus IN('NP','MP','A','RM') 
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE MOCInitializeDetails
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND MOCInitializeDate =@MOCInitializeDate 
					END 
					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE MOCInitializeDetails_Mod
							 SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND MOCInitializeDate =@MOCInitializeDate
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO MOCInitializeDateMaster_Insert
					MOCInitializeDateMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE MOCInitializeDetails SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								    WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
								    AND MOCInitializeDate=@MOCInitializeDate 
		end
		 
------------------------------------------------------- 
--start 20042021
ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE MOCInitializeDetails_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND MOCInitializeDate =@MOCInitializeDate
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM MOCInitializeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND MOCInitializeDate=@MOCInitializeDate)
				BEGIN
					UPDATE MOCInitializeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND MOCInitializeDate =@MOCInitializeDate
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	 
--till here
------------------------------------------------------- 
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE MOCInitializeDetails_Mod
					SET AuthorisationStatus='R'
					,ApprovedByFirstLevel	 =@ApprovedBy
					,DateApprovedFirstLevel	= @DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND MOCInitializeDate =@MOCInitializeDate
						AND AuthorisationStatus in('NP','MP','DP','RM')	

---------------Added for Rejection Pop Up Screen  29/06/2020   ----------

		Print 'Sunil'

--		DECLARE @EntityKey as Int 
		--SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
		--					 FROM MOCInitializeDetails_Mod 
		--						WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
		--							AND MOCInitializeDate=@MOCInitializeDate And ISNULL(AuthorisationStatus,'A')='R'
		
--	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
		

--------------------------------

				IF EXISTS(SELECT 1 FROM MOCInitializeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND MOCInitializeDate=@MOCInitializeDate)
				BEGIN
					UPDATE MOCInitializeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND MOCInitializeDate =@MOCInitializeDate
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE MOCInitializeDetails_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND MOCInitializeDate=@MOCInitializeDate 
	END

	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE MOCInitializeDetails_Mod
			 SET AuthorisationStatus ='1A'
			 	,ApprovedByFirstLevel	 =@ApprovedBy
			     ,DateApprovedFirstLevel	= @DateApproved
			 	WHERE MOCInitializeDate=@MOCInitializeDate
			 	AND AuthorisationStatus in('NP','MP','DP','RM') 
		END

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
						SET @ModifiedBy  =@CrModApBy
						SET @DateModified =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated FROM MOCInitializeDetails 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND MOCInitializeDate=@MOCInitializeDate
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END
			END	 
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'  
				BEGIN
				    Print 'B'
					DECLARE @DelStatus CHAR(2)=''-------------20042021
					DECLARE @CurrRecordFromTimeKey smallint=0

					Print 'C'
					SELECT @ExEntityKey= MAX(EntityKey) FROM MOCInitializeDetails_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND MOCInitializeDate=@MOCInitializeDate
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM MOCInitializeDetails_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM MOCInitializeDetails_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND MOCInitializeDate=@MOCInitializeDate
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM MOCInitializeDetails_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE MOCInitializeDetails_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND MOCInitializeDate=@MOCInitializeDate
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE  MOCInitializeDetails_Mod
						SET		 AuthorisationStatus ='A'
								,ApprovedBy=@ApprovedBy
								,DateApproved=@DateApproved
								,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE MOCInitializeDate=@MOCInitializeDate
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM MOCInitializeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND MOCInitializeDate=@MOCInitializeDate)
						BEGIN
								UPDATE MOCInitializeDetails
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND MOCInitializeDate=@MOCInitializeDate 
								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE MOCInitializeDetails_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE MOCInitializeDate=@MOCInitializeDate				
									AND AuthorisationStatus in('NP','MP','RM','1A') 
					END		
				END

		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM MOCInitializeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND MOCInitializeDate=@MOCInitializeDate)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM MOCInitializeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND MOCInitializeDate=@MOCInitializeDate)
									BEGIN
											PRINT 'BBBB'
										UPDATE MOCInitializeDetails SET
												 MOCInitializeDate		    = @MOCInitializeDate
												,MOC_Freeze                 = isnull(@MOC_FREEZE,'N')
												,MOC_Freeze_Date            = @MOC_FREEZE_DATE
												,ModifiedBy					= @ModifiedBy
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END 
										WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND MOCInitializeDate=@MOCInitializeDate
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO MOCInitializeDetails
												(
													 MOCInitializeDate
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModified
													,ApprovedBy
													,DateApproved
													,MOC_Freeze            
												    ,MOC_Freeze_Date     
												)

										SELECT
													Cast(@MOCInitializeDate as date)
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													--,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END --updated by vinit
													,@DateModified 
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													,isnull(@MOC_FREEZE,'N')
													,@MOC_FREEZE_DATE 
												----------------------SYSDATAMatrix  Update
												
												UPDATE SYSDATAMATRIX 
												SET MOC_Initialised='Y' 
												WHERE ExtDate=Cast(@MOCInitializeDate as Date) and ISNULL(MOC_Initialised,'N')='N'	

												----------------------------
													
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE MOCInitializeDetails SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND MOCInitializeDate=@MOCInitializeDate
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO MOCInitializeDateMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

MOCInitializeDateMaster_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO MOCInitializeDetails_Mod  
											( 
												MOCInitializeDate
												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy
												,DateApproved
												,MOC_Freeze              
												,MOC_Freeze_Date    							
											)
								VALUES
											( 
													Cast(@MOCInitializeDate as Date)
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													--,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END --updated by vinit
													,@DateModified
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													--,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END --Updated By Vinit
													,@DateApproved 
													,isnull(@MOC_FREEZE,'N')
													,@MOC_FREEZE_DATE 
											) 

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO MOCInitializeDateMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO MOCInitializeDateMaster_Insert_Edit_Delete
					END
					

				
	END



	-------------------
PRINT 7
		COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM MOCInitializeDetails WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND MOCInitializeDate=@MOCInitializeDate

		IF @OperationFlag =3
			BEGIN
				SET @Result=0
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

--END
GO