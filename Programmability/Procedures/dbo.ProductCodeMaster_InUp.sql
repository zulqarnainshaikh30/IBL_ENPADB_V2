SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[ProductCodeMaster_InUp]
--Declare
	  @ProductAlt_Key  	     Int	= 0
	 ,@SourceAlt_Key		 VARCHAR(20)=''
	 ,@ProductCode		     Varchar(20)	= ''
	 ,@ProductDescription    Varchar(500) = ''
	 ,@ProductGroup		     Varchar(500) = ''
	 ,@ProductSubGroup	     Varchar(500) = ''
	 ,@ProductCodeMaster_changeFields varchar(100)=null
	 ,@FacilityType varchar(20)
	 ,@SchemeType Varchar(20)
	 ,@ConvFactor Decimal(16,5)
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
		  @AuthorisationStatus		varchar(5)			= NULL 
		 ,@CreatedBy					VARCHAR(20)		= NULL
		 ,@DateCreated				DATETIME	= NULL
		 ,@ModifiedBy				VARCHAR(20)		= NULL
		 ,@DateModified				DATETIME	= NULL
		 ,@ApprovedBy				VARCHAR(20)		= NULL
		 ,@DateApproved				DATETIME	= NULL
		 ,@ErrorHandle				int				= 0
		 ,@ExEntityKey				int				= 0
		 ,@ApprovedByFirstLevel      VARCHAR(30)	 =  null
		 ,@DateApprovedFirstLevel    datetime =null
						
