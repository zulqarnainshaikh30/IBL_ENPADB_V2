SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SMAClassMaster_InUp]
 @XMLData          XML=''    
,@EffectiveFromTimeKey INT=0
,@EffectiveToTimeKey   INT=0
,@OperationFlag		   INT=0
,@AuthMode			   CHAR(1)='N'
,@CrModApBy			   VARCHAR(50)=''
,@TimeKey			   INT=0
,@Result			   INT=0 output
,@D2KTimeStamp		   INT=0 output
,@Remark			   VARCHAR(200)=''
,@MenuId				INT = 6100
,@ErrorMsg				VARCHAR(MAX)='' output
As
BEGIN
      DECLARE
		@BusinessMatrixAlt_key	INT
	   ,@CreatedBy				VARCHAR(50)
	   ,@DateCreated			DATETIME
	   ,@ModifiedBy				VARCHAR(50)
	   ,@DateModified			DATETIME
	   ,@ApprovedBy				VARCHAR(50)
	   ,@DateApproved			DATETIME
	   ,@AuthorisationStatus	CHAR(2)
	   ,@ErrorHandle			SMALLINT =0
	   ,@ExEntityKey			INT	    =0
	   ,@Data_Sequence			INT = 0


IF OBJECT_ID('TEMPDB..##SMAMaster') IS NOT NULL
        DROP TABLE ##SMAMaster

--,CASE WHEN C.value('./ACTUALDCCODATE [1]','VARCHAR(20)')='' THEN NULL ELSE C.value('./ACTUALDCCODATE [1]','VARCHAR(20)') END ACTUALDCCODATE
print 'A'
SELECT 
 CASE WHEN C.value('./RowNumber [1]','VARCHAR(30)')='' THEN NULL
            ELSE C.value('./RowNumber [1]','VARCHAR(30)') END RowNumber
,CASE WHEN C.value('./TotalCount [1]','VARCHAR(30)')='' THEN NULL
            ELSE C.value('./TotalCount [1]','VARCHAR(30)') END TotalCount			 
,CASE WHEN C.value('./AssetClassMappingAlt_Key [1]','VARCHAR(30)')='' THEN NULL
            ELSE C.value('./AssetClassMappingAlt_Key [1]','VARCHAR(30)') END AssetClassMappingAlt_Key
,C.value('./SrcSysClassCode[1]','VARCHAR(30)') SrcSysClassCode			    
,CASE WHEN C.value('./SrcSysClassName [1]','VARCHAR(30)')='' THEN NULL 
            ELSE C.value('./SrcSysClassName [1]','VARCHAR(30)') END SrcSysClassName 
,CASE WHEN C.value('./AssetClassAlt_Key [1]','VARCHAR(30)')='' THEN NULL
            ELSE C.value('./AssetClassAlt_Key [1]','VARCHAR(30)') END AssetClassAlt_Key   
,CASE WHEN C.value('./AssetClassName [1]','VARCHAR(30)')='' THEN NULL 
            ELSE C.value('./AssetClassName [1]','VARCHAR(30)') END AssetClassName     
,CASE WHEN C.value('./AssetClassShortName [1]','VARCHAR(30)')='' THEN NULL 
            ELSE C.value('./AssetClassShortName [1]','VARCHAR(30)') END AssetClassShortName    
   
,CASE WHEN C.value('./AssetClassShortNameEnum [1]','VARCHAR(30)')='' THEN NULL 
            ELSE C.value('./AssetClassShortNameEnum [1]','VARCHAR(30)') END AssetClassShortNameEnum 
,CASE WHEN C.value('./AssetClassGroup [1]','VARCHAR(20)')='' THEN NULL 
           ELSE C.value('./AssetClassGroup [1]','VARCHAR(20)') END AssetClassGroup  
,CASE WHEN C.value('./AssetClassSubGroup [1]','VARCHAR(20)')='' THEN NULL 
           ELSE C.value('./AssetClassSubGroup [1]','VARCHAR(20)') END AssetClassSubGroup   
