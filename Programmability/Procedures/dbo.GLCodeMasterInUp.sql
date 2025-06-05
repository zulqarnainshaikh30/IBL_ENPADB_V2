SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[GLCodeMasterInUp]

--Declare
 @GLAlt_Key		Int	= 0
 ,@GLCode				Varchar(20)	= ''
 ,@GLDescription				Varchar(500) = ''
 ,@GLCodeMaster_changeFields varchar(100)=null 
 
 ---------D2k System Common Columns		--
 ,@Remark					VARCHAR(500)	= ''
 --,@MenuID					SMALLINT		= 0  change to Int
 ,@MenuID                    Int=0
 ,@OperationFlag				TINYINT			= 0
 ,@AuthMode					CHAR(1)			= 'N'
 ,@Authlevel					VARCHAR(3)=''
 ,@EffectiveFromTimeKey		INT		= 0
 ,@EffectiveToTimeKey		INT		= 0
 ,@TimeKey					INT		= 0
 ,@CrModApBy					VARCHAR(20)		=''
 ,@ScreenEntityId			INT				=null
 ,@Result					INT				=0 OUTPUT
						
						
AS
BEGIN
---------------------Updated By Vinit-----------
 
------------------------------------------------------------------------
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
						 @AuthorisationStatus		varchar(5)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				 DATETIME	= NULL --updated by vinit
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				 DATETIME	= NULL  --updated by vinit
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				 DATETIME	= NULL --updated by vinit
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0 
						,@ApprovedByFirstLevel      VARCHAR(30)	 =  null
						,@DateApprovedFirstLevel    datetime =null
						
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE		   	 @Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL

				SET @ScreenName = 'GLCodeMaster'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') --26959

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
					 

----------Update By Vinit -------------
  
