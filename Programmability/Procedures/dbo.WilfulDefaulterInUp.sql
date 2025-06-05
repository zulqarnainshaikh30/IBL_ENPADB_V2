SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROC [dbo].[WilfulDefaulterInUp]

--Declare
							
							@ReportedByAlt_Key				Int=0,
							@CategoryofBankFIAlt_Key		Int=0,
							@ReportingBankFIAlt_Key			Int=0,
							@ReportingBranchAlt_Key			Int=0,
							@StateUTofBranchAlt_Key			Int=0,
							@CustomerID						varchar(20)='',
							@PartyName						varchar(100)='',
							@PAN							varchar(10)='',
							@ReportingSerialNo				Numeric (16,2),
							@RegisteredOfficeAddress		varchar(500)='',
							@OSAmountinlacs					Decimal(16,2),
							@WillfulDefaultDate				DATE,
							@SuitFiledorNotAlt_Key			Int=0,
							@OtherBanksFIInvolvedAlt_Key	Int=0,
							@NameofOtherBanksFIAlt_Key		Int=0,
							@CustomerTypeAlt_Key			Int=0,
							@EntityId			            Int	= 0,
							 
                          
						---------D2k System Common Columns		--
						--@AuthorisationStatus,
						@Remark								VARCHAR(500)= '',
						--,@MenuID							SMALLINT= 0 , change to Int
						@MenuID								Int=0,
						@OperationFlag						TINYINT	= 0,
						@AuthMode							CHAR(1)	= 'N',
						@EffectiveFromTimeKey				INT	= 0,
						@EffectiveToTimeKey					INT	= 0,
						@TimeKey							INT	= 0,
						@CrModApBy							VARCHAR(20)	='',
						@ScreenEntityId						INT	=null,
						@Result								INT	=0 OUTPUT
						
						
