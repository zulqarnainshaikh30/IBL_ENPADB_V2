SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[RestuctureMaster_InUp]
						   @AccountEntityId			    INT =0
						  ,@RestructureTypeAlt_Key		INT	=0	
						  ,@RestructureCatgAlt_Key		INT	=0	
						  ,@RestructureProposalDt		DATE=' '	
						  ,@RestructureDt				Varchar(20)	=' '					
						  ,@RestructureAmt				DECIMAL(18,0)=NULL	
						  ,@ApprovingAuthAlt_Key		VARCHAR(20)=NULL	
						  ,@RestructureApprovalDt		Varchar(20)	=' '	
						  ,@RestructureSequenceRefNo	INT	=0	
						  ,@DiminutionAmount			DECIMAL(18,0)=NULL	
						  ,@RestructureByAlt_Key		INT	=0	
						  ,@RefCustomerId				VARCHAR(20)=NULL	
						  ,@RefSystemAcId				VARCHAR(30)=NULL	
						  --,@OverDueSinceDt				Varchar(20)	=' '	
						 -- ,@BankApprovalDt				Varchar(20)	=' '	
						 -- ,@ForwardDt					Varchar(20)	=' '
						  ,@DisbursementDate		    Varchar(20)=''
						  ,@RestructureAssetClassAlt_key int = 0
							,@RestructureNPADate	Varchar(20) = ''
							,@Npa_Qtr	       VARCHAR(20)=NULL
							,@RestructurePOS	       Decimal(16,2) = 0
							,@RevisedBusinessSegment   Varchar(30) = ''
							,@BankingType		       int =0	
						  --,@Remark					VARCHAR(250)=NULL	
						  ,@RestuctureMaster_ChangeFields				VARCHAR(1000)=NULL
						  --,@PreRestrucDefaultDate		DATETIME=' '
						  --,@PreRestrucAssetClass		INT	=0	
						  --,@PreRestrucNPA_Date		DATETIME=' '
						  --,@PostRestrucAssetClass		INT=0	
						  ,@IntRepayStartDate			Varchar(20)	=' '
						  ,@PrinRepayStartDate			Varchar(20)	=' '		
						  --,@RefDate						Varchar(20)	=' '
						  ,@InvocationDate				Varchar(20)	=' '
						  ,@IsEquityCoversion			CHAR(1)=NULL
						  ,@ConversionDate				Varchar(20)	=' '	
						  ,@Is_COVID_Morat				CHAR(1)=NULL	
						  ,@COVID_OTR_Catg				VARCHAR(10)=NULL
						  ,@CRILIC_Fst_DefaultDate		Varchar(20)	=' '
						  ,@FstDefaultReportingBank		VARCHAR(50)=NULL
						  ,@ICA_SignDate				Varchar(20)	=' '	
						  ,@Is_InvestmentGrade			Varchar(10)=NULL
						  ,@StatusofSpecifiedPeriod     VARCHAR(MAX)=NULL
						  						 
						  ,@CreditProvision				DECIMAL(16,2)=NULL
						  ,@DFVProvision				DECIMAL(16,2)=NULL	
						  ,@MTMProvision				DECIMAL(16,2)=NULL	
						  ,@NPA_Provision_per           DECIMAL(16,2)=NULL	
                          ,@EquityConversionYN          varchar(5)=''
						  
						---------D2k System Common Columns		--
						,@Remark					VARCHAR(500)	= ''
						--,@MenuID					SMALLINT		= 0  change to Int
						,@MenuID                    Int=0
						,@OperationFlag				TINYINT			= 0
						,@AuthMode					VARCHAR(2)			= 'N'
						,@EffectiveFromTimeKey		INT		= 0
						,@EffectiveToTimeKey		INT		= 0
						,@TimeKey					INT		= 0
						,@CrModApBy					VARCHAR(20)		=''
						,@ScreenEntityId			INT				=null
						,@Result					INT				=0 OUTPUT
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;

    PRINT 1
	
		SET DATEFORMAT DMY
	
		DECLARE 
						 @AuthorisationStatus		CHAR(2)			= NULL 
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

				SET @ScreenName = 'RestructureMaster'

	-------------------------------------------------------------

 SET @Timekey =(Select Timekey from SysDataMatrix where CurrentStatus='C') 

 SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

	set @RestructureProposalDt=case when (@RestructureProposalDt='' or @RestructureProposalDt='01/01/1900')
	                                THEN NULL ELSE @RestructureProposalDt END
    set @RestructureApprovalDt=case when (@RestructureApprovalDt='' or @RestructureApprovalDt='01/01/1900')
	                                THEN NULL ELSE @RestructureApprovalDt END
    set @ICA_SignDate=case when (@ICA_SignDate='' or @ICA_SignDate='01/01/1900')
	                                THEN NULL ELSE @ICA_SignDate END
   set @PrinRepayStartDate=case when (@PrinRepayStartDate='' or @PrinRepayStartDate='01/01/1900')
	                                THEN NULL ELSE @PrinRepayStartDate END


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
					SELECT  1 FROM [CurDat].[AdvAcRestructureDetail] WHERE RefSystemAcId=@RefSystemAcId
					AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey
					UNION
					SELECT  1 FROM [dbo].[AdvAcRestructureDetail_Mod]  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)
															AND RefSystemAcId=@RefSystemAcId
															AND   ISNULL(AuthorisationStatus,'A') in('NP','MP','DP','RM') 
				)	
				BEGIN
				   PRINT 2
					SET @Result=-4
					RETURN @Result -- USER ALEADY EXISTS
				END
		--ELSE
		--	BEGIN
		--	   PRINT 3
		--		--SELECT @BankRPAlt_Key=NEXT VALUE FOR Seq_BankRPAlt_Key
		--		--PRINT @BankRPAlt_Key
				
		--			 --SET @AccountEntityId = (Select ISNULL(Max(AccountEntityId),0)+1 from 
		--				--						(Select AccountEntityId from Curdat.AdvAcRestructureDetail
		--				--						 UNION 
		--				--						 Select AccountEntityId from dbo.AdvAcRestructureDetail_Mod
		--				--						)A)
		--	END
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

					 --SET @AccountEntityId = (Select ISNULL(Max(AccountEntityId),0)+1 from 
						--						(Select AccountEntityId from Curdat.AdvAcRestructureDetail
						--						 UNION 
						--						 Select AccountEntityId from dbo.AdvAcRestructureDetail_Mod
						--						)A)

					 GOTO RestructureMaster_Insert
				     RestructureMaster_Insert_Add:
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
					FROM Curdat.AdvAcRestructureDetail  
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND RefSystemAcId=@RefSystemAcId

				---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM dbo.AdvAcRestructureDetail_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND RefSystemAcId=@RefSystemAcId
							AND AuthorisationStatus IN('NP','MP','A','RM')
															
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						UPDATE Curdat.AdvAcRestructureDetail
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND RefSystemAcId=@RefSystemAcId

					END

					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	

						UPDATE dbo.AdvAcRestructureDetail_Mod
							SET AuthorisationStatus='FM'
							,ModifiedBy=@Modifiedby
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND RefSystemAcId=@RefSystemAcId
								AND AuthorisationStatus IN('NP','MP','RM')
					END

					-- ConstitutionMaster_Insert
					--ConstitutionMaster_Insert_Edit_Delete:
					 GOTO RestructureMaster_Insert
				     RestructureMaster_Insert_Edit_Delete:
				END

		ELSE IF @OperationFlag =3 AND @AuthMode ='N'
		BEGIN
		-- DELETE WITHOUT MAKER CHECKER
											
						SET @Modifiedby   = @CrModApBy 
						SET @DateModified = GETDATE() 

						UPDATE Curdat.AdvAcRestructureDetail SET
									ModifiedBy =@Modifiedby 
									,DateModified =@DateModified 
									,EffectiveToTimeKey =@EffectiveFromTimeKey-1
								WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
								AND RefSystemAcId=@RefSystemAcId
				

		end
	
	
	ELSE IF @OperationFlag=17 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE dbo.AdvAcRestructureDetail_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND RefSystemAcId=@RefSystemAcId
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

				IF EXISTS(SELECT 1 FROM Curdat.AdvAcRestructureDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
				                    AND RefSystemAcId=@RefSystemAcId)
				BEGIN
					UPDATE Curdat.AdvAcRestructureDetail
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND RefSystemAcId=@RefSystemAcId
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

