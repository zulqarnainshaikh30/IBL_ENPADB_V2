SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[UpdateProjStatusPUI_InUp]

                      
                             @CustomerID                                    VARCHAR(20)		=0
                            ,@AccountID                                     VARCHAR(50)		=0
                            ,@ChangeinProjectScope                          VARCHAR(5)      =''
                            ,@FreshOriginalDCCO                             VARCHAR(10)		=''
                            ,@RevisedDCCO                                   VARCHAR(10)		=''
                            ,@CourtCaseArbitration                          VARCHAR(5)      =''
                            ,@ChangeinOwnerShip                             VARCHAR(5)      =''
                            ,@CIOReferenceDate                              VARCHAR(10)		=''
                            ,@CIODCCO                                       VARCHAR(10)		=''
                            ,@CostOverRun                                   VARCHAR(5)      =''
                            ,@RevisedProjectCost                            DECIMAL(16,2)	=0
                            ,@RevisedDebt								    DECIMAL(16,2)	=0
                            ,@RevisedDebtEquityRatio						DECIMAL(16,2)	=0
                            ,@TakeOutFinance								VARCHAR(5)       =''
                            ,@AssetClassSellerBookAltkey					INT=0
                            ,@NPADateSellerBook								VARCHAR(10)		=''
                            ,@Restructuring									CHAR(1)=''
                            ,@AccountEntityID							    INT=0
							,@InitialExtenstion								VARCHAR(5)       =''  
							,@ExtnReason_BCP								VARCHAR(5)       =''
					    	,@Npa_date                                      VARCHAR(10)		=''
							,@Npa_Reason			                        VARCHAR(255)	=''
						    ,@AssetClassAlt_Key                             INT=0
							,@ActualDCCO_Achieved                           CHAR(3)=''
							,@ActualDCCO_Date                                VARCHAR(10)		=''
							,@RM_CreditOfficer                             VARCHAR(250)		=''

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
						,@PUIUpdateProjectStatus_ChangeFields    VARCHAR(100)=''

						
						
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
		
	
		SET DATEFORMAT DMY
	
		DECLARE 
						@AuthorisationStatus		varchar(2)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				SMALLDATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				SMALLDATETIME	= NULL
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						,@ApprovedByFirstLevel		VARCHAR(20)		= NULL
						,@DateApprovedFirstLevel	SMALLDATETIME	= NULL
						
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL

				SET @ScreenName = 'PUI'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	SET @AccountEntityID=(select MAX(AccountEntityID) from AdvacBasicDetail
		                                where effectivefromTimekey<=@Timekey and Effectivetotimekey>=@Timekey
										and Customeracid=@AccountID)

	--SET @CollateralTypeAltKey = (Select ISNULL(Max(CollateralTypeAltKey),0)+1 from DimCollateralType)
												
	PRINT 'A'
	
	Set @CIOReferenceDate = case when @CIOReferenceDate in ('','01/01/1900') then null
	                        ELSE @CIOReferenceDate end

    Set @CIODCCO = case when @CIODCCO in ('','01/01/1900') then null
	                        ELSE @CIODCCO end

	Set @ActualDCCO_Date = case when @ActualDCCO_Date in ('','01/01/1900') then null
	                        ELSE @ActualDCCO_Date end

	Set @RevisedDCCO = case when @RevisedDCCO in ('','01/01/1900') then null
	                        ELSE @RevisedDCCO end


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
					SELECT  1 FROM AdvAcPUIDetailSub WHERE AccountID=@AccountID AND ISNULL(AuthorisationStatus,'A')='A' 
					                                    and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM AdvAcPUIDetailSub_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND AccountID=@AccountID
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
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

					 --SET @AccountEntityID = (Select ISNULL(Max(AccountEntityID),0)+1 from ( 
						--							Select AccountEntityID from AdvAcPUIDetailSub
						--							UNION 
						--							Select AccountEntityID from AdvAcPUIDetailSub_Mod)A)


					 GOTO CollateralType_Insert
					 CollateralType_Insert_Add:
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
					FROM AdvAcPUIDetailSub  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID=@AccountID

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM AdvAcPUIDetailSub_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID=@AccountID						
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE AdvAcPUIDetailSub
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AccountID=@AccountID

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE AdvAcPUIDetailSub_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AccountID=@AccountID
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO CollateralType_Insert
					CollateralType_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE AdvAcPUIDetailSub SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
								AND AccountID=@AccountID
				

		end
