﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[SecurityChargeMasterInUp]
						
						
						@SecurityMappingAlt_Key               int=0 ,			
						@SrcSysSecurityChargeTypeCode		  varchar(50)='',
						@SrcSysSecurityChargeTypeName		  varchar(50)='',
						@SecurityChargeTypeName				  varchar(100)='',
						@SecurityChargeTypeAlt_key			  int=0,
						@SecurityChargeMaster_changeFields      Varchar(100)=NULL
						
						
						
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
						@AuthorisationStatus		VARCHAR(5)			= NULL 
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

				SET @ScreenName = 'SecurityChargeStatusMaster'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
												
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
					SELECT  1 FROM DimSecurityChargeTypeMapping WHERE SecurityMappingAlt_Key = @SecurityMappingAlt_Key
					AND SrcSysSecurityChargeTypeCode=@SrcSysSecurityChargeTypeCode 
					AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM DimSecurityChargeTypeMapping_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND SecurityMappingAlt_Key = @SecurityMappingAlt_Key
															AND SrcSysSecurityChargeTypeCode=@SrcSysSecurityChargeTypeCode
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
				--SELECT @BankRPAlt_Key=NEXT VALUE FOR Seq_BankRPAlt_Key
				--PRINT @BankRPAlt_Key
				 SET @SecurityMappingAlt_Key = (Select ISNULL(Max(SecurityMappingAlt_Key),0)+1 from 
												(Select SecurityMappingAlt_Key from DimSecurityChargeTypeMapping
												 UNION 
												 Select SecurityMappingAlt_Key from DimSecurityChargeTypeMapping_Mod
												)A)
			END
		---------------------Added on 29/05/2020 for user allocation rights
		/*
		IF @AccessScopeAlt_Key in (1,2)
		BEGIN
		PRINT 'Sunil'

		IF EXISTS(				                
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@BankRPAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@BankRPAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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

					 --SET @SecurityMappingAlt_Key = (Select ISNULL(Max(SecurityMappingAlt_Key),0)+1 from 
						--						(Select SecurityMappingAlt_Key from DimSecurityChargeTypeMapping
						--						 UNION 
						--						 Select SecurityMappingAlt_Key from DimSecurityChargeTypeMapping_Mod
						--						)A)

					 GOTO SecurityChargeStatusMaster_Insert
					SecurityChargeStatusMaster_Insert_Add:
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
					FROM DimSecurityChargeTypeMapping  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SecurityMappingAlt_Key =@SecurityMappingAlt_Key

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimSecurityChargeTypeMapping_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SecurityMappingAlt_Key =@SecurityMappingAlt_Key
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimSecurityChargeTypeMapping
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND SecurityMappingAlt_Key =@SecurityMappingAlt_Key

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimSecurityChargeTypeMapping_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModifie=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND SecurityMappingAlt_Key =@SecurityMappingAlt_Key
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO SecurityChargeStatusMaster_Insert
					SecurityChargeStatusMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE DimSecurityChargeTypeMapping SET
									ModifiedBy =@Modifiedby 
									,DateModifie =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key
				

		end

		--------------------------------------------------------
		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimSecurityChargeTypeMapping_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND SecurityMappingAlt_Key =@SecurityMappingAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimSecurityChargeTypeMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                             AND SecurityMappingAlt_Key =@SecurityMappingAlt_Key)
				BEGIN
					UPDATE DimSecurityChargeTypeMapping
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SecurityMappingAlt_Key =@SecurityMappingAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

		---------------------------------------------
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimSecurityChargeTypeMapping_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND SecurityMappingAlt_Key =@SecurityMappingAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM')	

---------------Added for Rejection Pop Up Screen  29/06/2020   ----------

		Print 'Sunil'

--		DECLARE @EntityKey as Int 
--		SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
--							 FROM DimBankRP_Mod 
--								WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
--									AND BankRPAlt_Key=@BankRPAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
		
--	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
		

--------------------------------

				IF EXISTS(SELECT 1 FROM DimSecurityChargeTypeMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key)
				BEGIN
					UPDATE DimSecurityChargeTypeMapping
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SecurityMappingAlt_Key =@SecurityMappingAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimSecurityChargeTypeMapping_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key

	END
	------------------------------------------------------------
	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE DimSecurityChargeTypeMapping_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							WHERE SecurityMappingAlt_Key=@SecurityMappingAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM')

		END
	-------------------------------------------------------------

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
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM DimSecurityChargeTypeMapping 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM DimSecurityChargeTypeMapping_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModifie
					 FROM DimSecurityChargeTypeMapping_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DimSecurityChargeTypeMapping_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimSecurityChargeTypeMapping_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE DimSecurityChargeTypeMapping_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimSecurityChargeTypeMapping_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE SecurityMappingAlt_Key=@SecurityMappingAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimSecurityChargeTypeMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key)
						BEGIN
								UPDATE DimSecurityChargeTypeMapping
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModifie=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimSecurityChargeTypeMapping_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE SecurityMappingAlt_Key=@SecurityMappingAlt_Key				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimSecurityChargeTypeMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimSecurityChargeTypeMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimSecurityChargeTypeMapping SET
												 SecurityMappingAlt_Key         = @SecurityMappingAlt_Key         
												,SrcSysSecurityChargeTypeCode	= @SrcSysSecurityChargeTypeCode	
												,SrcSysSecurityChargeTypeName	= @SrcSysSecurityChargeTypeName	
												,SecurityChargeTypeName			= @SecurityChargeTypeName			
												,SecurityChargeTypeAlt_key		= @SecurityChargeTypeAlt_key
												,ModifiedBy						= @ModifiedBy
												,DateModifie					= @DateModified
												,ApprovedBy						= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved					= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus			= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO DimSecurityChargeTypeMapping
												(
													 SecurityMappingAlt_Key         
													,SrcSysSecurityChargeTypeCode	
													,SrcSysSecurityChargeTypeName	
													,SecurityChargeTypeName			
													,SecurityChargeTypeAlt_key	
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModifie
													,ApprovedBy
													,DateApproved
													
												)

										SELECT
													@SecurityMappingAlt_Key         
													,@SrcSysSecurityChargeTypeCode	
													,@SrcSysSecurityChargeTypeName	
													,@SecurityChargeTypeName			
													,@SecurityChargeTypeAlt_key	
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
								UPDATE DimSecurityChargeTypeMapping SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND SecurityMappingAlt_Key=@SecurityMappingAlt_Key
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO SecurityChargeStatusMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

SecurityChargeStatusMaster_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO DimSecurityChargeTypeMapping_Mod  
											( 
												 SecurityMappingAlt_Key         
												,SrcSysSecurityChargeTypeCode	
												,SrcSysSecurityChargeTypeName	
												,SecurityChargeTypeName			
												,SecurityChargeTypeAlt_key	
												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModifie
												,ApprovedBy
												,DateApproved
																								
											)
								VALUES
											( 
													
													@SecurityMappingAlt_Key         
													,@SrcSysSecurityChargeTypeCode	
													,@SrcSysSecurityChargeTypeName	
													,@SecurityChargeTypeName			
													,@SecurityChargeTypeAlt_key	
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
						GOTO SecurityChargeStatusMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO SecurityChargeStatusMaster_Insert_Edit_Delete
					END
					

				
	END
-------------------------------------Attendance Log----------------------------	
	IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
		BEGIN
					print 'log table'

		          declare @DateCreated1 datetime
				SET	@DateCreated1     =Getdate()

				--declare @ReferenceID1 varchar(max)
				--set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @SourceAlt_Key else @SourceAlt_Key end)


					IF @OperationFlag IN(16,17,18,20,21) 
						BEGIN 
						       Print 'Authorised'
					
			
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@SrcSysSecurityChargeTypeCode ,-- ReferenceID ,
								@CreatedBy=NULL,
								@ApprovedBy=@CrModApBy, 
								@CreatedCheckedDt=@DateCreated1,
								@Remark=NULL,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END
					ELSE
						BEGIN
						       Print 'UNAuthorised'
						    -- Declare
						    -- set @CreatedBy  =@UserLoginID
							 
							EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
								@BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@SrcSysSecurityChargeTypeCode ,-- ReferenceID ,
								@CreatedBy=@CrModApBy,
								@ApprovedBy=NULL, 						
								@CreatedCheckedDt=@DateCreated1,
								@Remark=NULL,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END

		END
---------------------------------------------------------------------------------------



	-------------------
PRINT 7
		COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimBankRP WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND BankRPAlt_Key=@BankRPAlt_Key

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