,CASE WHEN C.value('./DPD_LowerValue [1]','VARCHAR(20)')='' THEN NULL 
           ELSE C.value('./DPD_LowerValue [1]','VARCHAR(20)') END DPD_LowerValue
,CASE WHEN C.value('./DPD_HigherValue [1]','VARCHAR(20)')='' THEN NULL 
           ELSE C.value('./DPD_HigherValue [1]','VARCHAR(20)') END DPD_HigherValue    
 ,CASE WHEN C.value('./SrcSysGroup [1]','VARCHAR(20)')='' THEN NULL 
           ELSE C.value('./SrcSysGroup [1]','VARCHAR(20)') END SrcSysGroup  
  
INTO ##SMAMaster
FROM @XMLData.nodes('/DataSet/SMAClassMaster') AS t(c)

--select * from DimSMAClassMaster
--select * from DimSMAClassMaster_mod
IF @OperationFlag=1
BEGIN
	PRINT '1'
	IF EXISTS(
			Select 1 From DimSMAClassMaster_mod  D
						INNER JOIN ##SMAMaster GD 
						ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
							AND D.SrcSysClassCode= GD.SrcSysClassCode
						WHERE D.AuthorisationStatus in('MP','NP','DP','RM') )

	BEGIN
		PRINT 'EXISTS'
		Set @Result=-4
		SELECT DISTINCT @ErrorMsg=
								STUFF((SELECT distinct ', ' + CAST(SrcSysClassCode as varchar(max))
								 FROM ##SMAMaster t2
								 FOR XML PATH('')),1,1,'') 
							 From DimSMAClassMaster_mod  D
							INNER JOIN ##SMAMaster GD 
								ON (EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey) 
								AND D.SrcSysClassCode = GD.SrcSysClassCode
							WHERE D.AuthorisationStatus in('MP','NP','DP','RM') 

		SET @ErrorMsg='Authorization Pending for Customer id '+CAST(@ErrorMsg AS VARCHAR(MAX))+' Please Authorize first'
		Return @Result
	END
	--ELSE 
	BEGIN	
		--SET @BusinessMatrixAlt_key = 
		 SELECT @BusinessMatrixAlt_key= MAX(BusinessMatrixAlt_key)  FROM  
										(SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DimSMAClassMaster
										 UNION 
										 SELECT MAX(Entitykey) BusinessMatrixAlt_key FROM DimSMAClassMaster_mod
										)A
		SET @BusinessMatrixAlt_key = ISNULL(@BusinessMatrixAlt_key,0)
	END
END

BEGIN TRY


BEGIN TRAN
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
				Set @DateModified =GETDATE() 

					PRINT 5

					IF @OperationFlag = 2
						BEGIN
							PRINT 'Edit'
							SET @AuthorisationStatus ='MP'
							PRINT @AuthorisationStatus
							Print 'Anuj'
							--------------
							   Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE D
							SET AuthorisationStatus=@AuthorisationStatus
							FROM DimSMAClassMaster D
					INNER JOIN  ##SMAMaster GD	
					ON  D.SrcSysClassCode = GD.SrcSysClassCode
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
							--------

						END

					ELSE
						BEGIN
							PRINT 'DELETE'
							SET @AuthorisationStatus ='DP'
							
						END

						---FIND CREATED BY FROM MAIN TABLE
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM DimSMAClassMaster D
					INNER JOIN  ##SMAMaster GD	
					ON  D.SrcSysClassCode = GD.SrcSysClassCode
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
	             	        FROM DimSMAClassMaster_mod D
							INNER JOIN  ##SMAMaster GD	
							ON  D.SrcSysClassCode			= GD.SrcSysClassCode
							WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
							--AND    D.AuthorisationStatus IN('NP','MP','DP','RM')
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE  D
						SET D.AuthorisationStatus=@AuthorisationStatus
						FROM DimSMAClassMaster D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE D
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModifie=@DateModified
						FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO AssetClassMaster_Insert
					AssetClassMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE D SET
									ModifiedBy =@Modifiedby 
									,DateModifie =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
                             FROM DimSMAClassMaster D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								

		end


		---------------------------------------------First lvl Authorise----------
ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE D
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
					FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                 --- AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key
										  )
				BEGIN
					UPDATE D
						SET AuthorisationStatus='A'
						FROM DimSMAClassMaster D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	
