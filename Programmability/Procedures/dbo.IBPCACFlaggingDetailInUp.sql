SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


-- =============================================  
-- Author:    <Vasundhara>  
-- Create date:   <09/03/2021>  
-- Description:   <Account Flagging For IBPC Table Insert/ Update>  
-- =============================================  
CREATE PROCEDURE [dbo].[IBPCACFlaggingDetailInUp]  
    
  @AccountFlagAlt_Key INT    = 0   
  ,@SourceAlt_Key  INT    = 0   
  ,@SourceName  varchar(30)   =null  
  ,@AccountID  varchar(30)   =null  
  ,@CustomerID  varchar(30)   =null  
  ,@CustomerName  varchar(30)   =null  
  ,@FlagAlt_Key  varchar(30)   =null  
  --,@PoolID   int     =NULL  
  ,@PoolID   varchar(30)   =NULL  
  ,@PoolName   varchar(30)   =NULL  
  ,@AccountBalance  Decimal(18,2)  =NULL  
  ,@POS     Decimal(18,2)  =NULL  
  ,@InterestReceivable Decimal(18,2)  =NULL  
  ,@ExposureAmount Decimal(18,2)  =NULL  
 ,@ChangeFields  varchar(200) =null  
  ,@ErrorHandle    int    = 0    
  ,@ExEntityKey  int    = 0  
 ,@IBPCACFlaggingDetail_changefields varchar(100)=null
 ,@PoolType Varchar(30)=Null
 ,@MaturityDate Varchar(20)=Null
 ,@IBPCMarkingDate Varchar(20)=Null
  ---------D2k System Common Columns  --  
  ,@Remark     VARCHAR(500) = ''  
  ,@MenuID     SMALLINT  = 0  
  ,@OperationFlag    TINYINT   = 0  
  ,@AuthMode     CHAR(1)   = 'N'  
  ,@IsMOC      CHAR(1)   = 'N'  
  ,@EffectiveFromTimeKey  INT  = 0  
  ,@EffectiveToTimeKey  INT  = 0  
  ,@TimeKey     INT  = 0  
  ,@CrModApBy     VARCHAR(20)  =''  
  ,@D2Ktimestamp    INT    =0 OUTPUT   
  ,@Result     int    =0 OUTPUT  
   
AS  
BEGIN  
 SET NOCOUNT ON;  
  PRINT 1  

  DECLARE @Parameter varchar(max) = (select 'Source System |' + convert(varchar,ISNULL(@SourceAlt_Key,' ')) + '}'+ 'Account ID|' + isnull(@AccountID,' ')
	+ '}'+ 'Customer ID|'+isnull(@CustomerID,'')+ '}'+ 'Customer Name|'+isnull(@CustomerName,'')+ '}'+ 'Flag|'+isnull(@FlagAlt_Key,'')
	+ '}'+ 'Pool ID|'+isnull(@PoolID,'')+ '}'+ 'Pool Name |'+isnull(@PoolName,'')+ '}'+ 'Amount Balance|'+convert(varchar,isnull(@AccountBalance,''))
	+ '}'+ 'POS|'+convert(varchar,isnull(@POS,''))+ '}'+ 'Interest Receivable Amount|'+convert(varchar,isnull(@InterestReceivable,''))+ '}'+ 'Exposure Amount |'+convert(varchar,isnull(@ExposureAmount,'')))
	--DECLARE		@Result					INT				=0 
	exec SecurityCheckDataValidation 14571 ,@Parameter,@Result OUTPUT
				
	IF @Result = -1
	return -1

  DECLARE   
  
      @AuthorisationStatus  VARCHAR(5)   = NULL   
      ,@CreatedBy     VARCHAR(20)  = NULL    
	  ,@DateCreated    SmallDATETIME = NULL  
      ,@ModifiedBy    VARCHAR(20)  = NULL  
	   ,@DateModified    SmallDATETIME = NULL  
      ,@ApprovedBy    VARCHAR(20)  = NULL  
	   ,@DateApproved    SmallDATETIME = NULL
	   ,@ApprovedByFirstLevel		VARCHAR(20)		= NULL --updated by vinit
		,@DateApprovedFirstLevel	 SmallDATETIME	= NULL --updated by vinit


	  ----Added on 26-03-2021

			SET @Timekey=(select CAST(B.timekey as int)from SysDataMatrix A
			Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey
			 where A.CurrentStatus='C')

	PRINT @TIMEKEY

	SET @EffectiveFromTimeKey=@TimeKey
	SET @EffectiveToTimeKey=49999

	SET DATEFORMAT DMY
  
