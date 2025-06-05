SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:				<Amar>
-- Create date:			<03/03/2017>
-- Description:			<AdvFacBillDetail Table Insert/ Update>
-- =============================================
CREATE PROCEDURE [dbo].[ExceptionalDegrationDetailInUp] 
	--@AccountID			INT				= 0	
	  @DegrationAlt_Key	INT			    	= 0	
	 ,@SourceAlt_Key		INT				= 0	
	 ,@AccountID		varchar(30)			=null
	 ,@CustomerID		varchar(30)			=null
	 ,@FlagAlt_Key		varchar(30)			=null
	 ,@Date			Varchar(20)				=null
	 ,@Amount			decimal (18,2)
	 ,@MarkingAlt_Key int
	 --,@ExceptionDegradation_ChangeFields varchar(100)=null
	 -- ,@AuthorisationStatus		char(5)		=null
	 -- ,@Remark				varchar(200)	=null
	  ,@ExceptionDegradation_ChangeFields		varchar(200)	=null
	  ,@ErrorHandle				int				= 0
	  ,@ExEntityKey				int				= 0  
	 --,@EffectiveFromTimeKey
	 --,@EffectiveToTimeKey
	 --,@CreatedBy
	 --,@DateCreated
	 --,@ModifiedBy
	 --,@DateModified
	 --,@ApprovedBy
	-- ,@DateApproved
	-- ,@D2Ktimestamp 
	---------D2k System Common Columns		--
	,@Remark					VARCHAR(500)	= ''
	,@MenuID					SMALLINT		= 0
	,@OperationFlag				TINYINT			= 0
	,@AuthMode					CHAR(1)			= 'N'
	,@IsMOC						CHAR(1)			= 'N'
	,@EffectiveFromTimeKey		INT		= 0
	,@EffectiveToTimeKey		INT		= 0
	,@TimeKey					INT		= 0
	,@CrModApBy					VARCHAR(20)		=''
	,@D2Ktimestamp				INT				=0 OUTPUT	
	,@Result					INT				=0 OUTPUT
	,@BranchCode				varchar(10)		=null
	,@ScreenEntityId			INT				=null
	
AS
BEGIN
	SET NOCOUNT ON; 
	SET DATEFORMAT DMY 

	--    DECLARE @Parameter varchar(max) = (select 'SourceSystem|' + convert(varchar,ISNULL(@SourceAlt_Key,' ')) + '}'+ 'ACID|' + isnull(@AccountID,' ')
	--+ '}'+ 'CustID|'+isnull(@CustomerID,'')+ '}'+ 'Flag|'+isnull(@FlagAlt_Key,'')+ '}'+ 'EffectiveDate|'+isnull(@Date,'')
	--+ '}'+ 'Amount|'+convert(varchar,isnull(@Amount,'0'))+ '}'+ 'MarkingFlag|'+convert(varchar,isnull(@MarkingAlt_Key,'')))
	  
	----DECLARE		@Result					INT				=0 
	--exec SecurityCheckDataValidation 14571 ,@Parameter,@Result OUTPUT
				
	--IF @Result = -1
	--return -1
	 

		PRINT 1
		DECLARE 

		@AuthorisationStatus		VARCHAR(2)		= NULL 
		,@CreatedBy					VARCHAR(20)		= NULL
		--,@DateCreated				SMALLDATETIME	= NULL --updated by vinit
			,@DateCreated			DATETIME	= NULL --updated by vinit
		,@ModifiedBy				VARCHAR(20)		= NULL
		--,@DateModified				SMALLDATETIME	= NULL
		,@DateModified				DATETIME	= NULL --updated by vinit
		,@ApprovedBy				VARCHAR(20)		= NULL
		--,@DateApproved				SMALLDATETIME	= NULL  
		,@DateApproved			 DATETIME	= NULL --updated by vinit

 
