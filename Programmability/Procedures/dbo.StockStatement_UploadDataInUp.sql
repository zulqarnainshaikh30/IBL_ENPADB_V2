﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

 

 

--sp_rename 'StockStatement_UploadDataInUp','StockStatement_UploadDataInUp'

 

create PROCEDURE  [dbo].[StockStatement_UploadDataInUp]

      @Timekey INT,

      @UserLoginID VARCHAR(100),

      @OperationFlag INT,

      @MenuId INT,

      @AuthMode   CHAR(1),

      @filepath VARCHAR(MAX),

      @EffectiveFromTimeKey INT,

      @EffectiveToTimeKey     INT,

    @Result       INT=0 OUTPUT,

      @UniqueUploadID INT

      --@Authlevel varchar(5)

 

AS

 

--DECLARE @Timekey INT=24928,

--    @UserLoginID VARCHAR(100)='FNAOPERATOR',

--    @OperationFlag INT=1,

--    @MenuId INT=24742,

--    @AuthMode   CHAR(1)='N',

--    @filepath VARCHAR(MAX)='',

--    @EffectiveFromTimeKey INT=24928,

--    @EffectiveToTimeKey     INT=49999,

--    @Result           INT=0 ,

--    @UniqueUploadID INT=41

BEGIN

SET DATEFORMAT DMY

      SET NOCOUNT ON;

      --Declare @CollIDAutoGenerated   Int

--   Declare @CollateralID            varchar(30)=''

   --DECLARE @Timekey INT

   --SET @Timekey=(SELECT MAX(TIMEKEY) FROM dbo.SysProcessingCycle

                  --    WHERE ProcessType='Quarterly')

 

                  Set @Timekey=(

                  select CAST(B.timekey as int)from SysDataMatrix A

                  Inner Join SysDayMatrix B ON A.TimeKey=B.TimeKey

                   where A.CurrentStatus='C'

                   )

 

      PRINT @TIMEKEY

 

      SET @EffectiveFromTimeKey=@TimeKey

      SET @EffectiveToTimeKey=49999

 

 

      DECLARE @FilePathUpload VARCHAR(100)

                           SET @FilePathUpload=@UserLoginId+'_'+@filepath

                              PRINT '@FilePathUpload'

                              PRINT @FilePathUpload

 

 

            BEGIN TRY

 

            --BEGIN TRAN

            

IF (@MenuId=24742)

BEGIN

--Set @FilePathUpload='mismaker_CollateralUpload_3.xlsx'

--select * from SysCRisMacMenu where menucaption like '%Restru%'

      IF (@OperationFlag=1)

 

      BEGIN

 

            IF NOT (EXISTS (SELECT 1 FROM StockStatement_stg  where filname=@FilePathUpload))

 

                                          BEGIN

                                                       --Rollback tran

                                                      SET @Result=-8

 

                                                RETURN @Result

                                          END

                  

                   Print 'Sachin'

 

            IF EXISTS(SELECT 1 FROM StockStatement_stg WHERE filname=@FilePathUpload)

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

               ,'Stock Statement Upload'

               ,@EffectiveFromTimeKey

               ,@EffectiveToTimeKey

               ,@UserLoginID

               ,GETDATE()

 

               --sp

                     PRINT @@ROWCOUNT

 

               DECLARE @ExcelUploadId INT

      SET   @ExcelUploadId=(

      SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory

      )

            

                  Insert into UploadStatus (FileNames,UploadedBy,UploadDateTime,UploadType)

            Values(@filepath,@UserLoginID ,GETDATE(),'Stock Statement Upload')

 

 

PRINT '@ExcelUploadId'

