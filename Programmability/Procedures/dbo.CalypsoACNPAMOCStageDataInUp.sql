SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO



 
  
  
CREATE PROCEDURE  [dbo].[CalypsoACNPAMOCStageDataInUp]  
 @Timekey INT,  
 @UserLoginID VARCHAR(100),  
 @OperationFlag INT,  
 @MenuId INT,  
 @AuthMode CHAR(1),  
 @filepath VARCHAR(MAX),  
 @EffectiveFromTimeKey INT,  
 @EffectiveToTimeKey INT,  
    @Result  INT=0 OUTPUT,  
 @UniqueUploadID INT,  
 @Authlevel varchar(5)  
  
AS  
  
--DECLARE @Timekey INT=24928,  
-- @UserLoginID VARCHAR(100)='FNAOPERATOR',  
-- @OperationFlag INT=1,  
-- @MenuId INT=163,  
-- @AuthMode CHAR(1)='N',  
-- @filepath VARCHAR(MAX)='',  
-- @EffectiveFromTimeKey INT=24928,  
-- @EffectiveToTimeKey INT=49999,  
--    @Result  INT=0 ,  
-- @UniqueUploadID INT=41  
BEGIN  
SET DATEFORMAT DMY  
 SET NOCOUNT ON;  

 
	--	IF EXISTS(SELECT 1 FROM ACLProcessInProgressStatus WHERE Status='RUNNING' AND StatusFlag='N' AND TimeKey in (select max(Timekey) from ACLProcessInProgressStatus))
	
	--BEGIN
	--	PRINT 'ACL Process is In Progress'
	----IF EXISTS(SELECT 1 FROM ACLProcessInProgressStatus WHERE Status='COMPLETED' AND StatusFlag='Y' AND TimeKey in (select max(Timekey) from ACLProcessInProgressStatus) )
	----BEGIN
	----	PRINT 'ACL Process Completed'
	--END

	--ELSE 

	--BEGIN  
	
	---^^^^^^^^-- commeted on 07/02/2024
  
     
   --DECLARE @Timekey INT  
   --SET @Timekey=(SELECT MAX(TIMEKEY) FROM dbo.SysProcessingCycle  
   -- WHERE ProcessType='Quarterly')  
  
   --Set @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A  
   --Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey  
   -- where A.CurrentStatus='C')  
  --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')   
  
  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)   
  
  --DECLARE @LastMonthDate date = (select  LastMonthDate from SysDayMatrix where Timekey in (select  Timekey from sysdatamatrix where CurrentStatus = 'C'))  
  
  
    DECLARE @MocDate date  
    
 SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N')   
 SET @MocDate =(Select ExtDate from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N')  
  
 PRINT @TIMEKEY  
  
 SET @EffectiveFromTimeKey=@TimeKey  
 SET @EffectiveToTimeKey=49999  
   
  
  Declare @MocStatus Varchar(100)=''  
 Select @MocStatus=MocStatus   
 from CalypsoMOCMonitorStatus  
Where EntityKey in(Select Max(EntityKey) From CalypsoMOCMonitorStatus)  
  
IF(@MocStatus='InProgress')  
  Begin  
     SET @Result=5  
 RETURN @Result  
  End  
  
  
 DECLARE @FilePathUpload VARCHAR(100)  
       SET @FilePathUpload=@UserLoginId+'_'+@filepath  
     PRINT '@FilePathUpload'  
     PRINT @FilePathUpload  
  
  
  BEGIN TRY  
  
  --BEGIN TRAN  
    
IF (@MenuId=24749)  
BEGIN  
  
  
 IF (@OperationFlag=1)  
  
 BEGIN  
  
  IF NOT (EXISTS (SELECT 1 FROM CalypsoAccountLvlMOCDetails_stg  where filname=@FilePathUpload))  
  
       BEGIN  
          --Rollback tran  
         SET @Result=-8  
  
        RETURN @Result  
       END  
     
                   Print 'Sachin'  
         
  
  IF EXISTS(SELECT 1 FROM CalypsoAccountLvlMOCDetails_stg WHERE filname=@FilePathUpload)  
  BEGIN  
    
  INSERT INTO ExcelUploadHistory  
 (  
  UploadedBy   
  ,DateofUpload   
  ,AuthorisationStatus   
  --,Action   
  ,UploadType  
  ,EffectiveFromTimeKey   
  ,EffectiveToTimeKey   
  ,CreatedBy   
  ,DateCreated   
    
 )  
  
 SELECT @UserLoginID  
     ,GETDATE()  
     ,'NP'  
     --,'NP'  
     ,'Calypso Account MOC Upload'  
     ,@EffectiveFromTimeKey  
     ,@EffectiveToTimeKey  
     ,@UserLoginID  
     ,GETDATE()  
  
  
      PRINT @@ROWCOUNT  
      print 'Prashant'  
     DECLARE @ExcelUploadId INT  
 SET  @ExcelUploadId=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)  
    
   Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)  
  Values(@filepath,@UserLoginID ,GETDATE(),'Calypso Account MOC Upload')  
  
    
  
  
  --INSERT INTO AccountMOCDetail_MOD  
  --(  
  --  SrNo  
  -- ,UploadID  
     
  -- ,SlNo  
  -- ,AccountID  
  -- ,POSinRs  
  -- ,InterestReceivableinRs  
  -- ,AdditionalProvisionAbsoluteinRs  
  -- ,RestructureFlag  
  -- ,RestructureDat  
  -- ,FITLFlag  
  -- ,DFVAmount  
  -- ,RePossesssionFlag  
  -- ,RePossessionDate  
  -- ,InherentWeaknessFlag  
  -- ,InherentWeaknessDate  
  -- ,SARFAESIFlag  
  -- ,SARFAESIDate  
  -- ,UnusualBounceFlag  
  -- ,UnusualBounceDate  
  -- ,UnclearedEffectsFlag  
  -- ,UnclearedEffectsDate  
  -- ,FraudFlag  
  -- ,FraudDate  
  -- ,MOCSource  
  -- ,MOCReason  
  -- ,AuthorisationStatus   
  -- ,EffectiveFromTimeKey   
  -- ,EffectiveToTimeKey   
  -- ,CreatedBy   
  -- ,DateCreated  
  -- ,ScreenFlag  
  --)  
     
  --SELECT  
  --  SlNo  
  -- ,@ExcelUploadId  
     
  -- ,SlNo  
  -- ,AccountID  
  -- ,POSinRs  
  -- ,InterestReceivableinRs  
  -- ,AdditionalProvisionAbsoluteinRs  
  -- ,RestructureFlagYN  
  -- ,RestructureDate   
  -- ,FITLFlagYN  
  -- ,DFVAmount  
  -- ,RePossesssionFlagYN  
  -- ,RePossessionDate  
  -- ,InherentWeaknessFlag  
  -- ,InherentWeaknessDate  
  -- ,SARFAESIFlag  
  -- ,SARFAESIDate  
  -- ,UnusualBounceFlag  
  -- ,UnusualBounceDate  
  -- ,UnclearedEffectsFlag  
  -- ,UnclearedEffectsDate  
  -- ,FraudFlag  
  -- ,FraudDate  
  -- ,MOCSource  
  -- ,MOCReason  
  -- ,'NP'   
  -- ,@Timekey  
  -- ,@TimeKey   
  -- ,@UserLoginID   
  -- ,GETDATE()   
  -- ,'U'  
  --FROM AccountLvlMOCDetails_stg  
  --where filname=@FilePathUpload  
  SET DATEFORMAT DMY  
    
    
  
  INSERT INTO CalypsoAccountLevelMOC_Mod  
  (  
    SrNo  
   ,UploadID  
   ,AccountId   
   ,BookValue    
   ,unserviedint   
   ,AdditionalProvisionAbsolute  
   ,MOCSource  
   ,MOCReason  
   ,AuthorisationStatus   
   ,EffectiveFromTimeKey   
   ,EffectiveToTimeKey   
   ,CreatedBy   
   ,DateCreated  
   ,ScreenFlag  
   ,ChangeField  
   --,FlgTwo  
            --,TwoDate  
           -- ,TwoAmount  
   ,MOCDate  
   ,MOC_TYPEFLAG  
     
  )  
     
  SELECT  
    SlNo  
   ,@ExcelUploadId  
   ,InvestmentIDDerivativeRefNo  
   ,ISNULL(case when isnull(BookValueINRMTMValue,'')<>'' then CAST(ISNULL(CAST(BookValueINRMTMValue AS DECIMAL(16,2)),0) AS DECIMAL(30,2))   end,NULL) AS BookValueINRMTMValue  
   ,ISNULL(case when isnull(UnservicedInterest,'')<>'' then CAST(ISNULL(CAST(UnservicedInterest AS DECIMAL(16,2)),0) AS DECIMAL(30,2))   end,NULL) AS UnservicedInterest  
   ,ISNULL(case when isnull(AdditionalProvisionAbsolute,'')<>'' then CAST(ISNULL(CAST(AdditionalProvisionAbsolute AS DECIMAL(16,2)),0) AS DECIMAL(30,2))   end,NULL)   AdditionalProvisionAbsoluteinRs  
   ,MOCSource  
   ,MOCReason  
   ,'NP'   
   ,@Timekey  
   ,@EffectiveToTimeKey   
   ,@UserLoginID   
   ,GETDATE()   
   ,'U'  
   ,NULL  
   ,@MocDate  
   ,'ACCT'  
 FROM CalypsoAccountLvlMOCDetails_stg A  
  where filname=@FilePathUpload  
  
  
  IF EXISTS (select 1 From CalypsoAccountLevelMOC_Mod A  
  INNER JOIN InvestmentBasicDetail B ON A.AccountID =B.InvID  
  and B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey  
  Where A.UploadID=@ExcelUploadId)   
  BEGIN   
  Update A  
  SET A.AccountEntityID=B.InvEntityID  
  From CalypsoAccountLevelMOC_Mod A  
  INNER JOIN InvestmentBasicDetail B ON A.AccountID =B.InvID  
  and B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey  
  Where A.UploadID=@ExcelUploadId  
  END  
  ELSE   
  BEGIN  
  Update A  
  SET A.AccountEntityID=B.DerivativeEntityID  
  From CalypsoAccountLevelMOC_Mod A  
  INNER JOIN curdat.DerivativeDetail B ON A.AccountID =B.DerivativeRefNo  
  and B.EffectiveFromTimeKey<=@TimeKey AND B.EffectiveToTimeKey>=@TimeKey  
  Where A.UploadID=@ExcelUploadId  
  END  
  ---------------------------------------------------------ChangeField Logic---------------------  
  ----select * from AccountLvlMOCDetails_stg  
 IF OBJECT_ID('TempDB..#AccountMocUpload') Is Not Null  
 Drop Table #AccountMocUpload  
  
 Create TAble #AccountMocUpload  
 (  
 AccountID Varchar(30), FieldName Varchar(50),SrNo Varchar(Max))  
  
 Insert Into #AccountMocUpload(AccountID,FieldName)  
   
 Select InvestmentIDDerivativeRefNo, 'AdditionalProvisionAbsolute' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(AdditionalProvisionAbsolute,'')<>'' --AdditionalProvisionAbsoluteinRs Is not NULL  
 UNION ALL  
 --Select AccountID, 'RestructureFlagYN' FieldName from AccountLvlMOCDetails_stg Where isnull(RestructureFlagYN,'')<>'' --RestructureFlagYN Is not NULL  
 --UNION ALL  
 --Select AccountID, 'RestructureDate' FieldName from AccountLvlMOCDetails_stg Where isnull(RestructureDate,'')<>'' --RestructureDate Is not NULL  
 --UNION ALL  
 --countID, 'RePossesssionFlagYN' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(RePossesssionFlagYN,'')<>'' --RePossesssionFlagYN Is not NULL  
    --Select AccountID, 'UnclearedEffectsFlag' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(UnclearedEffectsFlag,'')<>'' --UnclearedEffectsFlag Is not NULL  
 --UNION ALL  
 --Select AccountID, 'UnclearedEffectsDate' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(UnclearedEffectsDate,'')<>'' --UnclearedEffectsDate Is not NULL  
 --UNION ALL  
 --Select AccountID, 'FraudFlag' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(FraudFlag,'')<>'' --FraudFlag Is not NULL  
 --UNION ALL  
 --Select InvestmentIDDerivativeRefNo,'FraudDate' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(FraudDate,'')<>'' --FraudDate Is not NULL  
 --UNION ALL  
 Select InvestmentIDDerivativeRefNo, 'MOCSource' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(MOCSource,'')<>'' --MOCSource Is not NULL  
 UNION ALL  
 Select InvestmentIDDerivativeRefNo,'MOCReason' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(MOCReason,'')<>'' --MOCReason Is not NULL  
 --UNION ALL  
 --Select AccountID, 'TwoFlag' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(TwoFlag,'')<>'' --TwoFlag Is not NULL  
 --UNION ALL  
 --Select InvestmentIDDerivativeRefNo, 'TwoDate' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(TwoDate,'')<>'' --TwoDate Is not NULL  
 ----UNION ALL  
 --Select AccountID, 'TwoAmount' FieldName from CalypsoAccountLvlMOCDetails_stg Where isnull(TwoAmount,'')<>'' --TwoAmount Is not NULL  
  
 --select *  
 Update B set B.SrNo=A.ScreenFieldNo  
 from MetaScreenFieldDetail A  
 Inner Join #AccountMocUpload B ON A.CtrlName=B.FieldName  
 Where A.MenuId=27767 And A.IsVisible='Y'  
  
  
   
     IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL  
     DROP TABLE #NEWTRANCHE  
  
     SELECT * INTO #NEWTRANCHE FROM(  
     SELECT   
       SS.InvestmentIDDerivativeRefNo,  
      STUFF((SELECT ',' + US.SrNo   
       FROM #AccountMocUpload US  
       WHERE US.AccountID = SS.InvestmentIDDerivativeRefNo  
       FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]  
      FROM CalypsoAccountLvlMOCDetails_stg SS   
      GROUP BY SS.InvestmentIDDerivativeRefNo  
      )B  
      ORDER BY 1  
  
      --Select * from #NEWTRANCHE  
  
     --SELECT *   
     UPDATE A SET A.ChangeField=B.REPORTIDSLIST  
     FROM DBO.CalypsoAccountLevelMOC_Mod A  
     INNER JOIN #NEWTRANCHE B ON A.AccountID=B.InvestmentIDDerivativeRefNo  
     WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey  
     And A.UploadID=@ExcelUploadId  
  
  
       
  
  
  -------------------------------------------------------------------------------------  
  
  --Declare @SummaryId int  
  --Set @SummaryId=IsNull((Select Max(SummaryId) from AccountMOCDetail_MOD),0)  
  
     
  --INSERT INTO AccountMOCSummary_Mod  
  --(  
  --  UploadID  
  -- ,SummaryID  
  -- ,PoolID  
  -- ,PoolName  
  -- ,PoolType  
  -- ,BalanceOutstanding  
  -- ,NoOfAccount  
  -- ,IBPCExposureAmt  
  -- ,IBPCReckoningDate  
  -- ,IBPCMarkingDate  
  -- ,MaturityDate  
  -- ,TotalPosBalance  
  -- ,TotalInttReceivable  
  --)  
  
  --SELECT  
  -- @ExcelUploadId  
  -- ,@SummaryId+Row_Number() over(Order by PoolID)  
  -- ,PoolID  
  -- ,PoolName  
  -- ,PoolType  
  -- ,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0)+IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))  
  -- ,Count(PoolID)  
  -- ,SUM(ISNULL(Cast(IBPCExposureinRs as Decimal(16,2)),0))  
  -- ,DateofIBPCreckoning  
  -- ,DateofIBPCmarking  
  -- ,MaturityDate  
  -- ,Sum(IsNull(Cast(PrincipalOutstandinginRs as decimal(16,2)),0))  
  -- ,Sum(IsNull(Cast(InterestReceivableinRs as Decimal(16,2)),0))  
  --FROM AccountLvlMOCDetails_stg  
  --where filename=@FilePathUpload  
  --Group by PoolID,PoolName,PoolType,DateofIBPCreckoning,DateofIBPCmarking,MaturityDate  
  
  --INSERT INTO IBPCPoolSummary_Mod  
  --(  
  -- UploadID  
  -- ,SummaryID  
  -- ,PoolID  
  -- ,PoolName  
  -- ,BalanceOutstanding  
  -- ,NoOfAccount  
  -- ,AuthorisationStatus   
  -- ,EffectiveFromTimeKey   
  -- ,EffectiveToTimeKey   
  -- ,CreatedBy   
  -- ,DateCreated   
  --)  
  
  --SELECT  
  -- @ExcelUploadId  
  -- ,@SummaryId+Row_Number() over(Order by PoolID)  
  -- ,PoolID  
  -- ,PoolName  
  -- ,Sum(IsNull(POS,0)+IsNull(InterestReceivable,0))  
  -- ,Count(PoolID)  
  -- ,'NP'   
  -- ,@Timekey  
  -- ,49999   
  -- ,@UserLoginID   
  -- ,GETDATE()  
  --FROM IBPCPoolDetail_stg  
  --where filename=@FilePathUpload  
  --Group by PoolID,PoolName  
  
  PRINT @@ROWCOUNT  
    
  -----DELETE FROM STAGING DATA  
  
   DELETE FROM CalypsoAccountLvlMOCDetails_stg  
   WHERE filname=@FilePathUpload  
  
   ----RETURN @ExcelUploadId  
  
