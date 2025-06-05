SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[SourceSystemsMasterInUp]
@Source_Key int = 0
,@SourceAlt_Key	Int	= 0
,@SourceName Varchar(50)	= ''
,@SourceSystemsMaster_changeFields varchar(100)=null


---------D2k System Common Columns		--
,@Remark					VARCHAR(500)	= ''
--,@MenuID					SMALLINT		= 0  change to Int
,@MenuID                    Int=0
,@OperationFlag				TINYINT			= 0
,@AuthMode					CHAR(1)			= 'N'
,@EffectiveFromTimeKey		INT		         =           0
,@EffectiveToTimeKey		INT		         =           0
,@TimeKey					INT		         =           0
,@CrModApBy					VARCHAR(20)		=''
,@ScreenEntityId			INT				=null
,@Result					INT				=0 OUTPUT 
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
		@AuthorisationStatus		varchar(5)		= NULL 
		,@CreatedBy					VARCHAR(20)		= NULL
		,@DateCreated				DATETIME	= NULL
		,@ModifiedBy				VARCHAR(20)		= NULL
		,@DateModified				 DATETIME	= NULL
		,@ApprovedBy				VARCHAR(20)		= NULL
		,@DateApproved				 DATETIME	= NULL
		,@ErrorHandle				int				= 0
		,@ExEntityKey				int				= 0  
		 ,@ApprovedByFirstLevel      VARCHAR(30)	 =  null
		 ,@DateApprovedFirstLevel    datetime =null
						
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			
		@Uniq_EntryID			int	= 0
		,@RejectedBY			Varchar(50)	= NULL
		,@RemarkBy				Varchar(50)	= NULL
		,@RejectRemark			Varchar(200) = NULL
		,@ScreenName			Varchar(200) = NULL 
				SET @ScreenName = 'SourceSystemMaster'


	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey
 SET @EffectiveToTimeKey = 49999

	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
 PRINT 'A'
	