-------------------------------------------------------------------------------------------------- 
--------------------------------------------------------------------------------------------------
 
	IF @OperationFlag=1  --- ADD
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE
	 IF EXISTS(				                
	 			SELECT  1 FROM DimGL WHERE  GLCode=@GLCode AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
	 			UNION
	 			SELECT  1 FROM DimGL_Mod  
	 			WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey) AND GLCode=@GLCode AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM')  
	 		)	
	 			
	 		BEGIN
	 		   PRINT 2
	 			SET @Result=-4
	 			RETURN @Result -- USER ALEADY EXISTS
	 		END
	 ELSE
			BEGIN
			   PRINT 3
				 SET @GLAlt_Key = (Select ISNULL(Max(GLAlt_Key),0)+1 from 
												(Select GLAlt_Key from DimGL
												 UNION 
												 Select GLAlt_Key from DimGL_Mod
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
					 SET @DateCreated = GETDATE()--Vinit 
					 SET @AuthorisationStatus='NP'

					 --SET @GLAlt_Key = (Select ISNULL(Max(GLAlt_Key),0)+1 from 
						--						(Select GLAlt_Key from DimGL
						--						 UNION 
						--						 Select GLAlt_Key from DimGL_Mod
						--						)A) 
					 GOTO GLCodeMaster_Insert
					GLCodeMaster_Insert_Add:
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				--SET @CreatedBy= @CrModApBy  
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
					SELECT  @CreatedBy		= Isnull(CreatedBy,'')
							,@DateCreated	= DateCreated 
					FROM DimGL  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND GLAlt_Key =@GLAlt_Key

							Print @CreatedBy
							Print @DateCreated

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimGL_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND GLAlt_Key =@GLAlt_Key
							AND AuthorisationStatus IN('NP','MP','A','RM')

							Print @CreatedBy
							Print @DateCreated
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimGL
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND GLAlt_Key =@GLAlt_Key

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimGL_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND GLAlt_Key =@GLAlt_Key
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

						UPDATE DimGL SET
						ModifiedBy =@Modifiedby 
						,DateModified =@DateModified 
						,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
						AND GLAlt_Key=@GLAlt_Key
				

		end


-------------------------------------------------------
--start 20042021
ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimGL_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND GLAlt_Key =@GLAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimGL WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND GLAlt_Key=@GLAlt_Key)
				BEGIN
					UPDATE DimGL
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND GLAlt_Key =@GLAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	


--till here
-------------------------------------------------------

	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimGL_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND GLAlt_Key =@GLAlt_Key
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

				IF EXISTS(SELECT 1 FROM DimGL WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND GLAlt_Key=@GLAlt_Key)
				BEGIN
					UPDATE DimGL
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND GLAlt_Key =@GLAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimGL_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND GLAlt_Key=@GLAlt_Key

	END

	ELSE IF @OperationFlag=16

		BEGIN

		--SET @ApprovedBy	   = @CrModApBy 
		--SET @DateApproved  = GETDATE()
		SET @ApprovedByFirstLevel	   = @CrModApBy 
		SET @DateApprovedFirstLevel  = GETDATE()
		Set @ModifiedBy = @CrModApBy --updated by vinit

		UPDATE DimGL_Mod
						    SET AuthorisationStatus ='1A'
							--,ApprovedBy=@ApprovedBy
							--,DateApproved=@DateApproved
							,ApprovedByFirstLevel=@ApprovedByFirstLevel --select ApprovedByFirstLevel,ModifiedBy from DimGLProduct_AU_Mod
							,DateApprovedFirstLevel=@DateApprovedFirstLevel
							,ModifiedBy =@ModifiedBy --updated by vinit
							WHERE GLAlt_Key=@GLAlt_Key
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
						
						SET @DateModified =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated FROM DimGL 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND GLAlt_Key=@GLAlt_Key 
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
					SET @ModifiedBy  =null
					SET @ModifiedBy  =@CrModApBy
					END
			END	
			
	---set parameters and UPDATE mod table in case maker checker enabled
			IF @AuthMode='Y'  
				BEGIN
				    Print 'B'
					DECLARE @DelStatus CHAR(2)=''-------------20042021
					DECLARE @CurrRecordFromTimeKey smallint=0

					Print 'C'
					SELECT @ExEntityKey= MAX(GL_Key) FROM DimGL_Mod 
						   WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND GLAlt_Key=@GLAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,
							@CreatedBy=CreatedBy,
							@DateCreated=DATECreated
						    ,@ModifiedBy=ModifiedBy, 
							@DateModified=DateModified
					 FROM DimGL_Mod WHERE GL_Key=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(GL_Key) FROM DimGL_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND GLAlt_Key=@GLAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	 
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey  FROM DimGL_Mod WHERE GL_Key=@ExEntityKey

					UPDATE DimGL_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND GLAlt_Key=@GLAlt_Key
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimGL_Mod
						SET  AuthorisationStatus ='A'
						    ,ModifiedBy =@CrModApBy --updated by vinit
							--,@ApprovedByFirstLevel	   = (select ModifiedBy  from DimGL_Mod where GLName=@GLDescription) --updated by vinit
							--,@DateApprovedFirstLevel  = (select  DateApprovedFirstLevel from DimGL_Mod where GLName=@GLDescription) --updated by vinit
							,ApprovedByFirstLevel =@ApprovedByFirstLevel
							,DateApprovedFirstLevel =@DateApprovedFirstLevel
							,DateApproved=@DateApproved 
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						    WHERE GLAlt_Key=@GLAlt_Key AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimGL WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND GLAlt_Key=@GLAlt_Key)
						BEGIN
								UPDATE DimGL
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND GLAlt_Key=@GLAlt_Key

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimGL_Mod
							SET AuthorisationStatus ='A'
							,ModifiedBy =@CrModApBy --updated by vinit 
							,ApprovedBy=@CrModApBy 
							,DateApproved = getdate()
							--,DateApproved=@DateApproved
						   WHERE GLAlt_Key=@GLAlt_Key AND AuthorisationStatus in('NP','MP','RM','1A') 
					END		
				END

		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimGL WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND GLAlt_Key=@GLAlt_Key)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A' 

								IF EXISTS(SELECT 1 FROM DimGL WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND GLAlt_Key=@GLAlt_Key)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimGL SET
												 GLAlt_Key					= @GLAlt_Key
												,GLCode				        = @GLCode
												,GLName						= @GLDescription
												,ModifiedBy					= @ModifiedBy
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND GLAlt_Key=@GLAlt_Key
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO DimGL
												(
													 GLAlt_Key
													,GLCode
													,GLName
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
													@GLAlt_Key
													,@GLCode
													,@GLDescription
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
								UPDATE DimGL SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND GLAlt_Key=@GLAlt_Key
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
			INSERT INTO DimGL_Mod  
											( 
												GLAlt_Key
												,GLCode
												,GLName
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
													@GLAlt_Key
													,@GLCode
													,@GLDescription
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
																,@GLCodeMaster_changeFields
													
											) 
DECLARE @Parameter2 varchar(50)
DECLARE @FinalParameter2 varchar(50)
SET @Parameter2 = (select STUFF((SELECT Distinct ',' +ChangeFields
								 from DimGL_Mod where GLAlt_Key=@GLAlt_Key
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
 
							UPDATE A
							set		 a.ChangeFields = @FinalParameter2							 																																	
							from	 DimGL_Mod   A
							WHERE (EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and		 GLAlt_Key=@GLAlt_Key									
										
	

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

					IF @OperationFlag IN(16,17,18,20,21) 
						BEGIN 
						       Print 'Authorised'
					
			
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
							    @BranchCode=''   ,  ----BranchCode
								@MenuID=@MenuID,
								@ReferenceID=@GLCode ,-- ReferenceID ,
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
								@ReferenceID=@GLCode ,-- ReferenceID ,
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