﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[CollateralOwnerTypeInUp]
						 @CollateralOwnerTypeAltKey			 INT	= 0
						,@OwnerID							 VARCHAR(20)=''
						,@OwnerShipType						 CHAR(25)=''
						,@CollOwnerDescription				 VARCHAR(500)=''
					    						
						
						---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
						,@MenuID					INT		= 0
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
						@AuthorisationStatus		CHAR(2)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
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

				SET @ScreenName = 'CollateralOwnerTypeMaster'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	--SET @CollateralOwnerTypeAltKey = (Select ISNULL(Max(CollateralOwnerTypeAltKey),0)+1 from DimCollateralOwnerType)
												
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
					SELECT  1 FROM DimCollateralOwnerType WHERE CollateralOwnerTypeAltKey = @CollateralOwnerTypeAltKey AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM DimCollateralOwnerType_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		----ELSE
		----	BEGIN
		----	   PRINT 3
		---		SELECT @CollateralOwnerTypeAltKey=NEXT VALUE FOR Seq_CollateralOwnerTypeAltKey
		----		PRINT @CollateralOwnerTypeAltKey
		----	END
		---------------------Added on 29/05/2020 for user allocation rights
		/*
		IF @AccessScopeAlt_Key in (1,2)
		BEGIN
		PRINT 'Sunil'

		IF EXISTS(				                
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@CollateralOwnerTypeAltKey AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					And IsChecker='N'
				)	
				BEGIN
				   PRINT 2
					SET @Result=-6
					RETURN @Result -- USER SHOULD HAVE CHECKER RIGHTS 
				END
		END

		
		IF @AccessScopeAlt_Key in (3)
		BEGIN
		PRINT 'Sunil1'

		IF EXISTS(				                
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@CollateralOwnerTypeAltKey AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					And IsChecker='Y'
				)	
				BEGIN
				   PRINT 2
					SET @Result=-8
					RETURN @Result -- USER SHOULD NOT HAVE CHECKER RIGHTS 
				END
		END
		*/
----------------------------------------
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

					 SET @CollateralOwnerTypeAltKey = (Select ISNULL(Max(CollateralOwnerTypeAltKey),0)+1 from ( 
													Select CollateralOwnerTypeAltKey from DimCollateralOwnerType
													UNION 
													Select CollateralOwnerTypeAltKey from DimCollateralOwnerType_Mod)A)


					 GOTO CollateralOwnerType_Insert
					 CollateralOwnerType_Insert_Add:
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				SET @DateCreated = GETDATE()
				Set @Modifiedby=@CrModApBy   
				Set @DateModified =GETDATE() 

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
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimCollateralOwnerType  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CollateralOwnerTypeAltKey =@CollateralOwnerTypeAltKey

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimCollateralOwnerType_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CollateralOwnerTypeAltKey =@CollateralOwnerTypeAltKey 						
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimCollateralOwnerType
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CollateralOwnerTypeAltKey =@CollateralOwnerTypeAltKey

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimCollateralOwnerType_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CollateralOwnerTypeAltKey =@CollateralOwnerTypeAltKey
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO CollateralOwnerType_Insert
					CollateralOwnerType_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE DimCollateralOwnerType SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey
				

		end


	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimCollateralOwnerType_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND CollateralOwnerTypeAltKey =@CollateralOwnerTypeAltKey
						AND AuthorisationStatus in('NP','MP','DP','RM')	

---------------Added for Rejection Pop Up Screen  29/06/2020   ----------

		Print 'Sunil'

--		DECLARE @EntityKey as Int 
--SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
--					 FROM DimCollateralOwnerType_Mod 
--								WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
--									AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey And ISNULL(AuthorisationStatus,'A')='R'
		
--	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
		

--------------------------------

				IF EXISTS(SELECT 1 FROM DimCollateralOwnerType WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey)
				BEGIN
					UPDATE DimCollateralOwnerType
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CollateralOwnerTypeAltKey =@CollateralOwnerTypeAltKey
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimCollateralOwnerType_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey 

	END

	ELSE IF @OperationFlag=16 OR @AuthMode='N'
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
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM DimCollateralOwnerType 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey 
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END
			END	
			
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'
				BEGIN
				    Print 'B'
					DECLARE @DelStatus CHAR(2)
					DECLARE @CurrRecordFromTimeKey smallint=0

					Print 'C'
					SELECT @ExEntityKey= MAX(EntityKey) FROM DimCollateralOwnerType_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey
							AND AuthorisationStatus IN('NP','MP','DP','RM')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM DimCollateralOwnerType_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DimCollateralOwnerType_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey
							AND AuthorisationStatus IN('NP','MP','DP','RM')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimCollateralOwnerType_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE DimCollateralOwnerType_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP'                     
					BEGIN	
						UPDATE DimCollateralOwnerType_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey
							AND AuthorisationStatus in('NP','MP','DP','RM')
						
						IF EXISTS(SELECT 1 FROM DimCollateralOwnerType WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey)
						BEGIN
								UPDATE DimCollateralOwnerType
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimCollateralOwnerType_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey				
									AND AuthorisationStatus in('NP','MP','RM')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimCollateralOwnerType WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimCollateralOwnerType WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimCollateralOwnerType SET
										         OwnerID							= @OwnerID
												,OwnerShipType						= @OwnerShipType
												,CollOwnerDescription				= @CollOwnerDescription
												,ModifiedBy							= @ModifiedBy
												,DateModified						= @DateModified
												,ApprovedBy							= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved						= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus				= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO DimCollateralOwnerType
												(
												     CollateralOwnerTypeAltKey
													,OwnerID
													,OwnerShipType
													,CollOwnerDescription
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModified
													,ApprovedBy
													,DateApproved
													
												)

										SELECT
													@CollateralOwnerTypeAltKey
													,@OwnerID
													,@OwnerShipType
													,@CollOwnerDescription
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END

													
													
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimCollateralOwnerType SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO CollateralOwnerType_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

CollateralOwnerType_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO DimCollateralOwnerType_Mod  
											( 
												CollateralOwnerTypeAltKey
												,OwnerID
												,OwnerShipType
												,CollOwnerDescription
												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy
												,DateApproved
																								
											)
								VALUES
											( 
													@CollateralOwnerTypeAltKey
													,@OwnerID
													,@OwnerShipType
													,@CollOwnerDescription
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													
											)
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO CollateralOwnerType_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO CollateralOwnerType_Insert_Edit_Delete
					END
					

				
	END



	-------------------
PRINT 7
		--COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimCollateralOwnerType WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND CollateralOwnerTypeAltKey=@CollateralOwnerTypeAltKey

		
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
GO