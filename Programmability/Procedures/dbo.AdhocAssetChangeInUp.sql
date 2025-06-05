SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------USE [SBM_MISDB]
------GO
------/****** Object:  StoredProcedure [dbo].[ValuationSourceDropDown]    Script Date: 9/3/2021 11:35:56 AM ******/
------DROP PROCEDURE [dbo].[ValuationSourceDropDown]--D
------GO
------/****** Object:  StoredProcedure [dbo].[ValidateExcel_DataUpload_ColletralUpload]    Script Date: 9/3/2021 11:35:56 AM ******/
------DROP PROCEDURE [dbo].[ValidateExcel_DataUpload_ColletralUpload] --D
------GO
------/****** Object:  StoredProcedure [dbo].[ColletralUploadDataInUp]    Script Date: 9/3/2021 11:35:56 AM ******/
------DROP PROCEDURE [dbo].[ColletralUploadDataInUp]  --D
------GO
------/****** Object:  StoredProcedure [dbo].[CollateralValueSearchList]    Script Date: 9/3/2021 11:35:56 AM ******/
------DROP PROCEDURE [dbo].[CollateralValueSearchList] --D
------GO
------/****** Object:  StoredProcedure [dbo].[CollateralValueInsert]    Script Date: 9/3/2021 11:35:56 AM ******/
------DROP PROCEDURE [dbo].[CollateralValueInsert] --D
------GO
------/****** Object:  StoredProcedure [dbo].[CollateralMgmtSearchList]    Script Date: 9/3/2021 11:35:56 AM ******/
------DROP PROCEDURE [dbo].[CollateralMgmtSearchList] --D
------GO
------/****** Object:  StoredProcedure [dbo].[CollateralMgmtInUp]    Script Date: 9/3/2021 11:35:56 AM ******/
------DROP PROCEDURE [dbo].[CollateralMgmtInUp] --D
------GO
------/****** Object:  StoredProcedure [dbo].[AdhocAssetClassViewDetail]    Script Date: 9/3/2021 11:35:56 AM ******/
------DROP PROCEDURE [dbo].[AdhocAssetClassViewDetail] --D
------GO
------/****** Object:  StoredProcedure [dbo].[ADHOCASSETCLASSQuickSearchList]    Script Date: 9/3/2021 11:35:56 AM ******/
------DROP PROCEDURE [dbo].[ADHOCASSETCLASSQuickSearchList] --D
------GO
------/****** Object:  StoredProcedure [dbo].[AdhocAssetChangeInUp]    Script Date: 9/3/2021 11:35:56 AM ******/
------DROP PROCEDURE [dbo].[AdhocAssetChangeInUp] --D
------GO
------/****** Object:  StoredProcedure [dbo].[AdhocAssetChangeInUp]    Script Date: 9/3/2021 11:35:56 AM ******/
------SET ANSI_NULLS ON
------GO
------SET QUOTED_IDENTIFIER ON
------GO



CREATE PROC [dbo].[AdhocAssetChangeInUp]

