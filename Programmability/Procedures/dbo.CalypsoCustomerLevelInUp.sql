SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE PROC [dbo].[CalypsoCustomerLevelInUp]  
  
--Declare  
                        @UCICID				varchar(30)=''
					   ,@CustomerName				varchar(100)=''
					   ,@AssetClassAlt_Key			int=0
					   ,@NPADate					Varchar(20)=NULL
					   ,@SecurityValue				varchar(50)=''
					   ,@AdditionalProvision		Decimal(18,2)=''
					   --,@FraudAccountFlagAlt_Key	Int=0
					   --,@FraudDate					Date
					   ,@MocTypeAlt_Key				Int=0
					   ,@MOCReason					Varchar(100)=''
					   ,@MOCSourceAltkey			Int=0
					   ,@ScreenFlag					varchar(1)='S'
						
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
						,@CustomerNPAMOC_ChangeFields varchar(50)	=''
						
AS    
  
BEGIN  
 SET NOCOUNT ON;  
  PRINT 1  
   
  SET DATEFORMAT DMY  
 
 
 ---Priyali----

 IF @Result = -1
	return -1


	declare @MocTypeDesc varchar(20)
						--select @MocTypeDesc =MOCTypeName from DimMOCType where MOCTypeAlt_Key=@MocTypeAlt_Key
						-- AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
                         select @MocTypeDesc =ParameterName from dimparameter 
						   where Dimparametername= 'MocType' 
                                          and ParameterAlt_Key=@MocTypeAlt_Key
                                         AND EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey

	set @NPADate = case when (@NPADate='' or  @NPADate='01/01/1900') then null else @NPADate end


 				DECLARE @Parameter1 varchar(max) = (select 'UCICID|' + ISNULL(@UCICID,' ') + '}'+ 'CustomerName|' + isnull(@CustomerName,' ')
	+ '}'+ 'AssetClassAlt_Key_Pos|'+convert(varchar,isnull(@AssetClassAlt_Key,''))+ '}'+ 'NPADate_Pos|'+isnull(@NPADate,'')+ '}'+ 'SecurityValue_Pos|'+isnull(@SecurityValue,'')
	+ '}'+ 'AdditionalProvision_Pos|'+convert(varchar,isnull(@AdditionalProvision,'0'))+ '} '+'MOCTypeAlt_Key|'+convert(varchar,isnull(@MocTypeAlt_Key,''))+ '}'+ 'MOCReason|'+isnull(@MOCReason,'')
	+ '}'+ 'MOCSourceAltKey|'+convert(varchar,isnull(@MOCSourceAltkey,'')))
  
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
   
    SET @ScreenName = 'CalypsoCustomerLevel'  
 -------------------------------------------------------------  
  

 
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

	--Declare @CustomerId  Varchar(max)
	--Select  @CustomerId= (select RefIssuerID  from InvestmentBasicDetail
	--where RefIssuerId=@UCICID   and   EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey
	--UNION
	--select CustomerId from curdat.DerivativeDetail
	--where UCIC_ID =@UCICID  and   EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)

		IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey) 
		AND UCICID =@UCICID AND MOCType_Flag='CUST' AND MOCProcessed='N')
										Begin
										SET @Result=6
										RETURN @Result
										End


		IF EXISTS(SELECT 1 FROM CalypsoDervMOC_ChangeDetails WHERE (EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey) 
		AND UCICID =@UCICID AND MOCType_Flag='CUST' AND MOCProcessed='N')
										Begin
										SET @Result=6
										RETURN @Result
										End
										

	--	Declare @CustomerEntityID int
	--Select  @CustomerEntityID= IssuerEntityId from InvestmentBasicDetail
	--                          where  InvID=@AccountID
							

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
		--					SET EffectiveToTimeKey >= @Timekey-1
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
							AND  UCICID =@UCICID)
							BEGIN
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM	[dbo].CalypsoInvMOC_ChangeDetails
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)							 
							AND  UCICID =@UCICID
						END
						ELSE
						BEGIN
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM	[dbo].CalypsoDervMOC_ChangeDetails
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							   
							AND  UCICID =@UCICID
						END



					---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE
				IF ISNULL(@CreatedBy,'')=''
				BEGIN
					PRINT 'NOT AVAILABLE IN MAIN'
					SELECT  @CreatedBy		= CreatedBy
							,@DateCreated	= DateCreated 
					FROM	[dbo].CalypsoCustomerLevelMOC_Mod 
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND UCIFID =@UCICID 					
							AND AuthorisationStatus IN('NP','MP','A','RM')
				END
				ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE
					BEGIN
					       Print 'AVAILABLE IN MAIN'
						----UPDATE FLAG IN MAIN TABLES AS MP
						IF EXISTS (select count(1) FROM	[dbo].CalypsoInvMOC_ChangeDetails
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND  UCICID =@UCICID)

							BEGIN
								UPDATE [dbo].CalypsoInvMOC_ChangeDetails
								SET AuthorisationStatus=@AuthorisationStatus
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND  UCICID =@UCICID
							END
							ELSE
							BEGIN
								UPDATE [dbo].CalypsoDervMOC_ChangeDetails
								SET AuthorisationStatus=@AuthorisationStatus
								WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND  UCICID =@UCICID
							END
					END
					--UPDATE NP,MP  STATUS 
					IF @OperationFlag=2
					BEGIN	
					IF EXISTS (select count(1) FROM	[dbo].CalypsoInvMOC_ChangeDetails
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							 
							AND  UCICID =@UCICID)
							BEGIN
					UPDATE [dbo].CalypsoInvMOC_ChangeDetails
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND  UCICID =@UCICID
							END
							ELSE
							BEGIN
							UPDATE [dbo].CalypsoDervMOC_ChangeDetails
							SET AuthorisationStatus=@AuthorisationStatus
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								 AND  UCICID =@UCICID
							END

						UPDATE CalypsoCustomerLevelMOC_Mod
							SET AuthorisationStatus='FM'
							,ModifyBy=@ModifiedBy
							,DateModified=@DateModified
						WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
								AND  UCIFID =@UCICID
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
  
     IF (@CrModApBy =(Select CreatedBy from CalypsoCustomerLevelMOC_Mod  where  CreatedBy=@CrModApBy  AND  UCIFID =@UCICID
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
        IF (@CrModApBy =(Select ApprovedByFirstLevel from CalypsoCustomerLevelMOC_Mod where  ApprovedByFirstLevel=@CrModApBy  AND  UCIFID =@UCICID
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
  
    UPDATE CalypsoCustomerLevelMOC_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      --AND AccountID=@AccountID  
	  AND  UCIFID =@UCICID
      AND AuthorisationStatus in('NP','MP','DP','RM','1A') 

	  	UPDATE A
		   SET A.AuthorisationStatus='R'
		   ,A.ApprovedBy	=@ApprovedBy
		   ,EffectiveToTimeKey =@EffectiveFromTimeKey-1
		   FROM	ExcelUploadHistory  A 
		   INNER JOIN CalypsoCustomerLevelMOC_Mod B
		   ON A.UniqueUploadID = B.UploadID		   		  
		   where  UCIFID =@UCICID and B.UploadID is not NULL
       AND	A.AuthorisationStatus in('NP','MP','DP','RM','1A')    and B.EffectiveToTimekey = 49999
	  
	  	IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                            AND   UCICID =@UCICID AND MOCType_Flag='CUST')
				BEGIN
					UPDATE CalypsoInvMOC_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND   UCICID =@UCICID
							 AND MOCType_Flag='CUST'
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END

				 
	  	IF EXISTS(SELECT 1 FROM CalypsoDervMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                            AND   UCICID =@UCICID AND MOCType_Flag='CUST')
				BEGIN
					UPDATE CalypsoDervMOC_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND  UCICID =@UCICID
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
  
     IF (@CrModApBy =(Select CreatedBy from CalypsoCustomerLevelMOC_Mod where  CreatedBy=@CrModApBy AND UCIFID =@UCICID
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
  
    UPDATE CalypsoCustomerLevelMOC_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedByFirstLevel  =@ApprovedBy  
     ,DateApprovedFirstLevel =@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      --AND AccountID=@AccountID  
	  AND  UCIFID =@UCICID
      AND AuthorisationStatus in('NP','MP','DP','RM')   
  
  	UPDATE A
		   SET A.AuthorisationStatus='R'
		   ,A.ApprovedBy	=@ApprovedBy
		   ,EffectiveToTimeKey =@EffectiveFromTimeKey-1
		   FROM	ExcelUploadHistory  A 
		   INNER JOIN CalypsoCustomerLevelMOC_Mod B
		   ON A.UniqueUploadID = B.UploadID		   		  
		   where  UCIFID =@UCICID and B.UploadID is not NULL
       AND	A.AuthorisationStatus in('NP','MP','DP','RM')   and B.EffectiveToTimekey = 49999
  
				IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey)
				AND   UCICID =@UCICID AND MOCType_Flag='CUST')
				BEGIN
					UPDATE CalypsoInvMOC_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND   UCICID =@UCICID
							 AND MOCType_Flag='CUST'
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END

				
				IF EXISTS(SELECT 1 FROM CalypsoDervMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey)
				AND   UCICID =@UCICID AND MOCType_Flag='CUST')
				BEGIN
					UPDATE CalypsoDervMOC_ChangeDetails
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND   UCICID =@UCICID
							 AND MOCType_Flag='CUST'
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
  UPDATE CalypsoCustomerLevelMOC_Mod   
  SET AuthorisationStatus='RM'  
  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  AND AuthorisationStatus IN('NP','MP','DP','RM')  
  --AND AccountID=@AccountID
  AND  UCIFID =@UCICID


  UPDATE A
		   SET A.AuthorisationStatus='RM'
		   ,A.ApprovedBy	=@ApprovedBy
		   ,EffectiveToTimeKey =@EffectiveFromTimeKey-1
		   FROM	ExcelUploadHistory  A 
		   INNER JOIN CalypsoCustomerLevelMOC_Mod B
		   ON A.UniqueUploadID = B.UploadID		   		  
		   where  UCIFID =@UCICID and B.UploadID is not NULL
       AND	A.AuthorisationStatus IN('NP','MP','DP','RM')  and B.EffectiveToTimekey = 49999
  
 END  
  
 ELSE IF @OperationFlag=16  
  
  BEGIN  
  
  IF (@CrModApBy =(Select CreatedBy from CalypsocustomerLevelMOC_Mod   
   
                           where AuthorisationStatus IN ('NP','MP') 
									    and CreatedBy=@CrModApBy
				                        --And AccountID=@AccountID 
										AND  UCIFID =@UCICID
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


  
  UPDATE CalypsoCustomerLevelMOC_Mod  
      SET AuthorisationStatus ='1A'  
       ,ApprovedByFirstLevel=@ApprovedBy  
       ,DateApprovedFirstLevel=@DateApproved  
       WHERE    UCIFID =@UCICID
       AND AuthorisationStatus in('NP','MP','DP','RM')  

	    UPDATE A
		   SET A.AuthorisationStatus='1A'
		   ,A.ApprovedBy	=@ApprovedBy
		   FROM	ExcelUploadHistory  A 
		   INNER JOIN CalypsoCustomerLevelMOC_Mod B
		   ON A.UniqueUploadID = B.UploadID		   		  
		   where  UCIFID =@UCICID and B.UploadID is not NULL
       AND	A.AuthorisationStatus in('NP','MP','DP','RM')  and B.EffectiveToTimekey = 49999

	  
		

  
    
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
  
		IF (@CrModApBy =(Select CreatedBy from CalypsoCustomerLevelMOC_Mod where AuthorisationStatus IN ('1A') and CreatedBy=@CrModApBy
                                                                  AND  UCIFID =@UCICID
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
					 IF (@CrModApBy =(Select ApprovedBy from CalypsoCustomerLevelMOC_Mod 
										  where AuthorisationStatus IN ('1A') and ApprovedBy=@CrModApBy
												AND  UCIFID =@UCICID
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
																AND  UCICID =@UCICID

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

										SELECT @ExEntityKey= MAX(Entity_Key) FROM CalypsoCustomerLevelMOC_Mod 
											WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey) 
												--AND AccountID=@AccountID
												AND  UCIFID =@UCICID
												AND AuthorisationStatus IN('NP','MP','DP','RM','1A')	

										SELECT	@DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated
											,@ModifiedBy=ModifyBy, @DateModified=DateModified,
											@ApprovedByFirstLevel=ApprovedByFirstLevel,
											@DateApprovedFirstLevel=DateApprovedFirstLevel
										 FROM CalypsoCustomerLevelMOC_Mod
											WHERE Entity_Key=@ExEntityKey
					
										SET @ApprovedBy = @CrModApBy			
										SET @DateApproved=GETDATE()
				
										DECLARE @CurEntityKey INT=0

			
										SELECT	@CurrRecordFromTimeKey=EffectiveFromTimeKey 
											 FROM DBO.CalypsoCustomerLevelMOC_Mod
												WHERE Entity_Key=@ExEntityKey

			
										UPDATE DBO.CalypsoCustomerLevelMOC_Mod
											SET  EffectiveToTimeKey =EffectiveFromTimeKey-1
											WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											--AND AccountID=@AccountID
											AND  UCIFID =@UCICID
											AND AuthorisationStatus='A'	
											--AND EntityKey=@ExEntityKey

							-------DELETE RECORD AUTHORISE
										IF @DelStatus='DP' 
											BEGIN	
												UPDATE DBO.CalypsoCustomerLevelMOC_Mod
												SET AuthorisationStatus ='A'
													,ApprovedBy=@ApprovedBy
													,DateApproved=@DateApproved
													,EffectiveToTimeKey =@EffectiveFromTimeKey -1
												WHERE   UcifID =@UCICID
													AND AuthorisationStatus in('NP','MP','DP','RM','1A')

													
										UPDATE A
										SET A.AuthorisationStatus='A'
										,A.ApprovedBy	=@ApprovedBy
										,EffectiveToTimeKey =@EffectiveFromTimeKey -1
										FROM	ExcelUploadHistory  A 
										INNER JOIN CalypsoCustomerLevelMOC_Mod B
										ON A.UniqueUploadID = B.UploadID		   		  
										where  UCIFID =@UCICID and B.UploadID is not NULL
										AND	A.AuthorisationStatus in('NP','MP','DP','RM','1A')  and B.EffectiveToTimekey = 49999

						
												IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
																AND UCICID =@UCICID AND MOCType_Flag='CUST')
													BEGIN
															UPDATE CalypsoInvMOC_ChangeDetails
																SET AuthorisationStatus ='A'
																	,ModifiedBy=@ModifiedBy 
																	,DateModified=@DateModified
																	,ApprovedBy=@ApprovedBy
																	,DateApproved=@DateApproved
																	,EffectiveToTimeKey =@EffectiveFromTimeKey-1
																WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
																		AND  UCICID =@UCICID
																			AND MOCType_Flag='CUST'

								
													END

														ELSE 

													BEGIN

																UPDATE CalypsoDervMOC_ChangeDetails
																SET AuthorisationStatus ='A'
																	,ModifiedBy=@ModifiedBy 
																	,DateModified=@DateModified
																	,ApprovedBy=@ApprovedBy
																	,DateApproved=@DateApproved
																	,EffectiveToTimeKey =@EffectiveFromTimeKey-1
																WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
																		AND  UCICID =@UCICID
																			AND MOCType_Flag='CUST'
											 			 END
											END
								END-- END OF DELETE BLOCK

							ELSE  -- OTHER THAN DELETE STATUS
								BEGIN
									  Print '@DelStatus'
									  Print  @DelStatus
									   Print '@AuthMode'
									  Print  @AuthMode

										UPDATE CalypsoCustomerLevelMOC_Mod
											SET AuthorisationStatus ='A'
												,ApprovedBy=@ApprovedBy
												,DateApproved=@DateApproved
									
											WHERE   UcifID =@UCICID			
												AND AuthorisationStatus in('NP','MP','RM','1A')

				UPDATE A
			 SET A.AuthorisationStatus='A'
			,A.ApprovedBy	=@ApprovedBy
			FROM	ExcelUploadHistory  A 
			INNER JOIN CalypsoCustomerLevelMOC_Mod B
			ON A.UniqueUploadID = B.UploadID		   		  
			where  UCIFID =@UCICID and B.UploadID is not NULL
			AND	A.AuthorisationStatus in('NP','MP','RM','1A')  and B.EffectiveToTimekey = 49999
								END		
						END

				END--Sachin

		IF @DelStatus <>'DP' OR @AuthMode ='N'
			BEGIN
				     PRINT 'Check'
						DECLARE @IsAvailable CHAR(1)='N'
						,@IsSCD2 CHAR(1)='N'
								SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020


						UPDATE CalypsoCustomerLevelMOC_Mod
									SET 
									    AuthorisationStatus='A'										
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND  UcifID =@UCICID
											AND AuthorisationStatus IN('1A')

			UPDATE A
		   SET A.AuthorisationStatus='A'
		   ,A.ApprovedBy	=@ApprovedBy
		   FROM	ExcelUploadHistory  A 
		   INNER JOIN CalypsoCustomerLevelMOC_Mod B
		   ON A.UniqueUploadID = B.UploadID		   		  
		   where  UCIFID =@UCICID and B.UploadID is not NULL
       AND	A.AuthorisationStatus in('1A')  and B.EffectiveToTimekey = 49999

						UPDATE CalypsoInvMOC_ChangeDetails
									SET EffectiveToTimeKey =@EffectiveFromTimeKey-1,
									    AuthorisationStatus='A'
										,ApprovedBy=@CrModApBy
										,DateApproved=GETDATE()
									WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)
											AND  UCICID =@UCICID
											AND MOCType_Flag='CUST'


						PRINT 'CHECK1'
						IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND  UCICID =@UCICID AND MOCType_Flag='CUST')
							BEGIN
								SET @IsAvailable='Y'
								--SET @AuthorisationStatus='A'
								IF EXISTS(SELECT 1 FROM CalypsoInvMOC_ChangeDetails WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
									 AND  UCICID =@UCICID AND MOCType_Flag='CUST' and EffectiveFromTimeKey <= @Timekey)
									BEGIN
											PRINT 'BBBB'
											--PRINT '@UCIF_ID'
											--PRINT @UCIF_ID
									
											UPDATE CalypsoInvMOC_ChangeDetails SET
											    ucicid=@UCICID,
												   AssetClassAlt_Key		 =@AssetClassAlt_Key
                                                      , NPA_Date				 =@NPADate
                                               , CurntQtrRv			 =@SecurityValue,
								                AddlProvPer             =@AdditionalProvision
												,MOC_Reason=@MOCReason_1         
												--,FlgFraud=CASE WHEN @FraudAccountFlagAlt_Key IS NULL THEN FlgFraud ELSE @FraudAccountFlagAlt_Key END  
												--,FraudDate=CASE WHEN @FraudDate IS NULL THEN FraudDate ELSE @FraudDate END      
												--,A.=@ScreenFlag        
												--,A.=@MOCSource         
												--,FlgMoc ='Y'  
												,MOC_Date=@MOC_Date
												 , MOC_Source			 =@MOCSourceAltkey
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
												,MOCType_Flag               ='CUST'
												--,CustomerEntityID            =@CustomerID
--												,TwoFlag=Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
												,MOCProcessed='N'
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND  UCICID =@UCICID
												AND MOCType_Flag='CUST'
									

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
										    ucicid=@UCICID,
												AssetClassAlt_Key		 =@AssetClassAlt_Key
                                                      , NPA_Date				 =@NPADate
                                               , CurntQtrRv			 =@SecurityValue,
								                AddlProvPer             =@AdditionalProvision
												,MOC_Reason=@MOCReason_1         
												--,FlgFraud=CASE WHEN @FraudAccountFlagAlt_Key IS NULL THEN FlgFraud ELSE @FraudAccountFlagAlt_Key END  
												--,FraudDate=CASE WHEN @FraudDate IS NULL THEN FraudDate ELSE @FraudDate END      
												--,A.=@ScreenFlag        
												--,A.=@MOCSource         
												--,FlgMoc ='Y'  
												,MOC_Date=@MOC_Date
												 , MOC_Source			 =@MOCSourceAltkey
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
												,MOCType_Flag               ='CUST'
												--,CustomerEntityID            =@CustomerID
--												,TwoFlag=Case When ISNULL(@TwoDate,'')<>'' Then 'Y' Else 'N' End
												,MOCProcessed='N'
											 WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) 
												AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND  UCICID =@UCICID
												AND MOCType_Flag='CUST'
									END
								END
							END
			IF @IsAvailable='N' OR @IsSCD2='Y'
				BEGIN
					print 'check11111'
					IF EXISTS(SELECT 1 FROM CalypsoCustomerLevelMOC_Mod a 
					iNNER JOIN		InvestmentIssuerDetail B 
					on				a.UcifID  = B.UcifId 
					 WHERE			(a.EffectiveFromTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)
									and (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 									
									AND  a.UcifID =@UCICID )
							BEGIN
						INSERT INTO CalypsoInvMOC_ChangeDetails    
									(
									    UCICID,
                                         MOCType_Flag
                                        ,CustomerEntityID
                                        ,AssetClassAlt_Key
                                        ,NPA_Date
                                        ,CurntQtrRv
										,AddlProvPer
                                        ,MOC_Reason
                                        ,MOC_Date
                                        ,MOC_Source
										,MOCProcessed
										,MOCTYPE
                                        ,AuthorisationStatus
                                        ,EffectiveFromTimeKey
                                        ,EffectiveToTimeKey
                                        ,CreatedBy
                                        ,DateCreated
                                        ,ModifiedBy
                                        ,DateModified
                                        ,ApprovedByFirstLevel
                                        ,DateApprovedFirstLevel
                                        ,ApprovedBy
                                        ,DateApproved
										
										
								)
					vALUES

					                 (    
									     @UCICID, 
                                         'CUST'
										,NULL
										,@AssetClassAlt_Key
										,@NPADate
										,@SecurityValue
										,@AdditionalProvision
										
										,@MOCReason_1
										,@MOC_DATE
										,@MOCSourceAltkey
										,'N'
								
										,@MocTypeDesc
										,@AuthorisationStatus  
									,@EffectiveFromTimeKey  
									,@EffectiveToTimeKey   
									,@CreatedBy  
									,@DateCreated  
									,@ModifiedBy   
									,@DateModified 
										,@ApprovedByFirstLevel
										,@DateApprovedFirstLevel  
									,@ApprovedBy     
									,@DateApproved  
									
										
										
)

						 print 'check111'
						 IF @IsSCD2='Y' 
								BEGIN
									UPDATE CALYPSOINVMOC_CHANGEDETAILS SET
											EffectiveToTimeKey=@EffectiveFromTimeKey-1
											,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
										WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)
										AND  UCICID =@UCICID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
											AND MOCType_Flag='CUST'
								END
								END
							
							IF EXISTS(SELECT 1 FROM CalypsoCustomerLevelMOC_Mod a 
					iNNER JOIN		curdat.DerivativeDetail B 
					on				a.UcifID  = B.UCIC_ID 
					 WHERE			(a.EffectiveFromTimeKey<=@TimeKey AND a.EffectiveToTimeKey>=@TimeKey)
									and (B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey) 									
									AND  a.UcifID =@UCICID )
								begin
								INSERT INTO CalypsoDervMOC_ChangeDetails    
														(
														UCICID, 
                                         MOCType_Flag

                                        ,CustomerEntityID
                                        ,AssetClassAlt_Key
                                        ,NPA_Date
                                        ,CurntQtrRv
										,AddlProvPer
                                        ,MOC_Reason
                                        ,MOC_Date
                                        ,MOC_Source
										,MOCProcessed
										,MOCTYPE
                                        ,AuthorisationStatus
                                        ,EffectiveFromTimeKey
                                        ,EffectiveToTimeKey
                                        ,CreatedBy
                                        ,DateCreated
                                        ,ModifiedBy
                                        ,DateModified
                                        ,ApprovedByFirstLevel
                                        ,DateApprovedFirstLevel
                                        ,ApprovedBy
                                        ,DateApproved
										
										
								)
					vALUES

					                 (     
									 @UCICID, 
                                         'CUST'
										,NULL
										,@AssetClassAlt_Key
										,@NPADate
										,@SecurityValue
										,@AdditionalProvision
										
										,@MOCReason_1
										,@MOC_DATE
										,@MOCSourceAltkey
										,'N'
								
										,@MocTypeDesc
										,@AuthorisationStatus  
									,@EffectiveFromTimeKey  
									,@EffectiveToTimeKey   
									,@CreatedBy  
									,@DateCreated  
									,@ModifiedBy   
									,@DateModified 
										,@ApprovedByFirstLevel
										,@DateApprovedFirstLevel  
									,@ApprovedBy     
									,@DateApproved 
)
						 print 'check111'
						 IF @IsSCD2='Y' 
								BEGIN
									UPDATE CalypsoDervMOC_ChangeDetails SET
											EffectiveToTimeKey=@EffectiveFromTimeKey-1
											,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END
										WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)
										AND  UCICID =@UCICID
											AND EffectiveFromTimekey<@EffectiveFromTimeKey
											AND MOCType_Flag='CUST'
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


  INSERT INTO CalypsoCustomerLevelMOC_Mod    
           (   

												UCIFID
												,CustomerEntityID			
												,CustomerName		
												,AssetClassAlt_Key			
												,NPADate			
												,SecurityValue
												,AdditionalProvision
												,MOCReason
												,MOCSourceAltkey
												,MOCDate
												,MOCType
												,ScreenFlag		
											 ,AuthorisationStatus   
            ,EffectiveFromTimeKey  
            ,EffectiveToTimeKey  
            ,CreatedBy  
            ,DateCreated  
            ,ModifyBy  
            ,DateModified  
            ,ApprovedBy  
            ,DateApproved  
												,ChangeField
												
												,MOCType_Flag									
											)
								VALUES
											( 
												 	@UCICID
													,NULL		
												   ,@CustomerName		
												   ,@AssetClassAlt_Key		
												   ,@NPADate			
												   ,@SecurityValue
												   ,@AdditionalProvision
												   ,@MOCReason_1	
												   ,@MOCSourceAltkey
												   ,@MOC_DATE
												  -- ,@MocTypeAlt_Key
												   ,@MocTypeDesc
												   ,@ScreenFlag		
												   ,@AuthorisationStatus  
               ,@EffectiveFromTimeKey  
               ,@EffectiveToTimeKey   
               ,@CreatedBy  
               ,@DateCreated  
               ,@ModifiedBy   
               ,@DateModified   
               ,@ApprovedBy     
               ,@DateApproved
													,@CustomerNPAMOC_ChangeFields
													--,@MOC_ExpireDate
													,'CUST'
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
								@ReferenceID=@UCICID,-- ReferenceID ,
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
								@ReferenceID=@UCICID ,-- ReferenceID ,
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