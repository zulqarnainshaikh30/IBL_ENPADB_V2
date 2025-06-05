SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO





CREATE PROC [dbo].[ACBUSegmentInUp]
						 
						 @AcBuSegmentAlt_Key			int				=0
						,@SourceAlt_key					varchar(30)		=''
						,@ACBUSegmentCode               varchar(20)		=''
						,@ACBUSegmentDescription		VARCHAR(100)	=''
					    ,@AcBuRevisedSegmentCode        VARCHAR(100)	=''						
						
						---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
						,@MenuID					INT				= 0
						,@OperationFlag				TINYINT			= 0
						,@AuthMode					CHAR(1)			= 'N'
						,@EffectiveFromTimeKey		INT				= 0
						,@EffectiveToTimeKey		INT				= 0
						,@TimeKey					INT				= 0
						,@CrModApBy					VARCHAR(20)		=''
						,@ScreenEntityId			INT				=null
						,@Result					INT				=0 OUTPUT
						,@ACBUSegment_ChangeFields	VARCHAR(100)	=''
						
AS
BEGIN
	SET NOCOUNT ON;
	
		PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
						 @AuthorisationStatus		VARCHAR(2)		= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifyBy					VARCHAR(20)		= NULL
						,@DateModified				SMALLDATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				SMALLDATETIME	= NULL
						,@ErrorHandle				int				= 0
						,@ExAcBuSegment_Key			int				= 0  
						


	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999


	--SET @AcBuSegmentAlt_Key = (Select ISNULL(Max(AcBuSegmentAlt_Key),0)+1 from DimACBUSegment)
	--PRINT 3
	Select  @AcBuSegmentAlt_Key= AcBuSegmentAlt_Key 
	from	DimACBUSegment_Mod
	where	ACBUSegmentCode=@ACBUSegmentCode
	and		SourceAlt_Key = @SourceAlt_Key
												
	PRINT 'A'
	

			DECLARE @AppAvail CHAR
					SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF(@AppAvail='N')                         
					BEGIN
						SET @Result=-11
						RETURN @Result
					END


IF Object_id('Tempdb..#Temp') Is Not Null

Drop Table #Temp



	IF Object_id('Tempdb..#final') Is Not Null

Drop Table #final



Create table #Temp

(ACBUSegmentCode Varchar(20)

,SourceAlt_Key Varchar(30)

,ACBUSegmentDescription	varchar(100)

)



Insert into #Temp values(@ACBUSegmentCode,@SourceAlt_Key,@ACBUSegmentDescription)



Select A.Businesscolvalues1 as SourceAlt_Key,ACBUSegmentCode,ACBUSegmentDescription  into #final From (

SELECT ACBUSegmentCode,ACBUSegmentDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  

                            FROM  (SELECT 

                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,

											ACBUSegmentCode,ACBUSegmentDescription

                                            from #Temp

                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)

						

)A 



