SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:				<SNEHAL >
-- Create date:			<28/06/2018>
-- Description:			<BorrBalanceDetail Table Insert/ Update>
-- =============================================
CREATE PROCEDURE [dbo].[BorrBalanceDetailInUp]
--DECLARE
						@BorrEntityID	            int   		 = 0
						,@BorrBalanceEntityID	    int			 = 0
						,@Balance	                decimal(16,2)= 0
												---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
						,@MenuID					SMALLINT		= 0
						,@OperationFlag				TINYINT			= 0
						,@AuthMode					CHAR(1)			= 'N'
					--	,@IsMOC						CHAR(1)			= 'N'
						,@EffectiveFromTimeKey		INT		= 24909
						,@EffectiveToTimeKey		INT		= 49999
						,@TimeKey					INT		= 24909
						,@CrModApBy					VARCHAR(20)		=''
						,@D2Ktimestamp				INT				=0 OUTPUT	
						,@Result					INT				=0 OUTPUT
						--,@BranchCode				varchar(10)		
						--,@ScreenEntityId			INT				=null
	
AS
BEGIN
PRINT 'BorrBalanceDetailInUp'
PRINT @OperationFlag
	SET NOCOUNT ON;
		PRINT 1
		DECLARE 
						@AuthorisationStatus		CHAR(2)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				SMALLDATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				SMALLDATETIME	= NULL
						,@ExCustomer_Key			INT				= 0
					    ,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						---FOR MOC
						 ,@MocFromTimeKey			INT				= 0
						 ,@MocToTimeKey				INT				= 0
						 ,@MocDate					DATETIME		= NULL
						 ,@PrevAssetClassAlt_Key	SMALLINT
						 ,@PrevNPADt				DATE
						 ,@PrevConstitutionAlt_Key  SMALLINT		= 0
						 ,@PrevConstName			VARCHAR(60)
						 ,@MocStatus				CHAR(1)

	PRINT 'A'
	


			DECLARE @AppAvail CHAR
					SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF(@AppAvail='N')                         
					BEGIN
						SET @Result=-11
						RETURN @Result
					END

				

				

			--IF @IsMOC='Y'
			--	BEGIN
			--		--- for MOC Effective from TimeKey and Effective to time Key is Prev_Qtr_key e.g for 2922  2830
			--		SET @EffectiveFromTimeKey =@TimeKey 
			--		SET @EffectiveToTimeKey =@TimeKey 
			--		SET @MocDate =GETDATE()
			--	END

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE BILL NO AT BRANCH LEVEL
		IF EXISTS(				                
					SELECT  1 FROM BorrBalanceDetail 
					WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey >= @TimeKey
					AND BorrEntityID = @BorrEntityID
					--AND BorrBalanceEntityID = @BorrBalanceEntityID
					AND ISNULL(AuthorisationStatus,'A')='A' 
					UNION
					SELECT  1 FROM BorrBalanceDetail_mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
														AND BorrEntityID = @BorrEntityID
					                                    --AND BorrBalanceEntityID = @BorrBalanceEntityID
															AND  AuthorisationStatus in('NP','MP','DP','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-6
					RETURN @Result -- CUSTOMERID ALEADY EXISTS
				END
		ELSE
			BEGIN
			   PRINT 3

					--SELECT @ReportEntityId = MAX(ReportEntityId) FROM 
					--(
					--	SELECT MAX(ReportEntityId) ReportEntityId FROM ExcelUtility_RptMaster_Mod --WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey>= @TimeKey
					--	UNION
					--	SELECT MAX(ReportEntityId) ReportEntityId FROM ExcelUtility_RptMaster --WHERE EffectiveFromTimeKey <= @TimeKey AND EffectiveToTimeKey>= @TimeKey
					--)a
					--SET @ReportEntityId = ISNULL(@ReportEntityId,0)+1
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
					 SET @DateCreated = GETDATE()
					 SET @AuthorisationStatus='NP'
					 GOTO TopManagementProfile_Insert
					TopManagementProfile_Insert_Add:
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
					FROM BorrBalanceDetail   
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND BorrEntityID = @BorrEntityID
					    --AND BorrBalanceEntityID = @BorrBalanceEntityID

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM BorrBalanceDetail_mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND BorrEntityID = @BorrEntityID
					        --AND BorrBalanceEntityID = @BorrBalanceEntityID		
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE BorrBalanceDetail 
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BorrEntityID = @BorrEntityID
					            --AND BorrBalanceEntityID = @BorrBalanceEntityID

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE BorrBalanceDetail_mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BorrEntityID = @BorrEntityID
					            --AND BorrBalanceEntityID = @BorrBalanceEntityID
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO TopManagementProfile_Insert
					TopManagementProfile_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
							PRINT ' 3 Deleteing'	
							PRINT @TImekey			
							PRINT @BorrEntityID
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						

						UPDATE BorrBalanceDetail  SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
								AND BorrEntityID = @BorrEntityID
					            --AND BorrBalanceEntityID = @BorrBalanceEntityID
				
						PRINT CAST(@@ROWCOUNT AS VARCHAR(2)) + 'Row Deleted'
		end
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE BorrBalanceDetail_mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND BorrEntityID = @BorrEntityID
					    --AND BorrBalanceEntityID = @BorrBalanceEntityID
						AND AuthorisationStatus in('NP','MP','DP','RM')	

				IF EXISTS(SELECT 1 FROM BorrBalanceDetail  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
					AND BorrEntityID = @BorrEntityID
					--AND BorrBalanceEntityID = @BorrBalanceEntityID	
					)
				BEGIN
					UPDATE BorrBalanceDetail 
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND BorrEntityID = @BorrEntityID
					        --AND BorrBalanceEntityID = @BorrBalanceEntityID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE BorrBalanceDetail_mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND BorrEntityID = @BorrEntityID
	    --AND BorrBalanceEntityID = @BorrBalanceEntityID	

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
					 FROM BorrBalanceDetail  
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND BorrEntityID = @BorrEntityID
					        --AND BorrBalanceEntityID = @BorrBalanceEntityID
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END



			END	 
			
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'
				BEGIN
				    Print 'B'
					PRINT @AuthMode
					DECLARE @DelStatus CHAR(2)
					DECLARE @CurrRecordFromTimeKey smallint=0
					
					Print 'C'
	
					SELECT @ExEntityKey= MAX(EntityKey) FROM BorrBalanceDetail_mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND BorrEntityID = @BorrEntityID
					        --AND BorrBalanceEntityID = @BorrBalanceEntityID	
							AND AuthorisationStatus IN('NP','MP','DP','RM')	
					
					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM BorrBalanceDetail_mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM BorrBalanceDetail_mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND BorrEntityID = @BorrEntityID
					        --AND BorrBalanceEntityID = @BorrBalanceEntityID	
							AND AuthorisationStatus IN('NP','MP','DP','RM')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM BorrBalanceDetail_mod
							WHERE EntityKey=@ExEntityKey

					UPDATE BorrBalanceDetail_mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND BorrEntityID = @BorrEntityID
					    --AND BorrBalanceEntityID = @BorrBalanceEntityID	
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE BorrBalanceDetail_mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE   BorrEntityID = @BorrEntityID
					    --AND BorrBalanceEntityID = @BorrBalanceEntityID	
							AND AuthorisationStatus in('NP','MP','DP','RM')
						
						IF EXISTS(SELECT 1 FROM BorrBalanceDetail
								 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND BorrEntityID = @BorrEntityID
					                    --AND BorrBalanceEntityID = @BorrBalanceEntityID
										)
						BEGIN
								UPDATE BorrBalanceDetail
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND BorrEntityID = @BorrEntityID
					                        --AND BorrBalanceEntityID = @BorrBalanceEntityID
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE BorrBalanceDetail_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE   BorrEntityID = @BorrEntityID
					                   --AND BorrBalanceEntityID = @BorrBalanceEntityID
									AND AuthorisationStatus in('NP','MP','RM')
					END		
				END

		PRINT @DelStatus+'authorization status'

		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						PRINT @DelStatus +'Del'
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
						
						IF EXISTS(SELECT 1 FROM BorrBalanceDetail 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									   AND BorrEntityID = @BorrEntityID
					                   --AND BorrBalanceEntityID = @BorrBalanceEntityID
									   )
							BEGIN
								SET @IsAvailable='Y'
								SET @AuthorisationStatus='A'

							

							 IF EXISTS(SELECT 1 FROM BorrBalanceDetail 
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												 AND EffectiveFromTimeKey=@EffectiveFromTimeKey 
												 AND BorrEntityID = @BorrEntityID
					                             --AND BorrBalanceEntityID = @BorrBalanceEntityID
												 )
									BEGIN
											
											PRINT 'BBBB'
										UPDATE BorrBalanceDetail  SET
																
												 BorrEntityID			    = @BorrEntityID
												--,BorrBalanceEntityID		= @BorrBalanceEntityID
												,Balance                    = @Balance
												,ModifiedBy					= @ModifiedBy
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey 
												AND BorrEntityID = @BorrEntityID
					                            --AND BorrBalanceEntityID = @BorrBalanceEntityID
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										PRINT @IsAvailable+' IsAvailable'
										PRINT 'MAIN INSERT 1'
										INSERT INTO BorrBalanceDetail
												(
													 BorrEntityID			  
													--,BorrBalanceEntityID		
													,Balance                  			
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
													 @BorrEntityID			  
													--,@BorrBalanceEntityID		
													,@Balance                   
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @IsAvailable = 'Y'	THEN @ModifiedBy	ELSE NULL END
													,CASE WHEN @IsAvailable = 'Y'	THEN @DateModified	ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y'		THEN @ApprovedBy	ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y'		THEN @DateApproved	ELSE NULL END
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE BorrBalanceDetail SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
										--,ServiceLastdate = @ServiceLastdate	 --ADDED BY HAMID ON 16 MAR 2018
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
									 AND BorrEntityID = @BorrEntityID
					                 --AND BorrBalanceEntityID = @BorrBalanceEntityID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO TopManagementProfile_Insert
					HistoryRecordInUp:
			END						



		END 

	----***********maintain log table

		--****************************
PRINT 6
SET @ErrorHandle=1

TopManagementProfile_Insert:
IF @ErrorHandle=0
	BEGIN
			--SELECT @ServiceLastdate
			INSERT INTO BorrBalanceDetail_mod  
											( 
												 BorrEntityID			  
												--,BorrBalanceEntityID		
												,Balance                  
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
													  @BorrEntityID			  
													--,@BorrBalanceEntityID		
													,@Balance                  
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,@ModifiedBy
													,@DateModified
													,@ApprovedBy 
													,@DateApproved 
												
											)




		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO TopManagementProfile_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO TopManagementProfile_Insert_Edit_Delete
					END
					

				
	END




	-------------------
PRINT 7
		COMMIT TRANSACTION

		SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM BorrBalanceDetail 
		WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
			 AND BorrEntityID = @BorrEntityID
	         --AND BorrBalanceEntityID = @BorrBalanceEntityID

		IF @OperationFlag =3
			BEGIN
				SET @Result = 3
				 RETURN @Result
			END
		ELSE
			BEGIN
			PRINT 8
				SET @Result = @BorrEntityID
				 RETURN @Result
				--RETURN @MgmtProfileEntityId
			END
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	SELECT ERROR_MESSAGE()
	RETURN -1

END CATCH
---------
END
GO