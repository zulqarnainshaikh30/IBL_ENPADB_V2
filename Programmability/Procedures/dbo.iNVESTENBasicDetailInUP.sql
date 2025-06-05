SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Proc [dbo].[iNVESTENBasicDetailInUP]

@BranchCode	varchar	(10) = '',
@InvEntityId	int	 = 0,
@InvID	varchar	(30) = '',
@IssuerEntityId	int	= 0,
@RefIssuerID	varchar	(30) = '',
@EntityKey                          INT        =0,
@ISIN	varchar	(12) = '',
@InstrTypeAlt_Key	tinyint	 = 0,
@InstrName	varchar	(100) = '',
@InvestmentNature	varchar	(25) = '',
@InternalRating	tinyint	 = 0,
@InRatingDate	varchar	(10) = '',
@InRatingExpiryDate	varchar	(10) = '',
@ExRating	tinyint	 = 0,
@ExRatingAgency	tinyint	 = 0,
@ExRatingDate	varchar	(10) = '',
@ExRatingExpiryDate	varchar	(10) = '',
@Sector	varchar	(25) = '',
@Industry_AltKey	tinyint	 = 0,
@ListedStkExchange	char	(1),
@ExposureType	varchar	(25) = '',
@SecurityValue	decimal	(18,2)   =0.0,
@MaturityDt varchar	(10) = '',
@ReStructureDate	varchar	(10) = '',
@MortgageStatus	char	(1) ='',
@NHBStatus	char	(1) ='',
@ResiPurpose	char	(1) =''
,@ScrCrError                         VARCHAR(100)    =''
 ,@ExEntityKey  INT=0


,@Remark					          VARCHAR(500)	   =''

,@MenuID					          INT		   =0

,@OperationFlag				          TINYINT		   =0

,@AuthMode					          CHAR(1)		   ='N'

,@IsMOC						          CHAR(1)		   ='N'

,@EffectiveFromTimeKey		          INT			   =0		

,@EffectiveToTimeKey		          INT			   =0

,@TimeKey					          INT			   =0

,@CrModApBy					          VARCHAR(20)	   =''

,@D2Ktimestamp				          INT			   =0 OUTPUT	

,@Result					          INT			   =0 OUTPUT

,@BlnSCD2ForInvestmentBasicDetail	      CHAR(1)		   ='Y'

,@Basic_ChangeFields				  VARCHAR(250)		=''

AS BEGIN

	Declare


  @AuthorisationStatus CHAR(2)=NULL		

 ,@CreatedBy VARCHAR(20) =NULL

 ,@DATECreated SMALLDATETIME=NULL

 ,@Modifiedby VARCHAR(20) =NULL

 ,@DateModified SMALLDATETIME=NULL

 ,@ApprovedBy  VARCHAR(20)=NULL

 ,@DateApproved  SMALLDATETIME=NULL

 ,@ExAccount_Key  INT=0

 ,@ErrorHandle int=0   

--FOR MOC

 ,@MocFromTimeKey INT=0

 ,@MocToTimeKey INT=0

 ,@MocTypeAlt_Key    INT=0

 ,@MocDate          DATETIME=NULL





Set @InRatingDate			=Convert(date,NULLIF(@InRatingDate,''),103)

Set @InRatingExpiryDate	=Convert(date,NULLIF(@InRatingExpiryDate,''),103 )

Set @ExRatingDate		    =Convert(date,NULLIF(@ExRatingDate,''),103 )

Set @ExRatingExpiryDate			    =Convert(date,NULLIF(@ExRatingExpiryDate,''),103)

Set @MaturityDt		=Convert(date,NULLIF(@MaturityDt,''),103)

Set @ReStructureDate		=Convert(date,NULLIF(@ReStructureDate,''),103)

Set @MocDate			=Convert(date,NULLIF(@MocDate,''),103)





PRINT 'InvestmentBasicDetailInUP'



 DECLARE @AppAvail CHAR

		SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE ParameterAlt_Key=6)

		IF(@AppAvail='N')                         

			BEGIN

					SET @Result=-11

					RETURN @Result

			END

			
	

