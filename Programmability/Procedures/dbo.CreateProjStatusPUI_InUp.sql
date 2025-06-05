SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



CREATE PROC [dbo].[CreateProjStatusPUI_InUp]

                         @CustomerId					 VARCHAR(20)		=0
						,@UCIFID					     VARCHAR(20)		=0
						,@AccountID                 VARCHAR(50)		=0
						,@CustomerName					 VARCHAR(80)		=''
						,@ProjectCategoryAltKey		     INT =0
						,@ProjectSubCategoryAltKey		 INT =0
						,@ProjectAuthorityAltkey             INT=0
						,@ProjectOwnershipAltKey		 INT =0
						,@OriginalDCCO            VARCHAR(10)		=''
						,@OriginalProjectCost     DECIMAL(16,2)	=0
						,@OriginalDebt            DECIMAL(16,2)	=0
                        ,@Debt_EquityRatio        DECIMAL(16,2)	=0
						,@AccountEntityID         INT=0
						,@CreateProjStatusPUI_changeFields varchar(100)=null
					     
						
					    						
						
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
						,@ProjectSubCatDescription  VARCHAR(50)
						
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
		SET @AccountEntityID=(select AccountEntityID from AdvacBasicDetail
		                                where effectivefromTimekey<=@Timekey and Effectivetotimekey>=@Timekey
										and Customeracid=@AccountID)
	
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

	--SET @CollateralTypeAltKey = (Select ISNULL(Max(CollateralTypeAltKey),0)+1 from DimCollateralType)
												
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
					SELECT  1 FROM AdvAcPUIDetailMain WHERE AccountID = @AccountID AND ISNULL(AuthorisationStatus,'A')='A' 
					                                    and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM AdvAcPUIDetailMain_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND AccountID = @AccountID
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

					 --SET @ProjectCategoryAltKey = (Select ISNULL(Max(ProjectCategoryAlt_Key),0)+1 from ( 
						--							Select ProjectCategoryAlt_Key from AdvAcPUIDetailMain
						--							UNION 
						--							Select ProjectCategoryAlt_Key from AdvAcPUIDetailMain_Mod)A)


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
					FROM AdvAcPUIDetailMain  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID = @AccountID

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM AdvAcPUIDetailMain_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID = @AccountID						
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE AdvAcPUIDetailMain
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AccountID = @AccountID

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE AdvAcPUIDetailMain_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AccountID = @AccountID
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

						UPDATE AdvAcPUIDetailMain SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
								AND AccountID = @AccountID
				

		end
