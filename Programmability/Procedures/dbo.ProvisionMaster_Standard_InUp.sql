SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[ProvisionMaster_Standard_InUp]
						
						@Code										Int	= 0
					   ,@BankCategoryID								Int=0
					   ,@AssetCategory								Varchar(255)=''
					   ,@CategoryTypeAlt_Key						Int=0
					   ,@Provision_RBI_Norms 						Decimal(6,2)	= ''--Sachin Previous Decimal(5,2)
					   ,@AdditionalBanksProvision					Decimal(18,2)=''
				       ,@Additional_Provision_Bank_Norms_if_any		Decimal(5,2)	= ''
					   ,@ProvisionMaster_Standard_changeFields varchar(100)=null
						
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
						@AuthorisationStatus		VARCHAR(2)			= NULL 
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

				SET @ScreenName = 'ConstitutionMaster'

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
					SELECT  1 FROM DimProvision_SegStd WHERE BankCategoryID=@BankCategoryID AND ISNULL(AuthorisationStatus,'A')='A' 
					                                        and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM DimProvision_SegStd_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND BankCategoryID=@BankCategoryID
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
				SET @Code = (Select ISNULL(Max(ProvisionAlt_Key),0)+1 from 
												(Select ProvisionAlt_Key from DimProvision_SegStd
												 UNION 
												 Select ProvisionAlt_Key from DimProvision_SegStd_Mod
												)A)
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

					 --SET @Code = (Select ISNULL(Max(ProvisionAlt_Key),0)+1 from 
						--						(Select ProvisionAlt_Key from DimProvision_SegStd
						--						 UNION 
						--						 Select ProvisionAlt_Key from DimProvision_SegStd_Mod
						--						)A)
						
					 GOTO ConstitutionMaster_Insert
					ConstitutionMaster_Insert_Add:
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
					FROM DimProvision_SegStd  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND ProvisionAlt_Key =@Code
							AND BankCategoryID=@BankCategoryID

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimProvision_SegStd_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND ProvisionAlt_Key =@Code
							AND BankCategoryID=@BankCategoryID
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimProvision_SegStd
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								--AND ProvisionAlt_Key =@Code
								AND BankCategoryID=@BankCategoryID

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimProvision_SegStd_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								--AND ProvisionAlt_Key =@Code
								AND BankCategoryID=@BankCategoryID
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO ConstitutionMaster_Insert
					ConstitutionMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE DimProvision_SegStd SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND  BankCategoryID=@BankCategoryID             -----ProvisionAlt_Key=@Code
				

		end
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimProvision_SegStd_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						--AND ProvisionAlt_Key =@Code
						AND BankCategoryID=@BankCategoryID
						AND AuthorisationStatus in('NP','MP','DP','RM')	



				IF EXISTS(SELECT 1 FROM DimProvision_SegStd WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND ProvisionAlt_Key=@Code)
				BEGIN
					UPDATE DimProvision_SegStd
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND ProvisionAlt_Key =@Code
							AND BankCategoryID=@BankCategoryID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

-----------------------------Two Level Auth. Chanegs--------------

ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimProvision_SegStd_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						--AND ProvisionAlt_Key =@Code
						AND BankCategoryID=@BankCategoryID
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

				IF EXISTS(SELECT 1 FROM DimProvision_SegStd WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND ProvisionAlt_Key=@Code)
				BEGIN
					UPDATE DimProvision_SegStd
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND ProvisionAlt_Key =@Code
							AND BankCategoryID=@BankCategoryID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

