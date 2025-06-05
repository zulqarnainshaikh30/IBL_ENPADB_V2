SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROC [dbo].[DimAssetClassMaster_InUp]
						
						  @AssetClassMappingAlt_Key Int=0
						 ,@SourceAlt_Key		  varchar(20)=''
						 ,@SrcSysAssetClassCode	  Varchar(50)=''    ---SourceSysCRRCode
						 ,@SrcSysAssetClassName	  Varchar(50)=''	------Sourcesysassetclass
						 ,@AssetClassName			  Varchar(100)=''	------
						 ,@AssetClassAlt_Key		   Int=0
						 ,@DPD_LowerValue int=0
						 ,@DPD_HigherValue int=0
						 ,@DimAssetClassMaster_changeFields varchar(100)=null
						
						
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
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModifie				SMALLDATETIME	= NULL
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

				SET @ScreenName = 'AssetClassMaster'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)

	Declare @SrcSysAssetClassNameNew as Varchar(200)=(Select SrcSysClassName from DimAssetclassMapping WHere EffectiveToTimeKey=49999 And AssetClassMappingAlt_Key= @AssetClassMappingAlt_Key)
												
	PRINT 'A'
	

			DECLARE @AppAvail CHAR
					SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
				IF(@AppAvail='N')                         
					BEGIN
						SET @Result=-11
						RETURN @Result
					END
					-------------------------------------------------
IF Object_id('Tempdb..#Temp') Is Not Null
Drop Table #Temp

	IF Object_id('Tempdb..#final') Is Not Null
Drop Table #final

Create table #Temp
(AssetClassAlt_Key int
,SourceAlt_Key Varchar(20)
,AssetClassName	varchar(100)
)

Insert into #Temp values(@AssetClassAlt_Key,@SourceAlt_Key,@AssetClassName)

Select A.Businesscolvalues1 as SourceAlt_Key,AssetClassName,AssetClassAlt_Key  into #final From (
SELECT AssetClassName,AssetClassAlt_Key,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
                            FROM  (SELECT 
                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
											AssetClassName,AssetClassAlt_Key
                                            from #Temp
                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						
)A 

