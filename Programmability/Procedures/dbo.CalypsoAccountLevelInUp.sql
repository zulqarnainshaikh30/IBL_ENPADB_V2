SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[CalypsoAccountLevelInUp]  
  
--Declare  
                                     @AccountID								varchar(30)=''
									,@POS									decimal(18,2) = 0
									,@InterestReceivable					decimal(18,2) = 0
									,@RestructureFlagAlt_Key				varchar(1)=''
									,@RestructureDate						Varchar(20)=NULL
									,@FITLFlagAlt_Key						varchar(1)=''
									,@DFVAmount								decimal(16,2) = 0
									,@RePossessionFlagAlt_Key				Varchar(1)=''
									,@RePossessionDate						Varchar(20)=NULL
									,@InherentWeaknessFlagAlt_Key			varchar(1)=''
									,@InherentWeaknessDate					Varchar(20)=NULL
									,@SARFAESIFlagAlt_Key				    varchar(1)=''
									,@SARFAESIDate							Varchar(20)=NULL
									,@UnusualBounceFlagAlt_Key						varchar(1)=''
									,@UnusualBounceDate						Varchar(20)=NULL
									,@UnclearedEffectsFlagAlt_Key			varchar(1)=''
									,@UnclearedEffectsDate					Varchar(20)=NULL
									,@AdditionalProvisionCustomerlevel		decimal(16,2)
									,@AdditionalProvisionAbsolute			decimal(16,2)
									,@MOCReason								varchar(500)=''
									,@FraudAccountFlagAlt_Key						varchar(1)=''
									,@FraudDate								Varchar(20)=NULL
									,@ScreenFlag							VArchar(1)=''
									,@MOCSource								int=0
									,@AccountNPAMOC_ChangeFields			varchar(50) = ''
									,@TwoDate								Varchar(20)=NULL
									--,@TwoFlagAlt_Key						varchar(1)=''
								   ,@TwoAmount								decimal(18,2)
						           ,@BookValue                              decimal(18,2)
								   ,@SMADate                                varchar(20)
								   ,@SMASubAssetClassValue                  Varchar(20)

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
 set @RestructureDate =case when ( @RestructureDate='' or @RestructureDate='01/01/1900' or @RestructureDate='1900/01/01')  
                             then NULL ELSE @RestructureDate END   
  
    set @FraudDate =case when ( @FraudDate='' or @FraudDate='01/01/1900' or @FraudDate='1900/01/01') then NULL ELSE @FraudDate END   
 

 --set @UnclearedEffectsDate =case when ( @UnclearedEffectsDate='' or @UnclearedEffectsDate='01/01/1900' or @UnclearedEffectsDate='1900/01/01') then NULL   
 --ELSE @UnclearedEffectsDate END  
  
  DECLARE   
      @AuthorisationStatus  varchar(5)   = NULL   
      ,@CreatedBy     VARCHAR(20)  = NULL  
      ,@DateCreated    SMALLDATETIME = NULL  
      ,@ModifiedBy    VARCHAR(20)  = NULL  
      ,@DateModified    SMALLDATETIME = NULL  
      ,@ApprovedBy    VARCHAR(20)  = NULL  
      ,@DateApproved    SMALLDATETIME = NULL  
      ,@ErrorHandle    int    = 0  
      ,@ExEntityKey    int    = 0    
      --,@AccountEntityID int=0  
        
------------Added for Rejection Screen  29/06/2020   ----------  
  
  DECLARE   @Uniq_EntryID   int = 0  
      ,@RejectedBY   Varchar(50) = NULL  
      ,@RemarkBy    Varchar(50) = NULL  
      ,@RejectRemark   Varchar(200) = NULL  
      ,@ScreenName   Varchar(200) = NULL  
      ,@ApprovedByFirstLevel		VARCHAR(20)		= NULL
	  ,@DateApprovedFirstLevel	SMALLDATETIME	= NULL
	  ,@MOC_Date date
  
    SET @ScreenName = 'AccountLevel'  
 -------------------------------------------------------------  
  
   --Declare @MOC_DATE                  date=NULL
	
 --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C') 
 
 -- SET @MOC_DATE =(Select CAST(LastMonthDate AS DATE) from SysDayMatrix where Timekey=@Timekey) 

 -- SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey) 

 
 	SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N') 

	   SET @MOC_Date =(Select cast(ExtDate as date) from SysDataMatrix where Timekey=@TimeKey)

 --PRINT '@MOC_DATE'
  -- PRINT @MOC_DATE

  SET @EffectiveFromTimeKey  = @TimeKey

	SET @EffectiveToTimeKey = 49999

		Declare @MocStatus Varchar(100)=''

Select @MocStatus=MocStatus 
 from CalypsoMOCMonitorStatus