-------------------Two level Auth. Changes------------------

ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE dbo.AdvAcRestructureDetail_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND RefSystemAcId=@RefSystemAcId
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	
						
				IF EXISTS(SELECT 1 FROM Curdat.AdvAcRestructureDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
				                                              AND RefSystemAcId=@RefSystemAcId)
				BEGIN
					UPDATE Curdat.AdvAcRestructureDetail
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND RefSystemAcId=@RefSystemAcId
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

----------------------------------------------------------------------

	ELSE IF @OperationFlag=18
	BEGIN
		PRINT 18
		SET @ApprovedBy=@CrModApBy
		SET @DateApproved=GETDATE()
		UPDATE dbo.AdvAcRestructureDetail_Mod
		SET AuthorisationStatus='RM'
		WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		AND AuthorisationStatus IN('NP','MP','DP','RM')
		AND RefSystemAcId=@RefSystemAcId

	END

	ELSE IF @OperationFlag=16

		BEGIN

		SET @ApprovedBy	   = @CrModApBy 
		SET @DateApproved  = GETDATE()

		UPDATE dbo.AdvAcRestructureDetail_Mod
						SET AuthorisationStatus ='1A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							WHERE RefSystemAcId=@RefSystemAcId
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
					 FROM Curdat.AdvAcRestructureDetail 
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
							AND RefSystemAcId=@RefSystemAcId
					
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
					SELECT @ExEntityKey= MAX(EntityKey) FROM dbo.AdvAcRestructureDetail_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND RefSystemAcId=@RefSystemAcId
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

					SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
						,@ModifiedBy=ModifiedBy, @DateModified=DateModified
					 FROM dbo.AdvAcRestructureDetail_Mod
						WHERE EntityKey=@ExEntityKey
					
					SET @ApprovedBy = @CrModApBy			
					SET @DateApproved=GETDATE()
				
					
					DECLARE @CurEntityKey INT=0

					SELECT @ExEntityKey= MIN(EntityKey) FROM dbo.AdvAcRestructureDetail_Mod 
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
							AND RefSystemAcId=@RefSystemAcId
							AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	
				
					SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
						 FROM dbo.AdvAcRestructureDetail_Mod
							WHERE EntityKey=@ExEntityKey

					UPDATE dbo.AdvAcRestructureDetail_Mod
						SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1
						WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
						AND RefSystemAcId=@RefSystemAcId
						AND AuthorisationStatus='A'	

		-------DELETE RECORD AUTHORISE
					IF @DelStatus='DP' 
					BEGIN	
						UPDATE dbo.AdvAcRestructureDetail_Mod
						SET AuthorisationStatus ='A'
							,ApprovedBy=@ApprovedBy
							,DateApproved=@DateApproved
							,EffectiveToTimeKey =@EffectiveFromTimeKey -1
						WHERE RefSystemAcId=@RefSystemAcId
							AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
						IF EXISTS(SELECT 1 FROM Curdat.AdvAcRestructureDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
										AND RefSystemAcId=@RefSystemAcId)
						BEGIN
								UPDATE Curdat.AdvAcRestructureDetail
									SET AuthorisationStatus ='A'
										,ModifiedBy=@ModifiedBy
										,DateModified=@DateModified
										,ApprovedBy=@ApprovedBy
										,DateApproved=@DateApproved
										,EffectiveToTimeKey =@EffectiveFromTimeKey-1
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND RefSystemAcId=@RefSystemAcId

								
						END
					END -- END OF DELETE BLOCK

					ELSE  -- OTHER THAN DELETE STATUS
					BEGIN
							UPDATE dbo.AdvAcRestructureDetail_Mod
								SET AuthorisationStatus ='A'
									,ApprovedBy=@ApprovedBy
									,DateApproved=@DateApproved
								WHERE RefSystemAcId=@RefSystemAcId
									AND AuthorisationStatus in('NP','MP','RM','1A')

			

									
					END		
				END



		IF @DelStatus <>'DP' OR @AuthMode ='N'
				BEGIN
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020

						IF EXISTS(SELECT 1 FROM Curdat.AdvAcRestructureDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									                                AND RefSystemAcId=@RefSystemAcId)
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'


								IF EXISTS(SELECT 1 FROM Curdat.AdvAcRestructureDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@TimeKey AND RefSystemAcId=@RefSystemAcId)
									BEGIN
											PRINT @AccountEntityId
										UPDATE Curdat.AdvAcRestructureDetail SET
											   AccountEntityId			=	@AccountEntityId
										      ,RestructureTypeAlt_Key	=	@RestructureTypeAlt_Key
											  ,RestructureCatgAlt_Key	=	@RestructureCatgAlt_Key     
											  ,RestructureProposalDt	=	@RestructureProposalDt
											  ,RestructureDt			=	convert(date,@RestructureDt ,103)
											  ,RestructureAmt			=	@RestructureAmt
											  ,RestructureApprovingAuthority		=	@ApprovingAuthAlt_Key
											  ,RestructureApprovalDt	=	@RestructureApprovalDt
											  ,RestructureSequenceRefNo	=	@RestructureSequenceRefNo
											  ,DiminutionAmount			=	@DiminutionAmount
											  ,RestructureByAlt_Key		=	@RestructureByAlt_Key
											  ,RefCustomerId			=	@RefCustomerId
											  ,RefSystemAcId			=	@RefSystemAcId
											  ,Restructure_NPA_Dt     =@RestructureNPADate
											  --,AuthorisationStatus		=	@AuthorisationStatus
											  --,OverDueSinceDt			=	@OverDueSinceDt
											  --,BankApprovalDt			=	@BankApprovalDt
											  --,ForwardDt				=	@ForwardDt
											 -- ,Remark					=	@Remark
											 -- ,ChangeFields				=	@ChangeFields
											  --,PreRestrucDefaultDate	=	@PreRestrucDefaultDate
											  --,PreRestrucAssetClass		=	@PreRestrucAssetClass
											  --,PreRestrucNPA_Date		=	@PreRestrucNPA_Date
											  --,PostRestrucAssetClass	=	@PostRestrucAssetClass
											  ,InttRepayStartDate		=	@IntRepayStartDate
											  ,PrincRepayStartDate       =  @PrinRepayStartDate
											--  ,RefDate					=	@RefDate--(date,@RefDate ,103)
											  ,InvocationDate			=	@InvocationDate
											 -- ,EquityConversionYN		=	@IsEquityCoversion
											  ,ConversionDate			=	@ConversionDate
											  ,FlgMorat			=	@Is_COVID_Morat
											  ,COVID_OTR_CatgAlt_Key			=	@COVID_OTR_Catg
											  ,CRILIC_Fst_DefaultDate   =	@CRILIC_Fst_DefaultDate
											  ,FstDefaultReportingBank	=	@FstDefaultReportingBank
											  ,ICA_SignDate				=	@ICA_SignDate
											  ,InvestmentGrade		=	@Is_InvestmentGrade
											  ,StatusofSpecificPeriod=@StatusofSpecifiedPeriod											
											  ,CreditProvision			=	@CreditProvision
											  ,DFVProvision				=	@DFVProvision
											  ,MTMProvision				=	@MTMProvision
												,ModifiedBy					= @ModifiedBy
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												,PreRestructureNPA_Prov          =@NPA_Provision_per
												,EquityConversionYN         =@EquityConversionYN
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND RefSystemAcId=@RefSystemAcId
									END	

									ELSE
										BEGIN
											SET @IsSCD2='Y'
										END
								END
