SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO




-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[SchemeCodeMaster_InUp]



--Declare
						 @SchemeCode		    varchar(50)=''
						,@SchemeCodeDescription				VARCHAR(500)=''
						,@SchemeCodeMaster_changeFields varchar(100)=null
						
						---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
					
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
						@AuthorisationStatus		varchar(5)			= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				SMALLDATETIME	= NULL
						,@ApprovedBy				VARCHAR(20)		= NULL
						,@DateApproved				SMALLDATETIME	= NULL
						,@ErrorHandle				int				= 0
						,@ExEntityKey				int				= 0  
						,@SchemeCodeAltKey                Int       =0
						
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL

				SET @ScreenName = 'BuyoutSchemeCodeMaster'

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

				


					--IF Object_id('Tempdb..#Temp') Is Not Null
					--Drop Table #Temp

					--IF Object_id('Tempdb..#final') Is Not Null
					--Drop Table #final

					--Create table #Temp
					--(ProductCode Varchar(20)
					--,SourceAlt_Key Varchar(20)
					--,ProductDescription Varchar(500)
					--)

	
					--Insert into #Temp values(@ProductCode,@SourceAlt_Key,@ProductDescription)

					--Select A.Businesscolvalues1 as SourceAlt_Key,ProductCode,ProductDescription  into #final From (
					--SELECT ProductCode,ProductDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
					--							FROM  (SELECT 
					--											CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
					--											ProductCode,ProductDescription
					--											from #Temp
					--									) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						
					--)A 

					--ALTER TABLE #FINAL ADD SchemeCodeAltKey INT

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM DimBuyoutSchemeCode WHERE  SchemeCode=@SchemeCode
					--AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
					AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM DimBuyoutSchemeCode_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND  SchemeCode=@SchemeCode
															
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

					 SET @SchemeCodeAltKey = (Select ISNULL(Max(SchemeCodeAltKey),0)+1 from 
												(Select SchemeCodeAltKey from DimBuyoutSchemeCode
												 UNION 
												 Select SchemeCodeAltKey from DimBuyoutSchemeCode_Mod
												)A)





			END
	
	END
	

	IF @OperationFlag=2 
	BEGIN

	SET @SchemeCodeAltKey=0

					Select @SchemeCodeAltKey=SchemeCodeAltKey
								from DimBuyoutSchemeCode_Mod A
								    WHERE
									(EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND
								 SchemeCode =@SchemeCode
								AND AuthorisationStatus IN('NP','MP','RM')
								 AND A.EntityKey IN
                     (
                         SELECT MAX(EntityKey)
                         FROM DimBuyoutSchemeCode_Mod
                         WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                               AND AuthorisationStatus IN('NP','MP','RM')
                         GROUP BY SchemeCodeAltKey
                     )

								PRINT '@SchemeCodeAltKey'
								PRINT @SchemeCodeAltKey

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

					 ----SET @SchemeCodeAltKey = (Select ISNULL(Max(SchemeCodeAltKey),0)+1 from 
						----						(Select SchemeCodeAltKey from DimBuyoutSchemeCode
						----						 UNION 
						----						 Select SchemeCodeAltKey from DimBuyoutSchemeCode_Mod
						----						)A)

					 GOTO GLCodeMaster_Insert
					GLCodeMaster_Insert_Add:
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
					FROM DimBuyoutSchemeCode  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SchemeCode =@SchemeCode

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimBuyoutSchemeCode_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SchemeCode =@SchemeCode
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimBuyoutSchemeCode
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND SchemeCode =@SchemeCode

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimBuyoutSchemeCode_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND SchemeCode =@SchemeCode
								AND AuthorisationStatus IN('NP','MP','RM')

								

								
								
					END

					IF @OperationFlag=3
					BEGIN	
					PRINT 'SacDelete'
					IF NOT EXISTS(SELECT 1 FROM DimBuyoutSchemeCode WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND SchemeCode=@SchemeCode)
					BEGIN
					PRINT 'SacDelete111'

						UPDATE DimBuyoutSchemeCode_Mod
							SET EffectiveToTimeKey=@TimeKey-1
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND SchemeCode =@SchemeCode
								AND AuthorisationStatus IN('NP','MP','RM')

								SET @Result=1
								COMMIT TRAN
					            RETURN @Result 
                      END
								
								
					END
					--IF @OperationFlag=3
					--BEGIN	

					--	UPDATE DimBuyoutSchemeCode_Mod
					--		SET AuthorisationStatus='FM'
					--		,ModifiedBy=@Modifiedby
					--		,DateModified=@DateModified
					--	WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
					--			AND SchemeCode =@SchemeCode
					--			AND AuthorisationStatus IN('DP')

								

								
								
					--END

					GOTO GLCodeMaster_Insert
					GLCodeMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE DimBuyoutSchemeCode SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND SchemeCode=@SchemeCode
				

		end

		----------------------------------NEW ADD FIRST LVL AUTH------------------
		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimBuyoutSchemeCode_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND SchemeCode =@SchemeCode
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimBuyoutSchemeCode WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                              AND SchemeCode =@SchemeCode)
				BEGIN
					UPDATE DimBuyoutSchemeCode
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SchemeCode =@SchemeCode
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	


		-------------------------------------------------------------------------
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimBuyoutSchemeCode_Mod
					SET AuthorisationStatus='R'
					,FirstLevelApprovedBy	 =@ApprovedBy
					,FirstLevelDateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND SchemeCode =@SchemeCode
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

				IF EXISTS(SELECT 1 FROM DimBuyoutSchemeCode WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND SchemeCode=@SchemeCode)
				BEGIN
					UPDATE DimBuyoutSchemeCode
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND SchemeCode =@SchemeCode
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimBuyoutSchemeCode_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND SchemeCode=@SchemeCode

	END

	--------NEW ADD------------------
	--ELSE IF @OperationFlag=16

	--	BEGIN

	--	SET @ApprovedBy	   = @CrModApBy 
	--	SET @DateApproved  = GETDATE()

	--	UPDATE DimBuyoutSchemeCode_Mod
	--					SET AuthorisationStatus ='1A'
	--						,ApprovedBy=@ApprovedBy
	--						,DateApproved=@DateApproved
	--						WHERE SchemeCode=@SchemeCode
	--						AND AuthorisationStatus in('NP','MP','DP','RM')

	--	END

	------------------------------