Where EntityKey in(Select Max(EntityKey) From CalypsoMOCMonitorStatus)

IF(@MocStatus='InProgress')
  Begin
     SET @Result=5
	RETURN @Result
  End

	Declare @AccountEntityID  int
	Select  @AccountEntityID= (select InvEntityId from InvestmentBasicDetail
	where InvID=@AccountID 
	UNION
	select DerivativeEntityID from curdat.DerivativeDetail
	where DerivativeRefNo=@AccountID) 

		IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey=@TimeKey AND EffectiveToTimeKey=@TimeKey) 
										AND AccountEntityID=@AccountEntityID AND MOCType_Flag='ACCT' AND MOCProcessed='N')
										BEGIN
										IF EXISTS(SELECT 1 FROM CalypsoDervMOC_ChangeDetails WHERE (EffectiveFromTimeKey=@TimeKey AND EffectiveToTimeKey=@TimeKey) 
										AND AccountEntityID=@AccountEntityID AND MOCType_Flag='ACCT' AND MOCProcessed='N')

										Begin
										SET @Result=6
										RETURN @Result
										End
										END

		Declare @CustomerEntityID int
	Select  @CustomerEntityID= IssuerEntityId from InvestmentBasicDetail
	                          where  InvID=@AccountID
							  and   EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey

      Declare @MOCReason_1 varchar(200)
      set @MOCReason_1 = (Select ParameterName from DimParameter where DimParameterName like '%MOCReason%'
	                                               and   EffectiveFromTimeKey<=@TimeKey 
												   AND EffectiveToTimeKey>=@TimeKey
												   and ParameterAlt_Key=@MOCReason )

	--SET @BankRPAlt_Key = (Select ISNULL(Max(BankRPAlt_Key),0)+1 from DimBankRP)
	PRINT 'A'

	DECLARE @AppAvail CHAR
			SET @AppAvail = (Select ParameterValue FROM SysSolutionParameter WHERE Parameter_Key=6)
					IF(@AppAvail='N')                         
			BEGIN
				SET @Result=-11
				RETURN @Result
			END
   
 BEGIN TRY  
 BEGIN TRANSACTION   
 -----  
   
 PRINT 3   
  --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK   
   
  
 IF(@OperationFlag = 2 OR @OperationFlag = 3) AND @AuthMode = 'Y' --EDIT AND DELETE  
  BEGIN  
  --  Print 4  
  --  SET @CreatedBy= @CrModApBy  
  --  SET @DateCreated = GETDATE()  
  --  Set @Modifiedby=@CrModApBy     
  --  Set @DateModified =GETDATE()   
  --  SET @AuthorisationStatus='MP'  
  --   --UPDATE NP,MP  STATUS   
  --   IF @OperationFlag=2  
  --   BEGIN   
  
  --    UPDATE CalypsoAccountLevelMOC_Mod  
  --     SET AuthorisationStatus='FM'  
  --     ,ModifyBy=@Modifiedby  
  --     ,DateModified=@DateModified  
  --    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  --      --AND AccountID=@AccountID  
		--AND  AccountEntityID =@AccountEntityID
  --      AND AuthorisationStatus IN('NP','MP','RM')  


		
		--						UPDATE CalypsoAccountLevelMOC_Mod
		--					SET EffectiveToTimeKey=@TimeKey-1
		--				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
		--						AND  AccountEntityID =@AccountEntityID
		--						AND AuthorisationStatus IN('A')
  --   END 
  
				 SET @CreatedBy= @CrModApBy
				SET @DateCreated = GETDATE()
				Set @Modifiedby=@CrModApBy   
				Set @DateModified =GETDATE() 
				SET @AuthorisationStatus='MP' 
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
						IF EXISTS (select count(1) FROM	[dbo].CalypsoInvMOC_ChangeDetails
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							 
							AND  AccountEntityID =@AccountEntityID)
							BEGIN
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM	[dbo].CalypsoInvMOC_ChangeDetails
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)							 
							AND  AccountEntityID =@AccountEntityID
						END
						ELSE
						BEGIN
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM	[dbo].CalypsoDervMOC_ChangeDetails
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							   
							AND  AccountEntityID =@AccountEntityID
						END



					---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM	[dbo].CalypsoAccountLevelMOC_Mod
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID =@AccountID 	
							AND  AccountEntityID =@AccountEntityID					
							AND AuthorisationStatus IN('NP','MP','A','RM')
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						IF EXISTS (select count(1) FROM	[dbo].CalypsoInvMOC_ChangeDetails
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							  
							AND  AccountEntityID =@AccountEntityID)
							BEGIN
								UPDATE [dbo].CalypsoInvMOC_ChangeDetails
								SET AuthorisationStatus=@AuthorisationStatus
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND  AccountEntityID =@AccountEntityID
							END
							ELSE
							BEGIN
								UPDATE [dbo].CalypsoDervMOC_ChangeDetails
								SET AuthorisationStatus=@AuthorisationStatus
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND  AccountEntityID =@AccountEntityID
							END
					END
					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	
					IF EXISTS (select count(1) FROM	[dbo].CalypsoInvMOC_ChangeDetails
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							 
							AND  AccountEntityID =@AccountEntityID)
							BEGIN
					UPDATE [dbo].CalypsoInvMOC_ChangeDetails
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND  AccountEntityID =@AccountEntityID
							END
							ELSE
							BEGIN
							UPDATE [dbo].CalypsoDervMOC_ChangeDetails
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND  AccountEntityID =@AccountEntityID
							END

						UPDATE CalypsoAccountLevelMOC_Mod
							SET AuthorisationStatus='FM'
							,ModifyBy=@ModifiedBy
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND AccountID =@AccountID AND  AccountEntityID =@AccountEntityID
								AND AuthorisationStatus IN('NP','MP','RM')
					END  
  
     GOTO GLCodeMaster_Insert  
     GLCodeMaster_Insert_Edit_Delete:  
  END  
  
 -------------------------------------------------------  