IF @OperationFlag=1  --- add

	BEGIN

	PRINT 5

		-----CHECK DUPLICATE BILL NO AT BRANCH LEVEL

		IF EXISTS(				                

					SELECT  1 FROM CurDat.InvestmentBasicDetail WHERE InvId=@InvId AND ISNULL(AuthorisationStatus,'A')='A' AND (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)

					UNION

					SELECT  1 FROM InvestmentBasicDetail_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)

															AND InvId=@InvId

															AND  AuthorisationStatus in('NP','MP','DP','A','RM') 

				)	

				BEGIN

				   PRINT 2

					SET @Result=-6

					RETURN @Result -- CUSTOMERID ALEADY EXISTS

				END

		ELSE

			BEGIN

			   PRINT 3

				IF 'AUSFB'=(SELECT ParameterValue from SysSolutionParameter WHERE ParameterName= 'ClientName')

				--SELECT * from SysSolutionParameter WHERE ParameterName= 'ClientName'

					BEGIN

					            SELECT @InvEntityId=ISNULL(MAX(InvEntityId),0)+1 FROM

                               (

                                  SELECT MAX(InvEntityId)InvEntityId FROM CURDAT.InvestmentBasicDetail

                                  UNION

                                  SELECT MAX(InvEntityId) FROM InvestmentBasicDetail_mod

								  --EntityID asked to sunil sir for mod taBle 

                               )A



                            SET @Result=@InvEntityId

						  

					END



				ELSE            

					BEGIN 



						SELECT @InvEntityId=NEXT VALUE FOR Seq_InvEntityId

						PRINT @InvEntityId



					END

			END

	END



BEGIN TRY

BEGIN TRANSACTION		

		

If (@OperationFlag IN(1,2,3)And @AuthMode='Y')

     Begin

	       Print 4

		   If @OperationFlag=1

		     Begin

			        PRINT 5

				   Set @CreatedBy=@CrModApBy

				   Set @DATECreated=GETDATE()

				   Set @AuthorisationStatus='NP'

				   GOTO investmentbasicdetail_Insert

					investmentbasicdetail_Insert_Add:

			 End



		   If @OperationFlag In (2,3)

		      Begin

			       PRINT 6

				   Set @Modifiedby=@CrModApBy

				   Set @DateModified=Getdate()



				   If @AuthMode='Y'

				     Begin

					        Print 10

							If @OperationFlag=2

							   Begin

							         Print 11

									 Set @AuthorisationStatus='MP'

							   End

							Else 

							    Begin

								      Print 12

									  Set @AuthorisationStatus='DP'

								End	

								
							Select @CreatedBy=CreatedBy,@DATECreated=DateCreated

							From Curdat.InvestmentBasicDetail

							Where (EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)and InvEntityId=@InvEntityId

							

							-----Find createdby from mod table if not available in main table

							IF ISNULL(@CreatedBy,'')=''

							  Begin

							       Print 13

							        Select @CreatedBy=CreatedBy,@DATECreated=DateCreated

							        From InvestmentBasicDetail_Mod

							        Where (EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) 
									
									and InvEntityId=@InvEntityId		

							  End

							  

						   Else

						      Begin

							        Print 14

									Update Curdat.InvestmentBasicDetail

									Set AuthorisationStatus=@AuthorisationStatus

									Where (EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)and InvEntityId=@InvEntityId

							  End	

							  

							  

						  If @OperationFlag=2

						     Begin

						          Print 15

								  Update InvestmentBasicDetail_Mod

								  Set AuthorisationStatus='FM'

								     ,ModifiedBy=@Modifiedby

									 ,DateModified=@DateModified

								  Where (EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)and InvEntityId=@InvEntityId

								        And AuthorisationStatus IN('NP','MP')

						   End							

					 End    

			  End
					GOTO investmentbasicdetail_Insert
					investmentbasicdetail_Insert_EDIT_DELETE:


		 End		

			  

			  

			  