-------------------------
		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE AdvAcPUIDetailSub_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AccountID=@AccountID
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		END

	-----------------------------
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE AdvAcPUIDetailSub_Mod
					SET AuthorisationStatus='R'
					--,ApprovedBy	 =@ApprovedBy
					--,DateApproved=@DateApproved
					,FirstLevelApprovedBy	 =@ApprovedBy
					,FirstLevelDateApproved	=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AccountID=@AccountID
						AND AuthorisationStatus in('NP','MP','DP','RM')	


				IF EXISTS(SELECT 1 FROM AdvAcPUIDetailSub WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
				                      AND AccountID=@AccountID)
				BEGIN
					UPDATE AdvAcPUIDetailSub
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID=@AccountID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE AdvAcPUIDetailSub_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND AccountID=@AccountID

	END

	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()
		SET @ApprovedByFirstLevel	   = @CrModApBy 
		SET @DateApprovedFirstLevel  = GETDATE()

		UPDATE AdvAcPUIDetailSub_Mod
						SET AuthorisationStatus ='1A'
							--,ApprovedBy=@ApprovedBy
							--,DateApproved=@DateApproved
					,FirstLevelApprovedBy	 =@ApprovedBy
					,FirstLevelDateApproved	=@DateApproved
							WHERE AccountID=@AccountID
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
					 FROM AdvAcPUIDetailSub 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND AccountID=@AccountID
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM AdvAcPUIDetailSub_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AccountID=@AccountID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
						,@ApprovedByFirstLevel=FirstLevelApprovedBy,@DateApprovedFirstLevel=FirstLevelDateApproved
					 FROM AdvAcPUIDetailSub_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM AdvAcPUIDetailSub_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AccountID=@AccountID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM AdvAcPUIDetailSub_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE AdvAcPUIDetailSub_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND AccountID=@AccountID
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP'                     
					BEGIN	
						UPDATE AdvAcPUIDetailSub_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE AccountID=@AccountID
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM AdvAcPUIDetailSub WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND AccountID=@AccountID)
						BEGIN
								UPDATE AdvAcPUIDetailSub
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND AccountID=@AccountID

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE AdvAcPUIDetailSub_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE AccountID=@AccountID				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM AdvAcPUIDetailSub WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND AccountID=@AccountID)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM AdvAcPUIDetailSub WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND AccountID=@AccountID)
									BEGIN
											PRINT 'BBBB'
										UPDATE AdvAcPUIDetailSub SET
										         
												  
													CustomerID                  =@CustomerID
												   ,AccountID					 =@AccountID
												   ,AccountEntityId              =@AccountEntityId
                                                   ,ChangeinProjectScope		 =CASE WHEN																											@ChangeinProjectScope='Yes' then 'Y'
																				  ELSE 'N'END
                                                   ,FreshOriginalDCCO			 =@FreshOriginalDCCO
                                                   ,RevisedDCCO					 =@RevisedDCCO
                                                   ,CourtCaseArbitration		  =CASE WHEN																										@CourtCaseArbitration='Yes' then 'Y'
																				  ELSE 'N'END
                                                   ,ChangeinOwnerShip			  =CASE WHEN @ChangeinOwnerShip='Yes'																					then 'Y'
																				  ELSE 'N'END
                                                   ,CIOReferenceDate			 =@CIOReferenceDate
                                                   ,CIODCCO						 =@CIODCCO
                                                   ,CostOverRun					 =CASE WHEN @CostOverRun='Yes' then                                                                                    'Y'ELSE 'N'END   
                                                   ,RevisedProjectCost			 =@RevisedProjectCost
                                                   ,RevisedDebt					 =@RevisedDebt
                                                   --,RevisedDebt_EquityRatio		 =@RevisedDebtEquityRatio
                                                   ,TakeOutFinance				 =CASE WHEN @TakeOutFinance='Yes'																					then																													 'Y'ELSE 'N'END
                                                   ,AssetClassSellerBookAlt_key	 =@AssetClassSellerBookAltkey
                                                   ,NPADateSellerBook			 =case when @NPADateSellerBook in ('1900-01-01','') then NULL ELSE @NPADateSellerBook END
                                                   ,Restructuring				 =@Restructuring
												   
												,ModifiedBy							= @ModifiedBy
												,DateModified						= @DateModified
												,ApprovedBy							= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved						= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus				= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												,InitialExtenstion				=CASE WHEN @InitialExtenstion='Yes'																					then                                                                                                                  'Y'ELSE 'N'END 
												,ExtnReason_BCP					=CASE WHEN @ExtnReason_BCP='Yes' then                                                                                    'Y'ELSE 'N'END 
												,Npa_date                       =@Npa_date
												,Npa_Reason						=@Npa_Reason
												,AssetClassAlt_Key              =@AssetClassAlt_Key
												,FirstLevelApprovedBy            =@ApprovedByFirstLevel
												,FirstLevelDateApproved          =@DateApprovedFirstLevel
												,ActualDCCO_Achieved             =CASE WHEN  @ActualDCCO_Achieved='Yes'																					then																													 'Y'ELSE 'N'END
												,ActualDCCO_Date                 =@ActualDCCO_Date
												,RM_CreditOfficer            =@RM_CreditOfficer
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND AccountID=@AccountID
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO AdvAcPUIDetailSub
												(
												    CustomerID
													,AccountID
													,AccountEntityId
                                                   ,ChangeinProjectScope
                                                   ,FreshOriginalDCCO
                                                   ,RevisedDCCO
                                                   ,CourtCaseArbitration
                                                   ,ChangeinOwnerShip
                                                   ,CIOReferenceDate
                                                   ,CIODCCO
                                                   ,CostOverRun
                                                   ,RevisedProjectCost
                                                   ,RevisedDebt
                                                   --,RevisedDebt_EquityRatio
                                                   ,TakeOutFinance
                                                   ,AssetClassSellerBookAlt_key
                                                   ,NPADateSellerBook
                                                   ,Restructuring
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModified
													,ApprovedBy
													,DateApproved
													,InitialExtenstion
													,ExtnReason_BCP
													,Npa_date
													,Npa_Reason
													,AssetClassAlt_Key
													,FirstLevelApprovedBy
													,FirstLevelDateApproved
													,ActualDCCO_Achieved
													,ActualDCCO_Date
													,RM_CreditOfficer
													
												)

										SELECT
													 @CustomerID                
                                                     ,@AccountID
													 ,@AccountEntityId                 
                                                     --,@ChangeinProjectScope      
													 ,CASE WHEN @ChangeinProjectScope='Yes' then 'Y'
																				  ELSE 'N'END
                                                     ,@FreshOriginalDCCO         
                                                     ,@RevisedDCCO               
                                                     --,@CourtCaseArbitration 
													 ,CASE WHEN @CourtCaseArbitration='Yes' then 'Y'
																				  ELSE 'N'END     
                                                    -- ,@ChangeinOwnerShip  
													 ,CASE WHEN @ChangeinOwnerShip='Yes' then 'Y'
																				  ELSE 'N'END       
                                                     ,@CIOReferenceDate          
                                                     ,@CIODCCO                   
                                                    -- ,@CostOverRun  
													  ,CASE WHEN @CostOverRun='Yes' then 'Y'
																				  ELSE 'N'END                
                                                     ,@RevisedProjectCost        
                                                     ,@RevisedDebt				
                                                     --,@RevisedDebtEquityRatio	
                                                    -- ,@TakeOutFinance
													 ,CASE WHEN @TakeOutFinance='Yes' then                                                                                    'Y'ELSE 'N'END			
                                                     ,@AssetClassSellerBookAltkey
                                                     ,case when @NPADateSellerBook in ('1900-01-01','') then NULL ELSE @NPADateSellerBook END			
                                                     ,@Restructuring
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													--,@InitialExtenstion
													,CASE WHEN @InitialExtenstion='Yes' then                                                                                    'Y'ELSE 'N'END 
													--,@ExtnReason_BCP
													,CASE WHEN @ExtnReason_BCP='Yes' then                                                                                    'Y'ELSE 'N'END 
													,@Npa_date
													,@Npa_Reason
													,@AssetClassAlt_Key
													,@ApprovedByFirstLevel
													,@DateApprovedFirstLevel
													,CASE WHEN @ActualDCCO_Achieved ='Yes' then                                                                                    'Y'ELSE 'N'END
													,@ActualDCCO_Date
													,@RM_CreditOfficer

										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE AdvAcPUIDetailSub SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
									AND AccountID=@AccountID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO CollateralType_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

