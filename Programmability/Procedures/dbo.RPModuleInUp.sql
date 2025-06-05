SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

  
CREATE PROC [dbo].[RPModuleInUp]  
  
--Declare  
      @PAN_No  Varchar(20)=''  
      ,@UCIC_ID    Varchar(20) = ''  
      ,@CustomerID   Varchar(20) = ''  
      ,@CustomerName   Varchar(100) = ''  
      ,@BankingArrangementAlt_Key int=0  
      ,@BorrowerDefaultDate Varchar(20)=NUll  
      ,@LeadBankAlt_Key int=0  
      ,@DefaultStatusAlt_Key Varchar(20)=''  
      ,@ExposureBucketAlt_Key int=0  
      ,@ReferenceDate Varchar(20)=NUll  
      ,@ReviewExpiryDate Varchar(20)=NUll  
      ,@RP_ApprovalDate Varchar(20)=NUll  
      ,@RPNatureAlt_Key int=0  
      ,@If_Other Varchar(100) = ''  
      ,@RP_ExpiryDate Varchar(20) = ''  
      ,@RP_ImplDate Varchar(20) = ''  
      ,@RP_ImplStatusAlt_Key int=0  
      ,@RP_failed char(1)=''  
      ,@Revised_RP_Expiry_Date Varchar(20)=NUll  
      ,@Actual_Impl_Date Varchar(20)=NUll  
      ,@RP_OutOfDateAllBanksDeadline Varchar(20)=NUll  
      ,@RBLExposure char(1)=''  
      ,@AssetClassAlt_Key int=0  
      ,@RiskReviewExpiryDate Varchar(20)=NUll  
      ,@NameOf1stReportingBanklenderAlt_Key int=0  
      ,@ICAStatusAlt_Key int=0  
      ,@ReasonnotsigningICA   Varchar(250) = ''  
      ,@ICAExecutionDate Varchar(20)=NUll  
      ,@IBCFillingDate Varchar(20)=NUll  
      ,@IBCAddmissionDate Varchar(20)=NUll  
      ,@IsActive Char(1)=NULL  
      ,@RevisedRPDeadline_Altkey INT=0  
	  ,@RPDetails_ChangeFields			varchar(50) = ''
      --,@RBLExposure Varchar(1)=''  
  
      ---------D2k System Common Columns  --  
      ,@Remark     VARCHAR(500) = ''  
      --,@MenuID     SMALLINT  = 0  change to Int  
      ,@MenuID                    Int=0  
      ,@OperationFlag    TINYINT   = 0  
      ,@AuthMode     CHAR(1)   = 'N'  
      ,@Authlevel     VARCHAR(3)=''  
      ,@EffectiveFromTimeKey  INT  = 0  
      ,@EffectiveToTimeKey  INT  = 0  
      ,@TimeKey     INT  = 0  
      ,@CrModApBy     VARCHAR(20)  =''  
      ,@ScreenEntityId   INT    =null  
      ,@Result     INT    =0 OUTPUT  
        
        
AS  
BEGIN  
 SET NOCOUNT ON;  
  PRINT 1  
   
  SET DATEFORMAT DMY  
   
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
        