declare @parameterName_1 varchar(50)
set @parameterName_1 =(select ParameterName from dimparameter 
where DimParameterName = 'UploadFLagType' 
and ParameterAlt_Key=@FlagAlt_Key
and  EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
 

IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
	 
		-----CHECK DUPLICATE BILL NO AT BRANCH LEVEL
		IF EXISTS(				                
					SELECT  1 FROM [dbo].[ExceptionalDegrationDetail] WHERE AccountId=@AccountID and FlagAlt_Key=@FlagAlt_Key
					                               AND ISNULL(AuthorisationStatus,'A')='A' 
					UNION
					SELECT  1 FROM [dbo].[ExceptionalDegrationDetail_Mod]  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND AccountId=@AccountID  and FlagAlt_Key=@FlagAlt_Key
															AND  AuthorisationStatus in('NP','MP','DP','A','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- CUSTOMERID ALEADY EXISTS
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
					 SET @CreatedBy = @CrModApBy 
					 SET @DateCreated = GETDATE()
					 SET @AuthorisationStatus='NP'
					 GOTO ExceptionalDegrationDetail_Insert
					ExceptionalDegrationDetail_Insert_Add:
		END

		ELSE IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE
			BEGIN
				Print 4
				SET @CreatedBy= @CrModApBy
				--SET @DateCreated = GETDATE()  by vinit
				Set @Modifiedby=@CrModApBy   
				Set @DateModified =GETDATE() --by vinit

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
					FROM	[dbo].[ExceptionalDegrationDetail]
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID =@AccountID
							and FlagAlt_Key=@FlagAlt_Key

					---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM	[dbo].[ExceptionalDegrationDetail_Mod]
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID =@AccountID 	
							and FlagAlt_Key=@FlagAlt_Key					
							AND AuthorisationStatus IN('NP','MP','A','RM')
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE [dbo].[ExceptionalDegrationDetail]
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AccountID =@AccountID and FlagAlt_Key=@FlagAlt_Key

					END
					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	
					UPDATE [dbo].[ExceptionalDegrationDetail]
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AccountID =@AccountID and FlagAlt_Key=@FlagAlt_Key

					UPDATE a
					SET AuthorisationStatus=@AuthorisationStatus
					from       [dbo].ExceptionFinalStatusType a
					inner join  DimParameter b
					on          a.StatusType=b.ParameterName
				    AND B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey	
						WHERE (A.EffectiveFromTimeKey<=@TimeKey AND A.EffectiveToTimeKey>=@TimeKey)
								AND A.ACID =@AccountID and B.ParameterAlt_Key=@FlagAlt_Key
								and b.DimParameterName='UploadFLagType'

						UPDATE ExceptionalDegrationDetail_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AccountID =@AccountID and FlagAlt_Key=@FlagAlt_Key
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					--GOTO AdvFacBillDetail_Insert
					--AdvFacBillDetail_Insert_Edit_Delete:
					GOTO ExceptionalDegrationDetail_Insert
					ExceptionalDegrationDetail_Insert_Edit_Delete:
				END

			ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE  ExceptionalDegrationDetail SET	
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND AccountID=@AccountID
				and FlagAlt_Key=@FlagAlt_Key

				--UPDATE  ExceptionFinalStatusType SET	
				--					ModifyBy =@Modifiedby 
				--					,DateModified =@DateModified 
				--					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				--				WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND ACID=@AccountID
				--and StatusType=@parameterName_1


		END
		---------------------------------------------------------------------
	ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE ExceptionalDegrationDetail_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AccountID =@AccountID and FlagAlt_Key=@FlagAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM ExceptionalDegrationDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                 AND AccountID =@AccountID and FlagAlt_Key=@FlagAlt_Key)
				BEGIN
					UPDATE ExceptionalDegrationDetail
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID =@AccountID and FlagAlt_Key=@FlagAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	
	-----------------------------------------------------------------------

		ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE ExceptionalDegrationDetail_Mod
					SET AuthorisationStatus='R'
					,ApprovedByFirstLevel	 =@ApprovedBy
					,DateApprovedFirstLevel=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AccountID =@AccountID and FlagAlt_Key=@FlagAlt_Key
						AND AuthorisationStatus in('NP','MP','DP','RM')	


				IF EXISTS(SELECT 1 FROM ExceptionalDegrationDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND AccountID=@AccountID)
				BEGIN
					UPDATE ExceptionalDegrationDetail
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID =@AccountID  and FlagAlt_Key=@FlagAlt_Key
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

		ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE ExceptionalDegrationDetail_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND AccountId=@AccountID and FlagAlt_Key=@FlagAlt_Key

	END
	--------------------------------------------------------
	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE ExceptionalDegrationDetail_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedByFirstLevel=@ApprovedBy
							,DateApprovedFirstLevel=@DateApproved
							WHERE AccountId=@AccountID and FlagAlt_Key=@FlagAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM')

		END

	--------------------------------------------------------

	ELSE IF @OperationFlag=20 OR @AuthMode='N'
		BEGIN
			
			Print 'Authorise'
	-------set parameter for  maker checker disabled
			IF @AuthMode='N'
			BEGIN
				IF @OperationFlag=1
					BEGIN
						SET @CreatedBy = @CrModApBy
						SET @DateCreated =GETDATE()
					END
				ELSE
					BEGIN
						SET @ModifiedBy  = @CrModApBy
						SET @DateModified =GETDATE()
						SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated
					 FROM  [dbo].[ExceptionalDegrationDetail]
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key
					
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
					SELECT @ExEntityKey= MAX(Entity_Key) FROM [dbo].[ExceptionalDegrationDetail_Mod]
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AccountID=@AccountID  and FlagAlt_Key=@FlagAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM ExceptionalDegrationDetail_Mod
						WHERE Entity_Key=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Entity_Key) FROM ExceptionalDegrationDetail_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND AccountID=@AccountID  and FlagAlt_Key=@FlagAlt_Key
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM ExceptionalDegrationDetail_Mod
							WHERE Entity_Key=@ExEntityKey

					UPDATE ExceptionalDegrationDetail_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND AccountID=@AccountID  and FlagAlt_Key=@FlagAlt_Key
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE ExceptionalDegrationDetail_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')

					IF EXISTS(SELECT 1 FROM ExceptionalDegrationDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND AccountID=@AccountID  and FlagAlt_Key=@FlagAlt_Key)
						BEGIN
								UPDATE ExceptionalDegrationDetail
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND AccountID=@AccountID  and FlagAlt_Key=@FlagAlt_Key
						END

						--IF EXISTS(SELECT 1 FROM ExceptionFinalStatusType WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
						--				AND ACID=@AccountID  and StatusType=@parameterName_1)
						--BEGIN
						--		UPDATE ExceptionFinalStatusType
						--			SET AuthorisationStatus ='A'
						--				,ModifyBy=@ModifiedBy
						--				,DateModified=@DateModified
						--				,ApprovedBy=@ApprovedBy
						--				,DateApproved=@DateApproved
						--				,EffectiveToTimeKey =@EffectiveFromTimeKey-1
						--			WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						--					AND ACID=@AccountID  and StatusType=@parameterName_1
						--END


					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE ExceptionalDegrationDetail_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE AccountID=@AccountID	and FlagAlt_Key=@FlagAlt_Key			
									AND AuthorisationStatus in('NP','MP','RM','1A')
					END		
				END

				IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
						SET @AuthorisationStatus='A'

						IF EXISTS(SELECT 1 FROM ExceptionalDegrationDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND AccountID=@AccountID  and FlagAlt_Key=@FlagAlt_Key)
							BEGIN
								SET @IsAvailable='Y'
								SET @AuthorisationStatus='A'

								IF EXISTS(SELECT 1 FROM ExceptionalDegrationDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key)
									BEGIN
											PRINT 'BBBB'
										UPDATE ExceptionalDegrationDetail SET
										               
												 DegrationAlt_Key = @DegrationAlt_Key
												,SourceAlt_Key= @SourceAlt_Key
												,AccountID= @AccountID
												,CustomerID= @CustomerID
												,FlagAlt_Key= @FlagAlt_Key
												,Date=@Date
												--,Date= convert(varchar(20),@Date,103)
												--,AuthorisationStatus= @AuthorisationStatus
												--,EffectiveFromTimeKey= @EffectiveFromTimeKey
												--,EffectiveToTimeKey= @EffectiveToTimeKey
												--,CreatedBy= @CreatedBy
												--,DateCreated=@DateCreated
												,ModifiedBy=@ModifiedBy
												,DateModified=@DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END

												 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND AccountID=@AccountID  and FlagAlt_Key=@FlagAlt_Key

										UPDATE ExceptionFinalStatusType SET
										               
												-- DegrationAlt_Key = @DegrationAlt_Key
												SourceAlt_Key= @SourceAlt_Key
												,ACID= @AccountID
												,CustomerID= @CustomerID
												,StatusType= @parametername_1
												,StatusDate=@Date
												,Amount=@Amount
												--,Date= convert(varchar(20),@Date,103)
												--,AuthorisationStatus= @AuthorisationStatus
												--,EffectiveFromTimeKey= @EffectiveFromTimeKey
												--,EffectiveToTimeKey= @EffectiveToTimeKey
												--,CreatedBy= @CreatedBy
												--,DateCreated=@DateCreated
												,ModifyBy=@ModifiedBy
												,DateModified=@DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END

												 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND ACID=@AccountID  and StatusType= @parametername_1

										END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END
								      IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO ExceptionalDegrationDetail
										(    --Entity_Key
												  DegrationAlt_Key
												  ,SourceAlt_Key
												  ,AccountID
												  ,CustomerID
												  ,FlagAlt_Key
												  ,Date
												  ,MarkingAlt_Key
												  ,Amount
												  ,AuthorisationStatus
												  ,EffectiveFromTimeKey
												  ,EffectiveToTimeKey
												  ,CreatedBy
												  ,DateCreated
												  ,ModifiedBy
												  ,DateModified
												  ,ApprovedBy
												  ,DateApproved
												  --,ApprovedByFirstLevel
												  --,DateApprovedFirstLevel
												 -- ,D2Ktimestamp
												)

									VALUES		 
											(	   @DegrationAlt_Key
												  ,@SourceAlt_Key
												  ,@AccountID
												  ,@CustomerID
												  ,@FlagAlt_Key
												  ,@Date
												  --,convert(varchar(20),@Date,103)
												  ,@MarkingAlt_Key
												  ,@Amount
												  ,@AuthorisationStatus
												  ,@EffectiveFromTimeKey
												  ,@EffectiveToTimeKey
												  ,@CreatedBy
												  ,@DateCreated
												  ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
												  ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
												  ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
												  ,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
												  --,@CrModApBy
												  --,Getdate()
												 -- ,@D2Ktimestamp
												  ) 

										INSERT INTO ExceptionFinalStatusType
										(    --Entity_Key
												  SourceAlt_Key
												  ,CustomerID
												  ,ACID
												  ,StatusType------
												  ,StatusDate
												  ,Amount												  
												  ,AuthorisationStatus
												  ,EffectiveFromTimeKey
												  ,EffectiveToTimeKey
												  ,CreatedBy
												  ,DateCreated
												  ,ModifyBy
												  ,DateModified
												  ,ApprovedBy
												  ,DateApproved
												 -- ,D2Ktimestamp
												 --,ApprovedByFirstLevel
												 --,DateApprovedFirstLevel
												)

									select		 
												   @SourceAlt_Key
												  ,@CustomerID
												  ,@AccountID
												  ,A.ParameterName as Marking
												  ,@Date
												  ,@Amount
												  ,@AuthorisationStatus
												  ,@EffectiveFromTimeKey
												  ,@EffectiveToTimeKey
												  ,@CreatedBy
												  ,@DateCreated
												  ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END
												  ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END
												  ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END
												  ,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
												 -- ,@D2Ktimestamp
												 --,@CrModApBy
												 --,GETDATE()
												  from DimParameter A
												  where DimParameterName ='UploadFLagType'
												  --AND ParameterAlt_Key= @MarkingAlt_Key
												  AND ParameterAlt_Key=@FlagAlt_Key
                                       
									   if exists (select 1 from ExceptionFinalStatusType where  AuthorisationStatus='A' 
																						 and ACID=@AccountID 
																						 and  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
									begin

											update ExceptionFinalStatusType
											set EffectiveToTimeKey=@TimeKey-1
											where ACID=@AccountID
											and AuthorisationStatus='MP'
											and StatusType=@parameterName_1

                                      end

									--   if exists (select 1 from ExceptionalDegrationDetail where  AuthorisationStatus='A' 
									--													 and AccountID=@AccountID 
									--													 and  EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey )
									--begin

									--		update ExceptionalDegrationDetail
									--		set EffectiveToTimeKey=@TimeKey-1
									--		where AccountID=@AccountID
									--		and AuthorisationStatus='MP'
									--		and FlagAlt_Key=@FlagAlt_Key

         --                             end


										END


/*Adding Flag ---------- 02-04-2021*/

IF (@MarkingAlt_Key=20)
Begin

IF OBJECT_ID('TempDB..#Flags') IS NOT NULL
Drop Table #Flags

Select A.AccountID,B.SplCatShortNameEnum into #Flags  from ExceptionalDegrationDetail_Mod A
Inner Join (Select 
B.ParameterAlt_Key,A.SplCatShortNameEnum
 from DimAcSplCategory A
inner join DimParameter B on A.SplCatName=B.ParameterName and B.EffectiveToTimeKey=49999
where A.splcatgroup='SplFlags' And A.EffectiveToTimeKey=49999 And B.DimParameterName ='uploadflagtype'
)B On A.FlagAlt_Key=B.ParameterAlt_Key
WHERE  A.EffectiveToTimeKey=49999 AND A.MarkingAlt_Key=20
And A.Entity_Key =(Select max(Entity_Key) From ExceptionalDegrationDetail_Mod where AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key)


		  UPDATE A
			SET  
				A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN B.SplCatShortNameEnum--'IBPC'     
								ELSE A.SplFlag+','+B.SplCatShortNameEnum     END
		   
		   FROM DBO.AdvAcOtherDetail A
		   Inner Join #Flags B On A.RefSystemAcId=B.AccountID
		   Where A.EffectiveToTimeKey=49999
End

---------------------

-----------Remove------------------------

-------
IF (@MarkingAlt_Key=10)
Begin


Update B Set B.EffectiveToTimeKey=@Timekey-1
FROM ExceptionalDegrationDetail_Mod A
					inner join AccountFlaggingDetails B
					ON A.AccountID=B.ACID
					AND B.EffectiveFromTimeKey <= @timekey
					AND B.EffectiveToTimeKey >= @Timekey
					WHERE  A.EffectiveFromTimeKey <= @timekey
					AND A.EffectiveToTimeKey >= @Timekey
					AND A.Entity_Key=(Select max(Entity_Key) From ExceptionalDegrationDetail_Mod where AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key)
					And A.MarkingAlt_Key=10
					And B.UploadTypeParameterAlt_Key=@FlagAlt_Key


Update B Set B.EffectiveToTimeKey=@Timekey-1
FROM ExceptionalDegrationDetail_Mod A
inner join ExceptionalDegrationDetail B
ON A.AccountID=B.AccountID
AND B.EffectiveFromTimeKey <= @timekey
AND B.EffectiveToTimeKey >= @Timekey
WHERE  A.EffectiveFromTimeKey <= @timekey
AND A.EffectiveToTimeKey >= @Timekey
AND A.Entity_Key=(Select max(Entity_Key) From ExceptionalDegrationDetail_Mod 
where AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key)
And A.MarkingAlt_Key=10
					

Update B Set B.EffectiveToTimeKey=@Timekey-1
FROM ExceptionalDegrationDetail_Mod A
					inner join ExceptionFinalStatusType B
					ON A.AccountID=B.ACID
					AND B.EffectiveFromTimeKey <= @timekey
					AND B.EffectiveToTimeKey >= @Timekey
					WHERE  A.EffectiveFromTimeKey <= @timekey
					AND A.EffectiveToTimeKey >= @Timekey
					AND A.Entity_Key=(Select max(Entity_Key) From ExceptionalDegrationDetail_Mod where AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key)
					And A.MarkingAlt_Key=10

  DEclare @ParameterName as Varchar(100)
 Set @ParameterName = (select ParameterName from DimParameter where DimParameterName ='uploadflagtype' and EffectiveToTimeKey=49999 
 and ParameterAlt_Key= (select distinct FlagAlt_Key from ExceptionalDegrationDetail_Mod where AccountID=@AccountID and MarkingAlt_Key=10
 And Entity_Key=(Select max(Entity_Key) From ExceptionalDegrationDetail_Mod where AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key)
 ))

--Update B Set B.EffectiveToTimeKey=@Timekey-1
--FROM ExceptionalDegrationDetail_Mod A
--					inner join ExceptionFinalStatusType B
--					ON A.AccountID=B.ACID
--					AND B.EffectiveFromTimeKey <= @timekey
--					AND B.EffectiveToTimeKey >= @Timekey
--					WHERE  A.EffectiveFromTimeKey <= @timekey
--					AND A.EffectiveToTimeKey >= @Timekey
--					AND A.Entity_Key=(Select max(Entity_Key) From ExceptionalDegrationDetail_Mod where AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key)
--					And B.StatusType=@ParameterName



IF OBJECT_ID('TempDB..#Flags1') IS NOT NULL
Drop Table #Flags1


Select A.AccountID,B.SplCatShortNameEnum into #Flags1  from ExceptionalDegrationDetail_Mod A
Inner Join (Select 
B.ParameterAlt_Key,A.SplCatShortNameEnum
 from DimAcSplCategory A
inner join DimParameter B on A.SplCatName=B.ParameterName and B.EffectiveToTimeKey=49999
where A.splcatgroup='SplFlags' And A.EffectiveToTimeKey=49999 And B.DimParameterName ='uploadflagtype'
)B On A.FlagAlt_Key=B.ParameterAlt_Key
WHERE  A.EffectiveToTimeKey=49999 AND A.MarkingAlt_Key=10
And A.Entity_Key =(Select max(Entity_Key) From ExceptionalDegrationDetail_Mod where AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key)


				IF OBJECT_ID('TempDB..#Temp') IS NOT NULL
				DROP TABLE #Temp

				Select A.AccountentityID,A.SplFlag into #Temp from Curdat.AdvAcOtherDetail A
				Inner Join #Flags1 B ON  A.RefSystemAcId=B.AccountID
				where A.EffectiveToTimeKey=49999 


				--Select * from #Temp


				IF OBJECT_ID('TEMPDB..#SplitValue')  IS NOT NULL
				DROP TABLE #SplitValue        
				SELECT AccountentityID,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  into #SplitValue
											FROM  (SELECT 
															CAST ('<M>' + REPLACE(SplFlag, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
															AccountentityID
															from #Temp 
													) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						


				 --Select * from #SplitValue 

				 DELETE FROM #SplitValue WHERE Businesscolvalues1 In (Select distinct SplCatShortNameEnum from #Flags1)




				 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
					DROP TABLE #NEWTRANCHE

					SELECT * INTO #NEWTRANCHE FROM(
					SELECT 
						 SS.AccountentityID,
						STUFF((SELECT ',' + US.BUSINESSCOLVALUES1 
							FROM #SPLITVALUE US
							WHERE US.AccountentityID = SS.AccountentityID
							FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
						FROM #TEMP SS 
						GROUP BY SS.AccountentityID
						)B
						ORDER BY 1

						--Select * from #NEWTRANCHE

					--SELECT * 
					UPDATE A SET A.SplFlag=B.REPORTIDSLIST
					FROM DBO.AdvAcOtherDetail A
					INNER JOIN #NEWTRANCHE B ON A.AccountentityID=B.AccountentityID
					WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey

End
	


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE ExceptionalDegrationDetail SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
									AND AccountID=@AccountID  and FlagAlt_Key=@FlagAlt_Key
											AND EffectiveFromTimekey<@EffectiveFromTimeKey


									--UPDATE ExceptionFinalStatusType SET
									--	EffectiveToTimeKey=@EffectiveFromTimeKey-1
									--	,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									--WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
									--AND Acid=@AccountID  
									--		AND EffectiveFromTimekey<@EffectiveFromTimeKey
									--		and  StatusType=@parameterName_1


								END
							END
		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					--GOTO AdvFacBillDetail_Insert
					GOTO ExceptionalDegrationDetail_Insert
					HistoryRecordInUp:
			END						

--/*Adding Flag ----------Farahnaaz 26-03-2021*/
--		Declare @variable Varchar(100)=''
		
--Set @variable=(Select Splcatshortnameenum from dimacsplcategory  where splcatgroup='splflags' and 
--SplCatName like (select ParameterName from dimparameter
--where dimparametername ='UploadFLagType' and ParameterAlt_Key=@FlagAlt_key))

--		  UPDATE A
--			SET  
--				A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN @variable--'IBPC'     
--								ELSE A.SplFlag+','+@variable     END
		   
--		   FROM DBO.AdvAcOtherDetail A
		

		END 

	PRINT 6
SET @ErrorHandle=1

ExceptionalDegrationDetail_Insert:
IF @ErrorHandle=0
BEGIN
			INSERT INTO ExceptionalDegrationDetail_Mod
			   (	--Entity_Key
						  DegrationAlt_Key
						  ,SourceAlt_Key
						  ,AccountID
						  ,CustomerID
						  ,FlagAlt_Key
						  ,Date
						  ,MarkingAlt_Key
						  ,Amount
						  ,AuthorisationStatus
						  ,Remark
						  ,ChangeFields
						  ,EffectiveFromTimeKey
						  ,EffectiveToTimeKey
						  ,CreatedBy
						  ,DateCreated
						  ,ModifiedBy
						  ,DateModified
						  ,ApprovedBy
						  ,DateApproved 
						 -- ,D2Ktimestamp
					 )

				VALUES		 
						(	   @DegrationAlt_Key
							  ,@SourceAlt_Key
							  ,@AccountID
							  ,@CustomerID
							  ,@FlagAlt_Key
							  ,@Date
							  ,@MarkingAlt_Key
							  ,@Amount
							  ,@AuthorisationStatus
							  ,@Remark
							  ,@ExceptionDegradation_ChangeFields
							  ,@EffectiveFromTimeKey
							  ,@EffectiveToTimeKey
							  ,@CreatedBy
							  ,@DateCreated
							  ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
							  ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
							  ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
							  ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
							 
							 -- ,@D2Ktimestamp
							  )
	DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from ExceptionalDegrationDetail_Mod  where AccountID=@AccountID  and FlagAlt_Key=@FlagAlt_Key
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
							from		ExceptionalDegrationDetail_Mod    A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and		AccountID=@AccountID  and FlagAlt_Key=@FlagAlt_Key										
										


			
	IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO ExceptionalDegrationDetail_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO ExceptionalDegrationDetail_Insert_Edit_Delete
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
								@ReferenceID=@AccountID ,-- ReferenceID ,
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
								@ReferenceID=@AccountID ,-- ReferenceID ,
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

		SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM [dbo].[ExceptionalDegrationDetail] WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
																	AND AccountID=@AccountID and FlagAlt_Key=@FlagAlt_Key

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
	SELECT ERROR_MESSAGE()
	RETURN -1

END CATCH
---------
END
	
GO