--start 20042021  
ELSE IF @OperationFlag=21 AND @AuthMode ='Y'   
  BEGIN  
  
  IF @CrModApBy= (select UserLoginID from DimUserInfo where IsChecker2='N' AND EffectiveToTimeKey>=49999 and UserLoginID=@CrModApBy group by UserLoginID)  
      BEGIN  
        SET @Result=-1  
        Rollback Tran
        RETURN @Result  
          
    END  
  
     IF (@CrModApBy =(Select CreatedBy from CalypsoAccountLevelMOC_Mod where  CreatedBy=@CrModApBy  AND  AccountEntityID =@AccountEntityID  
						and EffectiveToTimeKey = 49999 
						and AuthorisationStatus = '1A'
                 Group By CreatedBy))  
           BEGIN  
        SET @Result=-1  
        Rollback Tran
        RETURN @Result  
        --select createdby,* from DimBranch_Mod  
          END  
  
 ELSE
 BEGIN
        IF (@CrModApBy =(Select ApprovedByFirstLevel from CalypsoAccountLevelMOC_Mod where  ApprovedByFirstLevel=@CrModApBy  AND  AccountEntityID =@AccountEntityID
						and EffectiveToTimeKey = 49999 
						and AuthorisationStatus = '1A'  
                      Group By ApprovedByFirstLevel))  
           BEGIN  
        SET @Result=-1  
         Rollback Tran
        RETURN @Result  
        --select createdby,* from DimBranch_Mod  
          END  
ELSE
BEGIN

    SET @ApprovedBy    = @CrModApBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE CalypsoAccountLevelMOC_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      --AND AccountID=@AccountID  
	  AND  AccountEntityID =@AccountEntityID
      AND AuthorisationStatus in('NP','MP','DP','RM','1A') 
	  
	  	IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                            AND   AccountEntityID =@AccountEntityID AND MOCType_Flag='ACCT')
				BEGIN
					UPDATE CalypsoInvMOC_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND   AccountEntityID =@AccountEntityID
							 AND MOCType_Flag='ACCT'
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END

				 
	  	IF EXISTS(SELECT 1 FROM CalypsoDervMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                            AND   AccountEntityID =@AccountEntityID AND MOCType_Flag='ACCT')
				BEGIN
					UPDATE CalypsoDervMOC_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND   AccountEntityID =@AccountEntityID
							 AND MOCType_Flag='ACCT'
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
  
       END  
     END
  END