------------Added for Rejection Screen  29/06/2020   ----------  
  
  DECLARE   @Uniq_EntryID   int = 0  
      ,@RejectedBY   Varchar(50) = NULL  
      ,@RemarkBy    Varchar(50) = NULL  
      ,@RejectRemark   Varchar(200) = NULL  
      ,@ScreenName   Varchar(200) = NULL  
  
    SET @ScreenName = 'RPModule'  

	DECLARE @UploadCount Int=0
  
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
     SELECT  1 FROM RP_Portfolio_Details WHERE  CustomerID = @CustomerID AND ISNULL(AuthorisationStatus,'A')='A' and EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey  
     UNION  
     SELECT  1 FROM RP_Portfolio_Details_Mod  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)  
     AND CustomerID = @CustomerID  
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
     --SET @PAN_No = (Select ISNULL(Max(PAN_No),0)+1 from   
     --       (Select PAN_No from RP_Portfolio_Details  
     --        UNION   
     --        Select PAN_No from RP_Portfolio_Details_Mod  
     --       )A)  
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
      SET @CreatedBy =@CrModApBy   
      SET @DateCreated = GETDATE()  
      SET @AuthorisationStatus='NP'  
  
      --SET @PAN_No = (Select ISNULL(Max(PAN_No),0)+1 from   
      --      (Select PAN_No from RP_Portfolio_Details  
      --       UNION   
      --       Select PAN_No from RP_Portfolio_Details_Mod  
      --      )A)  
  
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
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM RP_Portfolio_Details    
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND CustomerID = @CustomerID
  
    ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE  
    IF ISNULL(@CreatedBy,'')=''  
    BEGIN  
     PRINT 'NOT AVAILABLE IN MAIN'  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM RP_Portfolio_Details_Mod   
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND CustomerID = @CustomerID
       AND AuthorisationStatus IN('NP','MP','A','RM')  
                 
    END  
    ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE  
     BEGIN  
            Print 'AVAILABLE IN MAIN'  
      ----UPDATE FLAG IN MAIN TABLES AS MP  
      UPDATE RP_Portfolio_Details  
       SET AuthorisationStatus=@AuthorisationStatus  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND CustomerID = @CustomerID
  
     END  
  
     --UPDATE NP,MP  STATUS   
     IF @OperationFlag=2  
     BEGIN   
  
      UPDATE RP_Portfolio_Details_Mod  
       SET AuthorisationStatus='FM'  
       ,ModifiedBy=@Modifiedby  
       ,DateModified=@DateModified  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND CustomerID = @CustomerID
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
  
      UPDATE RP_Portfolio_Details SET  
         ModifiedBy =@Modifiedby   
         ,DateModified =@DateModified   
         ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
        WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
        AND CustomerID = @CustomerID  
      
  
  end  
  
  
-------------------------------------------------------  
--start 20042021  
ELSE IF @OperationFlag=21 AND @AuthMode ='Y'   
  BEGIN  
    SET @ApprovedBy    = @CrModApBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE RP_Portfolio_Details_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      AND CustomerID = @CustomerID
      AND AuthorisationStatus in('NP','MP','DP','RM','1A')   
  
  IF EXISTS(SELECT 1 FROM RP_Portfolio_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CustomerID = @CustomerID)  
    BEGIN  
     UPDATE RP_Portfolio_Details  
      SET AuthorisationStatus='A'  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND CustomerID = @CustomerID
       AND AuthorisationStatus IN('MP','DP','RM')    
    END  
  END   
  
  
--till here  
-------------------------------------------------------  
  
   
   
 ELSE IF @OperationFlag=17 AND @AuthMode ='Y'   
  BEGIN  
    SET @ApprovedBy    = @CrModApBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE RP_Portfolio_Details_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedBy  =@ApprovedBy  
     ,DateApproved=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      AND CustomerID = @CustomerID
      AND AuthorisationStatus in('NP','MP','DP','RM')   
  
---------------Added for Rejection Pop Up Screen  29/06/2020   ----------  
  
  Print 'Sunil'  
  
--  DECLARE @EntityKey as Int   
  --SELECT @CreatedBy=CreatedBy,@DateCreated=DATECreated,@EntityKey=EntityKey  
  --      FROM RP_Portfolio_Details_Mod   
  --      WHERE (EffectiveToTimeKey =@EffectiveFromTimeKey-1 )  
  --       AND CustomerID = @CustomerID And ISNULL(AuthorisationStatus,'A')='R'  
    