--Declare
				
	
							 @UCIF_ID                      varchar(20)=''
							,@CustomerID					varchar(100)=''
							,@CustomerName					varchar(200)=''
							,@AssetclassAlt_key             INT
							,@NpaDate                        Varchar(10)=''
							,@Reasonforchange                Varchar(100)=''
							,@ChangeTypeAlt_Key              Varchar(20) =''
						
							
						
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
						,@OldUCIF_ID           VARCHAR(20)	=''
						--,@TotCollateralsUCICCustAcc VARCHAR(5)	=''
						,@IfPercentagevalue_or_Absolutevalue decimal(18,2)=0
						,@Result					INT				=0 OUTPUT
						,@AdhocACL_ChangeFields varchar(100)=''
						
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
		
			SET @NpaDate=Case when @NpaDate='' then NULL Else Convert(date,@NpaDate) END 

			Declare @PrevAssetclassAlt_key int=(Select Sysassetclassalt_key from Pro.CustomerCal_Hist
			where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
			and RefCustomerID=@CustomerID)

			Declare @PrevNPAdate Date=(Select SysNPA_Dt from Pro.CustomerCal_Hist
			where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
			and RefCustomerID=@CustomerID)
	--	DECLARE @Parameter varchar(max) = (select 'AccountID|' + ISNULL(@AccountID,' ') + '}'+ 'UCICID|' + isnull(@UCICID,' ')
	--+ '}'+ 'CustomerID|'+isnull(@CustomerID,'')+ '}'+ 'CustomerName|'+isnull(@CustomerName,'')
	--+ '}'+ 'TaggingAlt_Key|'+convert(VARCHAR,isnull(@TaggingAlt_Key,''))
	--+ '}'+ 'DistributionAlt_Key|'+convert(VARCHAR,isnull(@DistributionAlt_Key,''))

	--+ '}'+ 'UCIF_ID|'+isnull(@UCIF_ID,'')
	--+ '}'+ 'CollateralTypeAlt_Key|'+convert(VARCHAR,isnull(@CollateralTypeAlt_Key,''))
	--+ '}'+ 'CollateralSubTypeAlt_Key|'+convert(VARCHAR,isnull(@CollateralSubTypeAlt_Key,''))
	--+ '}'+ 'CollateralOwnerTypeAlt_Key|'+convert(VARCHAR,isnull(@CollateralOwnerTypeAlt_Key,''))
	--+ '}'+ 'CollateralOwnerShipTypeAlt_Key|'+convert(VARCHAR,isnull(@CollateralOwnerShipTypeAlt_Key,''))
	--+ '}'+ 'ChargeTypeAlt_Key|'+convert(VARCHAR,isnull(@ChargeTypeAlt_Key,''))
	--+ '}'+ 'ChargeNatureAlt_Key|'+convert(VARCHAR,isnull(@ChargeNatureAlt_Key,''))
	--+ '}'+ 'ShareAvailabletoBankAlt_Key|'+convert(VARCHAR,isnull(@ShareAvailabletoBankAlt_Key,''))
	--+ '}'+ 'CollateralShareamount|'+convert(VARCHAR,isnull(@CollateralShareamount,'')))
	----DECLARE		@Result					INT				=0 
	--exec SecurityCheckDataValidation 14610 ,@Parameter,@Result OUTPUT
				
	--IF @Result = -1
	--return -1

	--FirstLevelDateApproved 
	--	FirstLevelApprovedBy  
	
		DECLARE 
						@AuthorisationStatus		varchar(5)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				DATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@ModifyBy                  varchar(20)     =null
						,@DateModified				DATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				DATETIME	= NULL
						,@ApprovedByFirstLevel		VARCHAR(20)		= NULL
						,@DateApprovedFirstLevel	DATETIME	= NULL
						,@FirstLevelApprovedBy       VARCHAR(20)		= NULL
						,@FirstLevelDateApproved    DATETIME	= NULL
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						,@AccountEntityId            int				= 0  
						,@CustomerEntityId            int				= 0 
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL
						,@CollIDAutoGenerated   Int
						,@SecurityEntityID smallint

				SET @ScreenName = 'Collateral'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999


	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
												
	PRINT 'A'




	    	set @NpaDate =case when ( @NpaDate='' or @NpaDate='01/01/1900' or @NpaDate='1900/01/01')
	                            then NULL ELSE @NpaDate END 




			DECLARE @AppAvail CHAR
					SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF(@AppAvail='N')                         
					BEGIN
						SET @Result=-11
						RETURN @Result
					END

				