--till here  
-------------------------------------------------------  
   
 ELSE IF @OperationFlag=17 AND @AuthMode ='Y'   
  BEGIN  
  
     IF (@CrModApBy =(Select CreatedBy from CalypsoAccountLevelMOC_Mod where  CreatedBy=@CrModApBy AND  AccountEntityID =@AccountEntityID
																	   and AuthorisationStatus in ('NP','MP')
			                                                            and  EffectiveToTimeKey=49999 
	   
                      Group By CreatedBy))  
           BEGIN  
        SET @Result=-1  
        ROLLBACK TRAN
        RETURN @Result  
        --select createdby,* from DimBranch_Mod  
          END  
  ELSE
  BEGIN
    SET @ApprovedBy    = @CrModApBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE CalypsoAccountLevelMOC_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedByFirstLevel  =@ApprovedBy  
     ,DateApprovedFirstLevel =@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      --AND AccountID=@AccountID  
	  AND  AccountEntityID =@AccountEntityID
      AND AuthorisationStatus in('NP','MP','DP','RM')   
  

  
				IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey)
				AND   AccountEntityID =@AccountEntityID AND MOCType_Flag='ACCT')
				BEGIN
					UPDATE CalypsoInvMOC_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND   AccountEntityID =@AccountEntityID
							 AND MOCType_Flag='ACCT'
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END

				
				IF EXISTS(SELECT 1 FROM CalypsoDervMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey)
				AND   AccountEntityID =@AccountEntityID AND MOCType_Flag='ACCT')
				BEGIN
					UPDATE CalypsoDervMOC_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND   AccountEntityID =@AccountEntityID
							 AND MOCType_Flag='ACCT'
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
---------------Added for Rejection Pop Up Screen  29/06/2020   ----------  
   
  END   
  END

 ELSE IF @OperationFlag=18  
 BEGIN  
  PRINT 18  
  SET @ApprovedBy=@CrModApBy  
  SET @DateApproved=GETDATE()  
  UPDATE CalypsoAccountLevelMOC_Mod  
  SET AuthorisationStatus='RM'  
  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  AND AuthorisationStatus IN('NP','MP','DP','RM')  
  --AND AccountID=@AccountID
  AND  AccountEntityID =@AccountEntityID

  
 END  
  
 ELSE IF @OperationFlag=16  
  
  BEGIN  
  
  IF (@CrModApBy =(Select CreatedBy from CalypsoAccountLevelMOC_Mod   
   
                           where AuthorisationStatus IN ('NP','MP') 
									    and CreatedBy=@CrModApBy
				                        --And AccountID=@AccountID 
										AND  AccountEntityID =@AccountEntityID
			                            and  EffectiveToTimeKey=49999    
             Group By CreatedBy))  
    BEGIN  
        SET @Result=-1  
        ROLLBACK TRAN
        RETURN @Result  
        --select * from DimBranch_Mod  
    END  
  ELSE
  BEGIN
  
  SET @ApprovedBy    = @CrModApBy   
  SET @DateApproved  = GETDATE()  
print 111111111  

  
  UPDATE CalypsoAccountLevelMOC_Mod  
      SET AuthorisationStatus ='1A'  
       ,ApprovedByFirstLevel=@ApprovedBy  
       ,DateApprovedFirstLevel=@DateApproved  
       WHERE    AccountEntityID =@AccountEntityID 
       AND AuthorisationStatus in('NP','MP','DP','RM')  
  
    
  END  
  END

 
