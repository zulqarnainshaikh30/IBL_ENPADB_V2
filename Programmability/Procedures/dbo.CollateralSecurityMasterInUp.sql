SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROC [dbo].[CollateralSecurityMasterInUp]
						 @CollateralSubTypeAltKey			Int=0
						,@CollateralTypeAltKey				INT=0
						,@CollateralSubTypeID			    VARCHAR(25)=''
						,@CollateralSubType					VARCHAR(20)=''
						,@CollateralSubTypeDescription		VARCHAR(500)=''
					    ,@SrcSecurityCode					VARCHAR(50) = ''
						,@Valid								VARCHAR(20)=''											
						,@SourceAlt_Key					varchar(20)=''
						,@CollateralSubType_changeFields varchar(100)=null
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
						
						
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
						@AuthorisationStatus		CHAR(2)			= NULL 
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

				SET @ScreenName = 'CollateralSubTypeMaster'

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

	--select * into DimCollateralSubType  from DimActivity	 where 1=2
		
	--Alter table	DimCollateralSubType
	--ADD Source_Key INT

--EXEC sp_rename 'DimCollateralSubType_Mod.Source_Key', 'SourceAlt_Key', 'COLUMN';

			IF Object_id('Tempdb..#Temp') Is Not Null
            Drop Table #Temp

	       IF Object_id('Tempdb..#final') Is Not Null
           Drop Table #final

Create table #Temp
(CollateralSubTypeAltKey int
,SourceAlt_Key Varchar(20)
,CollateralSubTypeDescription	varchar(100)
)

Insert into #Temp values(@CollateralSubTypeAltKey,@SourceAlt_Key,@CollateralSubTypeDescription)