ALTER TABLE #FINAL ADD AcBuSegmentAlt_Key INT

				



	IF @OperationFlag=1  --- add

	BEGIN

	PRINT 1

		-----CHECK DUPLICATE

		IF EXISTS(				                

					SELECT  1 FROM DimAcBuSegment WHERE SourceAlt_Key in(Select * from Split(@SourceAlt_key,',')) 

					                                                  AND ACBUSegmentCode=@ACBUSegmentCode

					                                                  AND ISNULL(AuthorisationStatus,'A')='A' 

																	  and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey

					UNION

					SELECT  1 FROM DimAcBuSegment_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)

															           AND SourceAlt_Key in(Select * from Split(@SourceAlt_key,','))

															           AND ACBUSegmentCode=@ACBUSegmentCode

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

				 SET @AcBuSegmentAlt_Key = (Select ISNULL(Max(AcBuSegmentAlt_Key),0)+1 from 

												        (Select AcBuSegmentAlt_Key from DimAcBuSegment

												 UNION 

												        Select AcBuSegmentAlt_Key from DimAcBuSegment_Mod

												)A)

                 IF @OperationFlag=1 

						BEGIN



						UPDATE TEMP 

						SET TEMP.AcBuSegmentAlt_Key=ACCT.AcBuSegmentAlt_Key

						 FROM #final TEMP

						INNER JOIN (SELECT SourceAlt_Key,(@AcBuSegmentAlt_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) AcBuSegmentAlt_Key

									FROM #final

									WHERE AcBuSegmentAlt_Key=0 OR AcBuSegmentAlt_Key IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key

						END





			END

		

	END



	           IF @OperationFlag=2 



				BEGIN



				UPDATE TEMP 

				SET TEMP.AcBuSegmentAlt_Key=@AcBuSegmentAlt_Key

				 FROM #final TEMP



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

					 SET @AcBuSegmentAlt_Key = (	Select ISNULL(Max(AcBuSegmentAlt_Key),0)+1 
													from ( 
															Select AcBuSegmentAlt_Key from DimACBUSegment
															UNION 
															Select AcBuSegmentAlt_Key from DimACBUSegment_Mod
														)
												A)


					 GOTO ACBUSegment_Insert
					 ACBUSegment_Insert_Add:
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				SET @DateCreated = GETDATE()
				Set @ModifyBy=@CrModApBy   
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
					FROM   DimACBUSegment  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
							

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM    DimACBUSegment_Mod 
					WHERE	(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key				
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimACBUSegment
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimACBUSegment_Mod
							SET AuthorisationStatus='FM'
							,ModifyBy=@ModifyBy
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO ACBUSegment_Insert
					ACBUSegment_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @ModifyBy   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE DimACBUSegment SET
									ModifyBy =@ModifyBy 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
								AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key

		end

		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimAcbusegment_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimAcbusegment WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		AND ACBUSegmentCode =@ACBUSegmentCode AND SourceAlt_key = @SourceAlt_key)
				BEGIN
					UPDATE DimACBUSegment
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimACBUSegment_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM')	

---------------Added for Rejection Pop Up Screen  29/06/2020 ----------

		Print 'Sunil'

--		DECLARE @AcBuSegment_Key as Int 
--		SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@AcBuSegment_Key=AcBuSegment_Key
--							 from DimACBUSegment_Mod 
--								WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
--									AND AcBuSegmentAlt_Key=@AcBuSegmentAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
		
--	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @AcBuSegment_Key, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
		

--------------------------------

				IF EXISTS(SELECT 1 from DimACBUSegment WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND AcBuSegmentAlt_Key=@AcBuSegmentAlt_Key)
				BEGIN
					UPDATE DimACBUSegment
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimACBUSegment_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key

	END
	ELSE IF @OperationFlag=16

		BEGIN
		
		PRINT 16
		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE DimACBUSegment_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							WHERE  AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
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
						SET @ModifyBy  =@CrModApBy
						SET @DateModified =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM DimACBUSegment 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key

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
					SELECT		@ExAcBuSegment_Key= MAX(AcBuSegment_Key) 
					FROM		DimACBUSegment_Mod 
					WHERE		(EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
					AND			AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
					AND			AuthorisationStatus IN('NP','MP','DP','RM','1A')	



					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifyBy=ModifyBy, @DateModified=DateModified
					 FROM DimACBUSegment_Mod
						WHERE AcBuSegment_Key=@ExAcBuSegment_Key
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurAcBuSegment_Key INT=0

					SELECT @ExAcBuSegment_Key= MIN(AcBuSegment_Key) FROM DimACBUSegment_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
					FROM	DimACBUSegment_Mod
					WHERE	AcBuSegment_Key=@ExAcBuSegment_Key

					UPDATE	DimACBUSegment_Mod
					SET		EffectiveToTimeKey =@CurrRecordFromTimeKey-1
					WHERE	(EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
					AND		AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
					AND		AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP'                     
					BEGIN	
						UPDATE DimACBUSegment_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE  AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimACBUSegment WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key)
						BEGIN
								UPDATE DimACBUSegment
									SET AuthorisationStatus ='A'
										,ModifyBy=@ModifyBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
									AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimACBUSegment_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE  AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key			
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimACBUSegment WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimACBUSegment WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimACBUSegment SET
										         SourceAlt_key					    = @SourceAlt_key	
												 ,AcBuSegmentAlt_Key				=@AcBuSegmentAlt_Key
												,ACBUSegmentCode					= @ACBUSegmentCode
												,ACBUSegmentDescription             = @ACBUSegmentDescription
												,AcBuRevisedSegmentCode				=@AcBuRevisedSegmentCode
												,ModifyBy							= @ModifyBy
												,DateModified						= @DateModified
												,ApprovedBy							= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved						= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus				= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END


								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO DimACBUSegment
											(		SourceAlt_Key
													,AcBuSegmentAlt_Key		
													,ACBUSegmentCode														
													,ACBUSegmentDescription													
													,AcBuRevisedSegmentCode
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifyBy
													,DateModified
													,ApprovedBy
													,DateApproved
													
												)

										select		SourceAlt_Key
													,@AcBuSegmentAlt_Key		
													,ACBUSegmentCode		
													,ACBUSegmentDescription	
													,@AcBuRevisedSegmentCode
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifyBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													FROM  #final TEMP
													
													
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimACBUSegment SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
									AND  AcBuSegmentAlt_Key =@AcBuSegmentAlt_Key
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO ACBUSegment_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

ACBUSegment_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO DimACBUSegment_Mod  
											(	 SourceAlt_Key
												,AcBuSegmentAlt_Key		
												,ACBUSegmentCode														
												,ACBUSegmentDescription
												,AcBuRevisedSegmentCode
												,AuthorisationStatus	
												,EffectiveFromTimeKey
												,EffectiveToTimeKey
												,CreatedBy
												,DateCreated
												,ModifyBy
												,DateModified
												,ApprovedBy
												,DateApproved
												,ChangeFields											
											)
								
											(			
											select			 SourceAlt_Key
															,AcBuSegmentAlt_Key		
															,ACBUSegmentCode		
															,ACBUSegmentDescription																														
															,@AcBuRevisedSegmentCode
															,@AuthorisationStatus
															,@EffectiveFromTimeKey
															,@EffectiveToTimeKey 
															,@CreatedBy
															,@DateCreated
															,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifyBy ELSE NULL END
															,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
															,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
															,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
															,@ACBUSegment_ChangeFields
															 from #final
											)
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO ACBUSegment_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO ACBUSegment_Insert_Edit_Delete
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
								@ReferenceID=@ACBUSegmentCode ,-- ReferenceID ,
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
								@ReferenceID=@ACBUSegmentCode ,-- ReferenceID ,
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

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) from DimACBUSegment WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--															AND AcBuSegmentAlt_Key=@AcBuSegmentAlt_Key

		
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