ELSE IF @OperationFlag=20 OR @AuthMode='N'
	BEGIN  
  
			IF @CrModApBy= (select UserLoginID from DimUserInfo where IsChecker2='N' 
			 and EffectiveToTimeKey=49999 and UserLoginID=@CrModApBy group by UserLoginID)  
				BEGIN  
						SET @Result=-1  
						ROLLBACK TRAN
						RETURN @Result  
          
				END  
  
		IF (@CrModApBy =(Select CreatedBy from CalypsoAccountLevelMOC_Mod where AuthorisationStatus IN ('1A') and CreatedBy=@CrModApBy
                                                                  AND  AccountEntityID =@AccountEntityID
									                                and   EffectiveToTimeKey=49999 
                          --AND CreatedBy in (select createdby from DimUserInfo where  IsChecker='N')    
				Group By CreatedBy))  
				BEGIN  
					SET @Result=-1  
					ROLLBACK TRAN
					RETURN @Result  
					--select * from DimBranch_Mod  
				END  
	
		ELSE
				BEGIN
					 IF (@CrModApBy =(Select ApprovedBy from CalypsoAccountLevelMOC_Mod 
										  where AuthorisationStatus IN ('1A') and ApprovedBy=@CrModApBy
												AND  AccountEntityID =@AccountEntityID 
												and   EffectiveToTimeKey=49999 
												Group By ApprovedBy))
						BEGIN
								SET @Result=-1
								ROLLBACK TRAN
								RETURN @Result
								
						END

					ELSE 
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
														FROM CalypsoInvMOC_ChangeDetails
														WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )
															--AND AccountID=@AccountID
																AND  AccountEntityID =@AccountEntityID

														SET @ApprovedBy = @CrModApBy			
														SET @DateApproved=GETDATE()
													END
										END
							---set parameters and UPDATE mod table in case maker checker enabled
								IF @AuthMode='Y'
									BEGIN
										Print 'Bbbbbb'
										DECLARE @DelStatus CHAR(2)
										DECLARE @CurrRecordFromTimeKey smallint=0

										SELECT @ExEntityKey= MAX(EntityKey) FROM CalypsoAccountLevelMOC_Mod 
											WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
												--AND AccountID=@AccountID
												AND  AccountEntityID =@AccountEntityID
												AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

										SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
											,@ModifiedBy=ModifyBy, @DateModified=DateModified,
											@ApprovedByFirstLevel=ApprovedByFirstLevel,
											@DateApprovedFirstLevel=DateApprovedFirstLevel
										 FROM CalypsoAccountLevelMOC_Mod
											WHERE EntityKey=@ExEntityKey
					
										SET @ApprovedBy = @CrModApBy			
										SET @DateApproved=GETDATE()
				
										DECLARE @CurEntityKey INT=0

			
										SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
											 FROM DBO.CalypsoAccountLevelMOC_Mod
												WHERE EntityKey=@ExEntityKey

			
										UPDATE DBO.CalypsoAccountLevelMOC_Mod
											SET  EffectiveToTimeKey =EffectiveFromTimeKey-1
											WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											--AND AccountID=@AccountID
											AND  AccountEntityID =@AccountEntityID
											AND AuthorisationStatus='A'	
											--AND EntityKey=@ExEntityKey

							-------DELETE RECORD AUTHORISE
										IF @DelStatus='DP' 
											BEGIN	
												UPDATE DBO.CalypsoAccountLevelMOC_Mod
												SET AuthorisationStatus ='A'
													,ApprovedBy=@ApprovedBy
													,DateApproved=@DateApproved
													,EffectiveToTimeKey =@EffectiveFromTimeKey -1
												WHERE   AccountEntityID =@AccountEntityID
													AND AuthorisationStatus in('NP','MP','DP','RM','1A')
						
												IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
																AND AccountEntityID=@AccountID AND MOCType_Flag='ACCT')
													BEGIN
															UPDATE CalypsoInvMOC_ChangeDetails
																SET AuthorisationStatus ='A'
																	,ModifiedBy=@ModifiedBy 
																	,DateModified=@DateModified
																	,ApprovedBy=@ApprovedBy
																	,DateApproved=@DateApproved
																	,EffectiveToTimeKey =@EffectiveFromTimeKey-1
																WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
																		AND  AccountEntityID =@AccountEntityID
																			AND MOCType_Flag='ACCT'

								
													END
											
								END-- END OF DELETE BLOCK

							ELSE  -- OTHER THAN DELETE STATUS
								BEGIN
									  Print '@DelStatus'
									  Print  @DelStatus
									   Print '@AuthMode'
									  Print  @AuthMode

										UPDATE CalypsoAccountLevelMOC_Mod
											SET AuthorisationStatus ='A'
												,ApprovedBy=@ApprovedBy
												,DateApproved=@DateApproved
									
											WHERE   AccountEntityID =@AccountEntityID				
												AND AuthorisationStatus in('NP','MP','RM','1A')
								END	
								
								END
						END

				END--Sachin

		IF @DelStatus <>'DP' OR @AuthMode ='N'
			BEGIN
				     PRINT 'Check'
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020


						UPDATE CalypsoAccountLevelMOC_Mod
									SET 
									    AuthorisationStatus='A'										
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND  AccountEntityID=@AccountEntityID
											AND AuthorisationStatus IN('1A')

						UPDATE CalypsoInvMOC_ChangeDetails
									SET EffectiveToTimeKey =@EffectiveFromTimeKey-1,
									    AuthorisationStatus='A'
										,ApprovedBy=@CrModApBy
										,DateApproved=GETDATE()
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND  AccountEntityID=@AccountEntityID
											AND MOCType_Flag='ACCT'


						PRINT 'CHECK1'
						IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND  AccountEntityID=@AccountEntityID AND MOCType_Flag='ACCT')
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'
								IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND  AccountEntityID=@AccountEntityID AND MOCType_Flag='ACCT' and EffectiveFromTimeKey=@TimeKey)
									BEGIN
											PRINT 'BBBB'
											--PRINT '@UCIF_ID'
											--PRINT @UCIF_ID
									
											UPDATE CalypsoInvMOC_ChangeDetails SET
												 PrincOutStd= CASE WHEN @POS IS NULL THEN PrincOutStd  ELSE @POS END 						
												---,unserviedint=CASE WHEN @InterestReceivable IS NULL THEN unserviedint ELSE @InterestReceivable END      
												--,FLGFITL  =CASE WHEN @FITLFlagAlt_Key IS NULL THEN FLGFITL ELSE @FITLFlagAlt_Key END     
												--,DFVAmt=CASE WHEN @DFVAmount  IS NULL THEN DFVAmt ELSE @DFVAmount END     
												  
												--,FlgRestructure=CASE WHEN @RestructureFlagAlt_Key IS NULL THEN FlgRestructure  ELSE @RestructureFlagAlt_Key END  
												--,RestructureDate=CASE WHEN @RestructureDate IS NULL THEN RestructureDate  ELSE @RestructureDate END    
												--,TwoAmount=CASE WHEN @TwoAmount IS NULL THEN TwoAmount ELSE @TwoAmount  END     
												--,TwoDate=CASE WHEN @TwoDate  IS NULL THEN TwoDate ELSE @TwoDate END      
												,BookValue=CASE WHEN @BookValue  IS NULL THEN BookValue ELSE @BookValue END
												,SMADate=CASE WHEN @SMADate  IS NULL THEN SMADate ELSE @SMADate END
												,SMASubAssetClassValue =CASE WHEN @SMASubAssetClassValue   IS NULL THEN SMASubAssetClassValue  ELSE @SMASubAssetClassValue  END   
												 
												,AddlProvAbs=CASE WHEN @AdditionalProvisionAbsolute IS NULL THEN AddlProvAbs ELSE @AdditionalProvisionAbsolute END  
												,MOC_Reason=@MOCReason_1         
												--,FlgFraud=CASE WHEN @FraudAccountFlagAlt_Key IS NULL THEN FlgFraud ELSE @FraudAccountFlagAlt_Key END  
												--,FraudDate=CASE WHEN @FraudDate IS NULL THEN FraudDate ELSE @FraudDate END      
												--,A.=@ScreenFlag        
												--,A.=@MOCSource         
												--,FlgMoc ='Y'  
												,MOC_Date=@MOC_Date
												--,MOC_ExpireDate=CASE WHEN @MOC_ExpireDate IS NULL THEN MOC_ExpireDate  ELSE @MOC_ExpireDate END 
												,ApprovedByFirstLevel=@ApprovedByFirstLevel
												,DateApprovedFirstLevel=@DateApprovedFirstLevel
												--,ChangeType                 =CASE WHEN @ChangeTypeAlt_Key=1 THEN 'Auto' else 'Manual' end 
												,ModifiedBy					= @ModifiedBy 
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												--,AddlProvPer                =@AddlProvisionPer
												,MOCType_Flag               ='ACCT'
												,CustomerEntityID            =@CustomerEntityID