------------Added for Rejection Screen  29/06/2020   ----------

		DECLARE			@Uniq_EntryID			int	= 0
						,@RejectedBY			Varchar(50)	= NULL
						,@RemarkBy				Varchar(50)	= NULL
						,@RejectRemark			Varchar(200) = NULL
						,@ScreenName			Varchar(200) = NULL

				SET @ScreenName = 'GLProductCodeMaster'

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

				


					IF Object_id('Tempdb..#Temp') Is Not Null
					Drop Table #Temp

					IF Object_id('Tempdb..#final') Is Not Null
					Drop Table #final

					Create table #Temp
					(ProductCode Varchar(20)
					,SourceAlt_Key Varchar(20)
					,ProductDescription Varchar(500)
					)

	
					Insert into #Temp values(@ProductCode,@SourceAlt_Key,@ProductDescription)
					Select ProductCode,A.Businesscolvalues1 as SourceAlt_Key,ProductDescription  
				--	Select A.Businesscolvalues1 as SourceAlt_Key,ProductCode,ProductDescription  
					into #final From (
					SELECT ProductCode,ProductDescription,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
												FROM  (SELECT 
																CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
																ProductCode,ProductDescription
																from #Temp
														) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						
					)A 

					ALTER TABLE #FINAL ADD ProductAlt_Key INT

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM DimProduct WHERE  ProductCode=@ProductCode 
					AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
					AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >= @TimeKey
					UNION all
					SELECT  1 FROM DimProduct_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND  ProductCode=@ProductCode
															AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 

					--SELECT  1 FROM DimProduct WHERE  ProductCode='546' 
					----AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
					--AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=26959 AND EffectiveToTimeKey >=26959
					--UNION 
					--SELECT  1 FROM DimProduct_Mod  WHERE (EffectiveFromTimeKey <=26959 AND EffectiveToTimeKey >=26959)
					--										AND  ProductCode='546' 
					--										--AND SourceAlt_Key in(Select * from Split(@SourceAlt_Key,','))
					--										AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		ELSE
			BEGIN
			   PRINT 3

					 SET @ProductAlt_Key = (Select ISNULL(Max(ProductAlt_Key),0)+1 from 
												(Select ProductAlt_Key from DimProduct
												 UNION 
												 Select ProductAlt_Key from DimProduct_Mod
												)A) 



					IF @OperationFlag=1 
						BEGIN

								UPDATE TEMP 
								SET TEMP.ProductAlt_Key=ACCT.ProductAlt_Key
								 FROM #final TEMP
								INNER JOIN (SELECT SourceAlt_Key,(@ProductAlt_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) ProductAlt_Key
											FROM #final
											WHERE ProductAlt_Key=0 OR ProductAlt_Key IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key
						END


			END
	
	END
	

	IF @OperationFlag=2 
	BEGIN 

		UPDATE TEMP 
		SET TEMP.ProductAlt_Key=@ProductAlt_Key
			FROM #final TEMP

	END
	--select * from #final
	--select * from TEMP
	
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

					 ----SET @ProductAlt_Key = (Select ISNULL(Max(ProductAlt_Key),0)+1 from 
						----						(Select ProductAlt_Key from DimProduct
						----						 UNION 
						----						 Select ProductAlt_Key from DimProduct_Mod
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
					FROM DimProduct  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND ProductAlt_Key =@ProductAlt_Key

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimProduct_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND ProductAlt_Key =@ProductAlt_Key
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimProduct
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND ProductAlt_Key =@ProductAlt_Key

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimProduct_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModifie=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND ProductAlt_Key =@ProductAlt_Key
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

						UPDATE DimProduct SET
									ModifiedBy =@Modifiedby 
									,DateModifie =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey<=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND ProductAlt_Key=@ProductAlt_Key
				

		end

		----------------------------------NEW ADD FIRST LVL AUTH------------------
		ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimProduct_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND ProductAlt_Key =@ProductAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimProduct WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                              AND ProductAlt_Key =@ProductAlt_Key)
				BEGIN
					UPDATE DimProduct
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND ProductAlt_Key =@ProductAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	


		-------------------------------------------------------------------------
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimProduct_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND ProductAlt_Key =@ProductAlt_Key
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

				IF EXISTS(SELECT 1 FROM DimProduct WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND ProductAlt_Key=@ProductAlt_Key)
				BEGIN
					UPDATE DimProduct
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND ProductAlt_Key =@ProductAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimProduct_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND ProductAlt_Key=@ProductAlt_Key

	END

	--------NEW ADD------------------
	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedByFirstLevel	 = @CrModApBy 
		SET @DateApprovedFirstLevel  = GETDATE()
		Set @ModifiedBy = @CrModApBy --updated by vinit

		UPDATE DimProduct_Mod
						SET AuthorisationStatus ='1A'
							--,ApprovedBy=@ApprovedBy
							--,DateApproved=@DateApproved
							,ApprovedByFirstLevel=@ApprovedByFirstLevel --select ApprovedByFirstLevel,ModifiedBy from DimGLProduct_AU_Mod
							,DateApprovedFirstLevel=@DateApprovedFirstLevel
							,ModifiedBy =@ModifiedBy --updated by vinit
							WHERE ProductAlt_Key=@ProductAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM')

		END

	------------------------------

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
					 FROM DimProduct 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND ProductAlt_Key=@ProductAlt_Key
					
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
					SELECT @ExEntityKey= MAX(Product_Key) FROM DimProduct_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND ProductAlt_Key=@ProductAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModifie
					 FROM DimProduct_Mod
						WHERE Product_Key=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Product_Key) FROM DimProduct_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND ProductAlt_Key=@ProductAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimProduct_Mod
							WHERE Product_Key=@ExEntityKey

					UPDATE DimProduct_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND ProductAlt_Key=@ProductAlt_Key
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimProduct_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE ProductAlt_Key=@ProductAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimProduct WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND ProductAlt_Key=@ProductAlt_Key)
						BEGIN
								UPDATE DimProduct
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModifie=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND ProductAlt_Key=@ProductAlt_Key

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimProduct_Mod
								SET AuthorisationStatus ='A'
									--,ApprovedBy=@ApprovedBy
									--,DateApproved=@DateApproved
							          ,ModifiedBy =@CrModApBy --updated by vinit 
							         ,ApprovedBy=@CrModApBy 
							         ,DateApproved = getdate()
								WHERE ProductAlt_Key=@ProductAlt_Key				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

								-----------------------------new addby anuj /Jayadev 26052021 ----
								-- SET @ProductAlt_Key = (Select ISNULL(Max(ProductAlt_Key),0)+1 from 
								--				(Select ProductAlt_Key from DimProduct
								--				 UNION 
								--				 Select ProductAlt_Key from DimProduct_Mod
								--				)A)

								----------------------------------------------


						IF EXISTS(SELECT 1 FROM DimProduct WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND ProductAlt_Key=@ProductAlt_Key)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimProduct WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND ProductAlt_Key=@ProductAlt_Key)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimProduct SET
												 ProductAlt_Key			= @ProductAlt_Key
												 ,SourceAlt_Key			= @SourceAlt_Key
												,ProductCode			= @ProductCode
												,ProductName			= @ProductDescription
												,ProductGroup			= @ProductGroup
												,ProductSubGroup		= @ProductSubGroup
												,ModifiedBy				= @ModifiedBy
												,DateModifie			= @DateModified
												,ApprovedBy				= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved			= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus	= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												,FacilityType =@FacilityType
													,SchemeType =@SchemeType
													,ConvFactor=@ConvFactor
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND ProductAlt_Key=@ProductAlt_Key
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END
								--select @IsAvailable,@IsSCD2

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO DimProduct
												(
													 ProductAlt_Key
													,SourceAlt_Key
													,ProductCode
													,ProductName
													,ProductGroup
													,ProductSubGroup
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModifie
													,ApprovedBy
													,DateApproved
													,FacilityType
													,SchemeType
													,ConvFactor
												)

										select
													@ProductAlt_Key
													,SourceAlt_Key
													,@ProductCode				
					                             	,ProductDescription
													,@ProductGroup
													,@ProductSubGroup
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													,@FacilityType
													,@SchemeType
													,@ConvFactor
			FROM  #final TEMP
			
												
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimProduct SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND ProductAlt_Key=@ProductAlt_Key
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

