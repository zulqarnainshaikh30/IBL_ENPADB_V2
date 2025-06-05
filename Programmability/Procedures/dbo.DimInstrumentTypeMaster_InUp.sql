SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[DimInstrumentTypeMaster_InUp]
						
  @SrcSysInstrumentTypeCode			        Varchar(30)=''
 ,@SourceAlt_Key                              INT =0
 ,@SrcSysInstrumentTypeName	                Varchar(200)= ''
 ,@InstrumentTypeAlt_Key                      INT=0
 ,@InstrumentTypeName                         Varchar(200)=''
 ,@InstrumentTypeMappingAlt_Key               INT=0
 ,@DimInstrumentTypeMaster_changeFields varchar(100)=null
					   --,@InstrumentTypeGroup                              Varchar(200)=''
					   --,@InstrumentTypeSubGroup                              Varchar(200)='' 
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
						
				--select * from DimInstrumentType		
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
					   	@AuthorisationStatus		VARCHAR(5)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				DATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				DATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@ApprovedByFirstLevel      VARCHAR(30)		= NULL
						,@DateApproved				DATETIME	    = NULL
						,@DateApprovedFirstLevel	DATETIME	    = NULL
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0

						
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL

				SET @ScreenName = 'InstrumentTypeMaster'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') --26959

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
												
	PRINT 'A'
	

			DECLARE @AppAvail CHAR = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF(@AppAvail='N')                         
					BEGIN
						SET @Result=-11
						RETURN @Result
					END