Select A.Businesscolvalues1 as SourceAlt_Key,CollateralSubTypeDescription,CollateralSubTypeAltKey  into #final From (
SELECT CollateralSubTypeDescription,CollateralSubTypeAltKey,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  
                            FROM  (SELECT 
                                            CAST ('<M>' + REPLACE(SourceAlt_Key, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
											CollateralSubTypeDescription,CollateralSubTypeAltKey
                                            from #Temp
                                    ) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						
)A 

--ALTER TABLE #FINAL ADD SECURITYMAPPINGALT_KEY INT

	
print 'RRR'
	

	IF @OperationFlag=1  --- add

	BEGIN

	PRINT 1

		-----CHECK DUPLICATE

		IF EXISTS(				                

					SELECT  1 FROM DimCollateralSubType WHERE SourceAlt_Key in(Select * from Split(@SourceAlt_key,',')) 

					                                                  AND SrcSecurityCode=@SrcSecurityCode

					                                                  AND ISNULL(AuthorisationStatus,'A')='A' 

																	  and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey

					UNION

					SELECT  1 FROM DimCollateralSubType_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)

															           AND SourceAlt_Key in(Select * from Split(@SourceAlt_key,','))

															           AND SrcSecurityCode=@SrcSecurityCode

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

				 SET @CollateralSubTypeAltKey = (Select ISNULL(Max(CollateralSubTypeAltKey),0)+1 from 

												        (Select CollateralSubTypeAltKey from DimCollateralSubType

												 UNION 

												        Select CollateralSubTypeAltKey from DimCollateralSubType_Mod

												)A)

                 IF @OperationFlag=1 

						BEGIN



						UPDATE TEMP 

						SET TEMP.CollateralSubTypeAltKey=ACCT.CollateralSubTypeAltKey

						 FROM #final TEMP

						INNER JOIN (SELECT SourceAlt_Key,(@CollateralSubTypeAltKey + ROW_NUMBER()OVER(ORDER BY (SELECT 1))) CollateralSubTypeAltKey

									FROM #final

									WHERE CollateralSubTypeAltKey=0 OR CollateralSubTypeAltKey IS NULL)ACCT ON TEMP.SourceAlt_Key=ACCT.SourceAlt_Key

						END





			END

		

	END



	           IF @OperationFlag=2 



				BEGIN



				UPDATE TEMP 

				SET TEMP.CollateralSubTypeAltKey=CollateralSubTypeAltKey

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

					 --SET @CollateralSubTypeAltKey = (Select ISNULL(Max(CollateralSubTypeAltKey),0)+1 from 
						--						(Select CollateralSubTypeAltKey from DimCollateralSubType
						--						 UNION 
						--						 Select CollateralSubTypeAltKey from DimCollateralSubType_Mod
						--						)A)

					 GOTO CollateralSubType_Insert
					CollateralSubType_Insert_Add:
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
					FROM DimCollateralSubType  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CollateralSubTypeAltKey =@CollateralSubTypeAltKey

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimCollateralSubType_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CollateralSubTypeAltKey =@CollateralSubTypeAltKey
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE DimCollateralSubType
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CollateralSubTypeAltKey =@CollateralSubTypeAltKey

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE DimCollateralSubType_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND CollateralSubTypeAltKey =@CollateralSubTypeAltKey
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO CollateralSubType_Insert
					CollateralSubType_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE DimCollateralSubType SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
								AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey
				

		end
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimCollateralSubType_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND CollateralSubTypeAltKey =@CollateralSubTypeAltKey
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

				IF EXISTS(SELECT 1 FROM DimCollateralSubType WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
				                                              AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey)
				BEGIN
					UPDATE DimCollateralSubType
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CollateralSubTypeAltKey =@CollateralSubTypeAltKey
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	


------------------------------------------------------

ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE DimCollateralSubType_mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND CollateralSubTypeAltKey =CollateralSubTypeAltKey
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimCollateralSubType WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey)
				BEGIN
					UPDATE DimCollateralSubType
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CollateralSubTypeAltKey =@CollateralSubTypeAltKey
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	
---------------------------------------------------------------
	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE DimCollateralSubType_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey

	END

		ELSE IF @OperationFlag=16

		BEGIN

		--SET @ApprovedBy	   = @CrModApBy 
		--SET @DateApproved  = GETDATE()
		SET @ApprovedByFirstLevel	 = @CrModApBy 
		SET @DateApprovedFirstLevel  = GETDATE()
		Set @ModifiedBy = @CrModApBy --updated by vinit

						UPDATE DimCollateralSubType_Mod
						SET AuthorisationStatus ='1A'
							--,ApprovedBy=@ApprovedBy
							--,DateApproved=@DateApproved
							,ApprovedByFirstLevel=@ApprovedByFirstLevel --select ApprovedByFirstLevel,ModifiedBy from DimGLProduct_AU_Mod
							,DateApprovedFirstLevel=@DateApprovedFirstLevel
							--,ModifiedBy =@ModifiedBy --updated by vinit
							WHERE CollateralSubTypeAltKey=@CollateralSubTypeAltKey
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
					 FROM DimCollateralSubType 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM DimCollateralSubType_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM DimCollateralSubType_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DimCollateralSubType_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimCollateralSubType_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE DimCollateralSubType_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE DimCollateralSubType_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE CollateralSubTypeAltKey=@CollateralSubTypeAltKey
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimCollateralSubType WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey)
						BEGIN
								UPDATE DimCollateralSubType
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey 
								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE DimCollateralSubType_Mod
								SET AuthorisationStatus ='A'
							   -- ,ModifiedBy =@CrModApBy --updated by vinit 
							    ,ApprovedBy=@CrModApBy 
							    ,DateApproved = getdate()
								WHERE CollateralSubTypeAltKey=@CollateralSubTypeAltKey				
								AND AuthorisationStatus in('NP','MP','RM','1A') 
									
					END		
				END




		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimCollateralSubType WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimCollateralSubType WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimCollateralSubType SET
										         CollateralTypeAltKey				= @CollateralTypeAltKey			
												,CollateralSubTypeID				= @CollateralSubTypeID			
												,CollateralSubType					= @CollateralSubTypeID-- previously @CollateralSubType on date 18/01/2024			
												,CollateralSubTypeDescription		= @CollateralSubTypeDescription
												,SrcSecurityCode					= @SrcSecurityCode
												,Valid								= CASE WHEN @Valid = 'YES' THEN 'Y' ELSE 'N' END
												,ModifiedBy							= @ModifiedBy
												,DateModified						= @DateModified
												,ApprovedBy							= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved						= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus				= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												,SourceAlt_Key						= @SourceAlt_Key
												,SrcSecurityName                     =@CollateralSubType                ----------Newly Added column by kapil on 15/01/2024 As per Tester Vivek
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO DimCollateralSubType
												(
												     CollateralSubTypeAltKey
													,CollateralTypeAltKey
													,CollateralSubTypeID
													,CollateralSubType
													,CollateralSubTypeDescription
													,SrcSecurityCode
													,Valid		
													,SourceAlt_Key	
													,AuthorisationStatus
													,EffectiveFromTimeKey
													,EffectiveToTimeKey
													,CreatedBy 
													,DateCreated
													,ModifiedBy
													,DateModified
													,ApprovedBy
													,DateApproved
													,SrcSecurityName  ----------Newly Added column by kapil on 15/01/2024 As per Tester Vivek
													
												)

									SELECT
													@CollateralSubTypeAltKey
													,@CollateralTypeAltKey
													,@CollateralSubTypeID
													,@CollateralSubTypeID  -- @CollateralSubType  previously @CollateralSubType on date 18/01/2024
													,CollateralSubTypeDescription
													,@SrcSecurityCode
													,CASE WHEN @Valid = 'YES' THEN 'Y' ELSE 'N' END
													,SourceAlt_Key
													,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey
													,@CreatedBy 
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
													,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
													,@CollateralSubType      ----------Newly Added column by kapil on 15/01/2024 As per Tester Vivek

													     FROM  #final TEMP
													
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE DimCollateralSubType SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO CollateralSubType_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