AS
BEGIN
	SET NOCOUNT ON;
		PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
						@AuthorisationStatus		varchar(5)		= NULL 
						,@CreatedBy					VARCHAR(20)		= NULL
						,@DateCreated				SMALLDATETIME	= NULL
						,@ModifiedBy				VARCHAR(20)		= NULL
						,@DateModified				SMALLDATETIME	= NULL
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

				SET @ScreenName = 'Collateral'

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

				

	IF @OperationFlag=1  --- add
	BEGIN
	PRINT 1
		-----CHECK DUPLICATE
		IF EXISTS(				                
					SELECT  1 FROM WillfulDefaulters WHERE  CustomerID=@CustomerID AND ISNULL(AuthorisationStatus,'A')='A' 
					and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM WillfulDefaulters_mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															 AND CustomerID=@CustomerID
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		----ELSE
		----	BEGIN
		----	   PRINT 3
		----		SELECT @GLAlt_Key=NEXT VALUE FOR Seq_GLAlt_Key
		----		PRINT @GLAlt_Key
		----	END
		---------------------Added on 29/05/2020 for user allocation rights
		/*
		IF @AccessScopeAlt_Key in (1,2)
		BEGIN
		PRINT 'Sunil'

		IF EXISTS(				                
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@GLAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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
					SELECT  1 FROM DimUserinfo WHERE UserLoginID=@GLAlt_Key AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
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

					 SET @Uniq_EntryID = (Select ISNULL(Max(EntityId),0)+1 from 
												(Select EntityId from WillfulDefaulters
												 UNION 
												 Select EntityId from WillfulDefaulters_mod
												)A)

					 GOTO WillfulDefaulters_Insert
					 WillfulDefaulters_Insert_Add:
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
					FROM WillfulDefaulters  
					WHERE (EffectiveFromTimeKey<=@TimeKey 
							AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerID=@CustomerID AND EntityId=@EntityId

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM WillfulDefaulters_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerID=@CustomerID
							AND AuthorisationStatus IN('NP','MP','A','RM') AND EntityId=@EntityId
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE WillfulDefaulters
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey 
								AND EffectiveToTimeKey>=@TimeKey)
								AND CustomerID=@CustomerID AND EntityId=@EntityId

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE WillfulDefaulters_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey 
								AND EffectiveToTimeKey>=@TimeKey)
								AND CustomerID=@CustomerID AND EntityId=@EntityId
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					GOTO WillfulDefaulters_Insert
					WillfulDefaulters_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE WillfulDefaulters SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CustomerID=@CustomerID AND EntityId=@EntityId
				

		end
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE WillfulDefaulters_Mod
					SET AuthorisationStatus='R'
						,ApprovedBy	 =@ApprovedBy
						,DateApproved=@DateApproved
						,EffectiveToTimeKey =@EffectiveFromTimeKey-1
					 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND CustomerID=@CustomerID AND EntityId=@EntityId
						AND AuthorisationStatus in('NP','MP','DP','RM')	

---------------Added for Rejection Pop Up Screen  3/31/2020   ----------

		Print 'Farha'

--		DECLARE @EntityKey as Int 
		--SELECT	@CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey
		--					 FROM DimGL_Mod 
		--						WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )
		--							AND GLAlt_Key=@GLAlt_Key And ISNULL(AuthorisationStatus,'A')='R'
		
--	EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName
		

--------------------------------

				IF EXISTS(SELECT 1 FROM WillfulDefaulters WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CustomerID=@CustomerID AND EntityId=@EntityId)
				BEGIN
					UPDATE WillfulDefaulters
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerID=@CustomerID AND EntityId=@EntityId
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

-----------------------Two level Auth. changes----------------------

ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE WillfulDefaulters_Mod
					SET AuthorisationStatus='R'
						,ApprovedBy	 =@ApprovedBy
						,DateApproved=@DateApproved
						,EffectiveToTimeKey =@EffectiveFromTimeKey-1
					 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND CustomerID=@CustomerID AND EntityId=@EntityId
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	
						
				IF EXISTS(SELECT 1 FROM WillfulDefaulters WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CustomerID=@CustomerID AND EntityId=@EntityId)
				BEGIN
					UPDATE WillfulDefaulters
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND CustomerID=@CustomerID AND EntityId=@EntityId
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	
---------------------------------------------------------------
	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE WillfulDefaulters_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND CustomerID=@CustomerID AND EntityId=@EntityId

	END

	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE WillfulDefaulters_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							WHERE CustomerID=@CustomerID AND EntityId=@EntityId
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
					 FROM WillfulDefaulters 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND CustomerID=@CustomerID AND EntityId=@EntityId
					
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
					SELECT @ExEntityKey= MAX(Entity_Key) FROM WillfulDefaulters_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CustomerID=@CustomerID AND EntityId=@EntityId
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM WillfulDefaulters_Mod
						WHERE Entity_Key=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(Entity_Key) FROM WillfulDefaulters_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND CustomerID=@CustomerID AND EntityId=@EntityId
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM WillfulDefaulters_Mod
							WHERE Entity_Key=@ExEntityKey

						UPDATE WillfulDefaulters_Mod
							SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
							WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
							AND CustomerID=@CustomerID AND EntityId=@EntityId
							AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE WillfulDefaulters_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE CustomerID=@CustomerID AND EntityId=@EntityId
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM WillfulDefaulters WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND CustomerID=@CustomerID AND EntityId=@EntityId)
						BEGIN
								UPDATE WillfulDefaulters
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND CustomerID=@CustomerID AND EntityId=@EntityId
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
						BEGIN
								UPDATE WillfulDefaulters_Mod
									SET AuthorisationStatus ='A'
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
									WHERE CustomerID=@CustomerID AND EntityId=@EntityId				
										AND AuthorisationStatus in('NP','MP','RM','1A')
						END		
				  END

		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM WillfulDefaulters WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND CustomerID=@CustomerID AND EntityId=@EntityId)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM WillfulDefaulters WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND CustomerID=@CustomerID AND EntityId=@EntityId)
									BEGIN
											PRINT 'BBBB'
										UPDATE WillfulDefaulters 
										SET
												ReportedByAlt_Key			=	@ReportedByAlt_Key,
												CategoryofBankFIAlt_Key		=	@CategoryofBankFIAlt_Key,
												ReportingBankFIAlt_Key		=	@ReportingBankFIAlt_Key,
												ReportingBranchAlt_Key		=	@ReportingBranchAlt_Key,
												StateUTofBranchAlt_Key		=	@StateUTofBranchAlt_Key,
												CustomerID					=	@CustomerID,
												PartyName					=	@PartyName,
												PAN							=	@PAN,
												ReportingSerialNo			=	@ReportingSerialNo,
												RegisteredOfficeAddress		=	@RegisteredOfficeAddress,
												OSAmountinlacs				=	@OSAmountinlacs,
												WillfulDefaultDate			=	@WillfulDefaultDate,
												SuitFiledorNotAlt_Key		=	@SuitFiledorNotAlt_Key,
												OtherBanksFIInvolvedAlt_Key	=	@OtherBanksFIInvolvedAlt_Key,
												NameofOtherBanksFIAlt_Key	=	@NameofOtherBanksFIAlt_Key,
												CustomerTypeAlt_Key			=	@CustomerTypeAlt_Key,

												ModifiedBy					=	@ModifiedBy,
												DateModified				=	@DateModified,
												ApprovedBy					=	CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END,
												DateApproved				=	CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END,
												AuthorisationStatus		=	CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND CustomerID=@CustomerID AND EntityId=@EntityId
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO WillfulDefaulters
												(   EntityId,
													ReportedByAlt_Key,
													CategoryofBankFIAlt_Key,
													ReportingBankFIAlt_Key,
													ReportingBranchAlt_Key,
													StateUTofBranchAlt_Key,
													CustomerID,
													PartyName,
													PAN,
													ReportingSerialNo,
													RegisteredOfficeAddress,
													OSAmountinlacs,
													WillfulDefaultDate,
													SuitFiledorNotAlt_Key,
													OtherBanksFIInvolvedAlt_Key,
													NameofOtherBanksFIAlt_Key,
													CustomerTypeAlt_Key,
													AuthorisationStatus,
													EffectiveFromTimeKey,
													EffectiveToTimeKey,
													CreatedBy ,
													DateCreated,
													ModifiedBy,
													DateModified,
													ApprovedBy,
													DateApproved
													
												)

										SELECT        @EntityId,
													  @ReportedByAlt_Key,
													  @CategoryofBankFIAlt_Key,
													  @ReportingBankFIAlt_Key,
													  @ReportingBranchAlt_Key,
													  @StateUTofBranchAlt_Key,
													  @CustomerID,
													  @PartyName,
													  @PAN,
													  @ReportingSerialNo,
													  @RegisteredOfficeAddress,
													  @OSAmountinlacs,
													  @WillfulDefaultDate,
													  @SuitFiledorNotAlt_Key,
													  @OtherBanksFIInvolvedAlt_Key,
													  @NameofOtherBanksFIAlt_Key,
													  @CustomerTypeAlt_Key	,	
													  CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END,
													  @EffectiveFromTimeKey,
													  @EffectiveToTimeKey,
													  @CreatedBy ,
													  @DateCreated,
													  CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END,
													  CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END,
													  CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END,
													  CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END
 					END
					
-----Added on for Popup
		Declare
		@DirectorName				Varchar(100)		='',
		--@PAN						varchar(10)			='',
		@DIN						Numeric(8,2)		,
		@DirectorTypeAlt_Key		int					=0
		

		Exec [WilfulDirectorDetailInsert]
		@DirectorName		=	@DirectorName	,		
		@PAN				=	@PAN		,					
		@DIN				=	@DIN	,						
		@DirectorTypeAlt_Key=	@DirectorTypeAlt_Key,
		@AuthorisationStatus=	@AuthorisationStatus,
		--@EffectiveFromTimeK	=	@EffectiveFromTimeK	,
		--@EffectiveToTimeKey	=	@EffectiveToTimeKey	,
		@CreatedBy			=	@CreatedBy			,
		@DateCreated		=	@DateCreated		,
		@ModifiedBy			=	@ModifiedBy			,
		@DateModified		=	@DateModified		,
		@ApprovedBy			=	@ApprovedBy			,
		@DateApproved		=	@DateApproved		

-----------------Added on 13-03-2021--------Need some clarify with poonam
	------------------------------------------------------
		--declare 
		----@CollateralID								int=0		
		--@CollateralValueatSanctioninRs				decimal(18,2)
		--,@CollateralValueasonNPAdateinRs			decimal(18,2)
		--,@CollateralValueatthetimeoflastreviewinRs	decimal(18,2)
		--,@ValuationSourceNameAlt_Key				int=0
		--,@SourceName								varchar(30)
		--,@ValuationDate								Date
		--,@LatestCollateralValueinRs					decimal(18,2)
		--,@ExpiryBusinessRule						varchar(30)=''
		--,@Periodinmonth								int=0
		--,@ValueExpirationDate						Date
								
		--EXEC CollateralValueInsert  @CustomerID=@CustomerID
		--							,@CollateralValueatSanctioninRs=@CollateralValueatSanctioninRs
		--							,@CollateralValueasonNPAdateinRs=@CollateralValueasonNPAdateinRs
		--							,@CollateralValueatthetimeoflastreviewinRs=@CollateralValueatthetimeoflastreviewinRs
		--							--,@ValuationSourceNameAlt_Key=@ValuationSourceNameAlt_Key
		--							--,@SourceName=@SourceName
		--							,@ValuationDate=@ValuationDate
		--							,@LatestCollateralValueinRs=@LatestCollateralValueinRs
		--							,@ExpiryBusinessRule=@ExpiryBusinessRule
		--							,@Periodinmonth=@Periodinmonth
		--							,@ValueExpirationDate=@ValueExpirationDate
		--							,@AuthorisationStatus=@AuthorisationStatus
		--							,@EffectiveFromTimeKey=@EffectiveFromTimeKey
		--							,@EffectiveToTimeKey=@EffectiveToTimeKey
		--							,@CreatedBy	=@CreatedBy	
		--							 ,@DateCreated	=@DateCreated
		--							 ,@ModifiedBy=@ModifiedBy	
		--							 ,@DateModified	=@DateModified
		--							 ,@ApprovedBy=@ApprovedBy	
		--							 ,@DateApproved	=@DateApproved

		--	Declare
		--	--@CollateralID	int	=0
		--	@CustomeroftheBankAlt_Key	int=0
		--	--,@CollateralID	varchar(16)=''
		--	--,@CustomerID	varchar(50)=''
		--	,@OtherOwnerName	varchar(50)=''
		--	,@PAN	varchar(10)=''
		--	,@OtherOwnerRelationshipAlt_Key	int=0
		--	,@IfRelationselectAlt_Key	int=0
		--	,@AddressType	varchar(200)=''
		--	,@Category	varchar(200)=''
		--	,@AddressLine1	varchar(200)=''
		--	,@AddressLine2	varchar(200)=''
		--	,@AddressLine3	varchar(200)=''
		--	,@City	varchar(200)=''
		--	,@PinCode	varchar(6)=''
		--	,@Country	varchar(100)=''
		--	,@State	varchar(100)=''
		--	,@District	varchar	(100)=''
		--	,@STDCodeO	varchar	(100)=''
		--	,@PhoneNumberO	varchar(10)=''
		--	,@STDCodeR	varchar(100)=''
		--	,@PhoneNumberR	varchar(10)=''
		--	,@FaxNumber	varchar(20)=''
		--	,@MobileNO	varchar(15)=''

		--	Exec CollateralOwnerInsert
		--				@CustomerID=@CustomerID								
		--				,@CustomeroftheBankAlt_Key=@CustomeroftheBankAlt_Key
		--				--,@AccountID=@AccountID
		--				,@CustomerID=@CustomerID
		--				,@OtherOwnerName=@OtherOwnerName
		--				,@PAN=@PAN
		--				,@OtherOwnerRelationshipAlt_Key=@OtherOwnerRelationshipAlt_Key
		--				,@IfRelationselectAlt_Key=@IfRelationselectAlt_Key
		--				--,@AddressType=@AddressType
		--				--,@Category=@Category
		--				--,@AddressLine1=@AddressLine1
		--				--,@AddressLine2=@AddressLine2
		--				--,@AddressLine3=@AddressLine3
		--				--,@City=@City
		--				--,@PinCode=@PinCode
		--				--,@Country=@Country
		--				--,@State=@State
		--				--,@District=@District
		--				--,@STDCodeO=@STDCodeO
		--				--,@PhoneNumberO=@PhoneNumberO
		--				--,@STDCodeR=@STDCodeR
		--				--,@PhoneNumberR=@PhoneNumberR
		--				--,@FaxNumber=@FaxNumber
		--				--,@MobileNO=@MobileNO
		--				,@AuthorisationStatus=@AuthorisationStatus
		--				,@EffectiveFromTimeKey=@EffectiveFromTimeKey	
		--				,@EffectiveToTimeKey=@EffectiveToTimeKey	
		--				,@CreatedBy=@CreatedBy				
		--				,@DateCreated=@DateCreated			
		--				,@ModifiedBy=@ModifiedBy			
		--				,@DateModified=@DateModified			
		--				,@ApprovedBy=@ApprovedBy			
		--				,@DateApproved=@DateApproved	
						
						
		--			exec CollateralOwnerAddressInsert
		--			@CustomerID=@CustomerID	
		--			,@AddressType=@AddressType
		--				,@Category=@Category
		--				,@AddressLine1=@AddressLine1
		--				,@AddressLine2=@AddressLine2
		--				,@AddressLine3=@AddressLine3
		--				,@City=@City
		--				,@PinCode=@PinCode
		--				,@Country=@Country
		--				,@State=@State
		--				,@District=@District
		--				,@STDCodeO=@STDCodeO
		--				,@PhoneNumberO=@PhoneNumberO
		--				,@STDCodeR=@STDCodeR
		--				,@PhoneNumberR=@PhoneNumberR
		--				,@FaxNumber=@FaxNumber
		--				,@MobileNO=@MobileNO
		--				,@AuthorisationStatus=@AuthorisationStatus
		--				,@EffectiveFromTimeKey=@EffectiveFromTimeKey	
		--				,@EffectiveToTimeKey=@EffectiveToTimeKey	
		--				,@CreatedBy=@CreatedBy				
		--				,@DateCreated=@DateCreated			
		--				,@ModifiedBy=@ModifiedBy			
		--				,@DateModified=@DateModified			
		--				,@ApprovedBy=@ApprovedBy			
		--				,@DateApproved=@DateApproved			
						
		




----------------------------------------------------------------------------------------------------

									IF @IsSCD2='Y' 
								BEGIN
								UPDATE WillfulDefaulters SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CustomerID=@CustomerID AND EntityId=@EntityId
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO WillfulDefaulters_Insert
					HistoryRecordInUp:
			END						



		END 

		

PRINT 6
SET @ErrorHandle=1

WillfulDefaulters_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO WillfulDefaulters_Mod  
											(       EntityId,
													ReportedByAlt_Key,
													CategoryofBankFIAlt_Key,
													ReportingBankFIAlt_Key,
													ReportingBranchAlt_Key,
													StateUTofBranchAlt_Key,
													CustomerID,
													PartyName,
													PAN,
													ReportingSerialNo,
													RegisteredOfficeAddress,
													OSAmountinlacs,
													WillfulDefaultDate,
													SuitFiledorNotAlt_Key,
													OtherBanksFIInvolvedAlt_Key,
													NameofOtherBanksFIAlt_Key,
													CustomerTypeAlt_Key,		
													AuthorisationStatus,
													EffectiveFromTimeKey,
													EffectiveToTimeKey,
													CreatedBy,
													DateCreated,
													ModifiedBy,
													DateModified,
													ApprovedBy,
													DateApproved
																								
											)
								VALUES
											( 
													  Case When @OperationFlag = 1 then @Uniq_EntryID Else @EntityId END,
													  @ReportedByAlt_Key,
													  @CategoryofBankFIAlt_Key,
													  @ReportingBankFIAlt_Key,
													  @ReportingBranchAlt_Key,
													  @StateUTofBranchAlt_Key,
													  @CustomerID,
													  @PartyName,
													  @PAN,
													  @ReportingSerialNo,
													  @RegisteredOfficeAddress,
													  @OSAmountinlacs,
													  @WillfulDefaultDate,
													  @SuitFiledorNotAlt_Key,
													  @OtherBanksFIInvolvedAlt_Key,
													  @NameofOtherBanksFIAlt_Key,
													  @CustomerTypeAlt_Key	,
													  @AuthorisationStatus,
													  @EffectiveFromTimeKey,
													  @EffectiveToTimeKey ,
													  @CreatedBy,
													  @DateCreated,
													  CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END,
													  CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END,
													  CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END,
													  CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
													
											)
	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO WillfulDefaulters_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO WillfulDefaulters_Insert_Edit_Delete
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