Set @CustomerEntityId = (select CustomerEntityId from CurDat.CustomerBasicDetail where CustomerId=@CustomerID 
							and EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)

			DECLARE @ManualMOCDone CHAR
					SET @ManualMOCDone = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF exists (select 1 from MOC_ChangeDetails where CustomerEntityID = @CustomerEntityId and MOCType_Flag = 'CUST' --and MOC_ExpireDate>=@date
                  and EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey)                         
					BEGIN
						SET @Result=-50
						RETURN @Result
					END





	
	BEGIN TRY
	BEGIN TRANSACTION	
	-----
	
	PRINT 3	



	 IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
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
					--		SELECT 1,* --@SecurityEntityID=SecurityEntityID
							
					--FROM DBO.AdhocACL_ChangeDetails_Mod 
					--WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					--		AND UCIF_ID =@UCIF_ID
					--		AND AuthorisationStatus IN('NP','MP','A','RM')
							
						END 

					ELSE
						BEGIN
							PRINT 'DELETE'
							SET @AuthorisationStatus ='DP'
							
						END

						---FIND CREATED BY FROM MAIN TABLE
					Set @CreatedBy=(select  CreatedBy	
						
					FROM AdhocACL_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND UCIF_ID =@UCIF_ID)

                    Set @DateCreated	=(select  DateCreated						
					                    FROM AdhocACL_ChangeDetails 			 
					                    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							            AND UCIF_ID =@UCIF_ID)


				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				Print @CreatedBy+Space(2)+'Kaps'

				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM AdhocACL_ChangeDetails_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND UCIF_ID =@UCIF_ID
							AND AuthorisationStatus IN('NP','MP','1A','RM','A')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE AdhocACL_ChangeDetails
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND UCIF_ID =@UCIF_ID

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE AdhocACL_ChangeDetails_Mod
							SET AuthorisationStatus='FM'
							,ModifyBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND UCIF_ID =@UCIF_ID
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO Collateral_Insert
					Collateral_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE AdhocACL_ChangeDetails SET
									ModifyBy =@ModifyBy
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND UCIF_ID=@UCIF_ID
				

		end

----------------------------------------------------------------------------------
	ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE AdhocACL_ChangeDetails_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND UCIF_ID =@UCIF_ID
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	


				IF EXISTS(SELECT 1 FROM AdhocACL_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND UCIF_ID=@UCIF_ID)
				BEGIN
					UPDATE AdhocACL_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND UCIF_ID =@UCIF_ID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	