CollateralSubType_Insert:
IF @ErrorHandle=0
	BEGIN

			INSERT INTO DimCollateralSubType_Mod  
											( 
												CollateralSubTypeAltKey
												,CollateralTypeAltKey
												,CollateralSubTypeID
												,CollateralSubType
												,CollateralSubTypeDescription
												,SrcSecurityCode
												,Valid
												,SourceAlt_Key
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
												,SrcSecurityName --Newly Added by kapil 0n 15/01/2024
											)
								select
													 @CollateralSubTypeAltKey
													,@CollateralTypeAltKey
													,@CollateralSubTypeID
													,@CollateralSubTypeID--     previously @CollateralSubType on date 18/01/2024
													,CollateralSubTypeDescription
													,@SrcSecurityCode
													,CASE WHEN @Valid = 'YES' THEN 'Y' ELSE 'N' END
													,SourceAlt_Key
													,@AuthorisationStatus
													,@EffectiveFromTimeKey
													,@EffectiveToTimeKey 
													,@CreatedBy
													,@DateCreated
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													,@CollateralSubType_changeFields 
													,@CollateralSubType     --Newly Added by kapil 0n 15/01/2024
											from #final
	
	DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from DimCollateralSubType_Mod where   CollateralSubTypeAltKey=@CollateralSubTypeAltKey
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
							from		DimCollateralSubType_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			   CollateralSubTypeAltKey=@CollateralSubTypeAltKey										
										
	
	
	


		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO CollateralSubType_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO CollateralSubType_Insert_Edit_Delete
					END
					

				
	END


	-------------------
PRINT 7
		COMMIT TRANSACTION

		--SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM DimCollateralSubType WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
		--														AND CollateralSubTypeAltKey=@CollateralSubTypeAltKey

		
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

            
---------moni
END
GO