ELSE IF @OperationFlag=16  
	BEGIN
  
  SET @ApprovedBy    = @CrModApBy   
  SET @DateApproved  = GETDATE()  
  
  UPDATE DimBuyoutSchemeCode_Mod  
      SET AuthorisationStatus ='1A'  
       ,FirstLevelApprovedBy=@ApprovedBy  
       ,FirstLevelDateApproved=@DateApproved  
       WHERE    SchemeCode=@SchemeCode
       AND AuthorisationStatus in('NP','MP','RM')  
  

  
  UPDATE DimBuyoutSchemeCode_Mod  
      SET AuthorisationStatus ='D1'  
       ,FirstLevelApprovedBy=@ApprovedBy  
       ,FirstLevelDateApproved=@DateApproved  
       WHERE    SchemeCode=@SchemeCode
       AND AuthorisationStatus in('DP')  

	     UPDATE DimBuyoutSchemeCode 
      SET AuthorisationStatus ='D1'  
       
       WHERE    SchemeCode=@SchemeCode
       AND AuthorisationStatus in('DP') 
    
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
					 FROM DimBuyoutSchemeCode 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND SchemeCode=@SchemeCode
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM DimBuyoutSchemeCode_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND SchemeCode=@SchemeCode
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM DimBuyoutSchemeCode_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DimBuyoutSchemeCode_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND SchemeCode=@SchemeCode
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimBuyoutSchemeCode_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE DimBuyoutSchemeCode_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND SchemeCode=@SchemeCode
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimBuyoutSchemeCode_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE SchemeCode=@SchemeCode
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimBuyoutSchemeCode WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND SchemeCode=@SchemeCode)
						BEGIN
								UPDATE DimBuyoutSchemeCode
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND SchemeCode=@SchemeCode

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimBuyoutSchemeCode_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE SchemeCode=@SchemeCode				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

								-----------------------------new addby anuj /Jayadev 26052021 ----
								-- SET @SchemeCodeAltKey = (Select ISNULL(Max(SchemeCodeAltKey),0)+1 from 
								--				(Select SchemeCodeAltKey from DimBuyoutSchemeCode
								--				 UNION 
								--				 Select SchemeCodeAltKey from DimBuyoutSchemeCode_Mod
								--				)A)

								----------------------------------------------


						IF EXISTS(SELECT 1 FROM DimBuyoutSchemeCode WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND SchemeCode=@SchemeCode)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimBuyoutSchemeCode WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND SchemeCode=@SchemeCode)
									BEGIN
											PRINT 'BBBB'
												UPDATE DimBuyoutSchemeCode SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1,
										AuthorisationStatus='A'
										
									 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND SchemeCode=@SchemeCode AND AuthorisationStatus in('D1')

													UPDATE DimBuyoutSchemeCode_Mod SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1,
										AuthorisationStatus='A'
										
									 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND SchemeCode=@SchemeCode AND AuthorisationStatus in('D1')
										UPDATE DimBuyoutSchemeCode SET
											
												SchemeCodeDescription=@SchemeCodeDescription
												,ModifiedBy				= @ModifiedBy
												,DateModified			= @DateModified
												,ApprovedBy				= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved			= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus	= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND SchemeCode=@SchemeCode

											
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END
								--select @IsAvailable,@IsSCD2

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
									
			INSERT INTO DimBuyoutSchemeCode 
											( 
												SchemeCodeAltKey
												,SchemeCodeDescription
											    ,SchemeCode
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

											select 
								                 
												  SchemeCodeAltKey		
												,@SchemeCodeDescription		
												,@SchemeCode
												,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL  END
													From DimBuyoutSchemeCode_Mod A
                                   WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey) AND A.SchemeCode=@SchemeCode
												
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimBuyoutSchemeCode SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND SchemeCode=@SchemeCode
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