--alter table DimProvision_Seg_Mod
--add AdditionalprovisionRBINORMS decimal(16,2)

								IF @IsAvailable='N' OR @IsSCD2='Y'
									BEGIN
										INSERT INTO Curdat.AdvAcRestructureDetail
												(
													   AccountEntityId
													  ,RestructureTypeAlt_Key
													  ,RestructureCatgAlt_Key
													  ,RestructureProposalDt
													  ,RestructureDt
													  ,RestructureAmt
													  ,RestructureApprovingAuthority
													  ,RestructureApprovalDt
													  ,RestructureSequenceRefNo
													  ,DiminutionAmount
													  ,RestructureByAlt_Key
													  ,RefCustomerId
													  ,RefSystemAcId
													   ,Restructure_NPA_Dt     
													  ,AuthorisationStatus
													  --,OverDueSinceDt
													  --,BankApprovalDt
													  --,ForwardDt
													 -- ,Remark
													 -- ,ChangeFields
													  --,PreRestrucDefaultDate
													  --,PreRestrucAssetClass
													  --,PreRestrucNPA_Date
													  --,PostRestrucAssetClass
													  ,InttRepayStartDate
													  ,PrincRepayStartDate   ---=  @PrinRepayStartDate    
													  --,RefDate
													  ,InvocationDate
													 -- ,EquityConversionYN
													  ,ConversionDate
													  ,FlgMorat
													  ,COVID_OTR_CatgAlt_Key
													  ,CRILIC_Fst_DefaultDate
													  ,FstDefaultReportingBank
													  ,ICA_SignDate
													  ,InvestmentGrade
													  ,StatusofSpecificPeriod													
													  ,CreditProvision
													  ,DFVProvision
													  ,MTMProvision
													  ,CreatedBy	    
													  ,DateCreated	 
													  ,ModifiedBy	 
													  ,DateModified	
													  ,ApprovedBy	 
													  ,DateApproved	
													  ,EffectiveFromTimeKey
													  ,EffectiveToTimeKey
														--,RevisedBusinessSegment
														,BankingRelationTypeAlt_Key
														,DisbursementDate
														,PreRestructureAssetClassAlt_Key
														--,RestructureDate
														--,Npa_Qtr
														,RestructurePOS 
														,PreRestructureNPA_Prov
                                                        ,EquityConversionYN
													
												)

										SELECT
													      @AccountEntityId
														 ,@RestructureTypeAlt_Key	
														  ,@RestructureCatgAlt_Key	
														  ,@RestructureProposalDt
														  --,@RestructureDt	
														  , convert(date,@RestructureDt ,103)
														  ,@RestructureAmt	
														  ,@ApprovingAuthAlt_Key	
														  ,@RestructureApprovalDt	
														  ,@RestructureSequenceRefNo	
														  ,@DiminutionAmount	
														  ,@RestructureByAlt_Key	
														  ,@RefCustomerId	
														  ,@RefSystemAcId	
														   ,@RestructureNPADate
														  , CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END	
														 -- ,@EffectiveFromTimeKey	
														 -- ,@EffectiveToTimeKey	
														  --,@CreatedBy	
														 -- ,@DateCreated	
														 -- ,@ModifiedBy	
														  --,@DateModified	
														  --,@ApprovedBy	
														  --,@DateApproved	
														  --,@D2Ktimestamp	
														  --,@OverDueSinceDt	
														  --,@BankApprovalDt	
														  --,@ForwardDt	
														 -- ,@Remark	
														  --,@ChangeFields	
														  --,@PreRestrucDefaultDate	
														  --,@PreRestrucAssetClass	
														  --,@PreRestrucNPA_Date	
														  --,@PostRestrucAssetClass	
														  ,@IntRepayStartDate
														  ,@PrinRepayStartDate	
														 -- ,@RefDate
														   --,convert(date,@RefDate ,103)	
														  ,@InvocationDate	
														  --,@IsEquityCoversion	
														  ,@ConversionDate	
														  ,@Is_COVID_Morat	
														  ,@COVID_OTR_Catg	
														  ,@CRILIC_Fst_DefaultDate	
														  ,@FstDefaultReportingBank	
														  ,@ICA_SignDate	
														  ,@Is_InvestmentGrade
														  ,@StatusofSpecifiedPeriod														
														  ,@CreditProvision	
														  ,@DFVProvision	
														  ,@MTMProvision
														  ,@CreatedBy  
														  ,@DateCreated
														  ,@ModifiedBy
												         , @DateModified
												          ,CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												          ,CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												          
												          ,@EffectiveFromTimeKey
														,@EffectiveToTimeKey
														--,@RevisedBusinessSegment
														,@BankingType
														,@DisbursementDate
														,@RestructureAssetClassAlt_key
														--,@RestructureDate
														--,@Npa_Qtr
														,@RestructurePOS 
														,@NPA_Provision_per
														,@EquityConversionYN
													

									END


									IF @IsSCD2='Y' 
								BEGIN
								UPDATE Curdat.AdvAcRestructureDetail SET
										EffectiveToTimeKey=@EffectiveFromTimeKey-1
										,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
									WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) 
									       AND RefSystemAcId=@RefSystemAcId
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
								END
							END

		IF @AUTHMODE='N'
			BEGIN
					SET @AuthorisationStatus='A'
					GOTO RestructureMaster_Insert
					HistoryRecordInUp:
			END						



		END 