IF @OperationFlag=1  --- add  
 BEGIN  
 PRINT 1  
  -----CHECK DUPLICATE BILL NO AT BRANCH LEVEL  
  IF EXISTS(                      
     SELECT  1 FROM [dbo].[IBPCACFlaggingDetail] WHERE AccountId=@AccountID AND ISNULL(AuthorisationStatus,'A')='A'   
     UNION  
     SELECT  1 FROM [dbo].[IBPCACFlaggingDetail_Mod]  WHERE (EffectiveFromTimeKey <=@TimeKey AND EffectiveToTimeKey >=@TimeKey)  
               AND AccountId=@AccountID  
               AND  AuthorisationStatus in('NP','MP','DP','A','RM')   
    )   
    BEGIN  
       PRINT 2  
     SET @Result=-4  
     RETURN @Result -- CUSTOMERID ALEADY EXISTS  
    END  
 END  
  
 BEGIN TRY  
 --BEGIN TRANSACTION   
 -----  
   
 PRINT 3   
  --np- new,  mp - modified, dp - delete, fm - further modifief, A- AUTHORISED , 'RM' - REMARK   
 IF @OperationFlag =1 AND @AuthMode ='Y' -- ADD  
  BEGIN  
         PRINT 'Add'  
      SET @CreatedBy = @CrModApBy   
      SET @DateCreated = GETDATE()  
      SET @AuthorisationStatus='NP'  
      GOTO IBPCACFlaggingDetail_Insert  
     IBPCACFlaggingDetail_Insert_Add:  
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
     FROM [dbo].[IBPCACFlaggingDetail]  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND AccountID =@AccountID  
  
     ---FIND CREATED BY FROM MAIN TABLE IN CASE OF DATA IS NOT AVAILABLE IN MAIN TABLE  
    IF ISNULL(@CreatedBy,'')=''  
    BEGIN  
     PRINT 'NOT AVAILABLE IN MAIN'  
     SELECT  @CreatedBy  = CreatedBy  
       ,@DateCreated = DateCreated   
     FROM [dbo].[IBPCACFlaggingDetail_Mod]  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND AccountID =@AccountID         
       AND AuthorisationStatus IN('NP','MP','A','RM')  
    END  
    ELSE ---IF DATA IS AVAILABLE IN MAIN TABLE  
     BEGIN  
            Print 'AVAILABLE IN MAIN'  
      ----UPDATE FLAG IN MAIN TABLES AS MP  
      UPDATE [dbo].[IBPCACFlaggingDetail]  
       SET AuthorisationStatus=TRIM(@AuthorisationStatus)
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND AccountID =@AccountID  
  
     END  
     --UPDATE NP,MP  STATUS   
     IF @OperationFlag=2  
     BEGIN   
  
      UPDATE IBPCACFlaggingDetail_Mod  
       SET AuthorisationStatus='FM'  
       ,ModifiedBy=@Modifiedby  
	   --,@DateCreated = DateCreated  --update by vinit
       ,DateModified=@DateModified  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
        AND AccountID =@AccountID  
        AND AuthorisationStatus IN('NP','MP','RM')  
     END  
  
     --GOTO AdvFacBillDetail_Insert  
     --AdvFacBillDetail_Insert_Edit_Delete:  
     GOTO IBPCACFlaggingDetail_Insert  
     IBPCACFlaggingDetail_Insert_Edit_Delete:  
    END  
  
   ELSE IF @OperationFlag =3 AND @AuthMode ='N'  
  BEGIN  
  -- DELETE WITHOUT MAKER CHECKER  
             
      SET @Modifiedby   = @CrModApBy   
      SET @DateModified = GETDATE()   
  
      UPDATE  IBPCACFlaggingDetail SET   
         ModifiedBy =@Modifiedby   
         ,DateModified =@DateModified   
         ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
        WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND AccountID=@AccountID  
      
  
  END 
  ------------------------------------------------------------------
  ELSE IF @OperationFlag=21 AND @AuthMode ='Y' 
		BEGIN
				SET @ApprovedBy	   = @CrModApBy 
				SET @DateApproved  = GETDATE()

				UPDATE IBPCACFlaggingDetail_Mod
					SET AuthorisationStatus='R'
					,ApprovedBy	 =@ApprovedBy
					,DateApproved=@DateApproved
					,EffectiveToTimeKey =@EffectiveFromTimeKey-1
				WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
						AND AccountID =@AccountID 
						AND AuthorisationStatus in('NP','MP','DP','RM','1A')	

		IF EXISTS(SELECT 1 FROM IBPCACFlaggingDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) 
		                                  AND AccountID =@AccountID )
				BEGIN
					UPDATE IBPCACFlaggingDetail
						SET AuthorisationStatus='A'
					WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)
							AND AccountID =@AccountID 
							AND AuthorisationStatus IN('MP','DP','RM') 	
				END
		END	

  --------------------------------------------------------------
  
   
  ELSE IF @OperationFlag=17 AND @AuthMode ='Y'   
  BEGIN  
    SET @ApprovedBy    = @CrModApBy   
    SET @DateApproved  = GETDATE()  
  
    UPDATE IBPCACFlaggingDetail_Mod  
     SET AuthorisationStatus='R'  
     ,ApprovedByFirstLevel  =@ApprovedBy  
     ,DateApprovedFirstLevel=@DateApproved  
     ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
    WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
      AND AccountID =@AccountID  
      AND AuthorisationStatus in('NP','MP','DP','RM')   
  
    IF EXISTS(SELECT 1 FROM IBPCACFlaggingDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@Timekey) AND AccountID=@AccountID)  
    BEGIN  
     UPDATE IBPCACFlaggingDetail  
      SET AuthorisationStatus='A'  
     WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
       AND AccountID =@AccountID  
       AND AuthorisationStatus IN('MP','DP','RM')    
    END  
  END   
  
  ELSE IF @OperationFlag=18  
 BEGIN  
  PRINT 18  
  SET @ApprovedBy=@CrModApBy  
  SET @DateApproved=GETDATE()  
  UPDATE IBPCACFlaggingDetail_Mod  
  SET AuthorisationStatus='RM'  
  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
  AND AuthorisationStatus IN('NP','MP','DP','RM')  
  AND AccountId=@AccountID   
  
 END
 -------------------------------------------------
 ELSE IF @OperationFlag=16

		BEGIN 
		--SET @ApprovedBy	   = @CrModApBy 
		--SET @DateApproved  = GETDATE()
		SET @ApprovedByFirstLevel	 = @CrModApBy 
		SET @DateApprovedFirstLevel  = GETDATE()
		Set @ModifiedBy = @CrModApBy --updated by vinit

		UPDATE IBPCACFlaggingDetail_Mod
						   SET AuthorisationStatus ='1A'
							,ApprovedByFirstLevel=@ApprovedByFirstLevel --select ApprovedByFirstLevel,ModifiedBy from DimGLProduct_AU_Mod
							,DateApprovedFirstLevel=@DateApprovedFirstLevel
							,ModifiedBy =@ModifiedBy --updated by vinit
							WHERE AccountId=@AccountID
							AND AuthorisationStatus in('NP','MP','DP','RM')

		END

 -------------------------------------------  
  
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
      SELECT @CreatedBy=CreatedBy,@DateCreated=DATECreated  
      FROM  [dbo].[IBPCACFlaggingDetail]  
      WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey >=@TimeKey )  
       AND AccountID=@AccountID   
       
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
     SELECT @ExEntityKey= MAX(Entity_Key) FROM [dbo].[IBPCACFlaggingDetail_Mod]  
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND AccountID=@AccountID  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
  
     SELECT @DelStatus=AuthorisationStatus,@CreatedBy=CreatedBy,@DateCreated=DATECreated  
      ,@ModifiedBy=ModifiedBy, @DateModified=DateModified  
      FROM IBPCACFlaggingDetail_Mod  
      WHERE Entity_Key=@ExEntityKey  
       
     SET @ApprovedBy = @CrModApBy     
     SET @DateApproved=GETDATE()  
      
       
     DECLARE @CurEntityKey INT=0  
  
     SELECT @ExEntityKey= MIN(Entity_Key) FROM IBPCACFlaggingDetail_Mod   
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)   
       AND AccountID=@AccountID  
       AND AuthorisationStatus IN('NP','MP','DP','RM','1A')   
      
     SELECT @CurrRecordFromTimeKey=EffectiveFromTimeKey   
       FROM IBPCACFlaggingDetail_Mod  
       WHERE Entity_Key=@ExEntityKey  
  
     UPDATE IBPCACFlaggingDetail_Mod  
      SET  EffectiveToTimeKey =@CurrRecordFromTimeKey-1  
      WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
      AND AccountID=@AccountID  
      AND AuthorisationStatus='A'   
  
  -------DELETE RECORD AUTHORISE  
     IF @DelStatus='DP'   
     BEGIN   
      UPDATE IBPCACFlaggingDetail_Mod  
      SET AuthorisationStatus ='A'  
       ,ApprovedBy=@ApprovedBy  
       ,DateApproved=@DateApproved  
       ,EffectiveToTimeKey =@EffectiveFromTimeKey -1  
      WHERE AccountID=@AccountID  
       AND AuthorisationStatus in('NP','MP','DP','RM','1A')  
  
     IF EXISTS(SELECT 1 FROM IBPCACFlaggingDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
          AND AccountID=@AccountID)  
      BEGIN  
        UPDATE IBPCACFlaggingDetail  
         SET AuthorisationStatus ='A'  
          ,ModifiedBy=@ModifiedBy  
          ,DateModified=@DateModified  
          ,ApprovedBy=@ApprovedBy  
          ,DateApproved=@DateApproved  
          ,EffectiveToTimeKey =@EffectiveFromTimeKey-1  
         WHERE (EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey >=@Timekey)  
           AND AccountID=@AccountID  
      END  
     END -- END OF DELETE BLOCK  
  
     ELSE  -- OTHER THAN DELETE STATUS  
     BEGIN  
       UPDATE IBPCACFlaggingDetail_Mod  
			 SET AuthorisationStatus ='A'  
			    ,ModifiedBy =@CrModApBy --updated by vinit 
			    ,ApprovedBy=@CrModApBy 
			    ,DateApproved = getdate() 
        WHERE AccountID=@AccountID      
         AND AuthorisationStatus in('NP','MP','RM','1A')  
     END    
    END  
  
    IF @DelStatus <>'DP' OR @AuthMode ='N'  
    BEGIN  
      DECLARE @IsAvailable CHAR(1)='N'  
      ,@IsSCD2 CHAR(1)='N'  
  
      IF EXISTS(SELECT 1 FROM IBPCACFlaggingDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)  
          AND AccountID=@AccountID)  
       BEGIN  
        SET @IsAvailable='Y'  
        SET @AuthorisationStatus='A'  
  
        IF EXISTS(SELECT 1 FROM IBPCACFlaggingDetail WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@TimeKey AND AccountID=@AccountID)  
         BEGIN  
           PRINT 'BBBB'  
          UPDATE IBPCACFlaggingDetail SET  
                           
             AccountFlagAlt_Key =@AccountFlagAlt_Key  
             ,SourceAlt_Key  =@SourceAlt_Key   
             ,SourceName  =@SourceName  
             ,AccountID   =@AccountID   
             ,CustomerID  =@CustomerID    
             ,CustomerName  =@CustomerName    
             ,FlagAlt_Key  =@FlagAlt_Key    
             ,PoolID   =@PoolID     
             ,PoolName   =@PoolName     
             ,AccountBalance =@AccountBalance   
             ,POS    =@POS      
             ,InterestReceivable=@InterestReceivable
			 ,ExposureAmount=@ExposureAmount
			 ,PoolType=@PoolType
			 ,MaturityDate=Case when isnull(@MaturityDate,'')='' then Null else convert(Date,@MaturityDate,105) ENd
			 ,IBPCMarkingDate=Case when isnull(@IBPCMarkingDate,'')='' then Null else convert(Date,@IBPCMarkingDate,105) ENd
            ,ModifiedBy=@ModifiedBy  
            ,DateModified=@DateModified  
            ,ApprovedBy     = CASE WHEN @AuthMode ='Y' THEN @ApprovedBy ELSE NULL END  
            ,DateApproved    = CASE WHEN @AuthMode ='Y' THEN @DateApproved ELSE NULL END  
            ,AuthorisationStatus  = CASE WHEN @AuthMode ='Y' THEN  'A' ELSE NULL END 
			,Remark=@Remark 
  
             WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey)   
            AND EffectiveFromTimeKey=@EffectiveFromTimeKey AND AccountID=@AccountID  
  
  
  
          END   
  
         ELSE  
          BEGIN  
           SET @IsSCD2='Y'  
          END  
        END  
              IF @IsAvailable='N' OR @IsSCD2='Y'  
         BEGIN  
          INSERT INTO IBPCACFlaggingDetail  
          (    --Entity_Key  
              AccountFlagAlt_Key  
             ,SourceAlt_Key  
             ,SourceName  
             ,AccountID  
             ,CustomerID  
             ,CustomerName  
             ,FlagAlt_Key  
             ,PoolID  
             ,PoolName  
             ,AccountBalance  
             ,POS  
             ,InterestReceivable
			 ,ExposureAmount
			 ,PoolType
			 ,MaturityDate
			 ,IBPCMarkingDate
              ,AuthorisationStatus  
			  ,Remark
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
           (   @AccountFlagAlt_Key  
             ,@SourceAlt_Key  
             ,@SourceName  
             ,@AccountID  
             ,@CustomerID  
             ,@CustomerName  
             ,@FlagAlt_Key  
             ,@PoolID  
             ,@PoolName  
             ,@AccountBalance  
             ,@POS  
             ,@InterestReceivable
			 ,@ExposureAmount
			 ,@PoolType
			 ,Case when isnull(@MaturityDate,'')='' then Null else convert(Date,@MaturityDate,105) ENd
			 ,Case when isnull(@IBPCMarkingDate,'')='' then Null else convert(Date,@IBPCMarkingDate,105) ENd 
              --,trim(@AuthorisationStatus)
			  ,@AuthorisationStatus
			  ,@Remark
              ,@EffectiveFromTimeKey  
              ,@EffectiveToTimeKey  
              ,@CreatedBy  
              ,@DateCreated  
              ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END  
              ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END  
              ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END  
              ,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END  
             -- ,@D2Ktimestamp  
              )  
  
  
  -----------
  
  Print 'Sunil111'
		  IF @FlagAlt_Key='Y'
        BEGIN  
          INSERT INTO IBPCFinalPoolDetail  
          (    --Entity_Key  
              --AccountFlagAlt_Key  
             SourceAlt_Key  
             ,SourceName  
             ,AccountID  
             ,CustomerID  
             ,CustomerName  
             ,FlagAlt_Key  
             ,PoolID  
             ,PoolName  
             ,AccountBalance  
             ,POS  
             ,InterestReceivable
			 ,ExposureAmount
			 ,PoolType
			 ,MaturityDate
			 ,IBPCMarkingDate
              ,AuthorisationStatus  
			  ,Remark
              ,EffectiveFromTimeKey  
              ,EffectiveToTimeKey  
              ,CreatedBy  
              ,DateCreated  
              ,ModifyBy  
              ,DateModified  
              ,ApprovedBy  
              ,DateApproved  
			  ,IBPCinDate  ----new add
             -- ,D2Ktimestamp  
            )  
  
         VALUES     
           (  -- @AccountFlagAlt_Key  
             @SourceAlt_Key  
             ,@SourceName  
             ,@AccountID  
             ,@CustomerID  
             ,@CustomerName  
             ,@FlagAlt_Key  
             ,@PoolID  
             ,@PoolName  
             ,@AccountBalance  
             ,@POS  
             ,@InterestReceivable
			 ,@ExposureAmount
			 ,@PoolType
			 ,Case when isnull(@MaturityDate,'')='' then Null else convert(Date,@MaturityDate,105) ENd
			 ,Case when isnull(@IBPCMarkingDate,'')='' then Null else convert(Date,@IBPCMarkingDate,105) ENd 
              --,trim(@AuthorisationStatus)
			  ,@AuthorisationStatus
			  ,@Remark
              ,@EffectiveFromTimeKey  
              ,@EffectiveToTimeKey  
              ,@CreatedBy  
              ,@DateCreated  
              ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END  
              ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END  
              ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END  
              ,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END 
			  ,GETDATE()   --new add
             -- ,@D2Ktimestamp  
              )  
		  /*Adding Flag ----------Pranay 21-03-2021*/
		  UPDATE A
			SET  
				A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'IBPC'     
								ELSE A.SplFlag+','+'IBPC'     END
		   
		   FROM DBO.AdvAcOtherDetail A
		   Where A.EffectiveToTimeKey=49999 and A.RefSystemAcId=@AccountID
   

          END  
		  --ELSE

		  IF @FlagAlt_Key='N'

		  BEGIN
		   UPDATE IBPCFinalPoolDetail SET  
          EffectiveToTimeKey=@EffectiveFromTimeKey-1 
		  ,IBPCOutDate=GETDATE()  -- new add
          ,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END 
		  ,FlagAlt_Key=@FlagAlt_Key 
		  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND AccountID=@AccountID  
         --WHERE (EffectiveFromTimeKey>=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND AccountID=@AccountID  
           --AND EffectiveFromTimekey<@EffectiveFromTimeKey 


		   UPDATE IBPCACFlaggingDetail SET  
          EffectiveToTimeKey=@EffectiveFromTimeKey-1 
		  ----,FlagAlt_Key=@FlagAlt_Key 
		  WHERE (EffectiveFromTimeKey<=@TimeKey AND EffectiveToTimeKey>=@TimeKey) AND AccountID=@AccountID 


		   ------------------REMOVE FLAG--------1) @FlagAlt_Key='Y' (in IBPCACFlaggingDetailInUp SP)



				IF OBJECT_ID('TempDB..#Temp') IS NOT NULL
				DROP TABLE #Temp

				Select AccountentityID,SplFlag into #Temp from Curdat.AdvAcOtherDetail 
				where EffectiveToTimeKey=49999 AND RefSystemAcId=@AccountID AND splflag like '%IBPC%'


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

				 DELETE FROM #SplitValue WHERE Businesscolvalues1='IBPC'




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



		  END
  
  --------------
          END  

		   IF @IsSCD2='Y'   
        BEGIN  
        UPDATE IBPCACFlaggingDetail SET  
          EffectiveToTimeKey=@EffectiveFromTimeKey-1  
         -- ,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END  update by vinit
		 ,AuthorisationStatus='A'
         WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND AccountID=@AccountID  
           AND EffectiveFromTimekey<@EffectiveFromTimeKey  
        END  
       END  
  IF @AUTHMODE='N'  
   BEGIN  
     SET @AuthorisationStatus='A'  
     --GOTO AdvFacBillDetail_Insert  
     GOTO IBPCACFlaggingDetail_Insert  
     HistoryRecordInUp:  
   END        
  
  
 

		 -- IF @FlagAlt_Key='Y'
   --     BEGIN  
   --       INSERT INTO IBPCFinalPoolDetail  
   --       (    --Entity_Key  
   --           --AccountFlagAlt_Key  
   --          SourceAlt_Key  
   --          ,SourceName  
   --          ,AccountID  
   --          ,CustomerID  
   --          ,CustomerName  
   --          ,FlagAlt_Key  
   --          ,PoolID  
   --          ,PoolName  
   --          ,AccountBalance  
   --          ,POS  
   --          ,InterestReceivable
			-- ,ExposureAmount
   --           ,AuthorisationStatus  
			--  ,Remark
   --           ,EffectiveFromTimeKey  
   --           ,EffectiveToTimeKey  
   --           ,CreatedBy  
   --           ,DateCreated  
   --           ,ModifyBy  
   --           ,DateModified  
   --           ,ApprovedBy  
   --           ,DateApproved  
			--  ,IBPCinDate  ----new add
   --          -- ,D2Ktimestamp  
   --         )  
  
   --      VALUES     
   --        (  -- @AccountFlagAlt_Key  
   --          @SourceAlt_Key  
   --          ,@SourceName  
   --          ,@AccountID  
   --          ,@CustomerID  
   --          ,@CustomerName  
   --          ,@FlagAlt_Key  
   --          ,@PoolID  
   --          ,@PoolName  
   --          ,@AccountBalance  
   --          ,@POS  
   --          ,@InterestReceivable
			-- ,@ExposureAmount
   --           --,trim(@AuthorisationStatus)
			--  ,@AuthorisationStatus
			--  ,@Remark
   --           ,@EffectiveFromTimeKey  
   --           ,@EffectiveToTimeKey  
   --           ,@CreatedBy  
   --           ,@DateCreated  
   --           ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy  ELSE NULL END  
   --           ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified  ELSE NULL END  
   --           ,CASE WHEN @AUTHMODE= 'Y' THEN    @ApprovedBy ELSE NULL END  
   --           ,CASE WHEN @AUTHMODE= 'Y' THEN    @DateApproved  ELSE NULL END 
			--  ,GETDATE()   --new add
   --          -- ,@D2Ktimestamp  
   --           )  
		 -- /*Adding Flag ----------Pranay 21-03-2021*/
		 -- UPDATE A
			--SET  
			--	A.SplFlag=CASE WHEN ISNULL(A.SplFlag,'')='' THEN 'IBPC'     
			--					ELSE A.SplFlag+','+'IBPC'     END
		   
		 --  FROM DBO.AdvAcOtherDetail A
		 --  Where A.EffectiveToTimeKey=49999 and A.RefSystemAcId=@AccountID
   

   --       END  
		 -- --ELSE

		 -- IF @FlagAlt_Key='N'

		 -- BEGIN
		 --  UPDATE IBPCFinalPoolDetail SET  
   --       EffectiveToTimeKey=@EffectiveFromTimeKey-1 
		 -- ,IBPCOutDate=GETDATE()  -- new add
   --       ,AuthorisationStatus =CASE WHEN @AUTHMODE='Y' THEN  'A' ELSE NULL END  
   --      WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey) AND AccountID=@AccountID  
   --        AND EffectiveFromTimekey<@EffectiveFromTimeKey 

		 --  ------------------REMOVE FLAG--------1) @FlagAlt_Key='Y' (in IBPCACFlaggingDetailInUp SP)



			--	IF OBJECT_ID('TempDB..#Temp') IS NOT NULL
			--	DROP TABLE #Temp

			--	Select AccountentityID,SplFlag into #Temp from Curdat.AdvAcOtherDetail 
			--	where EffectiveToTimeKey=49999 AND RefSystemAcId=@AccountID AND splflag like '%IBPC%'


			--	--Select * from #Temp


			--	IF OBJECT_ID('TEMPDB..#SplitValue')  IS NOT NULL
			--	DROP TABLE #SplitValue        
			--	SELECT AccountentityID,Split.a.value('.', 'VARCHAR(8000)') AS Businesscolvalues1  into #SplitValue
			--								FROM  (SELECT 
			--												CAST ('<M>' + REPLACE(SplFlag, ',', '</M><M>') + '</M>' AS XML) AS Businesscolvalues1,
			--												AccountentityID
			--												from #Temp 
			--										) AS A CROSS APPLY Businesscolvalues1.nodes ('/M') AS Split(a)
						


			--	 --Select * from #SplitValue 

			--	 DELETE FROM #SplitValue WHERE Businesscolvalues1='IBPC'




			--	 IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL
			--		DROP TABLE #NEWTRANCHE

			--		SELECT * INTO #NEWTRANCHE FROM(
			--		SELECT 
			--			 SS.AccountentityID,
			--			STUFF((SELECT ',' + US.BUSINESSCOLVALUES1 
			--				FROM #SPLITVALUE US
			--				WHERE US.AccountentityID = SS.AccountentityID
			--				FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]
			--			FROM #TEMP SS 
			--			GROUP BY SS.AccountentityID
			--			)B
			--			ORDER BY 1

			--			--Select * from #NEWTRANCHE

			--		--SELECT * 
			--		UPDATE A SET A.SplFlag=B.REPORTIDSLIST
			--		FROM DBO.AdvAcOtherDetail A
			--		INNER JOIN #NEWTRANCHE B ON A.AccountentityID=B.AccountentityID
			--		WHERE  A.EFFECTIVEFROMTIMEKEY<=@TimeKey AND A.EFFECTIVETOTIMEKEY>=@TimeKey



		 -- END
  
  END   
  
 PRINT 6  