END  
     ----DECLARE @UniqueUploadID INT  
 --SET  @UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)  
 END  
  
  
----------------------01042021-------------  
  
IF (@OperationFlag=16)----AUTHORIZE  
  
 BEGIN  
    
  UPDATE   
   CalypsoAccountLevelMOC_Mod   
   SET   
   AuthorisationStatus ='1A'  
   ,ApprovedByFirstLevel =@UserLoginID  
   ,DateApprovedFirstLevel =GETDATE()  
     
   WHERE UploadId=@UniqueUploadID  
     
     UPDATE   
     ExcelUploadHistory  
     SET AuthorisationStatus='1A'  
     ,ApprovedBy =@UserLoginID  
     where UniqueUploadID=@UniqueUploadID  
     AND UploadType='Calypso Account MOC Upload'  
 END  
  
--------------------------------------------  
  
 IF (@OperationFlag=20)----AUTHORIZE  
  
 BEGIN  
  
   
      
    BEGIN  
    
  UPDATE   
   CalypsoAccountLevelMOC_Mod   
   SET AuthorisationStatus ='A'  
   ,ApprovedBy =@UserLoginID  
   ,DateApproved =GETDATE()  
   WHERE UploadId=@UniqueUploadID     
  
  IF EXISTS (select 1 from CalypsoInvMOC_ChangeDetails A  
  INNER JOIN InvestmentBasicDetail B  
   ON A.AccountEntityID=B.InvEntityId  
    AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey  
    AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey  
  INNER JOIN CalypsoAccountLevelMOC_Mod C  
   ON B.InvEntityId=C.AccountEntityID         
    AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey  
    AND C.AuthorisationStatus='A' AND UploadId=@UniqueUploadID  
  WHERE A.EffectiveToTimeKey >=@Timekey  
  AND A.AuthorisationStatus = 'A'  
  AND A.MOCType_Flag='ACCT'  
  AND UploadId=@UniqueUploadID)   
  BEGIN   
  
  UPDATE  A  
  SET A.EffectiveToTimeKey=@Timekey-1  
  from CalypsoInvMOC_ChangeDetails A  
  INNER JOIN InvestmentBasicDetail B  
   ON A.AccountEntityID=B.InvEntityId  
    AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey  
    AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey  
  INNER JOIN CalypsoAccountLevelMOC_Mod C  
   ON B.InvEntityId=C.AccountEntityID         
    AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey  
    AND C.AuthorisationStatus='A' AND UploadId=@UniqueUploadID  
  WHERE A.EffectiveToTimeKey >=@Timekey  
  AND A.AuthorisationStatus = 'A'  
  AND A.MOCType_Flag='ACCT'  
  AND UploadId=@UniqueUploadID  
  
  END  
  ELSE   
  BEGIN  
  
  UPDATE  A  
  SET A.EffectiveToTimeKey=@Timekey-1  
  from CalypsoDervMOC_ChangeDetails A  
  INNER JOIN Curdat.DerivativeDetail B  
   ON A.AccountEntityID=B.DerivativeEntityID  
    AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey >=@Timekey  
    AND B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey >=@Timekey  
  INNER JOIN CalypsoAccountLevelMOC_Mod C  
   ON B.DerivativeEntityID=C.AccountEntityID         
    AND C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey >=@Timekey  
    AND C.AuthorisationStatus='A' AND UploadId=@UniqueUploadID  
  WHERE A.EffectiveToTimeKey >=@Timekey  
  AND A.AuthorisationStatus = 'A'  
  AND A.MOCType_Flag='ACCT'  
  AND UploadId=@UniqueUploadID  
  
  END  
      
     
  IF EXISTS (select 1  FROM CalypsoAccountLevelMOC_MOd A  
     inner join  InvestmentFinancialDetail B  
     ON          A.AccountID=B.RefInvID  
     AND         B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey>=@Timekey  
   WHERE        A.UploadId=@UniqueUploadID AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey>=@Timekey  
            AND  A.AuthorisationStatus = 'A'  
)   
  BEGIN   
  INSERT INTO CalypsoInvMOC_ChangeDetails      
             (     
                     
            AccountEntityID    
            ,CustomerEntityId  
            ,AddlProvAbs   
            ,FlgFraud         
            ,FraudDate                 
            ,PrincOutStd            
            ,unserviedint                           
            ,FLGFITL           
            ,DFVAmt                      
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
           ,TwoFlag  
           ,TwoDate  
           ,ApprovedByFirstLevel  
           ,DateApprovedFirstLevel  
           ,MOC_Reason  
           ,MOCProcessed  
		   ,BookValue
		  
             )    
          Select    
            
            B.InvEntityID    
            ,B.IssuerEntityID  
            ,A.AdditionalProvisionAbsolute  
             ,A.FraudAccountFlag         
            ,A.FraudDate                         
            ,A.POS            
            ,A.unserviedint  --receivable column removed unserviced removed added        
             ,A.FITLFlag           
            ,A.DFVAmount                         
            ,A.MOCSource                     
              ,A.MOCDate  
              ,A.CreatedBy      
              ,A.AuthorisationStatus    
              ,A.EffectiveFromTimeKey    
              ,A.EffectiveToTimeKey     
              ,A.CreatedBy    
              ,A.DateCreated    
              ,A.ModifyBy     
              ,A.DateModified     
              ,A.ApprovedBy       
              ,A.DateApproved                        
              ,'ACCT' MOCType_Flag  
                 ,A.FlgTwo  
              ,A.TwoDate  
              ,a.ApprovedByFirstLevel  
              ,a.DateApprovedFirstLevel  
              ,MOCReason  
              ,'N'  
			  ,A.BookValue
			 
              FROM CalypsoAccountLevelMOC_MOd A  
     inner join  InvestmentBasicDetail B  
     ON          A.AccountID=B.InvID  
     AND         B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey>=@Timekey  
   WHERE        A.UploadId=@UniqueUploadID AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey>=@Timekey  
            AND        A.AuthorisationStatus = 'A'  
   END  
  
   ELSE  
  
   BEGIN  
        
   INSERT INTO CalypsoDervMOC_ChangeDetails      
             (     
                     
            AccountEntityID    
            ,CustomerEntityId  
            ,AddlProvAbs   
            ,FlgFraud         
            ,FraudDate                 
            ,PrincOutStd            
            ,unserviedint                           
            ,FLGFITL           
            ,DFVAmt                      
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
           ,TwoFlag  
           ,TwoDate  
           ,ApprovedByFirstLevel  
           ,DateApprovedFirstLevel  
           ,MOC_Reason  
           ,MOCProcessed  
             )    
          Select    
            
            B.DerivativeEntityID    
            ,C.CustomerEntityId  
            ,A.AdditionalProvisionAbsolute  
             ,A.FraudAccountFlag         
            ,A.FraudDate                         
            ,A.POS            
            ,A.InterestReceivable        
             ,A.FITLFlag           
            ,A.DFVAmount                         
            ,A.MOCSource                     
              ,A.MOCDate  
              ,A.CreatedBy      
              ,A.AuthorisationStatus    
              ,A.EffectiveFromTimeKey    
              ,A.EffectiveToTimeKey     
              ,A.CreatedBy    
              ,A.DateCreated    
              ,A.ModifyBy     
              ,A.DateModified     
              ,A.ApprovedBy       
              ,A.DateApproved                        
              ,'ACCT' MOCType_Flag  
                 ,A.FlgTwo  
              ,A.TwoDate  
              ,a.ApprovedByFirstLevel  
              ,a.DateApprovedFirstLevel  
              ,MOCReason  
              ,'N'  
              FROM CalypsoAccountLevelMOC_MOd A  
     inner join  curdat.DerivativeDetail B  
     ON          A.AccountID=B.DerivativeRefNo  
     AND         B.EffectiveFromTimeKey <=@Timekey AND B.EffectiveToTimeKey>=@Timekey  
      LEFT join  Advacbasicdetail  C  
     ON          A.AccountID=C.CustomerACID  
     AND         C.EffectiveFromTimeKey <=@Timekey AND C.EffectiveToTimeKey>=@Timekey  
   WHERE        A.UploadId=@UniqueUploadID AND A.EffectiveFromTimeKey <=@Timekey AND A.EffectiveToTimeKey>=@Timekey  
            AND        A.AuthorisationStatus = 'A'  
   END  
     
  
    UPDATE  
    ExcelUploadHistory  
    SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()  
    WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey  
    AND UniqueUploadID=@UniqueUploadID  
    AND UploadType='Calypso Account MOC Upload'   
  
     END  
     
  
  