---------------------------------------------------------------------------------------------	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE AdhocACL_ChangeDetails_Mod
					SET AuthorisationStatus='R'
					,FirstLevelApprovedBy	 =@ApprovedBy
					,FirstLevelDateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND UCIF_ID =@UCIF_ID
						AND AuthorisationStatus in('NP','MP','DP','RM')	

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

				IF EXISTS(SELECT 1 FROM AdhocACL_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND UCIF_ID=@UCIF_ID)
				BEGIN
					UPDATE AdhocACL_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND UCIF_ID =@UCIF_ID
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()

		UPDATE AdhocACL_ChangeDetails_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND UCIF_ID=@UCIF_ID

	END

     	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()
		--SET @ApprovedByFirstLevel	   = @CrModApBy 
		--SET @DateApprovedFirstLevel  = GETDATE()
		set @FirstLevelDateApproved  =  GETDATE()
		set @FirstLevelApprovedBy   =  @CrModApBy

		--select * from AdhocACL_ChangeDetails_MOD

		UPDATE AdhocACL_ChangeDetails_MOD
						SET AuthorisationStatus ='1A'
							,FirstLevelApprovedBy=@ApprovedBy
							,FirstLevelDateApproved=@DateApproved
							WHERE UCIF_ID=@UCIF_ID
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
					 FROM AdhocACL_ChangeDetails
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND UCIF_ID=@UCIF_ID
					
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

					SELECT @ExEntityKey= MAX(EntityKey) FROM AdhocACL_ChangeDetails_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND UCIF_ID=@UCIF_ID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifyBy, @DateModified=DateModified,
						@ApprovedByFirstLevel=FirstLevelApprovedBy,@DateApprovedFirstLevel=FirstLevelDateApproved
					 FROM AdhocACL_ChangeDetails_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					Select 'Kaps'
					Select @ModifiedBy
					Select @DateModified
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DBO.AdhocACL_ChangeDetails_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND UCIF_ID=@UCIF_ID
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DBO.AdhocACL_ChangeDetails_Mod
							WHERE EntityKey=@ExEntityKey

							PRINT 'SacExpire'

							PRINT '@EffectiveFromTimeKey'
								PRINT @EffectiveFromTimeKey

								PRINT '@Timekey'
								PRINT @Timekey

								PRINT '@UCIF_ID'
								PRINT @UCIF_ID

					UPDATE DBO.AdhocACL_ChangeDetails_MOD
						SET  EffectiveToTimeKey =EffectiveFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND UCIF_ID=@UCIF_ID
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DBO.AdhocACL_ChangeDetails_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE UCIF_ID=@UCIF_ID
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM AdhocACL_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND UCIF_ID=@UCIF_ID)
						BEGIN
								UPDATE AdhocACL_ChangeDetails
									SET AuthorisationStatus ='A'
										,ModifyBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND UCIF_ID=@UCIF_ID

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
					      Print '@DelStatus'
						  Print  @DelStatus
						   Print '@AuthMode'
						  Print  @AuthMode

							UPDATE AdhocACL_ChangeDetails_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
									
								WHERE UCIF_ID=@UCIF_ID				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			
			--select * from dbo.AdhocACL_ChangeDetails_Mod
									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
				     PRINT 'Check'
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM AdhocACL_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND UCIF_ID=@UCIF_ID)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM AdhocACL_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND UCIF_ID=@UCIF_ID)
									BEGIN
											PRINT 'BBBB'
											PRINT '@UCIF_ID'
											PRINT @UCIF_ID
										UPDATE AdhocACL_ChangeDetails SET

												 UCIF_ID							= @UCIF_ID						
												 ,CustomerId						= @CustomerID					
												 ,CustomerName						= @CustomerName					
												 ,AssetClassAlt_Key=@AssetClassAlt_Key
												 ,NPA_Date=Case when @NpaDate='' then NULL Else @NpaDate END 
												 ,Reason=@Reasonforchange
												,FirstLevelApprovedBy=@ApprovedByFirstLevel
												,FirstLevelDateApproved=@DateApprovedFirstLevel
												,ChangeType                 =@ChangeTypeAlt_Key
												,ModifyBy					= @ModifiedBy
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND UCIF_ID=@UCIF_ID
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
									PRINT 'Insert into Main Table'
									PRINT '@ExEntityKey'
									PRINT @ExEntityKey
									PRINT '@DateCreated'
									print @ModifyBy
									PRINT Convert(smalldatetime,@DateCreated)

										INSERT INTO AdhocACL_ChangeDetails
												(
											
                                                    UCIF_ID
                                                    
                                                    ,CustomerId
                                                    ,CustomerEntityId
													
                                                    ,CustomerName
                                      
                                                    ,AssetClassAlt_Key
                                                    ,NPA_Date
                                                    ,AuthorisationStatus
                                                    ,EffectiveFromTimeKey
                                                    ,EffectiveToTimeKey
                                                    ,DateCreated
                                                    ,CreatedBy

                                                    ,DateModified
                                                    ,ModifyBy

                                                    ,DateApproved
                                                    ,ApprovedBy
                                                 
                                                    ,Reason
                                                    ,FirstLevelDateApproved
                                                    ,FirstLevelApprovedBy
													,ChangeType
													,PrevAssetClassAlt_Key
													,PrevNPA_Date
												)

										SELECT       

										         
                                                    @UCIF_ID
                                                    
                                                    ,@CustomerId
                                                    ,@CustomerEntityId
                                                    ,@CustomerName
                                                    ,@AssetClassAlt_Key
                                                    ,Case when @NpaDate='' then NULL Else @NpaDate END  
                                                    ,@AuthorisationStatus
                                                    ,@EffectiveFromTimeKey
                                                    ,@EffectiveToTimeKey
                                                    ,@DateCreated
                                                    ,@CreatedBy

                                                    ,@DateModified
                                                    ,@ModifiedBy

                                                    ,@DateApproved
                                                    ,@ApprovedBy
                                             
                                                    ,@Reasonforchange 
                                                 
                                                    ,@DateApprovedFirstLevel
													,@ApprovedByFirstLevel
													, @ChangeTypeAlt_Key
													,@PrevAssetclassAlt_key
													,@PrevNPAdate


												
	
										
									END

									UPDATE A
									SET A.UcifEntityID=B.UcifEntityID,
									A.CustomerEntityId=B.CustomerEntityId
									From AdhocACL_ChangeDetails A
									INNER JOIN PRO.CustomerCal_Hist B
									ON A.UCIF_ID =B.UCIF_ID 

									 --IF (@CollateralOwnerShipTypeAlt_Key=1)
										--	BEGIN 
										--		Update CollateralOtherOwner
										--		SET EffectiveToTimeKey=EffectiveFromTimeKey-1
										--		Where   UCIF_ID=@UCIF_ID  and EffectiveFromTimeKey=@EffectiveFromTimeKey and EffectiveToTimeKey=@EffectiveToTimeKey
										--	END