PRINT @ExcelUploadId

       SET dateformat DMY

       --alter table StockStatement_Mod

       --add SrNo INT

 

       --IF exists (select 1 from StockStatement_Mod A

       --                         INNER JOIN StockStatement_stg B ON  A.CIF = B.CIF

            --                                                                      AND A.CustomerLimitSuffix = B.CustomerLimitSuffix

  --                           where @EffectiveFromTimeKey<=@Timekey and @EffectiveToTimeKey>=@Timekey

            --                                       and filname=@FilePathUpload)

             

 

            INSERT INTO [StockStatement_Mod]

            (

                  SrNo

              ,CIF

           

             ,UploadID

             ,CustomerLimitSuffix

             ,StockStamentDt

                 ,AccountID   

             ,AuthorisationStatus

             ,EffectiveFromTimeKey

             ,EffectiveToTimeKey

             ,CreatedBy

             ,DateCreated

             --,ModifiedBy

             --,DateModified

             --,ApprovedBy

             --,DateApproved

--D2Ktimestamp

            )

            

            SELECT

                          SrNo

                   ,CIF

                          

                           ,@ExcelUploadId

                   ,CustomerLimitSuffix

                 

                   ,Case When StockStatementDate<>'' Then  Convert(date,StockStatementDate) Else NULL END as StockStamentDt

                  --,AccountID

                          ,NULL

                            ,'NP'

                           ,@Timekey

                         ,49999

                      ,@UserLoginID

                         ,GETDATE()

                   

            --select *  

            FROM StockStatement_stg

            where filname=@FilePathUpload

 

            ---------------------------------------------------------ChangeField Logic---------------------

            ----select * from AccountLvlMOCDetails_stg

      IF OBJECT_ID('TempDB..#StockStatementUpload') Is Not Null

      Drop Table #StockStatementUpload

 

      Create TAble #StockStatementUpload

      (

      CIF Varchar(30), CustomerLimitSuffix Varchar(30),FieldName Varchar(50),SrNo Varchar(Max))

 

      Insert Into #StockStatementUpload(CIF,CustomerLimitSuffix,FieldName)

 

       Select CIF, CustomerLimitSuffix,'StockStatement' FieldName from StockStatement_stg Where isnull(StockStatementDate,'')<>''

 

 

      --select *

      Update B set B.SrNo=A.ScreenFieldNo

      from MetaScreenFieldDetail A

      Inner Join #StockStatementUpload B ON A.CtrlName=B.FieldName

      Where A.MenuId=@MenuId And A.IsVisible='Y'

 

 

            print 'nanda4'

      

                         IF OBJECT_ID('TEMPDB..#NEWTRANCHE')  IS NOT NULL

                              DROP TABLE #NEWTRANCHE

 

 

 

                                    SELECT * INTO #NEWTRANCHE FROM(

                                  SELECT

                                     SS.CIF,SS.CustomerLimitSuffix,

                                    STUFF((SELECT ',' + US.SrNo

                                          FROM #StockStatementUpload US

                                          WHERE US.CIF = SS.CIF AND US.CustomerLimitSuffix = SS.CustomerLimitSuffix

                                          FOR XML PATH('')), 1, 1, '') [REPORTIDSLIST]

                                    FROM StockStatement_stg SS

                                    GROUP BY SS.CIF,SS.CustomerLimitSuffix

                                    )B

                                    ORDER BY 1

                                    --Select * from #NEWTRANCHE

 

                              --SELECT *

                              UPDATE A SET A.ChangeFiels=B.REPORTIDSLIST

                              FROM DBO.StockStatement_Mod A

                              INNER JOIN #NEWTRANCHE B ON  A.CIF = B.CIF AND A.CustomerLimitSuffix = B.CustomerLimitSuffix

                              WHERE  A.EFFECTIVEFROMTIMEKEY=@TimeKey AND A.EFFECTIVETOTIMEKEY=@TimeKey

                              And A.UploadID=@ExcelUploadId

 

 

            

            ---DELETE FROM STAGING DATA Sachin

 

             DELETE FROM StockStatement_stg

             WHERE filname=@FilePathUpload

 

             --RETURN @ExcelUploadId

 

            

 

 

 