PRINT 6
SET @ErrorHandle=1

RestructureMaster_Insert:
IF @ErrorHandle=0
	BEGIN
			INSERT INTO dbo.AdvAcRestructureDetail_Mod  
											( 
											 AccountEntityId
											  ,RestructureTypeAlt_Key
											  ,RestructureCatgAlt_Key
											  ,RestructureProposalDt
											  ,RestructureDt
											  ,RestructureAmt
											  ,RestructureApprovingAuthority
											  ,RestructureApprovalDt
											  ,RestructureSequenceRefNo
											  ,DiminutionAmount
											  ,RestructureByAlt_Key
											  ,RefCustomerId
											  ,RefSystemAcId
											   ,Restructure_NPA_Dt  
											  ,AuthorisationStatus
											  ,EffectiveFromTimeKey
											  ,EffectiveToTimeKey
											  ,CreatedBy
											  ,DateCreated
											  ,ModifiedBy
											  ,DateModified
											  ,ApprovedBy
											  ,DateApproved
											  --,D2Ktimestamp
											  --,OverDueSinceDt
											  --,BankApprovalDt
											  --,ForwardDt
											  ,Remark
											  
											  --,PreRestrucDefaultDate
											  --,PreRestrucAssetClass
											  --,PreRestrucNPA_Date
											  --,PostRestrucAssetClass
											  ,InttRepayStartDate
											  ,PrincRepayStartDate
											  --,RefDate
											  ,InvocationDate
											  --,EquityConversionYN
											  ,ConversionDate
											  ,FlgMorat
											  ,COVID_OTR_CatgAlt_Key
											  ,CRILIC_Fst_DefaultDate
											  ,FstDefaultReportingBank
											  ,ICA_SignDate
											  ,InvestmentGrade
											  ,StatusofSpecificPeriod
											  ,CreditProvision
											  ,DFVProvision
											  ,MTMProvision
											 -- ,RevisedBusinessSegment
														,BankingRelationTypeAlt_Key
														,DisbursementDate
														,PreRestructureAssetClassAlt_Key
														--,RestructureDate
														--,Npa_Qtr
														,RestructurePOS 
														
														,PreRestructureNPA_Prov
														,EquityConversionYN
													,ChangeFields
  

											)
								VALUES
											( 
													      @AccountEntityId
														 ,@RestructureTypeAlt_Key	
														  ,@RestructureCatgAlt_Key	
														  ,@RestructureProposalDt	
														  --,@RestructureDt	
														  , convert(date,@RestructureDt ,103)
														  ,@RestructureAmt	
														  ,@ApprovingAuthAlt_Key	
														  ,@RestructureApprovalDt	
														  ,@RestructureSequenceRefNo	
														  ,@DiminutionAmount	
														  ,@RestructureByAlt_Key	
														  ,@RefCustomerId	
														  ,@RefSystemAcId	
														   ,@RestructureNPADate
														  ,@AuthorisationStatus	
														  ,@EffectiveFromTimeKey	
														  ,@EffectiveToTimeKey	
														   ,@CreatedBy  
                                                           ,@DateCreated
														,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													     ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													     ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													     ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END	
														  
														  --,@D2Ktimestamp	
														  --,@OverDueSinceDt	
														  --,@BankApprovalDt	
														  --,@ForwardDt	
														  ,@Remark	
														  	
														  --,@PreRestrucDefaultDate	
														  --,@PreRestrucAssetClass	
														  --,@PreRestrucNPA_Date	
														  --,@PostRestrucAssetClass	
														  ,@IntRepayStartDate	
														  ,@PrinRepayStartDate
														 -- ,@RefDate	
														  --,convert(date,@RefDate ,103)	
														  ,@InvocationDate	
														  --,@IsEquityCoversion	
														  ,@ConversionDate	
														  ,@Is_COVID_Morat	
														  ,@COVID_OTR_Catg	
														  ,@CRILIC_Fst_DefaultDate	
														  ,@FstDefaultReportingBank	
														  ,@ICA_SignDate	
														  ,@Is_InvestmentGrade
														  ,@StatusofSpecifiedPeriod															
														  ,@CreditProvision	
														  ,@DFVProvision	
														  ,@MTMProvision	
														 -- ,@RevisedBusinessSegment
														,@BankingType
														,@DisbursementDate
														,@RestructureAssetClassAlt_key
														--,@RestructureDate
														--,@Npa_Qtr
														,@RestructurePOS 
														,@NPA_Provision_per
														,@EquityConversionYN
														,@RestuctureMaster_ChangeFields														
													--,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END
													--,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END
													--,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END
													--,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END
												
											)
											
	DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from AdvAcRestructureDetail_Mod where  RefSystemAcId=@RefSystemAcId
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
							from		AdvAcRestructureDetail_Mod   A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and			 RefSystemAcId=@RefSystemAcId									
										
	
	
	

	
	

		         IF @OperationFlag =1 AND @AUTHMODE='Y'
					BEGIN
						PRINT 3
						GOTO RestructureMaster_Insert_Add
					END
				ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'
					BEGIN
						GOTO RestructureMaster_Insert_Edit_Delete
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
								@ReferenceID=@RefSystemAcId ,-- ReferenceID ,
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
								@ReferenceID=@RefSystemAcId ,-- ReferenceID ,
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