-----------------------------------------------------------
--	IF Object_id('Tempdb..#Temp') Is Not Null
--Drop Table #Temp

--	IF Object_id('Tempdb..#final') Is Not Null
--Drop Table #final

--Create table #Temp
--(ProductCode Varchar(20)
--,SourceAlt_Key Varchar(20)
--,ProductDescription Varchar(500)
--)

					
		

--Insert into #Temp values(@ProductCode,@SourceAlt_Key,@ProductDescription)

--Select A.Businesscolvalues1 as SourceAlt_Key,ProductCode,ProductDescription  into #final From (
--SELECT ProductCode,ProductDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
--                            FROM  (SELECT 
--                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
--											ProductCode,ProductDescription
--                                            from #Temp
--                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						
--)A 

--ALTER TABLE #FINAL ADD SchemeCodeAltKey INT

--IF @OperationFlag=1 

--BEGIN


--UPDATE TEMP 
--SET TEMP.SchemeCodeAltKey=ACCT.SchemeCodeAltKey
-- FROM #final TEMP
--INNER JOIN (SELECT SourceAlt_Key,(@SchemeCodeAltKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) SchemeCodeAltKey
--			FROM #final
--			WHERE SchemeCodeAltKey=0 OR SchemeCodeAltKey IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key
--END

--IF @OperationFlag=2 

--BEGIN

--UPDATE TEMP 
--SET TEMP.SchemeCodeAltKey=@SchemeCodeAltKey
-- FROM #final TEMP

--END


	--------------------------------------------------



			INSERT INTO DimBuyoutSchemeCode_Mod  
											( 
												SchemeCodeAltKey
												,SchemeCodeDescription
											     ,SchemeCode
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

											select 
								                  --@SecurityMappingAlt_Key
												  @SchemeCodeAltKey	
												
												,@SchemeCodeDescription			
												,@SchemeCode
												,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													,@SchemeCodeMaster_changeFields
													
												 
						
	
		If @SchemeCodeAltKey=0
		BEGIN

		Update A
		Set A.SchemeCodeAltKey=B.SchemeCodeAltKey
		From  DimBuyoutSchemeCode_Mod A INNER JOIN DimBuyoutSchemeCode B
		On A.SchemeCode=B.SchemeCode
		Where A.SchemeCode=@SchemeCode

		END
										
	
	

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