------------------------------------------
	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimProvision_SegStd_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		--AND ProvisionAlt_Key=@Code
		AND BankCategoryID=@BankCategoryID

	END

	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE DimProvision_SegStd_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							WHERE BankCategoryID=@BankCategoryID
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
					 FROM DimProvision_SegStd
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							--AND ProvisionAlt_Key=@Code
							AND BankCategoryID=@BankCategoryID
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM DimProvision_SegStd_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							--AND ProvisionAlt_Key=@Code
							AND BankCategoryID=@BankCategoryID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM DimProvision_SegStd_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DimProvision_SegStd_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							--AND ProvisionAlt_Key=@Code
							AND BankCategoryID=@BankCategoryID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimProvision_SegStd_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE DimProvision_SegStd_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						--AND ProvisionAlt_Key=@Code
						AND BankCategoryID=@BankCategoryID
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimProvision_SegStd_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE ProvisionAlt_Key=@Code
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimProvision_SegStd WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										--AND ProvisionAlt_Key=@Code
										AND BankCategoryID=@BankCategoryID
										)
						BEGIN
								UPDATE DimProvision_SegStd
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											--AND ProvisionAlt_Key=@Code
											AND BankCategoryID=@BankCategoryID

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimProvision_SegStd_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE ProvisionAlt_Key=@Code				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimProvision_SegStd WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 --AND ProvisionAlt_Key=@Code
									 AND BankCategoryID=@BankCategoryID
									 )
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimProvision_SegStd WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey --AND ProvisionAlt_Key=@Code
												AND BankCategoryID=@BankCategoryID
												)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimProvision_SegStd SET
												 ProvisionAlt_Key				= @Code
												,BankCategoryID					= @BankCategoryID
												,ProvisionName					= @AssetCategory
												,CategoryTypeAlt_Key			= @CategoryTypeAlt_Key
												,ProvisionSecured				= @Provision_RBI_Norms
												,ProvisionunSecured 			= @Provision_RBI_Norms
												,RBIProvisionSecured			= @Provision_RBI_Norms
												,RBIProvisionUnSecured			= @Provision_RBI_Norms
												,AdditionalBanksProvision 	    = @AdditionalBanksProvision           
												,AdditionalprovisionRBINORMS	= @Additional_Provision_Bank_Norms_if_any
												,ModifiedBy						= @ModifiedBy
												,DateModified					= @DateModified
												,ApprovedBy						= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved					= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus			= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND	BankCategoryID=@BankCategoryID				---ProvisionAlt_Key=@Code
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END


								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN

									--PRINT 123
									--PRINT @IsSCD2
									--PRINT @IsAvailable
										INSERT INTO DimProvision_SegStd
												(
													 ProvisionAlt_Key
													,BankCategoryID
													,ProvisionName
													,CategoryTypeAlt_Key
													,ProvisionSecured 
													,ProvisionunSecured 
													,RBIProvisionSecured
													,RBIProvisionUnSecured
													,AdditionalBanksProvision
													,AdditionalprovisionRBINORMS
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
													 @Code
													 ,@BankCategoryID
													 ,@AssetCategory 
													 ,@CategoryTypeAlt_Key                        
													 ,@Provision_RBI_Norms
													 ,@Provision_RBI_Norms
													 ,@Provision_RBI_Norms
													 ,@Provision_RBI_Norms 	
													 ,@AdditionalBanksProvision               
													 ,@Additional_Provision_Bank_Norms_if_any			
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END

									
									
									
---------------------------Added On 19032021     ------------

--Declare @BusinessRule_Alt_key		INT
--,@CatAlt_key				INT
--,@UniqueID					INT
--,@Businesscolalt_key		INT	
--,@Scope						INT
--,@Businesscolvalues1		VARCHAR(MAX)	
--,@Businesscolvalues			VARCHAR(MAX)
--,@UserId					VARCHAR(50)
----,@OperationFlag				INT
--,@D2kTimestamp				INT	=0
----,@Result					INT OUTPUT
----,@AuthMode					CHAR(1)			= 'Y'
----,@CrModApBy					VARCHAR(20)		=''


--Exec [dbo].[BusinessRuleSetupInUp] @BusinessRule_Alt_key=@BusinessRule_Alt_key, @CatAlt_key=@CatAlt_key,@UniqueID=@UniqueID,@Businesscolalt_key=@Businesscolalt_key,@Scope=@Scope,@Businesscolvalues1=@Businesscolvalues1,
--@Businesscolvalues=@Businesscolvalues,@UserId=@UserId,@OperationFlag=@OperationFlag,@D2kTimestamp=@D2kTimestamp,@Result=@Result,@AuthMode=@AuthMode,@CrModApBy=@CrModApBy

--Declare @Expression varchar(max)=''
--,@FinalExpression VARCHAR(MAX)=''
----,@D2kTimestamp				INT	OUTPUT
----,@Result					INT OUTPUT
----,@UserId					VARCHAR(50)
----,@OperationFlag				INT


--Exec [dbo].[Provision_Update]  @ProvisionAlt_Key=@CatAlt_key,@Expression=@Expression,@FinalExpression=@FinalExpression,
--@UserId=@UserId,@OperationFlag=@OperationFlag,@D2kTimestamp=@D2kTimestamp,@Result=@Result
																							
	----------------------------------------------------------------------------------------------									
					END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimProvision_SegStd SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND	BankCategoryID=@BankCategoryID			---ProvisionAlt_Key=@Code
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO ConstitutionMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

ConstitutionMaster_Insert:
IF @ErrorHandle=0
	BEGIN
	
			INSERT INTO DimProvision_SegStd_Mod  
											( 
												ProvisionAlt_Key 
												,BankCategoryID
												,ProvisionName
												,CategoryTypeAlt_Key
													,ProvisionSecured 
													,ProvisionunSecured 
													,RBIProvisionSecured
													,RBIProvisionUnSecured
													,AdditionalBanksProvision
													,AdditionalprovisionRBINORMS
												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy
												,DateApproved
												,changeFields
																								
											)
								VALUES
											( 
													 @Code
													 ,@BankCategoryID
													 ,@AssetCategory
													 ,@CategoryTypeAlt_Key                         
													 ,@Provision_RBI_Norms
													 ,@Provision_RBI_Norms
													 ,@Provision_RBI_Norms
													 ,@Provision_RBI_Norms
													 ,@AdditionalBanksProvision 	               
													 ,@Additional_Provision_Bank_Norms_if_any	
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													 ,@ProvisionMaster_Standard_changeFields 
													
											)
											DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from DimProvision_SegStd_Mod where  ProvisionAlt_Key = @Code	
											and ISNULL(AuthorisationStatus,'A')  in ( 'A','MP')
											 for XML PATH('')),1,1,'') )

											If OBJECT_ID('#AA') is not null
											drop table #AA