ALTER TABLE #FINAL ADD AssetClassMAPPINGALT_KEY INT

	/*
	select * Into DimAssetclassMapping_Mod  from DimAssetclassMapping where 1=2


	Alter Table DimAssetclassMapping
	add SourceAlt_Key int

	*/			

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM DimAssetClassMapping 
					WHERE  SourceAlt_Key in ( Select * from Split(@SourceAlt_Key,',')) 
					AND SrcSysClassCode=@SrcSysAssetClassCode 
					AND ISNULL(AuthorisationStatus,'A')='A' 
					and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM DimAssetClassMapping_Mod  
					WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
					AND  SourceAlt_Key in  ( Select * from Split(@SourceAlt_Key,','))
					AND SrcSysClassCode=@SrcSysAssetClassCode
					AND ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		ELSE
			BEGIN
			   PRINT 3
					 SET @AssetClassMappingAlt_Key = (Select ISNULL(Max(AssetClassMappingAlt_Key),0)+1 from 
												(Select AssetClassMappingAlt_Key from DimAssetClassMapping
												 UNION 
												 Select AssetClassMappingAlt_Key from DimAssetClassMapping_Mod
												)A)
                             
			IF @OperationFlag=1 
                   BEGIN


						UPDATE TEMP 
						SET TEMP.AssetClassMappingAlt_Key=ACCT.AssetClassMappingAlt_Key
						 FROM #final TEMP
						INNER JOIN (SELECT SourceAlt_Key,(@AssetClassMappingAlt_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) AssetClassMappingAlt_Key
									FROM #final
									WHERE AssetClassMappingAlt_Key=0 OR AssetClassMappingAlt_Key IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key

                           END

			END
		
	END
	               IF @OperationFlag=2 

					BEGIN

					UPDATE TEMP 
					SET TEMP.AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
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

					 --SET @AssetClassMappingAlt_Key = (Select ISNULL(Max(AssetClassMappingAlt_Key),0)+1 from 
						--						(Select AssetClassMappingAlt_Key from DimAssetClassMapping
						--						 UNION 
						--						 Select AssetClassMappingAlt_Key from DimAssetClassMapping_Mod
						--						)A)

					 GOTO AssetClassMaster_Insert
					AssetClassMaster_Insert_Add:
			END


			ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				SET @DateCreated = GETDATE()
				Set @Modifiedby=@CrModApBy   
				Set @DateModifie =GETDATE() 

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
					FROM DimAssetClassMapping  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimAssetClassMapping_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimAssetClassMapping
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimAssetClassMapping_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModifie=@DateModifie
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key
								--AND SourceAlt_Key = @SourceAlt_Key
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO AssetClassMaster_Insert
					AssetClassMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModifie = GETDATE() 

						UPDATE DimAssetClassMapping SET
									ModifiedBy =@Modifiedby 
									,DateModifie =@DateModifie 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
				

		end


		---------------------------------------------First lvl Authorise----------
ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimAssetClassMapping_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimAssetClassMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                  AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key)
				BEGIN
					UPDATE DimAssetClassMapping
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	
-------------------------------------------------------

	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimAssetClassMapping_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key
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

				IF EXISTS(SELECT 1 FROM DimAssetClassMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key)
				BEGIN
					UPDATE DimAssetClassMapping
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimAssetClassMapping_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key

	END
	---------------------new add
	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE DimAssetClassMapping_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							WHERE AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM')

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
					END
				ELSE
					BEGIN
						SET @ModifiedBy  =@CrModApBy
						SET @DateModifie =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM DimAssetClassMapping 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM DimAssetClassMapping_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModifie=DateModifie
					 FROM DimAssetClassMapping_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DimAssetClassMapping_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimAssetClassMapping_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE DimAssetClassMapping_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimAssetClassMapping_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimAssetClassMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key)
						BEGIN
								UPDATE DimAssetClassMapping
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModifie=@DateModifie
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimAssetClassMapping_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key				
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimAssetClassMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimAssetClassMapping WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimAssetClassMapping SET
												AssetClassMappingAlt_Key		= @AssetClassMappingAlt_Key
												,SourceAlt_Key				= @SourceAlt_Key	-----source	 
												,SrcSysClassCode			= @SrcSysAssetClassCode	 ---sourcesysCRRCode
												,SrcSysClassName			= @SrcSysAssetClassNameNew	----sourcesysclassname 
												,AssetClassName				= @AssetClassName  ------CrismacAssetclass			 
												,AssetClassAlt_Key			= @AssetClassAlt_Key -----Crismacode
												,DPD_LowerValue             =@DPD_LowerValue
												,DPD_HigherValue	        =@DPD_HigherValue
												 ,SrcSysGroup				=@SrcSysAssetClassName
												,ModifiedBy					= @ModifiedBy
												,DateModifie				= @DateModifie
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO DimAssetClassMapping
												(
													AssetClassMappingAlt_Key	
													,SourceAlt_Key			
													,SrcSysClassCode		
													,SrcSysClassName		
													,AssetClassName			
													,AssetClassAlt_Key
													,DPD_LowerValue
													,DPD_HigherValue
													,SrcSysGroup
															
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
													 @AssetClassMappingAlt_Key	
													,SourceAlt_Key			
													,@SrcSysAssetClassCode		
													,@SrcSysAssetClassNameNew		
													,AssetClassName			
													,@AssetClassAlt_Key	
													,@DPD_LowerValue
													,@DPD_HigherValue
													,@SrcSysAssetClassName	
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModifie  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END

											FROM #Temp		
													
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimAssetClassMapping SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO AssetClassMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

AssetClassMaster_Insert:
IF @ErrorHandle=0
	BEGIN

-----------------------------------------------------------
--	IF Object_id('Tempdb..#Temp') Is Not Null
--Drop Table #Temp

--	IF Object_id('Tempdb..#final') Is Not Null
--Drop Table #final

--Create table #Temp
--(AssetClassAlt_Key int
--,SourceAlt_Key Varchar(20)
--,AssetClassName	varchar(100)
--)

--Insert into #Temp values(@AssetClassAlt_Key,@SourceAlt_Key,@AssetClassName)

--Select A.Businesscolvalues1 as SourceAlt_Key,AssetClassName,AssetClassAlt_Key  into #final From (
--SELECT AssetClassName,AssetClassAlt_Key,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
--                            FROM  (SELECT 
--                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
--											AssetClassName,AssetClassAlt_Key
--                                            from #Temp
--                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						
--)A 

--ALTER TABLE #FINAL ADD AssetClassMAPPINGALT_KEY INT

--IF @OperationFlag=1 
--BEGIN


--UPDATE TEMP 
--SET TEMP.AssetClassMappingAlt_Key=ACCT.AssetClassMappingAlt_Key
-- FROM #final TEMP
--INNER JOIN (SELECT SourceAlt_Key,(@AssetClassMappingAlt_Key + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) AssetClassMappingAlt_Key
--			FROM #final
--			WHERE AssetClassMappingAlt_Key=0 OR AssetClassMappingAlt_Key IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key

--END

--IF @OperationFlag=2 

--BEGIN

--UPDATE TEMP 
--SET TEMP.AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
-- FROM #final TEMP

--END


	--------------------------------------------------
			INSERT INTO DimAssetClassMapping_Mod  
											( 
												AssetClassMappingAlt_Key	
												,SourceAlt_Key			
												,SrcSysClassCode		
												,SrcSysClassName		
												,AssetClassName			
												,AssetClassAlt_Key
												,DPD_LowerValue
												,DPD_HigherValue
												,SrcSysGroup
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
								select 
								                  --@AssetClassMappingAlt_Key
												  @AssetClassMappingAlt_Key	
												,SourceAlt_Key		
												,@SrcSysAssetClassCode		
												,@SrcSysAssetClassNameNew		
												,AssetClassName			
												,AssetClassAlt_Key
												,@DPD_LowerValue
												,@DPD_HigherValue
												,@SrcSysAssetClassName
												,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModifie ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													,@DimAssetClassMaster_changeFields
													
												 
								
								 from #final
											--(   
											--		 @AssetClassMappingAlt_Key	
											--		,@SourceAlt_Key			
											--		,@SrcSysAssetClassCode		
											--		,@SrcSysAssetClassName		
											--		,@AssetClassName			
											--		,@AssetClassAlt_Key
											--		,@AuthorisationStatus
											--		,@EffectiveFromTimeKey
											--		,@EffectiveToTimeKey 
											--		,@CreatedBy
											--		,@DateCreated
											--		,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
											--		,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModifie ELSE NULL END
											--		,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
											--		,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
											--		
											--)
											DECLARE @Parameter2 varchar(50)
	DECLARE @FinalParameter2 varchar(50)
	SET @Parameter2 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from DimAssetClassMapping_Mod where  AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
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
							from		DimAssetClassMapping_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key										
										
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO AssetClassMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO AssetClassMaster_Insert_Edit_Delete
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
								@ReferenceID=@SrcSysAssetClassCode ,-- ReferenceID ,
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
								@ReferenceID=@SrcSysAssetClassCode ,-- ReferenceID ,
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