SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--/****** Object:  StoredProcedure [dbo].[InvestmentFinancialDetailInUP]    Script Date: 9/24/2021 8:20:04 PM ******/
--DROP PROCEDURE [dbo].[InvestmentFinancialDetailInUP]
--GO
--/****** Object:  StoredProcedure [dbo].[InvestmentFinancialDetailInUP]    Script Date: 9/24/2021 8:20:04 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Create PROCEDURE [dbo].[InvestmentFinancialDetailInUP]


						 @Entitykey			bigint  =0
						,@InvEntityId		int   =0
						,@InvID				Varchar (100)				    = ''
						,@IssuerID			Varchar (100)				    = ''
						,@HoldingNature		char(3)				= '0'
						,@CurrencyAlt_Key	TINYINT				= 0
						,@CurrencyConvRate  decimal	(18,2)		=0.0
						,@BookType			varchar(25)			=''
						,@BookValue			decimal	(18,2)		=0.0
						,@BookValueINR		decimal	(18,2)		=0.0
						,@MTMValue			decimal	(18,2)		=0.0
						,@MTMValueINR		decimal	(18,2)		=0.0
						,@EncumberedMTM		decimal	(18,2)		=0.0
						,@AssetClass_AltKey	TINYINT				= 0
						,@NPIDt				VARCHAR(20)			= NULL
						,@DBTDate			VARCHAR(20)			= NULL
						,@LatestBSDate			VARCHAR(20)			= NULL
						,@Interest_DividendDueDate			VARCHAR(20)			= NULL
						,@Interest_DividendDueAmount		DECImAL(18,2) = 0.0
						,@PartialRedumptionDueDate			VARCHAR(20)			= NULL
						,@PartialRedumptionSettledY_N		char(1)  ='N'
						,@DegradationFlag					char(1)  ='N'
						,@DegradationReason					VARCHAR(50)			= NULL
						,@DPD								VARCHAR(20)			= NULL
						,@UpgradationFlag					char(1)  ='N' 
						,@UpgradationDate					VARCHAR(20)			= NULL


						---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
						--,@MenuID					SMALLINT		= 0  change to Int
						,@MenuID                    Int				=0
						,@OperationFlag				TINYINT			= 0
						,@AuthMode					CHAR(1)			= 'N'
						,@Authlevel					VARCHAR(3)		=''
						,@EffectiveFromTimeKey		INT				= 0
						,@EffectiveToTimeKey		INT				= 0
						,@TimeKey					INT				= 0
						,@CrModApBy					VARCHAR(20)		=''
						,@ScreenEntityId			INT				=null
						,@Result					INT				=0 OUTPUT
						,@Financial_ChangeFields					VARCHAR(250)=''	
						
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
						@AuthorisationStatus		varchar(5)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				SMALLDATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				SMALLDATETIME	= NULL
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						

	-------------------------------------------------------------
	


 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999


	SET @Entitykey = (Select ISNULL(Max(Entitykey),0)+1 from curdat.InvestmentfINANCIALDetail)

		Select  @InvEntityId= InvEntityId 
	from InvestmentFinancialDetail_mod
	where RefInvID=@InvID


									

	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
												
	PRINT 'A'
	

			DECLARE @AppAvail CHAR
					SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF(@AppAvail='N')                         
					BEGIN
						SET @Result=-11
						--return @Result
					END

				

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
	
	
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM curdat.InvestmentFinancialDetail WHERE  RefInvID=@InvID AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM InvestmentFinancialDetail_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															 AND RefInvID=@InvID
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM','1A') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					return @Result -- USER ALEADY EXISTS
				END
		
		--BEGIN 
		--				SELECT @InvEntityId= NEXT VALUE FOR Seq_FinancialEntityId
		--				PRINT @InvEntityId

		--			END
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

					 SET @InvEntityId = (Select ISNULL(Max(InvEntityId),0)+1 from 
												(Select InvEntityId from curdat.InvestmentFinancialDetail
												 UNION 
												 Select InvEntityId from InvestmentFinancialDetail_Mod
												)A)

					 GOTO IssuerIDMaster_Insert
					IssuerIDMaster_Insert_Add:
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				SET @DateCreated = GETDATE()
				Set @Modifiedby=@CrModApBy   
				Set @DateModified =GETDATE() 
				SET @Entitykey = (Select ISNULL(Max(Entitykey),0)+1 from investMentFinancialdetail_Mod)
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
					FROM curdat.InvestmentFinancialDetail  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND InvEntityId =@InvEntityId
							 AND RefInvID=@InvID
				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM InvestmentFinancialDetail_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND InvEntityId =@InvEntityId  AND RefInvID=@InvID
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE curdat.InvestmentFinancialDetail
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND InvEntityId =@InvEntityId AND RefInvID=@InvID

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE InvestmentFinancialDetail_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND InvEntityId =@InvEntityId  AND RefInvID=@InvID
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO IssuerIDMaster_Insert
					IssuerIDMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE curdat.InvestmentFinancialDetail SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND InvEntityId=@InvEntityId  AND RefInvID=@InvID
				

		end


-------------------------------------------------------
--start 20042021
ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE InvestmentFinancialDetail_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND InvEntityId =@InvEntityId  AND RefInvID=@InvID
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM curdat.InvestmentFinancialDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND InvEntityId=@InvEntityId)
				BEGIN
					UPDATE curdat.InvestmentFinancialDetail
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND InvEntityId =@InvEntityId  AND RefInvID=@InvID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	


--till here
-------------------------------------------------------

	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE InvestmentFinancialDetail_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND InvEntityId =@InvEntityId  AND RefInvID=@InvID
						AND AuthorisationStatus in('NP','MP','DP','RM')	


--------------------------------

				IF EXISTS(SELECT 1 FROM curdat.InvestmentFinancialDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND InvEntityId=@InvEntityId)
				BEGIN
					UPDATE curdat.InvestmentFinancialDetail
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND InvEntityId =@InvEntityId  AND RefInvID=@InvID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE InvestmentFinancialDetail_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND InvEntityId=@InvEntityId
		 AND RefInvID=@InvID 
	END

	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE			InvestmentFinancialDetail_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							WHERE InvEntityId=@InvEntityId  AND RefInvID=@InvID
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
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM curdat.InvestmentFinancialDetail 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND InvEntityId=@InvEntityId
							 AND RefInvID=@InvID
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM InvestmentFinancialDetail_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND InvEntityId=@InvEntityId  AND RefInvID=@InvID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM InvestmentFinancialDetail_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM InvestmentFinancialDetail_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND InvEntityId=@InvEntityId  AND RefInvID=@InvID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM InvestmentFinancialDetail_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE InvestmentFinancialDetail_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND InvEntityId=@InvEntityId  AND RefInvID=@InvID
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE InvestmentFinancialDetail_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE InvEntityId=@InvEntityId  AND RefInvID=@InvID
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM curdat.InvestmentFinancialDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND InvEntityId=@InvEntityId  AND RefInvID=@InvID)
						BEGIN
								UPDATE curdat.InvestmentFinancialDetail
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND InvEntityId=@InvEntityId  AND RefInvID=@InvID

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE InvestmentFinancialDetail_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE InvEntityId=@InvEntityId		  AND RefInvID=@InvID		
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END

		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM curdat.InvestmentFinancialDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND InvEntityId=@InvEntityId  AND RefInvID=@InvID)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM curdat.InvestmentFinancialDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND InvEntityId=@InvEntityId  AND RefInvID=@InvID)
									BEGIN
											PRINT 'BBBB'
										UPDATE curdat.InvestmentFinancialDetail SET
											 HoldingNature					=	@HoldingNature		
											,CurrencyAlt_Key				=	@CurrencyAlt_Key	
											,CurrencyConvRate				=	@CurrencyConvRate  
											,BookType						=	@BookType			
											,BookValue						=	@BookValue			
											,BookValueINR					=	@BookValueINR		
											,MTMValue						=	@MTMValue			
											,MTMValueINR					=	@MTMValueINR		
											,EncumberedMTM					=	@EncumberedMTM		
											,AssetClass_AltKey				=	@AssetClass_AltKey	
											,NPIDt							=	@NPIDt		
											,DBTDate						=	@DBTDate
											,LatestBSDate					=	@LatestBSDate
											,Interest_DividendDueDate		=	@Interest_DividendDueDate
											,Interest_DividendDueAmount		=	@Interest_DividendDueAmount
											,PartialRedumptionDueDate		=	@PartialRedumptionDueDate
											,PartialRedumptionSettledY_N	=	@PartialRedumptionSettledY_N	
											,FLGDEG							=	@DegradationFlag					
											,DEGREASON						=	@DegradationReason					
											,DPD							=	@DPD								
											,FLGUPG							=	@UpgradationFlag					
											,UpgDate						=	@UpgradationDate																
											,ModifiedBy						=	@ModifiedBy
											,DateModified					=	@DateModified
											,ApprovedBy						=	CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
											,DateApproved					=	CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
											,AuthorisationStatus			=	CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
											 WHERE	(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
											AND		EffectiveFromTimeKey=@EffectiveFromTimeKey AND InvEntityId=@InvEntityId  AND RefInvID=@InvID
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO curdat.InvestmentFinancialDetail
												(	
													--Entitykey
													InvEntityID
													,RefInvID
													,RefIssuerID
													,HoldingNature			
													,CurrencyAlt_Key		
													,CurrencyConvRate	  
													,BookType						
													,BookValue						
													,BookValueINR				
													,MTMValue					
													,MTMValueINR			
													,EncumberedMTM			
													,AssetClass_AltKey	
													,NPIDt								
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModified
													,ApprovedBy
													,DateApproved
													,DBTDate
													,LatestBSDate
													,Interest_DividendDueDate
													,Interest_DividendDueAmount
													,PartialRedumptionDueDate
													,PartialRedumptionSettledY_N
													,FLGDEG
													,DEGREASON
													,DPD
													,FLGUPG
													,UpgDate			
												)

										SELECT		-- @Entitykey
													@InvEntityID
													,@InvID
													,@IssuerID
													,@HoldingNature			
													,@CurrencyAlt_Key		
													,@CurrencyConvRate	  
													,@BookType						
													,@BookValue						
													,@BookValueINR				
													,@MTMValue					
													,@MTMValueINR			
													,@EncumberedMTM			
													,@AssetClass_AltKey	
													,@NPIDt																	
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													,@DBTDate
													,@LatestBSDate
													,@Interest_DividendDueDate
													,@Interest_DividendDueAmount
													,@PartialRedumptionDueDate
													,@PartialRedumptionSettledY_N
													,@DegradationFlag								
													,@DegradationReason				
													,@DPD							
													,@UpgradationFlag				
													,@UpgradationDate	

													
													
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE curdat.InvestmentFinancialDetail SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND InvEntityId=@InvEntityId  AND RefInvID=@InvID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO IssuerIDMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

IssuerIDMaster_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO InvestmentFinancialDetail_Mod  
											(		 InvEntityID
													,RefInvID
													,RefIssuerID
													,HoldingNature			
													,CurrencyAlt_Key		
													,CurrencyConvRate	  
													,BookType						
													,BookValue						
													,BookValueINR				
													,MTMValue					
													,MTMValueINR			
													,EncumberedMTM			
													,AssetClass_AltKey	
													,NPIDt								
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModified
													,ApprovedBy
													,DateApproved
													,DBTDate
													,LatestBSDate
													,Interest_DividendDueDate
													,Interest_DividendDueAmount
													,PartialRedumptionDueDate
													,PartialRedumptionSettledY_N
													,FLGDEG
													,DEGREASON
													,DPD
													,FLGUPG
													,UpgDate		
													,ChangeFields
																								
											)
								VALUES
											(		@InvEntityID
													,@InvID
													,@IssuerID
													,@HoldingNature			
													,@CurrencyAlt_Key		
													,@CurrencyConvRate	  
													,@BookType						
													,@BookValue						
													,@BookValueINR				
													,@MTMValue					
													,@MTMValueINR			
													,@EncumberedMTM			
													,@AssetClass_AltKey	
													,@NPIDt	
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													,@DBTDate
													,@LatestBSDate
													,@Interest_DividendDueDate
													,@Interest_DividendDueAmount
													,@PartialRedumptionDueDate
													,@PartialRedumptionSettledY_N
													,@DegradationFlag								
													,@DegradationReason				
													,@DPD							
													,@UpgradationFlag				
													,@UpgradationDate	
													,@Financial_ChangeFields
													
											)
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO IssuerIDMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO IssuerIDMaster_Insert_Edit_Delete
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
								@ReferenceID=@InvID ,-- ReferenceID ,
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
								@ReferenceID=@InvID ,-- ReferenceID ,
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

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM curdat.InvestmentFinancialDetail WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND InvEntityId=@InvEntityId

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
	--return -1
   
END CATCH
---------
END

GO