end  
  
  
 IF (@OperationFlag=17)----REJECT  
  
 BEGIN  
    
  UPDATE   
   CalypsoAccountLevelMOC_Mod   
   SET   
   AuthorisationStatus ='R'  
   ,ApprovedByFirstLevel =@UserLoginID  
   ,DateApprovedFirstLevel =GETDATE()  
   ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
   WHERE UploadId=@UniqueUploadID  
   AND AuthorisationStatus='NP'  
  
    
   UPDATE  
    ExcelUploadHistory  
    SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()  
    WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey  
    AND UniqueUploadID=@UniqueUploadID  
    AND UploadType='Calypso Account MOC Upload'  
  
  
  
 END  
  
IF (@OperationFlag=21)----REJECT  
  
 BEGIN  
    
  UPDATE   
   CalypsoAccountLevelMOC_Mod   
   SET   
   AuthorisationStatus ='R'  
   ,ApprovedBy =@UserLoginID  
   ,DateApproved =GETDATE()  
   ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
   WHERE UploadId=@UniqueUploadID  
   AND AuthorisationStatus in('NP','1A')  
  
     
  
   UPDATE  
    ExcelUploadHistory  
    SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()  
    WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey  
    AND UniqueUploadID=@UniqueUploadID  
    AND UploadType='Calypso Account MOC Upload'  
  
  
  
 END  
  
  