--												,TwoFlag=Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
												,MOCProcessed='N'
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND  AccountEntityID=@AccountEntityID
												AND MOCType_Flag='ACCT'
									

            --                                  UPDATE CalypsoInvMOC_ChangeDetails
											 -- set FraudDate=CASE WHEN FlgFraud='N' THEN NULL ELSE @FraudDate END
											 --     ,RestructureDate=CASE WHEN RestructureDate ='N'THEN NULL  ELSE @RestructureDate END
												--  ,TwoDate=CASE WHEN TwoDate='N' THEN NULL ELSE @TwoDate END  
											
												  
											 --  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												--AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND  AccountEntityID=@AccountEntityID
												--AND MOCType_Flag='ACCT'

									END	

								ELSE
									BEGIN
										SET @IsSCD2='Y'
										UPDATE CALYPSODERVMOC_CHANGEDETAILS SET
												 PrincOutStd= CASE WHEN @POS IS NULL THEN PrincOutStd  ELSE @POS END 						
												---,unserviedint=CASE WHEN @InterestReceivable IS NULL THEN unserviedint ELSE @InterestReceivable END      
												--,FLGFITL  =CASE WHEN @FITLFlagAlt_Key IS NULL THEN FLGFITL ELSE @FITLFlagAlt_Key END     
												--,DFVAmt=CASE WHEN @DFVAmount  IS NULL THEN DFVAmt ELSE @DFVAmount END     
												  
												--,FlgRestructure=CASE WHEN @RestructureFlagAlt_Key IS NULL THEN FlgRestructure  ELSE @RestructureFlagAlt_Key END  
												--,RestructureDate=CASE WHEN @RestructureDate IS NULL THEN RestructureDate  ELSE @RestructureDate END    
												--,TwoAmount=CASE WHEN @TwoAmount IS NULL THEN TwoAmount ELSE @TwoAmount  END     
												--,TwoDate=CASE WHEN @TwoDate  IS NULL THEN TwoDate ELSE @TwoDate END      
												,BookValue=CASE WHEN @BookValue  IS NULL THEN BookValue ELSE @BookValue END
												,SMADate=CASE WHEN @SMADate  IS NULL THEN SMADate ELSE @SMADate END
												,SMASubAssetClassValue =CASE WHEN @SMASubAssetClassValue   IS NULL THEN SMASubAssetClassValue  ELSE @SMASubAssetClassValue  END   
												 
												,AddlProvAbs=CASE WHEN @AdditionalProvisionAbsolute IS NULL THEN AddlProvAbs ELSE @AdditionalProvisionAbsolute END  
												,MOC_Reason=@MOCReason_1         
												--,FlgFraud=CASE WHEN @FraudAccountFlagAlt_Key IS NULL THEN FlgFraud ELSE @FraudAccountFlagAlt_Key END  
												--,FraudDate=CASE WHEN @FraudDate IS NULL THEN FraudDate ELSE @FraudDate END      
												--,A.=@ScreenFlag        
												--,A.=@MOCSource         
												--,FlgMoc ='Y'  
												,MOC_Date=@MOC_Date
												--,MOC_ExpireDate=CASE WHEN @MOC_ExpireDate IS NULL THEN MOC_ExpireDate  ELSE @MOC_ExpireDate END 
												,ApprovedByFirstLevel=@ApprovedByFirstLevel
												,DateApprovedFirstLevel=@DateApprovedFirstLevel
												--,ChangeType                 =CASE WHEN @ChangeTypeAlt_Key=1 THEN 'Auto' else 'Manual' end 
												,ModifiedBy					= @ModifiedBy 
												,DateModified				= @DateModified
												,ApprovedBy					= CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END
												,DateApproved				= CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END
												,AuthorisationStatus		= CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END
												--,AddlProvPer                =@AddlProvisionPer
												,MOCType_Flag               ='ACCT'
												,CustomerEntityID            =@CustomerEntityID