-- EXEC [AxisIntReversalDB].[RejectedEntryDtlsInsert]  @Uniq_EntryID = @EntityKey, @OperationFlag = @OperationFlag ,@AuthMode = @AuthMode ,@RejectedBY = @CrModApBy  
--,@RemarkBy = @CreatedBy,@DateCreated=@DateCreated ,@RejectRemark = @Remark ,@ScreenName = @ScreenName  
    
  
--------------------------------  
  
    IF EXISTS(SELECT 1 FROM RP_Portfolio_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND CustomerID = @CustomerID)  
    BEGIN  
     UPDATE RP_Portfolio_Details  
      SET AuthorisationStatus='A'  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND CustomerID = @CustomerID
       AND AuthorisationStatus IN('MP','DP','RM')    
    END  
  END   
  
 ELSE IF @OperationFlag=18  
 BEGIN  
  PRINT 18  
  SET @ApprovedBy=@CrModApBy  
  SET @DateApproved=GETDATE()  
  UPDATE RP_Portfolio_Details_Mod  
  SET AuthorisationStatus='RM'  
  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  AND AuthorisationStatus IN('NP','MP','DP','RM')  
  AND CustomerID = @CustomerID  
  
 END  
  
 ELSE IF @OperationFlag=16  
  
  BEGIN  
  
  SET @ApprovedBy    = @CrModApBy   
  SET @DateApproved  = GETDATE()  
  
  UPDATE RP_Portfolio_Details_Mod  
      SET AuthorisationStatus ='1A'  
       ,ApprovedByFirstLevel=@ApprovedBy  
       ,DateApprovedFirstLevel=@DateApproved  
       WHERE CustomerID = @CustomerID  
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
        
      SELECT @CreatedBy=CreatedBy,@DateCreated=DATECreated  
      FROM RP_Portfolio_Details   
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )  
       AND CustomerID = @CustomerID  
       
     SET @ApprovedBy = @CrModApBy     
     SET @DateApproved=GETDATE()  
     END  
   END   
  
     
 ---set parameters and UPDATE mod table in case maker checker enabled  
   IF @AuthMode='Y'    
    BEGIN  
        Print 'B'  
     DECLARE @DelStatus CHAR(2)=''-------------20042021  
     DECLARE @CurrRecordFromTimeKey int=0  
  
     Print 'C'  
     SELECT @ExEntityKey= MAX(EntityKey) FROM RP_Portfolio_Details_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND CustomerID = @CustomerID  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
  
     SELECT @DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated  
      ,@ModifiedBy=ModifiedBy, @DateModified=DateModified  
      FROM RP_Portfolio_Details_Mod  
      WHERE EntityKey=@ExEntityKey  
       
     SET @ApprovedBy = @CrModApBy     
     SET @DateApproved=GETDATE()  
      
       
     DECLARE @CurEntityKey INT=0  
  
     SELECT @ExEntityKey= MIN(EntityKey) FROM RP_Portfolio_Details_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND CustomerID = @CustomerID  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
      
     SELECT @CurrRecordFromTimeKey=EffectiveFromTimeKey   
       FROM RP_Portfolio_Details_Mod  
       WHERE EntityKey=@ExEntityKey  
  
     UPDATE RP_Portfolio_Details_Mod  
      SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1  
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
      AND CustomerID = @CustomerID  
      AND AuthorisationStatus='A'   
        
  -------DELETE RECORD AUTHORISE  
     IF @DelStatus='DP'   
     BEGIN   
      UPDATE RP_Portfolio_Details_Mod  
      SET AuthorisationStatus ='A'  
       ,ApprovedBy=@ApprovedBy  
       ,DateApproved=@DateApproved  
       ,EffectiveToTimeKey =@EffectiveFromTimeKey -1  
      WHERE CustomerID = @CustomerID  
       AND AuthorisationStatus in('NP','MP','DP','RM','1A')  
        
      IF EXISTS(SELECT 1 FROM RP_Portfolio_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
          AND CustomerID = @CustomerID)  
      BEGIN  
        UPDATE RP_Portfolio_Details  
         SET AuthorisationStatus ='A'  
          ,ModifiedBy=@ModifiedBy  
          ,DateModified=@DateModified  
          ,ApprovedBy=@ApprovedBy  
          ,DateApproved=@DateApproved  
          ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
         WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
           AND CustomerID = @CustomerID  
  
          
      END  
     END -- END OF DELETE BLOCK  
  
     ELSE  -- OTHER THAN DELETE STATUS  
     BEGIN  
       UPDATE RP_Portfolio_Details_Mod  
        SET AuthorisationStatus ='A'  
         ,ApprovedBy=@ApprovedBy  
         ,DateApproved=@DateApproved  
        WHERE CustomerID = @CustomerID      
         AND AuthorisationStatus in('NP','MP','RM','1A')  
  
     
  
           
     END    
    END  
  
  IF @DelStatus <>'DP' OR @AuthMode ='N'  
    BEGIN  
       
      DECLARE @IsAvailable CHAR(1)='N'  
      ,@IsSCD2 CHAR(1)='N'  
        SET @AuthorisationStatus='A' --changedby siddhant 5/7/2020  
  
      IF EXISTS(SELECT 1 FROM RP_Portfolio_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
          AND CustomerID = @CustomerID)  
       BEGIN  
        SET @IsAvailable='Y'  
        SET @AuthorisationStatus='A'  
  
        IF EXISTS(SELECT 1 FROM RP_Portfolio_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@TimeKey AND CustomerID = @CustomerID)  
         BEGIN  
           PRINT 'BBBB'  
          UPDATE RP_Portfolio_Details SET  
              
      
      UCIC_ID=@UCIC_ID      
      ,CustomerID =@CustomerID     
  ,CustomerName=@CustomerName   
   ,BankingArrangementAlt_Key=@BankingArrangementAlt_Key   
      ,BorrowerDefaultDate=Convert(Date,@BorrowerDefaultDate )  
      ,LeadBankAlt_Key=@LeadBankAlt_Key   
      ,DefaultStatusAlt_Key=@DefaultStatusAlt_Key   
      ,ExposureBucketAlt_Key=@ExposureBucketAlt_Key   
      ,ReferenceDate=Convert(Date,@ReferenceDate)   
      ,ReviewExpiryDate=Convert(Date,@ReviewExpiryDate )  
      ,RP_ApprovalDate=Convert(Date,@RP_ApprovalDate )  
      ,RPNatureAlt_Key=@RPNatureAlt_Key   
      ,If_Other=@If_Other   
      ,RP_ExpiryDate=Convert(Date,@RP_ExpiryDate)   
      ,RP_ImplDate=Convert(Date,@RP_ImplDate )  
      ,RP_ImplStatusAlt_Key=@RP_ImplStatusAlt_Key   
      ,RP_failed=@RP_failed   
      ,Revised_RP_Expiry_Date=Convert(Date,@Revised_RP_Expiry_Date)   
      ,Actual_Impl_Date=Convert(Date,@Actual_Impl_Date )  
      ,RP_OutOfDateAllBanksDeadline=Convert(Date,@RP_OutOfDateAllBanksDeadline )  
      ,IsBankExposure=@RBLExposure  
      ,AssetClassAlt_Key=@AssetClassAlt_Key   
      ,RiskReviewExpiryDate=Convert(Date,@RiskReviewExpiryDate )  
      ,NameOf1stReportingBanklenderAlt_Key=@NameOf1stReportingBanklenderAlt_Key   
      ,ICAStatusAlt_Key=@ICAStatusAlt_Key   
      ,ReasonnotsigningICA=@ReasonnotsigningICA     
      ,ICAExecutionDate=Convert(Date,@ICAExecutionDate)   
      ,IBCFillingDate=Convert(Date,@IBCFillingDate )  
      ,IBCAddmissionDate=Convert(Date,@IBCAddmissionDate )  
      ,IsActive=Case When @OperationFlag=1 Then 'Y'  
               When @OperationFlag=20 AND  @RevisedRPDeadline_Altkey in(1,2,3) Then 'N' End  
      ,RevisedRPDeadline_Altkey=@RevisedRPDeadline_Altkey  
      --,RBLExposure=@RBLExposure   
            ,ModifiedBy     = @ModifiedBy  
            ,DateModified    = @DateModified  
            ,ApprovedBy     = CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END  
            ,DateApproved    = CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END  
            ,AuthorisationStatus  = CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END  
            ,ScreenFlag='S'  
              
            WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND CustomerID = @CustomerID  
         END   
  
         ELSE  
          BEGIN  
           SET @IsSCD2='Y'  
          END  
        END  
  
        IF @IsAvailable='N' OR @IsSCD2='Y'  
        Print 'SachinTest'  
  
          
      IF EXISTS(SELECT 1 FROM RP_Portfolio_Details WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
          AND CustomerID = @CustomerID)  
      BEGIN  
        UPDATE RP_Portfolio_Details  
         SET AuthorisationStatus ='A'  
          ,ModifiedBy=@ModifiedBy  
          ,DateModified=@DateModified  
          ,ApprovedBy=@ApprovedBy  
          ,DateApproved=@DateApproved  
          ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
         WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
           AND CustomerID = @CustomerID  
  
          
      END  
  
      BEGIN  
          INSERT INTO RP_Portfolio_Details  
            (  
                
      PAN_No    
      ,UCIC_ID      
      ,CustomerID     
      ,CustomerName     
      ,BankingArrangementAlt_Key   
      ,BorrowerDefaultDate   
      ,LeadBankAlt_Key   
      ,DefaultStatusAlt_Key   
      ,ExposureBucketAlt_Key   
      ,ReferenceDate   
      ,ReviewExpiryDate   
      ,RP_ApprovalDate   
      ,RPNatureAlt_Key   
      ,If_Other   
      ,RP_ExpiryDate   
      ,RP_ImplDate   
      ,RP_ImplStatusAlt_Key   
      ,RP_failed   
      ,Revised_RP_Expiry_Date   
      ,Actual_Impl_Date   
      ,RP_OutOfDateAllBanksDeadline   
      ,IsBankExposure  
      ,AssetClassAlt_Key   
      ,RiskReviewExpiryDate   
      ,NameOf1stReportingBanklenderAlt_Key   
      ,ICAStatusAlt_Key   
      ,ReasonnotsigningICA     
      ,ICAExecutionDate   
      ,IBCFillingDate   
      ,IBCAddmissionDate   
      --,RBLExposure   
             ,AuthorisationStatus  
             ,EffectiveFromTimeKey  
             ,EffectiveToTimeKey  
             ,CreatedBy   
             ,DateCreated  
             ,ModifiedBy  
             ,DateModified  
             ,ApprovedBy  
             ,DateApproved  
             ,ScreenFlag  
             ,IsActive  
             ,ApprovedByFirstLevel  
             ,DateApprovedFirstLevel  
             ,RevisedRPDeadline_Altkey  
              
            )  
  
          SELECT  
               
      @PAN_No    
      ,@UCIC_ID      
      ,@CustomerID     
      ,@CustomerName     
      ,@BankingArrangementAlt_Key   
      ,Convert(Date,@BorrowerDefaultDate)   
      ,@LeadBankAlt_Key   
      ,@DefaultStatusAlt_Key   
      ,@ExposureBucketAlt_Key   
      ,Convert(Date,@ReferenceDate)    
      ,Convert(Date,@ReviewExpiryDate)    
      ,Convert(Date,@RP_ApprovalDate)    
      ,@RPNatureAlt_Key   
      ,@If_Other   
      ,Convert(Date,@RP_ExpiryDate)    
      ,Convert(Date,@RP_ImplDate)    
      ,@RP_ImplStatusAlt_Key   
      ,@RP_failed   
      ,Convert(Date,@Revised_RP_Expiry_Date)    
      ,Convert(Date,@Actual_Impl_Date)    
      ,Convert(Date,@RP_OutOfDateAllBanksDeadline)   
      ,@RBLExposure  
      ,@AssetClassAlt_Key   
      ,Convert(Date,@RiskReviewExpiryDate)    
      ,@NameOf1stReportingBanklenderAlt_Key   
      ,@ICAStatusAlt_Key   
      ,@ReasonnotsigningICA     
      ,Convert(Date,@ICAExecutionDate)    
      ,Convert(Date,@IBCFillingDate)    
      ,Convert(Date,@IBCAddmissionDate)   
      --,@RBLExposure   
             ,CASE WHEN @AUTHMODE= 'Y' THEN   @AuthorisationStatus ELSE NULL END  
             ,@EffectiveFromTimeKey  
             ,@EffectiveToTimeKey  
             ,@CreatedBy   
             ,@DateCreated  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END  
             ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END  
             ,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END  
             ,'S'  
             ,Case When @OperationFlag=1 Then 'Y'  
               When @OperationFlag=20 AND  @RevisedRPDeadline_Altkey in(1,2,3) Then 'N' ELSE 'Y' End  
             ,ApprovedByFirstLevel  
             ,DateApprovedFirstLevel  
             ,@RevisedRPDeadline_Altkey  
               
             From RP_Portfolio_Details_Mod  
             WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
                                                   AND CustomerID = @CustomerID  
                                                   AND isnull (AuthorisationStatus,'A')='A'
            
      END  
  
  
         IF @IsSCD2='Y'   
        BEGIN  
        UPDATE RP_Portfolio_Details SET  
          EffectiveToTimeKey=@EffectiveFromTimeKey-1  
          ,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END  
         WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND CustomerID = @CustomerID  
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
  