SET @Source_Key = (select Source_key from DimSourceDB_Mod where SourceAlt_Key = @SourceAlt_Key)

	DECLARE @AppAvail CHAR = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
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
					SELECT  1 FROM DIMSOURCEDB WHERE SourceName=@SourceName AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM DimSourceDB_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND SourceName=@SourceName
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
				 SET @SourceAlt_Key = (Select ISNULL(Max(SourceAlt_Key),0)+1 from 
												(Select SourceAlt_Key from DIMSOURCEDB
												 UNION 
												 Select SourceAlt_Key from DimSourceDB_Mod
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

					 SET @SourceAlt_Key = (Select ISNULL(Max(SourceAlt_Key),0)+1 from 
												(Select SourceAlt_Key from DIMSOURCEDB
												 UNION 
												 Select SourceAlt_Key from DimSourceDB_Mod
												)A)

					 GOTO SourceSystemMaster_Insert
					SourceSystemMaster_Insert_Add:
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				set @DateCreated=null
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
					SELECT  
					@CreatedBy		= CreatedBy ,
					@DateCreated	= DateCreated  
					FROM DIMSOURCEDB  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND SourceAlt_Key =@SourceAlt_Key

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimSourceDB_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SourceAlt_Key =@SourceAlt_Key
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DIMSOURCEDB
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND SourceAlt_Key =@SourceAlt_Key 
					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	 
						UPDATE DimSourceDB_Mod 
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified= @DateModified
						    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND SourceAlt_Key =@SourceAlt_Key
							AND AuthorisationStatus IN('NP','MP','RM')
					END 

					GOTO SourceSystemMaster_Insert
					SourceSystemMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE DIMSOURCEDB SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND SourceAlt_Key=@SourceAlt_Key
				

		end

		-----------------------------------------first lvel auth.---------
		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimSourceDB_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND SourceAlt_Key =@SourceAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimSourceDB WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                        AND SourceAlt_Key =@SourceAlt_Key)
				BEGIN
					UPDATE DimSourceDB
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SourceAlt_Key =@SourceAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END

		---------------------------------------------------------------------------
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimSourceDB_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND SourceAlt_Key =@SourceAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM')	



				IF EXISTS(SELECT 1 FROM DIMSOURCEDB WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND SourceAlt_Key=@SourceAlt_Key)
				BEGIN
					UPDATE DIMSOURCEDB
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SourceAlt_Key =@SourceAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimSourceDB_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND SourceAlt_Key=@SourceAlt_Key

	END

	-----new add
	ELSE IF @OperationFlag=16

		BEGIN

        SET @ApprovedByFirstLevel	 = @CrModApBy 
		SET @DateApprovedFirstLevel  = GETDATE()
		Set @ModifiedBy = @CrModApBy --updated by vinit

		UPDATE DimSourceDB_Mod
						SET AuthorisationStatus ='1A'
							--,ApprovedBy=@ApprovedBy
							--,DateApproved=@DateApproved
							,ApprovedByFirstLevel=@ApprovedByFirstLevel --select ApprovedByFirstLevel,ModifiedBy from DimGLProduct_AU_Mod
							,DateApprovedFirstLevel=@DateApprovedFirstLevel
							--,ModifiedBy =@ModifiedBy --updated by vinit
							WHERE SourceAlt_Key=@SourceAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM')

		END

	---------------------------

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
					 FROM DIMSOURCEDB 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND SourceAlt_Key=@SourceAlt_Key
					
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
					SELECT @ExEntityKey= MAX(Source_Key) FROM DimSourceDB_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND SourceAlt_Key=@SourceAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM DimSourceDB_Mod
						WHERE Source_Key=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Source_Key) FROM DimSourceDB_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND SourceAlt_Key=@SourceAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimSourceDB_Mod
							WHERE Source_Key=@ExEntityKey

					UPDATE DimSourceDB_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND SourceAlt_Key=@SourceAlt_Key
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimSourceDB_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE SourceAlt_Key=@SourceAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DIMSOURCEDB WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND SourceAlt_Key=@SourceAlt_Key)
						BEGIN
								UPDATE DIMSOURCEDB
									SET AuthorisationStatus ='A'
										--,ModifiedBy=@ModifiedBy
										--,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND SourceAlt_Key=@SourceAlt_Key

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimSourceDB_Mod
								SET AuthorisationStatus ='A'
							       --,ModifiedBy =@CrModApBy --updated by vinit 
							       ,ApprovedBy=@CrModApBy 
							       ,DateApproved = getdate()
								WHERE SourceAlt_Key=@SourceAlt_Key				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DIMSOURCEDB WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND SourceAlt_Key=@SourceAlt_Key)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DIMSOURCEDB WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND SourceAlt_Key=@SourceAlt_Key)
									BEGIN
											PRINT 'BBBB'
										UPDATE DIMSOURCEDB SET
												 SourceAlt_Key				=@SourceAlt_Key
												,SourceName					= @SourceName
												,ModifiedBy					= @ModifiedBy
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND SourceAlt_Key=@SourceAlt_Key
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO DIMSOURCEDB
												(	
												--Source_Key
													 SourceAlt_Key
													,SourceName
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,RecordStatus
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModified
													,ApprovedBy
													,DateApproved
													
												)

										SELECT		--@Source_Key
													@SourceAlt_Key
													,@SourceName
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,'C'
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END

													
													
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DIMSOURCEDB SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND SourceAlt_Key=@SourceAlt_Key
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO SourceSystemMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

SourceSystemMaster_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO DimSourceDB_Mod  
											( 
												SourceAlt_Key
												,SourceName
												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifiedBy
												,DateModified
												,ApprovedBy
												,DateApproved
												,changefields
																								
											)
								VALUES
											( 
													@SourceAlt_Key
													,@SourceName
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													,@SourceSystemsMaster_changeFields 
											)
	DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from DimSourceDB_Mod   where  SourceAlt_Key=@SourceAlt_Key
											and ISNULL(AuthorisationStatus,'CustomerACID=A')  in ( 'A','MP')
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
							from		DimSourceDB_Mod     A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			   SourceAlt_Key=@SourceAlt_Key
	
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO SourceSystemMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO SourceSystemMaster_Insert_Edit_Delete
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
								@ReferenceID=@SourceName ,-- ReferenceID ,
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
								@ReferenceID=@SourceName ,-- ReferenceID ,
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