-----------------Added on 13-03-2021
	------------------------------------------------------
			
						
		




----------------------------------------------------------------------------------------------------

									IF @IsSCD2='Y' 
								BEGIN
								UPDATE AdhocACL_ChangeDetails SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND UCIF_ID=@UCIF_ID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO Collateral_Insert
					HistoryRecordInUp:
			END						



		END 

		

PRINT 6
SET @ErrorHandle=1

Collateral_Insert:
       
IF @ErrorHandle=0
	BEGIN

	            PRINT '@SecurityEntityIDSac'
						--PRINT @SecurityEntityID
						Declare @AccountExist Int=0

						Set @AccountExist =
						(
						Select 1 from AdhocACL_ChangeDetails
						where UCIF_ID=@UCIF_ID and (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --and isnull(AuthorisationStatus,'A')='A'
						union
						Select 1 from AdhocACL_ChangeDetails_Mod
						where UCIF_ID=@UCIF_ID and (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) --and AuthorisationStatus in ('NP','MP','1A','DP') 
						)

			INSERT INTO AdhocACL_ChangeDetails_Mod  
											( 
												
                                                 UCIF_ID
                                                
                                                 ,CustomerId
                                                 ,CustomerEntityId
                                                ,CustomerName
                                                 ,AssetClassAlt_Key
                                                 ,NPA_Date
                                                 ,Remark

                                                 ,AuthorisationStatus
                                                 ,EffectiveFromTimeKey
                                                 ,EffectiveToTimeKey

                                                 ,DateCreated
                                                 ,CreatedBy

												 ,DateModified
                                                 ,ModifyBy                                          

                                                 ,DateApproved
                                                 ,ApprovedBy
                                            
                                                
                                                 ,Reason
                                                 ,FirstLevelDateApproved
                                                 ,FirstLevelApprovedBy
												 ,ChangeType
												 ,ChangeFields
												 ,PrevAssetClassAlt_Key
												 ,PrevNPA_Date
											)
								VALUES
											( 
												 
                                                 @UCIF_ID
                                               
                                                 ,@CustomerId
                                                 ,@CustomerEntityId
                                                 ,@CustomerName
                                                 ,@AssetClassAlt_Key
                                                 ,Case when @NpaDate='' then NULL Else @NpaDate END 
                                                 ,@Remark

                                                 ,@AuthorisationStatus
                                                 ,@EffectiveFromTimeKey
                                                 ,@EffectiveToTimeKey

                                                 ,Case When @AccountExist=1    then  @DateCreated    Else    Getdate()     END
                                                 ,Case when @AccountExist=1    Then @CreatedBy       Else    @CrModApBy   END


												 ,Case  when @AccountExist=1 then  Getdate() else  Null END
                                                 ,Case  when @AccountExist=1 then  @CrModApBy else  Null END

                                                 ,@DateApproved
                                                 ,@ApprovedBy
                                  
                                                
                                                 ,@Reasonforchange 
                                                 ,@ApprovedByFirstLevel
                                                 ,@DateApprovedFirstLevel
												 ,@ChangeTypeAlt_Key
												 ,@AdhocACL_ChangeFields
												 ,@PrevAssetclassAlt_key
												 ,@PrevNPAdate
											)


	DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from AdhocACL_ChangeDetails_Mod where   UCIF_ID=@UCIF_ID
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
							from		AdhocACL_ChangeDetails_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			 UCIF_ID=@UCIF_ID	






	

	UPDATE A
	SET A.UcifEntityID=B.UcifEntityID,
	A.CustomerEntityId=B.CustomerEntityId
	From AdhocACL_ChangeDetails_Mod A
	INNER JOIN PRO.CustomerCal_Hist B
	ON A.UCIF_ID =B.UCIF_ID 


		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO Collateral_Insert_Edit_Delete
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
								@ReferenceID=@CustomerID ,-- ReferenceID ,
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
								@ReferenceID=@CustomerID ,-- ReferenceID ,
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