select DISTINCT VALUE 
into #AA 
from (
		SELECT 	CHARINDEX('|',VALUE) CHRIDX,VALUE
		FROM( SELECT VALUE FROM STRING_SPLIT(@Parameter3,',')
 ) A
 )X
 SET @FinalParameter3 = (select STUFF((	SELECT Distinct ',' + Value from #AA  for XML PATH('')),1,1,''))
 
							UPDATE		A
							set			a.ChangeFields = @FinalParameter3							 																																	
							from		DimProvision_SegStd_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			ProvisionAlt_Key = @Code										
										
	
	
	
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO ConstitutionMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO ConstitutionMaster_Insert_Edit_Delete
					END
					

				
	END

	IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
		BEGIN
					print 'log table'

					
				SET	@DateCreated     =Getdate()

					IF @OperationFlag IN(16,17,18,20,21) 
						BEGIN 
						       Print 'Authorised'
					
			
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@BankCategoryID ,-- ReferenceID ,
								@CreatedBy=NULL,
								@ApprovedBy=@CrModApBy, 
								@CreatedCheckedDt=@DateCreated,
								@Remark=@Remark,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END
					ELSE
						BEGIN
						       Print 'UNAuthorised'
						    -- Declare
						     set @CreatedBy  =@CrModApBy
							 
							EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
								@BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@BankCategoryID ,-- ReferenceID ,
								@CreatedBy=@CrModApBy,
								@ApprovedBy=NULL, 						
								@CreatedCheckedDt=@DateCreated,
								@Remark=@Remark,
								@ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen
								@Flag=@OperationFlag,
								@AuthMode=@AuthMode
						END

		END

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