-------------------------
		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE AdvAcPUIDetailMain_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AccountID = @AccountID
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
      IF EXISTS(SELECT 1 FROM AdvAcPUIDetailMain WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
	                AND AccountID = @AccountID)
				BEGIN
					UPDATE AdvAcPUIDetailMain
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID = @AccountID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END								

		

	-----------------------------
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE AdvAcPUIDetailMain_Mod
					SET AuthorisationStatus='R'
					--,ApprovedBy	 =@ApprovedBy
					--,DateApproved=@DateApproved
					,FirstLevelApprovedBy	 =@ApprovedBy
					,FirstLevelDateApproved	=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AccountID = @AccountID
						AND AuthorisationStatus in('NP','MP','DP','RM')	


				IF EXISTS(SELECT 1 FROM AdvAcPUIDetailMain WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
				                      AND AccountID = @AccountID)
				BEGIN
					UPDATE AdvAcPUIDetailMain
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID = @AccountID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE AdvAcPUIDetailMain_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND AccountID = @AccountID 

	END

	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()
		SET @ApprovedByFirstLevel	   = @CrModApBy 
		SET @DateApprovedFirstLevel  = GETDATE()

		UPDATE AdvAcPUIDetailMain_Mod
						SET AuthorisationStatus ='1A'
							--,ApprovedBy=@ApprovedBy
							--,DateApproved=@DateApproved
							,FirstLevelApprovedBy	 =@ApprovedBy
					        ,FirstLevelDateApproved	=@DateApproved
							WHERE AccountID = @AccountID
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
					 FROM AdvAcPUIDetailMain 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND AccountID = @AccountID
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM AdvAcPUIDetailMain_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AccountID = @AccountID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
						,@ApprovedByFirstLevel=FirstLevelApprovedBy,@DateApprovedFirstLevel=FirstLevelDateApproved
					 FROM AdvAcPUIDetailMain_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM AdvAcPUIDetailMain_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AccountID = @AccountID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM AdvAcPUIDetailMain_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE AdvAcPUIDetailMain_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND AccountID = @AccountID
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP'                     
					BEGIN	
						UPDATE AdvAcPUIDetailMain_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE AccountID = @AccountID
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM AdvAcPUIDetailMain WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND AccountID = @AccountID)
						BEGIN
								UPDATE AdvAcPUIDetailMain
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND AccountID = @AccountID

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE AdvAcPUIDetailMain_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE AccountID = @AccountID				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM AdvAcPUIDetailMain WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND AccountID = @AccountID)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM AdvAcPUIDetailMain WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND AccountID = @AccountID)
									BEGIN
											PRINT 'BBBB'
										UPDATE AdvAcPUIDetailMain SET
										              CustomerID                    =@CustomerID
                                                     ,UCIFID                        =@UCIFID
													 ,AccountID                     =@AccountID
                                                     ,CustomerName                  =@CustomerName
                                                     ,ProjectCategoryAlt_Key        =@ProjectCategoryAltKey
                                                     ,ProjectSubCategoryAlt_key     =@ProjectSubCategoryAltkey
                                                     ,ProjectOwnerShipAlt_Key       =@ProjectOwnerShipAltKey
                                                     ,ProjectAuthorityAlt_key       =@ProjectAuthorityAltkey
                                                     ,OriginalDCCO                  =@OriginalDCCO
                                                     ,OriginalProjectCost           =@OriginalProjectCost
                                                     ,OriginalDebt                  =@OriginalDebt
													 ,ProjectSubCatDescription      =@ProjectSubCatDescription
                                                    -- ,Debt_EquityRatio              =@Debt_EquityRatio
												,ModifiedBy							= @ModifiedBy
												,DateModified						= @DateModified
												,ApprovedBy							= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved						= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus				= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
													,FirstLevelApprovedBy            =@ApprovedByFirstLevel
												,FirstLevelDateApproved          =@DateApprovedFirstLevel
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND AccountID = @AccountID
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO AdvAcPUIDetailMain
												(
												     CustomerID
                                                     ,UCIFID
													 ,AccountID
													 ,AccountEntityID
                                                     ,CustomerName
                                                     ,ProjectCategoryAlt_Key
                                                     ,ProjectSubCategoryAlt_key
                                                     ,ProjectOwnerShipAlt_Key
                                                     ,ProjectAuthorityAlt_key
                                                     ,OriginalDCCO
                                                     ,OriginalProjectCost
                                                     ,OriginalDebt
													 ,ProjectSubCatDescription
                                                   --  ,Debt_EquityRatio    --- handled in screen 
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModified
													,ApprovedBy
													,DateApproved
														,FirstLevelApprovedBy
													,FirstLevelDateApproved
												)

										SELECT
													@CustomerID
													,@UCIFID
													,@AccountID
													,@AccountEntityID
													,@CustomerName
													,@ProjectCategoryAltKey
													,@ProjectSubCategoryAltkey
													,@ProjectOwnerShipAltKey
													,@ProjectAuthorityAltkey
													,@OriginalDCCO
													,@OriginalProjectCost
													,@OriginalDebt
													,@ProjectSubCatDescription
													--,@Debt_EquityRatio
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													,@ApprovedByFirstLevel
													,@DateApprovedFirstLevel
													
													
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE AdvAcPUIDetailMain SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND AccountID = @AccountID
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
			INSERT INTO AdvAcPUIDetailMain_Mod  
											( 
												      CustomerID
                                                     ,UCIFID
													 ,AccountID
													 ,AccountEntityID
                                                     ,CustomerName
                                                     ,ProjectCategoryAlt_Key
                                                     ,ProjectSubCategoryAlt_key
                                                     ,ProjectOwnerShipAlt_Key
                                                     ,ProjectAuthorityAlt_key
                                                     ,OriginalDCCO
                                                     ,OriginalProjectCost
                                                     ,OriginalDebt
													 ,ProjectSubCatDescription
                                                    -- ,Debt_EquityRatio
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
													@CustomerID
													,@UCIFID
													,@AccountID
													,@AccountEntityID
													,@CustomerName
													,@ProjectCategoryAltKey
													,@ProjectSubCategoryAltkey
													,@ProjectOwnerShipAltKey
													,@ProjectAuthorityAltkey
													,@OriginalDCCO
													,@OriginalProjectCost
													,@OriginalDebt
													,@ProjectSubCatDescription
													--,@Debt_EquityRatio
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													
	                                               ,@CreateProjStatusPUI_changeFields

											)
											DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from AdvAcPUIDetailMain_Mod where  AccountID = @AccountID
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
							from		AdvAcPUIDetailMain_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			AccountID = @AccountID										
										
	
	
	

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
								@ReferenceID=@AccountID ,-- ReferenceID ,
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
								@ReferenceID=@AccountID ,-- ReferenceID ,
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

END
GO