If @OperationFlag=3 AND @AuthMode ='N'

	Begin

			    Print 16

				Set @Modifiedby=@CrModApBy

				Set @DateModified=Getdate()



				Update Curdat.InvestmentBasicDetail

				Set EffectiveToTimeKey=@EffectiveFromTimeKey-1

				    ,ModifiedBy=@Modifiedby

					,DateModified=@DateModified					

				Where (EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey)and InvEntityId=@InvEntityId

	 End			

	
	
		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE InvestmentBasicDetail_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND InvEntityID =@InvEntityId
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM curdat.investmentbasicdetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND EntityKey =@EntityKey)
				BEGIN
					UPDATE curdat.InvestmentBasicDetail
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND @InvEntityId =@InvEntityId
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	




Else If @Operationflag=17

   Begin

          Print 17

		  Set @ApprovedBy=@CrModApBy

		  Set @DateApproved=Getdate()



		  DECLARE @MocAuthRec_EntityKey int=0

		  IF @IsMOC='Y'

		     Begin

			        Print 18

					---- FINDS Entity Keys of Authorized record from MOD Table

					select @MocAuthRec_EntityKey=isnull(max(EntityKey),0) From InvestmentBasicDetail_Mod

					Where (EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@TimeKey) And InvEntityId=@InvEntityId And @IsMoc='Y' And AuthorisationStatus='A'

			  End			



					Print 19

					Update InvestmentBasicDetail_Mod

					Set AuthorisationStatus='R'

					   ,ApprovedBy=@ApprovedBy

					   ,DateApproved=@DateApproved

					   ,EffectiveTotimeKey=@EffectiveFromTimeKey-1

					Where (EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@TimeKey)And InvEntityId=@InvEntityId

					      And (Case When @IsMoc='N' And AuthorisationStatus IN('NP','MP','DP','RM')Then 1

						             When @IsMoc='Y'  And EntityKey>@MocAuthRec_EntityKey And AuthorisationStatus<>'FM' Then 1  

									 End)=1   --FOR MOC Set R for Records which are not authorized & Change effective to time key



                     Print 20

				     Update Curdat.InvestmentBasicDetail

				     Set AuthorisationStatus='A'

				        ,ApprovedBy=@ApprovedBy

				  	   ,DateApproved=@DateApproved

				     where (EffectiveFromTimeKey<=@TimeKey And EffectiveToTimeKey>=@TimeKey) 

					 And InvEntityId=@InvEntityId 

					And AuthorisationStatus IN('NP','MP','RM','DP')
				   		
			 

   End

   ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE Investmentbasicdetail_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							WHERE EntityKey=@EntityKey
							AND AuthorisationStatus in('NP','MP','DP','RM')

		END