--												,TwoFlag=Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
												,MOCProcessed='N'
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND  AccountEntityID=@AccountEntityID
												AND MOCType_Flag='ACCT'
									END
								END
							END
			IF @IsAvailable='N' OR @IsSCD2='Y'
				BEGIN
					print 'check11111'
					IF EXISTS(SELECT 1 FROM CalypsoAccountLevelMOC_Mod a 
					iNNER JOIN		InvestmentBasicDetail B 
					on				a.aCCOUNTID = B.iNVid 
					AND				A.AccountEntityID = B.InvEntityId
					 WHERE			(a.EffectiveFromTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)
									and (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 									
									AND  AccountEntityID=@AccountEntityID AND aCCOUNTID = @aCCOUNTID )
							BEGIN
						INSERT INTO CalypsoInvMOC_ChangeDetails    
						(   
								AccountEntityID       
								,AddlProvAbs 
								,FlgFraud      
								,FraudDate
								,PrincOutStd          
								,unserviedint       
								,FLGFITL         
								,DFVAmt           
								,MOC_Reason         
								,MOC_Source                  
								,MOC_Date  
								,MOC_By     
								,AuthorisationStatus   
								,EffectiveFromTimeKey  
								,EffectiveToTimeKey  
								,CreatedBy  
								,DateCreated  
								,ModifiedBy  
								,DateModified  
								,ApprovedBy  
								,DateApproved  
								,MOCType_Flag
								,TwoAmount	
								,TwoDate
								,BookValue                            
								,SMADate                               
								,SMASubAssetClassValue 
								,CustomerEntityID
								,ApprovedByFirstLevel
								,DateApprovedFirstLevel
								,TwoFlag
								,MOCProcessed
							)   
						VALUES  
							(   
  
									@AccountEntityID       
									,@AdditionalProvisionAbsolute           
									,@FraudAccountFlagAlt_Key       
									,@FraudDate
									,@POS
									,@InterestReceivable
									,@FITLFlagAlt_Key
									,@DFVAmount
									,@MOCReason_1          
									,@MOCSource                  
									,Convert(Varchar(20),@MOC_Date,103)  
									,@CrModApBy
									,@AuthorisationStatus  
									,@EffectiveFromTimeKey  
									,@EffectiveToTimeKey   
									,@CreatedBy  
									,@DateCreated  
									,@ModifiedBy   
									,@DateModified   
									,@ApprovedBy     
									,@DateApproved   										  
									,'ACCT'
									,@TwoAmount				
									,@TwoDate
									,@BookValue                            
									,@SMADate                               
									,@SMASubAssetClassValue  
									,@CustomerEntityID
									,@ApprovedByFirstLevel
									,@DateApprovedFirstLevel
									,Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
									,'N'
								)  
						 print 'check111'
						 IF @IsSCD2='Y' 
								BEGIN
									UPDATE CALYPSOINVMOC_CHANGEDETAILS SET
											EffectiveToTimeKey=@EffectiveFromTimeKey-1
											,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
										WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)
										AND  AccountEntityID =@AccountEntityID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
											AND MOCType_Flag='ACCT'
								END
								END
								ELSE
								begin
								INSERT INTO CalypsoDervMOC_ChangeDetails    
						(   
								AccountEntityID       
								,AddlProvAbs 
								,FlgFraud      
								,FraudDate
								,PrincOutStd          
								,unserviedint       
								,FLGFITL         
								,DFVAmt           
								,MOC_Reason         
								,MOC_Source                  
								,MOC_Date  
								,MOC_By     
								,AuthorisationStatus   
								,EffectiveFromTimeKey  
								,EffectiveToTimeKey  
								,CreatedBy  
								,DateCreated  
								,ModifiedBy  
								,DateModified  
								,ApprovedBy  
								,DateApproved  
								,MOCType_Flag
								,TwoAmount	
								,TwoDate
								,BookValue                            
								,SMADate                               
								,SMASubAssetClassValue 
								,CustomerEntityID
								,ApprovedByFirstLevel
								,DateApprovedFirstLevel
								,TwoFlag
								,MOCProcessed
							)   
						VALUES  
							(   
  
									@AccountEntityID       
									,@AdditionalProvisionAbsolute           
									,@FraudAccountFlagAlt_Key       
									,@FraudDate
									,@POS
									,@InterestReceivable
									,@FITLFlagAlt_Key
									,@DFVAmount
									,@MOCReason_1          
									,@MOCSource                  
									,Convert(Varchar(20),@MOC_Date,103)  
									,@CrModApBy
									,@AuthorisationStatus  
									,@EffectiveFromTimeKey  
									,@EffectiveToTimeKey   
									,@CreatedBy  
									,@DateCreated  
									,@ModifiedBy   
									,@DateModified   
									,@ApprovedBy     
									,@DateApproved   										  
									,'ACCT'
									,@TwoAmount				
									,@TwoDate
									,@BookValue                            
									,@SMADate                               
									,@SMASubAssetClassValue  
									,@CustomerEntityID
									,@ApprovedByFirstLevel
									,@DateApprovedFirstLevel
									,Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
									,'N'
								)  
						 print 'check111'
						 IF @IsSCD2='Y' 
								BEGIN
									UPDATE CalypsoDervMOC_ChangeDetails SET
											EffectiveToTimeKey=@EffectiveFromTimeKey-1
											,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
										WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)
										AND  AccountEntityID =@AccountEntityID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
											AND MOCType_Flag='ACCT'
								END
								end
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
 print 'aaaaa'
   INSERT INTO CalypsoAccountLevelMOC_Mod    
           (   
              AccountID         
    ,AccountEntityID       
             ,AdditionalProvisionAbsolute 
			,FraudAccountFlag       
			,FraudDate
			 ,RestructureFlag       
			 ,RestructureDate 
			,RePossessionFlag
			,RePossessionDate
			,InherentWeaknessFlag
			,InherentWeaknessDate
			,SARFAESIFlag
            ,SARFAESIDate
             
             ,POS      
			 ,InterestReceivable       
      
				,FITLFlag         
				,DFVAmount           
                  
   
             ,MOCReason         
                  
             ,ScreenFlag 
             ,MOCSource                  
            ,MOCDate  
            --,MOCBy     
            ,AuthorisationStatus   
            ,EffectiveFromTimeKey  
            ,EffectiveToTimeKey  
            ,CreatedBy  
            ,DateCreated  
            ,ModifyBy  
            ,DateModified  
            ,ApprovedBy  
            ,DateApproved  
            ,Changefield  
			
			,MOC_TYPEFLAG
			,TwoAmount
			,TwoDate
			,BookValue                            
,SMADate                               
,SMASubAssetClassValue 
			,FlgTwo
			
           )  
        VALUES  
           (   
  
             @AccountID         
             ,@AccountEntityID       
             ,@AdditionalProvisionAbsolute           
             ,@FraudAccountFlagAlt_Key       
             ,@FraudDate
		     ,@RestructureFlagAlt_Key
			 ,@RestructureDate 
			 ,@RePossessionFlagAlt_Key
			 ,@RePossessionDate
			 ,@InherentWeaknessFlagAlt_Key 
			 ,@InherentWeaknessDate
			 ,@SARFAESIFlagAlt_Key
			 ,@SARFAESIDate
			 ,@POS
			 ,@InterestReceivable
			 ,@FITLFlagAlt_Key
			 ,@DFVAmount
			 
              ,@MOCReason_1          
                     
             ,'S'         
             ,@MOCSource                   
               ,Convert(Varchar(20),@MOC_Date,103)  
              -- ,@CreatedBy    
               ,@AuthorisationStatus  
               ,@EffectiveFromTimeKey  
               ,@EffectiveToTimeKey   
               ,@CreatedBy  
               ,@DateCreated  
               ,@ModifiedBy   
               ,@DateModified   
               ,@ApprovedBy     
               ,@DateApproved   
               ,@AccountNPAMOC_ChangeFields  
            

			   ,'ACCT'
			    ,@TwoAmount				
				,@TwoDate
				,@BookValue                            
,@SMADate                               
,@SMASubAssetClassValue  
				,Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
				
           )  --Sachin     
             
                    PRINT 'Sachin'  
           IF @OperationFlag =1 AND @AUTHMODE='Y'  
     BEGIN  
      PRINT 3  
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


PRINT 7  
  COMMIT TRANSACTION  
  
  --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM CustomerLevelMOC WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
  --               AND GLAlt_Key=@GLAlt_Key  
  
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
	PRINT 'ERRR............'  
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