/*
	select * into DimInstrumentTypeMapping  from DimInstrumentType	 where 1=2
		
	Alter table	DimInstrumentTypeMapping
	ADD SourceAlt_Key INT

	Alter table	DimInstrumentTypeMapping_Mod
	ADD InstrumentTypeMappingAlt_Key INT

	Alter table	DimInstrumentTypeMapping_Mod
	ADD SrcSysInstrumentTypeCode varchar(200)

	Alter table	DimInstrumentTypeMapping
	ADD SrcSysInstrumentTypeName varchar(200)

	alter table DimInstrumentTypeMapping_Mod
	drop column InstrumentType_Key 

	alter table DimInstrumentTypeMapping_mod
	add InstrumentType_Key smallint identity(1,1)


------EXEC sp_rename 'DimInstrumentTypeMapping_Mod.Source_Key', 'SourceAlt_Key', 'COLUMN';
*/	

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM DimInstrumentTypeMapping WHERE @InstrumentTypeAlt_Key=@InstrumentTypeAlt_Key
					                                  and InstrumentTypeName=@InstrumentTypeName
													 -- and SourceAlt_Key=@SourceAlt_Key
					 AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM DimInstrumentTypeMapping_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND @InstrumentTypeAlt_Key=@InstrumentTypeAlt_Key
															and InstrumentTypeName=@InstrumentTypeName
													      --  and SourceAlt_Key=@SourceAlt_Key
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM','1A') 
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
				 SET @InstrumentTypeAlt_Key = (Select ISNULL(Max(@InstrumentTypeAlt_Key),0)+1 from 
												(Select InstrumentTypeAlt_Key from DimInstrumentTypeMapping
												 UNION 
												 Select InstrumentTypeAlt_Key from DimInstrumentTypeMapping_Mod
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

					 --SET @InstrumentTypeMappingAlt_Key = (Select ISNULL(Max(InstrumentTypeMappingAlt_Key),0)+1 from 
						--						(Select InstrumentTypeMappingAlt_Key from DimInstrumentTypeMapping
						--						 UNION 
						--						 Select InstrumentTypeMappingAlt_Key from DimInstrumentTypeMapping_Mod
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
					FROM DimInstrumentTypeMapping  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND InstrumentTypeMappingAlt_Key =@InstrumentTypeMappingAlt_Key

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimInstrumentTypeMapping_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND InstrumentTypeMappingAlt_Key =@InstrumentTypeMappingAlt_Key
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimInstrumentTypeMapping
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND InstrumentTypeMappingAlt_Key =@InstrumentTypeMappingAlt_Key

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimInstrumentTypeMapping_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModifie=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND InstrumentTypeMappingAlt_Key =@InstrumentTypeMappingAlt_Key
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

						UPDATE DimInstrumentTypeMapping SET
									ModifiedBy =@Modifiedby 
									,DateModifie =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
								AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key 

		end
		--------------------------------
		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimInstrumentTypeMapping_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND InstrumentTypeMappingAlt_Key =@InstrumentTypeMappingAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimInstrumentTypeMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                  AND InstrumentTypeMappingAlt_Key =@InstrumentTypeMappingAlt_Key)
				BEGIN
					UPDATE DimInstrumentTypeMapping
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND InstrumentTypeMappingAlt_Key =@InstrumentTypeMappingAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	 
		----------------------
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimInstrumentTypeMapping_Mod
					SET AuthorisationStatus='R'
					 ,ApprovedByFirstLevel=   @CrModApBy 
					 ,DateApprovedFirstLevel=   GETDATE()
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND InstrumentTypeMappingAlt_Key =@InstrumentTypeMappingAlt_Key
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

				IF EXISTS(SELECT 1 FROM DimInstrumentTypeMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
				                                              AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key)
				BEGIN
					UPDATE DimInstrumentTypeMapping
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND InstrumentTypeMappingAlt_Key =@InstrumentTypeMappingAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimInstrumentTypeMapping_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key

	END
	-----------------------------------------------------------------------------
	ELSE IF @OperationFlag=16

		BEGIN

		--SET @ApprovedBy	   = @CrModApBy 
		--SET @DateApproved  = GETDATE()
		SET @ApprovedByFirstLevel	 = @CrModApBy 
		SET @DateApprovedFirstLevel  = GETDATE()
		Set @ModifiedBy = @CrModApBy --updated by vinit
		 UPDATE DimInstrumentTypeMapping_Mod --select ApprovedByFirstLevel,DateApprovedFirstLevel from DimInstrumentTypeMapping_Mod
						   SET AuthorisationStatus ='1A'
							--,ApprovedBy=@ApprovedBy
							--,DateApproved=@DateApproved
							,ApprovedByFirstLevel=@ApprovedByFirstLevel --select ApprovedByFirstLevel,ModifiedBy from DimGLProduct_AU_Mod
							,DateApprovedFirstLevel=@DateApprovedFirstLevel
							--,ModifiedBy =@ModifiedBy --updated by vinit
							WHERE InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM') 
		END
	----------------------------------------------------------------------------

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
					 FROM DimInstrumentTypeMapping 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key
					
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
					SELECT @ExEntityKey= MAX(InstrumentType_Key) FROM DimInstrumentTypeMapping_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModifie
					 FROM DimInstrumentTypeMapping_Mod
						WHERE InstrumentType_Key=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(InstrumentType_Key) FROM DimInstrumentTypeMapping_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimInstrumentTypeMapping_Mod
							WHERE InstrumentType_Key=@ExEntityKey

					UPDATE DimInstrumentTypeMapping_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimInstrumentTypeMapping_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimInstrumentTypeMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key)
						BEGIN
								UPDATE DimInstrumentTypeMapping
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModifie=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimInstrumentTypeMapping_Mod
								SET AuthorisationStatus ='A'
							     --  ,ModifiedBy =@CrModApBy --updated by vinit 
							       ,ApprovedBy=@CrModApBy 
							       ,DateApproved = getdate()
								WHERE InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimInstrumentTypeMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimInstrumentTypeMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimInstrumentTypeMapping SET
												         SrcSysInstrumentTypeCode     =@SrcSysInstrumentTypeCode	
												        ,SourceAlt_Key                =@SourceAlt_Key      
												        ,SrcSysInstrumentTypeName     =@SrcSysInstrumentTypeName	
												        ,InstrumentTypeAlt_Key        =@InstrumentTypeAlt_Key    
												        ,InstrumentTypeName           =@InstrumentTypeName
														,InstrumentTypeMappingAlt_Key =@InstrumentTypeMappingAlt_Key  
														--,InstrumentTypeGroup         =@InstrumentTypeGroup
														--,InstrumentTypeSubGroup         =@InstrumentTypeSubGroup      

												,ModifiedBy					= @ModifiedBy
												,DateModifie				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END
--alter table DimProvision_Seg_Mod
--add AdditionalprovisionRBINORMS decimal(16,2)

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO DimInstrumentTypeMapping
												(
													 InstrumentTypeAlt_Key
													,InstrumentTypeName
													,SourceAlt_Key
													,SrcSysInstrumentTypeName
													,SrcSysInstrumentTypeCode
													,InstrumentTypeMappingAlt_Key
													--,InstrumentTypeGroup
													--,InstrumentTypeSubGroup

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
													 @InstrumentTypeAlt_Key
													 ,@InstrumentTypeName  
													 ,@SourceAlt_Key                       
													 ,@SrcSysInstrumentTypeName
													,@SrcSysInstrumentTypeCode		
													,@InstrumentTypeMappingAlt_Key
													--,@InstrumentTypeGroup
													--,@InstrumentTypeSubGroup

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
								UPDATE DimInstrumentTypeMapping SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
									       AND InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key
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
			INSERT INTO DimInstrumentTypeMapping_Mod  
											( 
												     InstrumentTypeAlt_Key
													,InstrumentTypeName
													,SourceAlt_Key
													,SrcSysInstrumentTypeName
													,SrcSysInstrumentTypeCode
													,InstrumentTypeMappingAlt_Key
													--,InstrumentTypeGroup
													--,InstrumentTypeSubGroup

												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModifie
												,ApprovedBy
												,DateApproved
												,changeFields
																								
											)
								VALUES
											( 
													   @InstrumentTypeAlt_Key
													 ,@InstrumentTypeName 
													 ,@SourceAlt_Key                        
													 ,@SrcSysInstrumentTypeName
													,@SrcSysInstrumentTypeCode		
													,@InstrumentTypeMappingAlt_Key
													--,@InstrumentTypeGroup
													--,@InstrumentTypeSubGroup
													 	
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													,@DimInstrumentTypeMaster_changeFields
													
											)
	
				DECLARE @Parameter2 varchar(50)
	DECLARE @FinalParameter2 varchar(50)
	SET @Parameter2 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from DimInstrumentTypeMapping_Mod where  InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key
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
							from		DimInstrumentTypeMapping_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			 InstrumentTypeMappingAlt_Key=@InstrumentTypeMappingAlt_Key								
									
	

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
								@ReferenceID=@SrcSysInstrumentTypeCode ,-- ReferenceID ,
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
								@ReferenceID=@SrcSysInstrumentTypeCode ,-- ReferenceID ,
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