CollateralType_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO AdvAcPUIDetailSub_Mod  
											( 
												    CustomerID
													,AccountID
													,AccountEntityId
                                                   ,ChangeinProjectScope
                                                   ,FreshOriginalDCCO
                                                   ,RevisedDCCO
                                                   ,CourtCaseArbitration
                                                   ,ChangeinOwnerShip
                                                   ,CIOReferenceDate
                                                   ,CIODCCO
                                                   ,CostOverRun
                                                   ,RevisedProjectCost
                                                   ,RevisedDebt
                                                   --,RevisedDebt_EquityRatio
                                                   ,TakeOutFinance
                                                   ,AssetClassSellerBookAlt_key
                                                   ,NPADateSellerBook
                                                   ,Restructuring
												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy
												,DateApproved
												,InitialExtenstion
												,ExtnReason_BCP
												,Npa_date
												,Npa_Reason
												,AssetClassAlt_Key
												,ActualDCCO_Achieved
												,ActualDCCO_Date
												,RM_CreditOfficer
												,Changefields
																								
											)
								VALUES
											( 
														 @CustomerID                
                                                     ,@AccountID
													 ,@AccountEntityId                 
                                                     --,@ChangeinProjectScope 
													 ,CASE WHEN @ChangeinProjectScope='Yes' then 'Y'
																				  ELSE 'N'END
													      
                                                     ,@FreshOriginalDCCO         
                                                     ,@RevisedDCCO               
                                                     --,@CourtCaseArbitration 
													 ,CASE WHEN @CourtCaseArbitration='Yes' then 'Y'
																				  ELSE 'N'END     
                                                     --,@ChangeinOwnerShip  
													 ,CASE WHEN @ChangeinOwnerShip='Yes' then 'Y'
																				  ELSE 'N'END        
                                                     ,@CIOReferenceDate          
                                                     ,@CIODCCO                   
                                                    -- ,@CostOverRun 
													 ,CASE WHEN @CostOverRun='Yes' then 'Y'
																				  ELSE 'N'END              
                                                     ,@RevisedProjectCost        
                                                     ,@RevisedDebt				
                                                     --,@RevisedDebtEquityRatio	
                                                     --,@TakeOutFinance
													 ,CASE WHEN @TakeOutFinance='Yes' then                                                                                    'Y'ELSE 'N'END			
                                                     ,@AssetClassSellerBookAltkey
                                                     ,case when @NPADateSellerBook in ('1900-01-01','') then NULL ELSE @NPADateSellerBook END			
                                                     ,@Restructuring
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													--,@InitialExtenstion
													,CASE WHEN @InitialExtenstion='Yes' then                                                                                    'Y'ELSE 'N'END 
												--	,@ExtnReason_BCP
													,CASE WHEN @ExtnReason_BCP='Yes' then                                                                                    'Y'ELSE 'N'END 
													,@Npa_date
													,@Npa_Reason
													,@AssetClassAlt_Key
													,CASE WHEN @ActualDCCO_Achieved='Yes' then 'Y' ELSE 'N' END
														                       
													,@ActualDCCO_Date
													,@RM_CreditOfficer
													,@PUIUpdateProjectStatus_ChangeFields
											)
	DECLARE @Parameter2 varchar(50)
	DECLARE @FinalParameter2 varchar(50)
	SET @Parameter2 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from AdvAcPUIDetailSub_Mod where AccountID=@AccountID
											and ISNULL(AuthorisationStatus,'A')  in ( 'A','MP')
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
							from		AdvAcPUIDetailSub_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and	AccountID=@AccountID										
										
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO CollateralType_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO CollateralType_Insert_Edit_Delete
					END
					

				
	END



	-------------------
PRINT 7
		COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimCollateralType WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--														AND CollateralTypeAltKey=@CollateralTypeAltKey

		
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