-------------------------------------------------------

	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE D
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
					FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						---AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key
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

				IF EXISTS(SELECT 1 FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						-- AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key)
						)
				BEGIN
					UPDATE D
						SET AuthorisationStatus='A'
						FROM DimSMAClassMaster D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND AssetClassMappingAlt_Key =@AssetClassMappingAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE D
		SET AuthorisationStatus='RM'
		FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		---AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key

	END
	---------------------new add
	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE D
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--WHERE AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
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
						SET @DateModified =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						
							---AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							--AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModifie
					 FROM DimSMAClassMaster_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM DimSMAClassMaster_Mod D
					
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
					 
													AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM DimSMAClassMaster_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE D
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						--AND AssetClassMappingAlt_Key=@AssetClassMappingAlt_Key
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE D
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
							FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						 
										)
						BEGIN
								UPDATE D
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModifie=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
										FROM DimSMAClassMaster D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE D
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
									FROM DimSMAClassMaster_mod D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
												
									AND AuthorisationStatus in('NP','MP','RM','1A')

												
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
				print'vj0'
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM DimSMAClassMaster D
						INNER JOIN  ##SMAMaster GD 
						ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						 
									 )
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM DimSMAClassMaster D
						                        INNER JOIN  ##SMAMaster GD 
						                         ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						                  where (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						 												AND EffectiveFromTimeKey=@TimeKey 
												)
									BEGIN
											PRINT 'BBBB'
										UPDATE DimSMAClassMaster SET
												AssetClassMappingAlt_Key	= GD.AssetClassMappingAlt_Key
												--,SourceAlt_Key				= GD.SourceAlt_Key	-----source	 
												,SrcSysClassCode			= GD.SrcSysClassCode	 ---sourcesysCRRCode
												,SrcSysClassName			= GD.SrcSysClassName	----sourcesysclassname 
												,AssetClassName				= GD.AssetClassName  ------CrismacAssetclass			 
												,AssetClassAlt_Key			= GD.AssetClassAlt_Key -----Crismacode
												,DPD_LowerValue             = GD.DPD_LowerValue
												,DPD_HigherValue	        = GD.DPD_HigherValue
												 ,SrcSysGroup				= GD.SrcSysGroup
												,ModifiedBy					= @ModifiedBy
												,DateModifie				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
												FROM DimSMAClassMaster D
						                        INNER JOIN  ##SMAMaster GD 
						                         ON  D.SrcSysClassCode			= GD.SrcSysClassCode
						                  
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey 
												AND D.AssetClassMappingAlt_Key=GD.AssetClassMappingAlt_Key
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END
	Print 'Vj1'
								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
									Print 'Anu'
										INSERT INTO DimSMAClassMaster
														(
														 AssetClassMappingAlt_Key	
														,SrcSysClassCode	
														,SrcSysClassName	
														,AssetClassAlt_Key	
														,AssetClassName	
														,AssetClassShortName	
														,AssetClassShortNameEnum	
														,AssetClassGroup	
														,AssetClassSubGroup	
														,DPD_LowerValue	
														,DPD_HigherValue	
														--,NPAAgeingBucket	
														--,BankSecuredNorms	
														--,BankUnsecuredNorms	
														--,RBISecuredNorms	
														--,RBIUnsecuredNorms
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
													   AssetClassMappingAlt_Key	
														,SrcSysClassCode	
														,SrcSysClassName	
														,AssetClassAlt_Key	
														,AssetClassName	
														,AssetClassShortName	
														,AssetClassShortNameEnum	
														,AssetClassGroup	
														,AssetClassSubGroup	
														,DPD_LowerValue	
														,DPD_HigherValue	
														--,NPAAgeingBucket	
														--,BankSecuredNorms	
														--,BankUnsecuredNorms	
														--,RBISecuredNorms	
														--,RBIUnsecuredNorms

														,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
														,@EffectiveFromTimeKey
														,@EffectiveToTimeKey
														,@CreatedBy
														,@DateCreated
														,@ModifiedBy
														,@DateModified
														,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
														,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
														FROM ##SMAMaster S

												
										
									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE G SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
										  FROM DimSMAClassMaster G
                                           INNER JOIN ##SMAMaster GD ON (G.EffectiveFromTimeKey<=@TimeKey AND G.EffectiveToTimeKey>=@TimeKey )
										AND G.SrcSysClassCode			= GD.SrcSysClassCode
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)
									
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		END 


	IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO AssetClassMaster_Insert
					HistoryRecordInUp:
			END						


										

	
