SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[BranchMaster_InUp]

--select * from Dimbranch

--Declare
    @BranchAlt_Key		Int	= 0
   ,@BranchCode		Varchar(20)	= ''
   ,@BranchName		Varchar(50) = ''
   ,@Add_1				Varchar(500) = ''
   ,@Add_2				Varchar(500) = ''
   ,@Add_3				Varchar(500) = ''
   ,@DistrictAlt_Key          INT=0                 -------cityAlt_key
   ,@StateAlt_Key         Int = 0      -----BranchStateAlt_Key
   ,@PinCode           INT=0
   ,@CountryAlt_Key       Int = 0       ------CountryAlt_key
   ,@BranchMaster_ChangeFields Varchar(100)=NULL
   
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
	

	    DECLARE @Parameter varchar(max) = (select 'BranchCode|' + ISNULL(@BranchCode,' ') + '}'+ 'BranchName|' + isnull(@BranchName,' ')
	+ '}'+ 'FirstAddress|'+isnull(@Add_1,'')+ '}'+ 'District|'+convert(VARCHAR,isnull(@DistrictAlt_Key,''))+ '}'+ 'State|'+convert(VARCHAR,isnull(@StateAlt_Key,''))
	+ '}'+ 'PinCode|'+convert(VARCHAR,isnull(@PinCode,''))+ '}'+ 'CountryCode|'+convert(VARCHAR,isnull(@CountryAlt_Key,'')))
	--DECLARE		@Result					INT				=0 
	exec SecurityCheckDataValidation 14553 ,@Parameter,@Result OUTPUT
				
	IF @Result = -1
	return -1






		DECLARE 
						@AuthorisationStatus		VARCHAR(2)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				DATETIME	= NULL  --updated by vinit
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				DATETIME	= NULL --updated by vinit
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				 DATETIME	= NULL --updated by vinit
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						,@ApprovedByFirstLevel		VARCHAR(20)		= NULL
						,@DateApprovedFirstLevel	 DATETIME	= NULL --updated by vinit
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL

				SET @ScreenName = 'GLProductCodeMaster'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	Declare @DistrictName Varchar(50)=''
	Set @DistrictName=(Select DistrictName from DimGeography where DistrictAlt_Key=@DistrictAlt_Key)

	Declare @StateName Varchar(50)=''
	Set @StateName=(Select StateName from DimState where StateAlt_Key=@StateAlt_Key)

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
					SELECT  1 FROM DimBranch WHERE  BranchCode=@BranchCode
					            AND ISNULL(AuthorisationStatus,'A')='A' 
								and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM DimBranch_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND  BranchCode=@BranchCode
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM','1A','D1') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		ELSE
			BEGIN
			   PRINT 3
				 SET @BranchAlt_Key = (Select ISNULL(Max(BranchAlt_Key),0)+1 from 
												(Select BranchAlt_Key from DimBranch
												 UNION 
												 Select BranchAlt_Key from DimBranch_Mod
												)A)
			END
		---------------------Added on 29/05/2020 for user allocation rights
		/*
		IF @AccessScopeAlt_Key in (1,2)
		BEGIN
		PRINT 'Sunil'

		IF EXISTS(				                
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@GLAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@GLAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
					 SET @DateCreated =  getdate() 
					 --SET @DateCreated = fORMAT (getdate(), 'yyyy-MM-dd, hh:mm:ss') --Updated By Vinit
					 SET @AuthorisationStatus='NP'

					 --SET @BranchAlt_Key = (Select ISNULL(Max(BranchAlt_Key),0)+1 from 
						--						(Select BranchAlt_Key from DimBranch
						--						 UNION 
						--						 Select BranchAlt_Key from DimBranch_Mod
						--						)A)

					 GOTO GLCodeMaster_Insert
					GLCodeMaster_Insert_Add:
			END 

			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				--SET @DateCreated = GETDATE() --uncomment by vinit
				--SET @DateCreated = fORMAT (getdate(), 'yyyy-MM-dd, hh:mm:ss') --Updated By Vinit
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
					FROM DimBranch  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND BranchAlt_Key =@BranchAlt_Key

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimBranch_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND BranchAlt_Key =@BranchAlt_Key
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimBranch
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BranchAlt_Key =@BranchAlt_Key

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimBranch_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BranchAlt_Key =@BranchAlt_Key
								AND AuthorisationStatus IN('NP','MP','RM')
					END
					IF @OperationFlag=3
					BEGIN	

						UPDATE DimBranch_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BranchAlt_Key =@BranchAlt_Key
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO GLCodeMaster_Insert
					GLCodeMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

							UPDATE DimBranch
							SET AuthorisationStatus=@AuthorisationStatus
							    ,ModifiedBy =@Modifiedby 
							   ,DateModified =@DateModified 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BranchAlt_Key =@BranchAlt_Key

								
							UPDATE DimBranch_MOD
							SET AuthorisationStatus=@AuthorisationStatus
							    ,ModifiedBy =@Modifiedby 
							   ,DateModified =@DateModified 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BranchAlt_Key =@BranchAlt_Key

								
--uncomment by vinit
						UPDATE DimBranch SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND BranchAlt_Key=@BranchAlt_Key
				

		end

		
		ELSE IF @OperationFlag =3 AND @AuthMode ='Y'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

							UPDATE DimBranch_Mod
							SET AuthorisationStatus=@AuthorisationStatus
							   ,ModifiedBy =@Modifiedby 
							   ,DateModified =@DateModified 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BranchAlt_Key =@BranchAlt_Key
								--AND AuthorisationStatus IN('DP')

					  	UPDATE DimBranch
							SET AuthorisationStatus='DP'
							   ,ModifiedBy =@Modifiedby 
							   ,DateModified =@DateModified 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BranchAlt_Key =@BranchAlt_Key
								--AND AuthorisationStatus IN('DP')

						--UPDATE DimBranch SET
						--			ModifiedBy =@Modifiedby 
						--			,DateModified =@DateModified 
						--			,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						--		WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND BranchAlt_Key=@BranchAlt_Key
					GOTO GLCodeMaster_Insert
					

		end

		ELSE IF @OperationFlag =5 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

							UPDATE DimBranch
							SET AuthorisationStatus='DP2'
									,ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BranchAlt_Key =@BranchAlt_Key
								AND AuthorisationStatus IN('DP1')


							UPDATE DimBranch_Mod
							SET AuthorisationStatus='DP2'
									,ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND BranchAlt_Key =@BranchAlt_Key
								AND AuthorisationStatus IN('DP1')


						--UPDATE DimBranch SET
						--			ModifiedBy =@Modifiedby 
						--			,DateModified =@DateModified 
						--			,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						--		WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND BranchAlt_Key=@BranchAlt_Key
				

		end
	------------------------------------new add for First lvl Auth.
	ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimBranch_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND BranchAlt_Key =@BranchAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A','D1')	

		IF EXISTS(SELECT 1 FROM DimBranch WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND BranchAlt_Key=@BranchAlt_Key)
				BEGIN
					UPDATE DimBranch
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND BranchAlt_Key =@BranchAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM','D1') 	
				END
		END	

	----------------------------------------------
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimBranch_Mod
					SET AuthorisationStatus='R'
					,ApprovedByFirstLevel	 =@ApprovedBy
					,DateApprovedFirstLevel=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND BranchAlt_Key =@BranchAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','D1')	

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

				IF EXISTS(SELECT 1 FROM DimBranch WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND BranchAlt_Key=@BranchAlt_Key)
				BEGIN
					UPDATE DimBranch
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND BranchAlt_Key =@BranchAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM','D1') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimBranch_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND BranchAlt_Key=@BranchAlt_Key

	END
	-------new addd 
	ELSE IF @OperationFlag=16

		BEGIN

		--SET @ApprovedBy	   = @CrModApBy 
		--SET @DateApproved  = GETDATE()
		SET @ApprovedByFirstLevel	 = @CrModApBy 
		SET @DateApprovedFirstLevel  = GETDATE()
		Set @ModifiedBy = @CrModApBy --updated by vinit
		UPDATE DimBranch_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedByFirstLevel=@ApprovedByFirstLevel --select ApprovedByFirstLevel,ModifiedBy from DimGLProduct_AU_Mod
							,DateApprovedFirstLevel=@DateApprovedFirstLevel
							--,ModifiedBy =@ModifiedBy --updated by vinit
							WHERE BranchAlt_Key=@BranchAlt_Key
							AND AuthorisationStatus in('NP','MP','RM')
		
		UPDATE DimBranch_Mod
						SET AuthorisationStatus ='D1'
						,ApprovedByFirstLevel	 =@ApprovedBy
					,DateApprovedFirstLevel=@DateApproved
							WHERE BranchAlt_Key=@BranchAlt_Key
							AND AuthorisationStatus in('DP')
        END
----------------------------------------------------------

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
						--SET @DateCreated = fORMAT (getdate(), 'yyyy-MM-dd, hh:mm:ss') --Updated By Vinit
					END
				ELSE
					BEGIN
						SET @ModifiedBy  =@CrModApBy
						SET @DateModified =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM DimBranch
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND BranchAlt_Key=@BranchAlt_Key
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					END
			END
			
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'
				BEGIN
				    Print 'B'
					DECLARE @DelStatus varchar(2)=''
					DECLARE @CurrRecordFromTimeKey smallint=0

					Print 'C'
					SELECT @ExEntityKey= MAX(Branch_Key) FROM DimBranch_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND BranchAlt_Key=@BranchAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A','D1')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified,@ApprovedByFirstLevel=ApprovedByFirstLevel,@DateApprovedFirstLevel=DateApprovedFirstLevel
					 FROM DimBranch_Mod
						WHERE Branch_Key=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Branch_Key) FROM DimBranch_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND BranchAlt_Key=@BranchAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A','D1')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimBranch_Mod
							WHERE Branch_Key=@ExEntityKey

					UPDATE DimBranch_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND BranchAlt_Key=@BranchAlt_Key
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' OR @DelStatus='D1'
					BEGIN	
						UPDATE DimBranch_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE BranchAlt_Key=@BranchAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM','1A','D1')
							AND Branch_Key = @ExEntityKey
						IF EXISTS(SELECT 1 FROM DimBranch WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND BranchAlt_Key=@BranchAlt_Key)
						BEGIN
								UPDATE DimBranch
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND BranchAlt_Key=@BranchAlt_Key
											--AND AuthorisationStatus in ('MP')

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimBranch_Mod
								SET AuthorisationStatus ='A'
							       --,ModifiedBy =@CrModApBy --updated by vinit 
							       ,ApprovedBy=@CrModApBy 
							       ,DateApproved = getdate()
								    WHERE BranchAlt_Key=@BranchAlt_Key				
									AND AuthorisationStatus in('NP','MP','RM','1A','D1') 
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimBranch WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND BranchAlt_Key=@BranchAlt_Key)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'
--alter table DimBranch_Mod
--Add  CountryAlt_Key INT

								IF EXISTS(SELECT 1 FROM DimBranch WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND BranchAlt_Key=@BranchAlt_Key)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimBranch SET
												BranchAlt_Key			= @BranchAlt_Key
												,BranchCode				        = @BranchCode
												,BranchName						= @BranchName
												,Add_1                    =@Add_1
												,Add_2                    =@Add_2
												,Add_3                    =@Add_3
												,BranchDistrictAlt_Key    =@DistrictAlt_Key
												,BranchDistrictName		  =@DistrictName
												,BranchStateAlt_Key       =@StateAlt_Key
												,BranchStateName		  =@StateName
												,PinCode                  =@PinCode
												,CountryAlt_Key           =@CountryAlt_Key
												,ModifiedBy					= @ModifiedBy
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												,ChangeFields						= @BranchMaster_ChangeFields
												,FirstLevelApprovedBy         =@ApprovedByFirstLevel
												,FirstLevelDateApproved       =@DateApprovedFirstLevel
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND BranchAlt_Key=@BranchAlt_Key
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END


								IF ((@IsAvailable='N' OR @IsSCD2='Y') AND (@DelStatus <>'DP' AND @DelStatus <>'D1'))
									BEGIN
									print @DelStatus
										INSERT INTO DimBranch
												(
													 BranchAlt_Key
													,BranchCode
													,BranchName
													,Add_1             
													,Add_2             
													,Add_3             
													,BranchDistrictAlt_Key
													,BranchDistrictName
													,BranchStateAlt_Key
													,BranchStateName
													,PinCode           
													,CountryAlt_Key    
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModified
													,ApprovedBy
													,DateApproved
													,ChangeFields
													,FirstLevelApprovedBy
                                                    ,FirstLevelDateApproved
												)

										select
													@BranchAlt_Key
													,@BranchCode				
					                             	,@BranchName
													,@Add_1
													,@Add_2
													,@Add_3
													,@DistrictAlt_Key
													,@DistrictName
													,@StateAlt_Key
													,@StateName
													,@PinCode
													,@CountryAlt_Key											
																	
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													,@BranchMaster_ChangeFields
												    ,@ApprovedByFirstLevel
													,@DateApprovedFirstLevel
													
					
					
				DECLARE @Parameter2 varchar(50)
	DECLARE @FinalParameter2 varchar(50)
	SET @Parameter2 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from DimBranch where  BranchAlt_Key=@BranchAlt_Key
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
							from		DimBranch   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			 BranchAlt_Key=@BranchAlt_Key										
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimBranch SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND BranchAlt_Key=@BranchAlt_Key
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
			INSERT INTO DimBranch_Mod  
											( 
												BranchAlt_Key
												,BranchCode
												,BranchName
												,Add_1             
												,Add_2             
												,Add_3             
												,BranchDistrictAlt_Key
												,BranchDistrictName
												,BranchStateAlt_Key
												,BranchStateName
												,PinCode           
												,CountryAlt_Key 
												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy
												,DateApproved
												,Changefields
																								
											)
								values(
											  
													@BranchAlt_Key
												
													,@BranchCode				
					                             	,@BranchName
													,@Add_1
													,@Add_2
													,@Add_3
													,@DistrictAlt_Key
													,@DistrictName
													,@StateAlt_Key
													,@StateName
													,@PinCode
													,@CountryAlt_Key

													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													,@BranchMaster_ChangeFields
												
											)		
													
										
						
				DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from DimBranch_Mod where  BranchAlt_Key=@BranchAlt_Key
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
							from		DimBranch_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			 BranchAlt_Key=@BranchAlt_Key										
										
	

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

		
IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'
		BEGIN
					print 'log table' 
					
				SET	@DateCreated     =Getdate()
				--SET @DateCreated = fORMAT (getdate(), 'yyyy-MM-dd, hh:mm:ss') --Updated By Vinit

					IF @OperationFlag IN(16,17,18,20,21) 
						BEGIN 
						       Print 'Authorised'
					
			
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@BranchCode ,-- ReferenceID ,
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
								@ReferenceID=@BranchCode ,-- ReferenceID ,
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

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimGL WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND GLAlt_Key=@GLAlt_Key

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