----------------------------------------------------  
  
 DECLARE @Parameter varchar(50)  
 DECLARE @FinalParameter varchar(50)  
 SET @Parameter = (select STUFF(( SELECT Distinct ',' +ChangeField   
           from RP_Portfolio_Details_Mod where CustomerID = @CustomerID  
           and ISNULL(AuthorisationStatus,'A') = 'A' for XML PATH('')),1,1,'') )  
  
           If OBJECT_ID('#A') is not null  
           drop table #A  
  
select DISTINCT VALUE   
into #A   
from (  
  SELECT  CHARINDEX('|',VALUE) CHRIDX,VALUE  
  FROM( SELECT VALUE FROM STRING_SPLIT(@Parameter,',')  
 ) A  
 )X  
 SET @FinalParameter = (select STUFF(( SELECT Distinct ',' + Value from #A  for XML PATH('')),1,1,''))  
   
       UPDATE  A  
       set   a.ChangeField = @FinalParameter                                           
       from  RP_Portfolio_Details   A  
       WHERE  (EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY)   
       and   CustomerID = @CustomerID  
        
  
----------------------------------------------------  
  
PRINT 6  
SET @ErrorHandle=1  
  
GLCodeMaster_Insert:  
IF @ErrorHandle=0  
 BEGIN  
 PRINT 'SachinMod'  

 Select @UploadCount=Count(*) From RP_Portfolio_Details_Mod
 Where CustomerID=@CustomerID

   INSERT INTO RP_Portfolio_Details_Mod    
           (   
              
      PAN_No    
      ,UCIC_ID      
      ,CustomerID     
      ,CustomerName     
      ,BankingArrangementAlt_Key   
      ,BorrowerDefaultDate   
      ,LeadBankAlt_Key   
      ,DefaultStatusAlt_Key   
      ,ExposureBucketAlt_Key   
      ,ReferenceDate   
      ,ReviewExpiryDate   
      ,RP_ApprovalDate   
      ,RPNatureAlt_Key   
      ,If_Other   
      ,RP_ExpiryDate   
      ,RP_ImplDate   
      ,RP_ImplStatusAlt_Key   
      ,RP_failed   
      ,Revised_RP_Expiry_Date   
      ,Actual_Impl_Date   
      ,RP_OutOfDateAllBanksDeadline   
      ,IsBankExposure  
      ,AssetClassAlt_Key   
      ,RiskReviewExpiryDate   
      ,NameOf1stReportingBanklenderAlt_Key   
      ,ICAStatusAlt_Key   
      ,ReasonnotsigningICA     
      ,ICAExecutionDate   
      ,IBCFillingDate   
      ,IBCAddmissionDate   
      ----,RBLExposure   
            ,AuthorisationStatus   
            ,EffectiveFromTimeKey  
            ,EffectiveToTimeKey  
            ,CreatedBy  
            ,DateCreated  
            ,ModifiedBy  
            ,DateModified  
            ,ApprovedBy  
            ,DateApproved  
            ,IsActive  
            ,RevisedRPDeadline_Altkey  
            ,ChangeField   
			
           )  
        VALUES  
           (   
               
      @PAN_No    
      ,@UCIC_ID      
      ,@CustomerID     
      ,@CustomerName     
      ,@BankingArrangementAlt_Key   
      ,Convert(Date,@BorrowerDefaultDate )    
      ,@LeadBankAlt_Key   
      ,@DefaultStatusAlt_Key   
      ,@ExposureBucketAlt_Key   
      ,Convert(Date,@ReferenceDate)    
      ,Convert(Date,@ReviewExpiryDate)    
      ,Convert(Date,@RP_ApprovalDate)    
      ,@RPNatureAlt_Key   
      ,@If_Other   
      ,Convert(Date,@RP_ExpiryDate)    
      ,Convert(Date,@RP_ImplDate)    
      ,@RP_ImplStatusAlt_Key   
      ,@RP_failed   
      ,Convert(Date,@Revised_RP_Expiry_Date)    
      ,Convert(Date,@Actual_Impl_Date)    
      ,Convert(Date,@RP_OutOfDateAllBanksDeadline)   
      ,@RBLExposure  
      ,@AssetClassAlt_Key   
      ,Convert(Date,@RiskReviewExpiryDate)    
      ,@NameOf1stReportingBanklenderAlt_Key   
      ,@ICAStatusAlt_Key   
      ,@ReasonnotsigningICA     
      ,Convert(Date,@ICAExecutionDate)  
    
      ,Convert(Date,@IBCFillingDate)  
      ,Convert(Date,@IBCAddmissionDate )  
      ----,@RBLExposure   
             ,@AuthorisationStatus  
             ,@EffectiveFromTimeKey  
             ,@EffectiveToTimeKey   
             ,@CreatedBy  
             ,@DateCreated  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END  
             ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END  
             ,Case  When @UploadCount=0 Then 'Y'
			  When @OperationFlag=1 Then 'Y'  
              When @OperationFlag=2 AND  @RevisedRPDeadline_Altkey in(1,2,3) Then 'N'
			  When @OperationFlag=2 Then'Y' End  
               ,@RevisedRPDeadline_Altkey  
              ,@RPDetails_ChangeFields 
			
           )  
   
   
 
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
  
  --SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM RP_Portfolio_Details WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
  --               AND CustomerID = @CustomerID  
  
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