Else if @OperationFlag=18 and @AuthMode='Y'

	    Begin

		       Set @ApprovedBy=@CrModApBy

			   Set @DateApproved=Getdate()



		       Update InvestmentBasicDetail_Mod

			   Set 

			   ApprovedBy=@ApprovedBy

			   ,DateApproved=@DateApproved

			   ,AuthorisationStatus='RM'

			   Where (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND InvEntityId=@InvEntityId

			         and AuthorisationStatus in ('NP','MP','DP')

		End		


			  
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
					 FROM curdat.investmentbasicdetail 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND InvEntityId=@InvEntityId
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END
			END	
			
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'  
				BEGIN
				    --Print 'B'
					DECLARE @DelStatus CHAR(2)=''-------------20042021
					DECLARE @CurrRecordFromTimeKey smallint=0

					Print 'C'
					SELECT @ExEntityKey= MAX(EntityKey) FROM InvestmentBasicDetail_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND InvEntityId=@InvEntityId
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM InvestmentBasicDetail_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM InvestmentBasicDetail_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND EntityKey=@EntityKey
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM InvestmentBasicDetail_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE InvestmentBasicDetail_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND EntityKey=@EntityKey
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE InvestmentBasicDetail_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE EntityKey=@EntityKey
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM curdat.investmentbasicdetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND EntityKey=@EntityKey)
						BEGIN
								UPDATE curdat.investmentbasicdetail
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND EntityKey=@EntityKey

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE InvestmentBasicDetail_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE EntityKey=@EntityKey				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END

			  ----3:40----------------------------------

		  IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM curdat.investmentbasicdetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND EntityKey=@EntityKey)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM curdat.investmentbasicdetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND EntityKey=@EntityKey)
									BEGIN
											PRINT 'BBBB'
										UPDATE curdat.investmentbasicdetail SET
												 EntityKey					= @EntityKey												
												,ModifiedBy					= @ModifiedBy
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND EntityKey=@EntityKey
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO curdat.investmentbasicdetail
												(
														 EntityKey,	
														 BranchCode,
														InvEntityId,
														InvID,
														IssuerEntityId,
														RefIssuerID,
														ISIN,
														InstrTypeAlt_Key,
														InstrName,
														InvestmentNature,
														InternalRating,
														InRatingDate,
														InRatingExpiryDate,
														ExRating,
														ExRatingAgency,
														ExRatingDate,
														ExRatingExpiryDate,
														Sector,
														Industry_AltKey,
														ListedStkExchange,
														ExposureType,
														SecurityValue,
														MaturityDt,
														ReStructureDate,
														MortgageStatus,
														NHBStatus,
														ResiPurpose												
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
													@EntityKey,	
													@BranchCode,
@InvEntityId,
@InvID,
@IssuerEntityId,
@RefIssuerID
,@ISIN
,@InstrTypeAlt_Key
,@InstrName
,@InvestmentNature
,@InternalRating
,@InRatingDate
,@InRatingExpiryDate
,@ExRating
,@ExRatingAgency
,@ExRatingDate
,@ExRatingExpiryDate
,@Sector
,@Industry_AltKey
,@ListedStkExchange
,@ExposureType
,@SecurityValue
,@MaturityDt
,@ReStructureDate
,@MortgageStatus
,@NHBStatus
,@ResiPurpose
											
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
								UPDATE curdat.investmentbasicdetail SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND EntityKey=@EntityKey
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO investmentbasicdetail_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

investmentbasicdetail_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO investmentbasicdetail_Mod  
											( 
												EntityKey,	
												 BranchCode,
														InvEntityId,
														InvID,
														IssuerEntityId,
														RefIssuerID,
														ISIN,
														InstrTypeAlt_Key,
														InstrName,
														InvestmentNature,
														InternalRating,
														InRatingDate,
														InRatingExpiryDate,
														ExRating,
														ExRatingAgency,
														ExRatingDate,
														ExRatingExpiryDate,
														Sector,
														Industry_AltKey,
														ListedStkExchange,
														ExposureType,
														SecurityValue,
														MaturityDt,
														ReStructureDate,
														MortgageStatus,
														NHBStatus,
														ResiPurpose	,										
												AuthorisationStatus	
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
													@EntityKey,		
													@BranchCode,
@InvEntityId,
@InvID,
@IssuerEntityId,
@RefIssuerID
,@ISIN
,@InstrTypeAlt_Key
,@InstrName
,@InvestmentNature
,@InternalRating
,@InRatingDate
,@InRatingExpiryDate
,@ExRating
,@ExRatingAgency
,@ExRatingDate
,@ExRatingExpiryDate
,@Sector
,@Industry_AltKey
,@ListedStkExchange
,@ExposureType
,@SecurityValue
,@MaturityDt
,@ReStructureDate
,@MortgageStatus
,@NHBStatus
,@ResiPurpose											
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
						GOTO investmentbasicdetail_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO investmentbasicdetail_Insert_Edit_Delete
					END
					

				
	END



	-------------------
PRINT 7
		COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM investmentbasicdetail WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND EntityKey=@EntityKey

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

END
GO