--ALTER TABLE #FINAL ADD ProductAlt_Key INT

--IF @OperationFlag=1 

--BEGIN


--UPDATE TEMP 
--SET TEMP.ProductAlt_Key=ACCT.ProductAlt_Key
-- FROM #final TEMP
--INNER JOIN (SELECT SourceAlt_Key,(@ProductAlt_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) ProductAlt_Key
--			FROM #final
--			WHERE ProductAlt_Key=0 OR ProductAlt_Key IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key
--END

--IF @OperationFlag=2 

--BEGIN

--UPDATE TEMP 
--SET TEMP.ProductAlt_Key=@ProductAlt_Key
-- FROM #final TEMP

--END


	--------------------------------------------------




			INSERT INTO DimProduct_Mod  
											( 
												ProductAlt_Key
												,SourceAlt_Key
												,ProductCode
												,ProductName
												,ProductGroup
												,ProductSubGroup
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
												,FacilityType
												,SchemeType
												,ConvFactor												
											)

											select 
								                  --@SecurityMappingAlt_Key
												  @ProductAlt_Key	
												,SourceAlt_Key		
												,ProductCode			
												,ProductDescription
												,@ProductGroup
												,@ProductSubGroup
												,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													,@ProductCodeMaster_changeFields
													,@FacilityType
													,@SchemeType
													,@ConvFactor
												 
								 from #final

								--values(
											  
								--					@ProductAlt_Key
													
								--					,@ProductCode				
					   --                          	,@ProductDescription
								--					,@ProductGroup
								--					,@ProductSubGroup
								--					,@AuthorisationStatus
								--					,@EffectiveFromTimeKey
								--					,@EffectiveToTimeKey 
								--					,@CreatedBy
								--					,@DateCreated
								--					,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
								--					,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
								--					,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
								--					,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END

												
								--			)		
								DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from DimProduct_Mod where  ProductAlt_Key=@ProductAlt_Key
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
							from		DimProduct_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and		ProductAlt_Key=@ProductAlt_Key	
							
															
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
								@ReferenceID=@ProductCode ,-- ReferenceID ,
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
								@ReferenceID=@ProductCode ,-- ReferenceID ,
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