SET @ErrorHandle=1  
  
IBPCACFlaggingDetail_Insert:  
IF @ErrorHandle=0  
 BEGIN  
   INSERT INTO IBPCACFlaggingDetail_Mod  
      ( --Entity_Key  
        AccountFlagAlt_Key  
       ,SourceAlt_Key  
       ,SourceName  
       ,AccountID  
       ,CustomerID  
       ,CustomerName  
       ,FlagAlt_Key  
       ,PoolID  
       ,PoolName  
       ,AccountBalance  
       ,POS  
       ,InterestReceivable
	   ,ExposureAmount
	   ,PoolType
	   ,MaturityDate
	   ,IBPCMarkingDate
        ,AuthorisationStatus  
        ,Remark  
        --,ChangeFields  
        ,EffectiveFromTimeKey  
        ,EffectiveToTimeKey  
        ,CreatedBy  
        ,DateCreated  
        ,ModifiedBy  
        ,DateModified  
        ,ApprovedBy  
        ,DateApproved  
		,changefields
       -- ,D2Ktimestamp  
      )  
  
    VALUES     
      (    @AccountFlagAlt_Key  
        ,@SourceAlt_Key  
        ,@SourceName  
        ,@AccountID  
        ,@CustomerID  
        ,@CustomerName  
        ,@FlagAlt_Key  
        ,@PoolID  
        ,@PoolName  
        ,@AccountBalance  
        ,@POS  
        ,@InterestReceivable
		,@ExposureAmount
		,@PoolType
		,Case when isnull(@MaturityDate,'')='' then Null else convert(Date,@MaturityDate,105) ENd
		,Case when isnull(@IBPCMarkingDate,'')='' then Null else convert(Date,@IBPCMarkingDate,105) ENd 
         ,trim(@AuthorisationStatus)
         ,@Remark  
         --,@ChangeFields  
         ,@EffectiveFromTimeKey  
         ,@EffectiveToTimeKey  
         ,@CreatedBy  
         ,@DateCreated  
         ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @ModifiedBy ELSE NULL END  
         ,CASE WHEN @AuthMode='Y' OR @IsAvailable='Y' THEN @DateModified ELSE NULL END  
         ,CASE WHEN @AuthMode='Y' THEN @ApprovedBy    ELSE NULL END  
         ,CASE WHEN @AuthMode='Y' THEN @DateApproved  ELSE NULL END 
		, @IBPCACFlaggingDetail_changefields
        -- ,@D2Ktimestamp  
         )  
		   DECLARE @Parameter3 varchar(50)
	DECLARE @FinalParameter3 varchar(50)
	SET @Parameter3 = (select STUFF((	SELECT Distinct ',' +ChangeFields
											from IBPCACFlaggingDetail_Mod  where AccountID=@AccountID   
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
							from		IBPCACFlaggingDetail_Mod    A
							WHERE		(EffectiveFromTimeKey<=@tiMEKEY AND EffectiveToTimeKey>=@tiMEKEY) 
							and		AccountID=@AccountID  									
										

  
  
     
 IF @OperationFlag =1 AND @AUTHMODE='Y'  
     BEGIN  
      PRINT 3  
      GOTO IBPCACFlaggingDetail_Insert_Add  
     END  
    ELSE IF (@OperationFlag =2 OR @OperationFlag =3)AND @AUTHMODE='Y'  
     BEGIN  
      GOTO IBPCACFlaggingDetail_Insert_Edit_Delete  
     END   
  
END  
-------------------  


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
 -- COMMIT TRANSACTION  
  
  SELECT @D2Ktimestamp=CAST(D2Ktimestamp AS INT) FROM [dbo].[IBPCACFlaggingDetail] WHERE (EffectiveFromTimeKey=EffectiveFromTimeKey AND EffectiveToTimeKey>=@TimeKey)   
                 AND AccountID=@AccountID  
  
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
 --ROLLBACK TRAN  
 SELECT ERROR_MESSAGE()  
 RETURN -1  
  
END CATCH  
---------  
END  
 
GO