--END


	IF (@OperationFlag IN(1,2,3,16,17,18 )AND @AuthMode ='Y')
			BEGIN
		PRINT 5
				IF @OperationFlag=2 
					BEGIN 

						SET @CreatedBy=@ModifiedBy
					--end

				END
					IF @OperationFlag IN(16,17) 
						BEGIN 
							SET @DateCreated= GETDATE()
					
								EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
									'' ,
									@MenuID,
									@BusinessMatrixAlt_key,-- ReferenceID ,
									@CreatedBy,
									@ApprovedBy,-- @ApproveBy 
									@DateCreated,
									@Remark,
									@MenuID, -- for FXT060 screen
									@OperationFlag,
									@AuthMode
						END
					ELSE
						BEGIN
					
						--Print @Sc
							EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE
								'' ,
								@MenuID,
								@BusinessMatrixAlt_key ,-- ReferenceID ,
								@CreatedBy,
								NULL,-- @ApproveBy 
								@DateCreated,
								@Remark,
								@MenuID, -- for FXT060 screen
								@OperationFlag,
								@AuthMode
						END
			END	


PRINT 6
SET @ErrorHandle=1

AssetClassMaster_Insert:
IF @ErrorHandle=0
								
  	BEGIN
								Print 'insert into DimSMAClassMaster_mod'

									PRINT '@ErrorHandle'
									INSERT INTO DimSMAClassMaster_mod
											(
											 AssetClassMappingAlt_Key	
														,SrcSysClassCode	
														,SrcSysClassName	
														,AssetClassAlt_Key	
														,AssetClassName	
														,AssetClassShortName	
														,AssetClassShortNameEnum	
														,AssetClassGroup	
														,AssetClassSubGroup	
														,DPD_LowerValue	
														,DPD_HigherValue	
														--,NPAAgeingBucket	
														--,BankSecuredNorms	
														--,BankUnsecuredNorms	
														--,RBISecuredNorms	
														--,RBIUnsecuredNorms
														
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
											  AssetClassMappingAlt_Key	
														,SrcSysClassCode	
														,SrcSysClassName	
														,AssetClassAlt_Key	
														,AssetClassName	
														,AssetClassShortName	
														,AssetClassShortNameEnum	
														,AssetClassGroup	
														,AssetClassSubGroup	
														,DPD_LowerValue	
														,DPD_HigherValue	
														--,NPAAgeingBucket	
														--,BankSecuredNorms	
														--,BankUnsecuredNorms	
														--,RBISecuredNorms	
														--,RBIUnsecuredNorms
														
											,CASE WHEN @AuthMode ='Y' THEN @AuthorisationStatus ELSE NULL END
											,@EffectiveFromTimeKey
											,@EffectiveToTimeKey
											,@CreatedBy
											,@DateCreated
											,@ModifiedBy
											,@DateModified
											,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
											,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
											FROM ##SMAMaster S
											--WHERE Amount<>0

								PRINT CAST(@@ROWCOUNT AS VARCHAR)+'INSERTED'
								

				
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
	
 COMMIT TRANSACTION

 SET @Result=1
 RETURN  @RESULT
 END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE() ERRORDESC
	ROLLBACK TRAN
	


	

		SET @RESULT=-1
	RETURN @RESULT

		

END  CATCH

	


END						            

GO