END  
  
IF @OperationFlag IN (1,2,3,16,17,18,20,21) AND @AuthMode ='Y'  
  BEGIN  
     print 'log table'  
  
     declare @DateCreated datetime  
    SET @DateCreated     =Getdate()  
  
    declare @ReferenceID1 varchar(max)  
    set @ReferenceID1 = (case when @OperationFlag in (16,20,21) then @UniqueUploadID else @ExcelUploadId end)  
  
  
     IF @OperationFlag IN(16,17,18,20,21)   
      BEGIN   
             Print 'Authorised'  
       
     
        EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE  
           @BranchCode=''   ,  ----BranchCode  
        @MenuID=@MenuID,  
        @ReferenceID=@UniqueUploadID ,-- ReferenceID ,  
        @CreatedBy=NULL,  
        @ApprovedBy=@UserLoginID,   
        @CreatedCheckedDt=@DateCreated,  
        @Remark=NULL,  
        @ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen  
        @Flag=@OperationFlag,  
        @AuthMode=@AuthMode  
      END  
     ELSE  
      BEGIN  
             Print 'UNAuthorised'  
          -- Declare  
          -- set @CreatedBy  =@UserLoginID  
          
       EXEC LogDetailsInsertUpdate_Attendence -- MAINTAIN LOG TABLE  
        @BranchCode=''   ,  ----BranchCode  
        @MenuID=@MenuID,  
        @ReferenceID=@ExcelUploadId ,-- ReferenceID ,  
        @CreatedBy=@UserLoginID,  
        @ApprovedBy=NULL,         
        @CreatedCheckedDt=@DateCreated,  
        @Remark=NULL,  
        @ScreenEntityAlt_Key=16  ,---ScreenEntityId -- for FXT060 screen  
        @Flag=@OperationFlag,  
        @AuthMode=@AuthMode  
      END  
  
  END  
  
 --COMMIT TRAN  
  ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END  
  SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=24749 THEN @ExcelUploadId   
     ELSE 1 END  
  
    
   Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath  
  
   ---- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filEname=@FilePathUpload)  
   ----BEGIN  
   ----  DELETE FROM IBPCPoolDetail_stg  
   ----  WHERE filEname=@FilePathUpload  
  
   ----  PRINT 'ROWS DELETED FROM IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))  
   ----END  
     
  
  RETURN @Result  
  ------RETURN @UniqueUploadID  
 END TRY  
 BEGIN CATCH   
    --ROLLBACK TRAN  
 SELECT ERROR_MESSAGE(),ERROR_LINE()  
 SET @Result=-1  
  Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath  
 RETURN -1  
 END CATCH  
 
 END
--END   commeted on 07/02/2024
  
  
  
GO