END

               ----DECLARE @UniqueUploadID INT

      --SET       @UniqueUploadID=(SELECT MAX(UniqueUploadID) FROM  ExcelUploadHistory)

      END

 

 

      IF (@OperationFlag=16)----AUTHORIZE

 

      BEGIN

            

            UPDATE

                  [StockStatement_Mod]

                  SET

                  AuthorisationStatus     ='1A'

                  ,FirstLevelApprovedBy   =@UserLoginID

                  ,FirstLevelDateApproved =GETDATE()

                  

                  WHERE UploadId=@UniqueUploadID

 

      

 

 

                  UPDATE

                        ExcelUploadHistory

                        SET AuthorisationStatus='1A',

                        ApprovedByFirstLevel=@UserLoginID,

                        DateApprovedFirstLevel=GETDATE()

                        WHERE UniqueUploadID=@UniqueUploadID

                        AND UploadType='Stock Statement Upload'

                        

 

      End

      IF (@OperationFlag=20)----AUTHORIZE

 

      BEGIN

            

            UPDATE

                  [StockStatement_Mod]

                  SET

                  AuthorisationStatus     ='A'

                  ,ApprovedBy =@UserLoginID

                  ,DateApproved     =GETDATE()

                  ,CreatedBy= CreatedBy

                  ,DateCreated = DateCreated

                  ,ModifiedBy = ModifiedBy

                  ,DateModified = DateModified

                  

                  WHERE UploadId=@UniqueUploadID

          

               select * into #Data from StockStatement where EffectiveToTimeKey=49999

 

                BEGIN

                    Update   A

                    set A.EffectiveToTimeKey=A.EffectiveFromTimeKey-1

                     FROM StockStatement A

                    INNER JOIN StockStatement_Mod B

                    ON  A.CIF = B.CIF

                    AND A.CustomerLimitSuffix = B.CustomerLimitSuffix

                    WHERE A.EffectiveFromTimeKey=@Timekey AND A.EffectiveToTimeKey=@Timekey

                    and B.AuthorisationStatus   ='A'

                   

             END

                        INSERT INTO [StockStatement]

            (     SrNo

              ,CIF

              ,AccountID

             ,CustomerLimitSuffix

             ,StockStamentDt

              ,AccountEntityID      

             ,AuthorisationStatus

             ,EffectiveFromTimeKey

             ,EffectiveToTimeKey

             ,CreatedBy

             ,DateCreated

             --,ModifiedBy

             --,DateModified

             ,ApprovedBy

             ,DateApproved

 

            )

 

            Select

                   A.SrNo

              ,A.CIF

           

              ,A.AccountID

             ,A.CustomerLimitSuffix

             ,B.StockStamentDt

              ,A.AccountEntityID    

             ,B.AuthorisationStatus

             ,@Timekey

                    ,49999

             ,B.CreatedBy

             ,B.DateCreated

                   ,@UserLoginID

                   ,GetDate()

 

                    From #Data A

      INNER JOIN  StockStatement_Mod B

      ON A.CIF=B.CIF     and A.CustomerLimitSuffix=B.CustomerLimitSuffix

                        

                  

                     WHERE --A.EffectiveFromTimeKey<=26372 and A.EffectiveToTimeKey>=26372

                        B.UploadId=@UniqueUploadID

                         -- and A.EffectiveToTimeKey>=@Timekey

 

                        

                  --Update A  

                  --SET A.StockStamentDt=B.StockStamentDt

                  --FROM StockStatement A

                  --INNER JOIN StockStatement_Mod B ON A.CIF = B.CIF AND A.CustomerLimitSuffix = B.CustomerLimitSuffix

                  --WHERE  B.UploadId=@UniqueUploadID and B.EffectiveToTimeKey>=@Timekey

                  

 

                        UPDATE

                        ExcelUploadHistory

                        SET AuthorisationStatus='A',ApprovedBy=@UserLoginID,DateApproved=GETDATE()

                        WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

                        AND UniqueUploadID=@UniqueUploadID

                        AND UploadType='Stock Statement Upload'

 

                        

 

 

      END

 

 

      IF (@OperationFlag=17)----REJECT

 

      BEGIN

            

            UPDATE

                  [StockStatement_Mod]

                  SET

                  AuthorisationStatus     ='R'

                  ,EffectiveToTimeKey=@Timekey-1

                  --,ApprovedBy     =@UserLoginID

                  --,DateApproved   =GETDATE()

                  ,FirstLevelApprovedBy   =@UserLoginID

                  ,FirstLevelDateApproved =GETDATE()

                  

                  WHERE UploadId=@UniqueUploadID

                  AND AuthorisationStatus='NP'

 

                  ----SELECT * FROM IBPCPoolDetail

 

                  UPDATE

                        ExcelUploadHistory

                        SET AuthorisationStatus='R',ApprovedBy=@UserLoginID,DateApproved=GETDATE()

                        WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

                        AND UniqueUploadID=@UniqueUploadID

                        AND UploadType='Stock Statement Upload'

 

 

 

      END

 

IF (@OperationFlag=21)----REJECT

 

      BEGIN

            

            UPDATE

                  [StockStatement_Mod]

                  SET

                  AuthorisationStatus     ='R'

                  ,EffectiveToTimeKey=@Timekey-1

                  ,ApprovedBy =@UserLoginID

                  ,DateApproved     =GETDATE()              

                  WHERE UploadId=@UniqueUploadID

                  AND AuthorisationStatus in('NP','1A')

 

            

 

                  UPDATE

                        ExcelUploadHistory

                        SET AuthorisationStatus='R',ApprovedByFirstLevel=@UserLoginID,DateApprovedFirstLevel=GETDATE()

                        WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey

                        AND UniqueUploadID=@UniqueUploadID

                        AND UploadType='Stock Statement Upload'

 

 

 

      END

 

 

END

 

 

      --COMMIT TRAN

            ---SET @Result=CASE WHEN  @OperationFlag=1 THEN @UniqueUploadID ELSE 1 END

            SET @Result=CASE WHEN  @OperationFlag=1 AND @MenuId=24742 THEN @ExcelUploadId

                              ELSE 1 END

 

            

             Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath

 

             ---- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filEname=@FilePathUpload)

             ----BEGIN

                  ----   DELETE FROM IBPCPoolDetail_stg

                  ----   WHERE filEname=@FilePathUpload

 

                  ----   PRINT 'ROWS DELETED FROM IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))

             ----END

            

 

            RETURN @Result

            --RETURN @ExcelUploadId

      END TRY

      BEGIN CATCH

         --ROLLBACK TRAN

      SELECT ERROR_MESSAGE(),ERROR_LINE()

      SET @Result=-1

       Update UploadStatus Set InsertionOfData='Y',InsertionCompletedOn=GETDATE() where FileNames=@filepath

      RETURN -1

      END CATCH

 

END

 
GO