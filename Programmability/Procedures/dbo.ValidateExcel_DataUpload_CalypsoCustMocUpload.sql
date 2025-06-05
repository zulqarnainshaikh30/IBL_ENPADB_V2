SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_CalypsoCustMocUpload]  
@MenuID INT=27766,  
@UserLoginId  VARCHAR(20)='lvl1admin',  
@Timekey INT=26479
,@filepath VARCHAR(MAX) ='UCIClvlInvstDerivMOCUpload.xlsx'  
WITH RECOMPILE  
AS  
 
BEGIN

BEGIN TRY  
--BEGIN TRAN  
 
--Declare @TimeKey int  
    --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath  
     
       SET DATEFORMAT DMY

 --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle  
 -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL
 

  --SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')

  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)  

  SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N')  
    Declare @Date date =(Select Date from SysDayMatrix Where Timekey = @Timekey)  
 --  DECLARE @DepartmentId SMALLINT ,@DepartmentCode varchar(100)  
 --SELECT  @DepartmentId= DepartmentId FROM dbo.DimUserInfo  
 --WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey  
 --AND UserLoginID = @UserLoginId  
 --PRINT @DepartmentId  
 --PRINT @DepartmentCode  
 
   
 
 --SELECT @DepartmentCode=DepartmentCode FROM AxisIntReversalDB.DimDepartment  
 --    WHERE EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey  
 --    --AND DepartmentCode IN ('BBOG','FNA')  
 --    AND DepartmentAlt_Key = @DepartmentId  
 
 --    print @DepartmentCode  
     --Select @DepartmentCode=REPLACE('',@DepartmentCode,'_')  
     
       
 
   
 
  DECLARE @FilePathUpload     VARCHAR(100)

                  SET @FilePathUpload=@UserLoginId+'_'+@filepath
      PRINT '@FilePathUpload'
      PRINT @FilePathUpload

      IF EXISTS(SELECT 1 FROM dbo.MasterUploadData    where FileNames=@filepath )
      BEGIN
            Delete from dbo.MasterUploadData    where FileNames=@filepath  
            print @@rowcount
      END


IF (@MenuID=24747)      
BEGIN


        --IF OBJECT_ID('tempdb..CalypsoUploadCustMocUpload') IS NOT NULL  
        IF OBJECT_ID('CalypsoUploadCustMocUpload') IS NOT NULL  
        BEGIN  
         DROP TABLE CalypsoUploadCustMocUpload  
      
        END
        
  IF NOT (EXISTS (SELECT * FROM CalypsoCustlevelNPAMOCDetails_stg where filname=@FilePathUpload))

BEGIN
print 'NO DATA'
                  Insert into dbo.MasterUploadData
                  (SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag)
                  SELECT 0 SlNo , '' ColumnName,'No Record found' ErrorData,'No Record found' ErrorType,@filepath,'SUCCESS'
                  --SELECT 0 SlNo , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS'

                  goto errordata
   
END

ELSE
BEGIN
PRINT 'DATA PRESENT'
         Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows
         into CalypsoUploadCustMocUpload
         from CalypsoCustlevelNPAMOCDetails_stg
         WHERE filname=@FilePathUpload
        
         --  update A
         --set A.SourceAlt_Key = B.SourceAlt_Key
         --from CalypsoUploadCustMocUpload A
         --INNER JOIN DIMSOURCEDB B
         --ON A.SourceSystem = B.SourceName

        
END
  ------------------------------------------------------------------------------  
    ----SELECT * FROM CalypsoUploadCustMocUpload
      --SlNo      Territory   ACID  InterestReversalAmount  filename
      UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage='There is no data in excel. Kindly check and upload again'
            ,ErrorinColumn='Sl.No.,UCIC ID,AssetClass,NPIDate,AdditionalProvision%,MOCSource,MOCType,MOCReason'    
            ,Srnooferroneousrows=''
 FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(SlNo,'')=''
AND ISNULL(UCICID,'')=''
AND ISNULL(AssetClass,'')=''
AND ISNULL(NPIDate,'')=''
--AND ISNULL(SecurityValue,'')=''
AND ISNULL([AdditionalProvision],'')=''
AND ISNULL(MOCSource,'')=''
AND ISNULL(MOCType,'')=''
AND ISNULL(MOCReason,'')=''
 
--WHERE ISNULL(V.SlNo,'')=''
-- ----AND ISNULL(Territory,'')=''
-- AND ISNULL(AccountID,'')=''
-- AND ISNULL(PoolID,'')=''
-- AND ISNULL(filename,'')=''

  IF EXISTS(SELECT 1 FROM CalypsoUploadCustMocUpload WHERE ISNULL(ErrorMessage,'')<>'')
  BEGIN
  PRINT 'NO DATA'
  GOTO ERRORDATA;
  END

 
 --  UPDATE CalypsoUploadCustMocUpload
      --SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'UCIC ID not existing with Source System; Please check and upload again.'    
      --                            ELSE ErrorMessage+','+SPACE(1)+'UCIC ID not existing with Source System; Please check and upload again.'     END
      --    ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem/UCICID' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem/UCICID' END  
      --    ,Srnooferroneousrows=V.UCICID       
 --   FROM
 -- CalypsoUploadCustMocUpload V
 -- left join dimsourcedb E
 -- on v.sourcealt_key=e.sourcealt_key
 -- AND e.EffectiveFromTimeKey<=@timekey AND e.EffectiveToTimeKey>=@timekey  
 --  left JOIN InvestmentIssuerDetail B
 --  ON
 --     V.UCICID = B.UCIFID
 --  AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey
 --   left JOIN CurDat.DerivativeDetail c
 --  ON c.Sourcesystem = e.sourcename
 --  and V.UCICID = c.UCIC_ID
 --  AND c.EffectiveFromTimeKey<=@timekey AND c.EffectiveToTimeKey>=@timekey
 --  left join CurDat.InvestmentIssuerDetail d
 --  on b.UCIFID=d.UCIFID
 --  and v.SourceAlt_key = d.SourceAlt_Key
 --  and d.EffectiveFromTimeKey<=@timekey AND d.EffectiveToTimeKey>=@timekey
 --WHERE (ISNULL(c.UCIC_ID,'')=''
 --and ISNULL(b.UCIFID,'')='')

 

 


      /*validations on Sl. No.*/
 ------------------------------------------------------------

  Declare @DuplicateCnt int=0
   UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SlNo cannot be blank  or zero. Please check the values and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'SlNo cannot be blank . Please check the values and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END  
            ,Srnooferroneousrows=V.SlNo
                                                
   
   FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(SlNo,'')='' or ISNULL(SlNo,'0')='0'


  UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SlNo cannot be greater than 16 character . Please check the values and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'SlNo cannot be greater than 16 character . Please check the values and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END  
            ,Srnooferroneousrows=V.SlNo
                                                
   
   FROM CalypsoUploadCustMocUpload V  
 WHERE Len(SlNo)>16

  UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END  
            ,Srnooferroneousrows=V.SlNo
                                                
   
   FROM CalypsoUploadCustMocUpload V  
  WHERE (ISNUMERIC(SlNo)=0 AND ISNULL(SlNo,'')<>'') OR
 ISNUMERIC(SlNo) LIKE '%^[0-9]%'

 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END  
            ,Srnooferroneousrows=V.SlNo
      
   FROM CalypsoUploadCustMocUpload V  
  WHERE SlNo < 0

 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END  
            ,Srnooferroneousrows=V.SlNo
                                                
   
   FROM CalypsoUploadCustMocUpload V  
   WHERE ISNULL(SlNo,'') LIKE'%[,!@#$%^&*()_-+=/]%- \ / _'

   --
  SELECT @DuplicateCnt=Count(1)
FROM CalypsoUploadCustMocUpload
GROUP BY  SlNo
HAVING COUNT(SlNo) >1;

IF (@DuplicateCnt>0)

 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END  
            ,Srnooferroneousrows=V.SlNo
                                                
   
   FROM CalypsoUploadCustMocUpload V  
   Where ISNULL(SlNo,'') In(  
   SELECT SlNo
      FROM CalypsoUploadCustMocUpload
      GROUP BY  SlNo
      HAVING COUNT(SlNo) >1

)
----------------------------------------------



 ------------------------------------------------------------
  Declare @Count Int,@I Int,@Entity_Key Int
   Declare @UCICID Varchar(100)=''
   Declare @UCICIDFound Int=0
   Declare @DuplicateUCICCnt INT=0
  UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column ‘UCIC ID’ is mandatory. Kindly check and upload again'    
                              ELSE ErrorMessage+','+SPACE(1)+'The column ‘UCIC ID’ is mandatory. Kindly check and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCICID' ELSE ErrorinColumn +','+SPACE(1)+  'UCICID' END  
            ,Srnooferroneousrows=V.SlNo
--                                              ----STUFF((SELECT ','+SlNo
--                                              ----FROM CalypsoUploadCustMocUpload A
--                                              ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadCustMocUpload V  
--                                              ----                    WHERE ISNULL(ACID,'')='' )
--                                              ----FOR XML PATH ('')
--                                              ----),1,1,'')  

FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(UCICID,'')=''
 

 -------

  UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - \ / _. are not allowed , Kindly remove and upload again '    
                                    ELSE ErrorMessage+','+SPACE(1)+'Special characters - \ / _. are not allowed , Kindly remove and upload again '    END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCICId' ELSE   ErrorinColumn +','+SPACE(1)+'UCICId' END  
            ,Srnooferroneousrows=V.SlNo
                                                
   
   FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(UCICId,'') LIKE'%[,!@#$%^&*()+=]%'



 IF OBJECT_ID('TempDB..#tmp') IS NOT NULL DROP TABLE #tmp;
 
  Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(varchar(50),UCICID) ) RecentRownumber,UCICID  into #tmp from CalypsoUploadCustMocUpload
                 
 Select @Count=Count(*) from #tmp
 
   SET @I=1

   SET @UCICID=''
     While(@I<=@Count)
               BEGIN
                        Select @UCICID =UCICID  from #tmp where RecentRownumber=@I
                                          

                        Select   @UCICIDFound=(
                        CASE WHEN               (
                                                      select Count(1)
                                                      from InvestmentIssuerDetail  A Where  UCIFID =@UCICID
                                                      and EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
                                                      ) >= 1
                              
                              THEN
                                                      1                       
                              WHEN
                                          (                       
                                                      select Count(1)
                                                      from curdat.DerivativeDetail  A Where  UCIC_ID =@UCICID
                                                      and EffectiveFromTimeKey <= @Timekey AND EffectiveToTimeKey >= @Timekey
                                                ) >= 1
                              THEN
                                                      1                       
                              ELSE
                        
                                                      0
                          
                              END
                         )

                        IF @UCICIDFound =0
                            Begin
                               Update CalypsoUploadCustMocUpload
                                                               SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN ' UCIC ID is invalid. Kindly check the entered UCIC ID '    
                                                                   ELSE ErrorMessage+','+SPACE(1)+' UCIC ID is invalid. Kindly check the entered  UCIC ID '      END
                                                                   ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCIC ID' ELSE   ErrorinColumn +','+SPACE(1)+'UCIC ID' END  
                                                               Where UCICID =@UCICID
                              END
                                SET @I=@I+1
                                 SET @UCICID=''
                                                
                                                
                     END

  SELECT @DuplicateUCICCnt=Count(1)
FROM CalypsoUploadCustMocUpload
GROUP BY  UCICID
HAVING COUNT(UCICID) >1;

IF (@DuplicateUCICCnt>0)



BEGIN
 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate UCIC ID., kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'Duplicate UCIC ID., kindly check and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCIC ID' ELSE   ErrorinColumn +','+SPACE(1)+'UCIC ID' END  
            ,Srnooferroneousrows=V.SlNo
                                                
   
   FROM CalypsoUploadCustMocUpload V  
   Where ISNULL(UCICID,'') In(  
   SELECT UCICID
      FROM CalypsoUploadCustMocUpload
      GROUP BY  UCICID
      HAVING COUNT(UCICID) >1
      )
END

 


 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'    
                                    ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through ‘Customer Level MOC – Authorization’ menu'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCICID' ELSE ErrorinColumn +','+SPACE(1)+  'UCICId' END  
            ,Srnooferroneousrows=V.SlNo
 
            FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(V.UCICId,'')<>''
 AND V.UCICId  IN (SELECT Distinct UcifID FROM CalypsoCustomerLevelMOC_Mod A
                                                  WHERE EffectiveFromTimeKey <= @TimeKey
                               AND EffectiveToTimeKey >= @TimeKey
                                             AND  ISNULL(ScreenFlag,'')<>'U'
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                                             )

                                            

                 


      UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through ‘Customer Level MOC Upload – Authorization’ menu'    
                                    ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this UCIC ID. Kindly authorize or Reject the record through ‘Customer Level MOC Upload – Authorization’ menu'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCICID' ELSE ErrorinColumn +','+SPACE(1)+  'UCICID' END  
            ,Srnooferroneousrows=V.SlNo  
      FROM CalypsoUploadCustMocUpload V  
      WHERE ISNULL(V.UCICId,'')<>''
      AND V.UCICId  IN (SELECT Distinct UcifID FROM CalypsoCustomerLevelMOC_Mod A
                                          WHERE EffectiveFromTimeKey <= @Timekey
                               AND EffectiveToTimeKey >= @Timekey AND   ISNULL(ScreenFlag,'')='U'
                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
                                             )


--UPDATE CalypsoUploadCustMocUpload
--    SET  
--        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You can not upload UCICID. For these UCICID MOC is not Processed'    
--                                  ELSE ErrorMessage+','+SPACE(1)+ 'You can not upload UCICID. For these UCICID MOC is not Processed'     END
--          ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCICID' ELSE ErrorinColumn +','+SPACE(1)+  'UCICID' END  
--          ,Srnooferroneousrows=V.SlNo
----                                
-- FROM CalypsoUploadCustMocUpload V  
-- WHERE ISNULL(V.UCICID,'')<>''
--AND ISNULL(V.UCICID,'') in ( Select B.UcifId from CalypsoInvMOC_ChangeDetails A
--INNER JOIN InvestmentISsuerDetail B ON A.UCICID=B.UcifId
--where A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey
--AND A.MOCProcessed='N' )

--UPDATE CalypsoUploadCustMocUpload
--    SET  
--        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You can not upload UCICID. For these UCICID MOC is not Processed'    
--                                  ELSE ErrorMessage+','+SPACE(1)+ 'You can not upload UCICID. For these UCICID MOC is not Processed'     END
--          ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UCICID' ELSE ErrorinColumn +','+SPACE(1)+  'UCICID' END  
--          ,Srnooferroneousrows=V.SlNo
----                                
-- FROM CalypsoUploadCustMocUpload V  
-- WHERE ISNULL(V.UCICId,'')<>''
--AND ISNULL(V.UCICId,'') in ( Select B.UCIC_ID from CalypsoDervMOC_ChangeDetails A
--INNER JOIN curdat.DerivativeDetail B ON A.UCICID=B.UCIC_ID
--where A.EffectiveFromTimeKey<=@TimeKey and A.EffectiveToTimeKey>=@TimeKey
--AND A.MOCProcessed='N' )



--UPDATE CalypsoUploadCustMocUpload
--    SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for an Account ID' + CONVERT(VARCHAR(30),Y.CustomerAcID)+ ' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC Upload – Authorization’ menuu'    
--                                  ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for an Account ID' + CONVERT(VARCHAR(30),Y.CustomerAcID)+ ' under this Customer ID. Kindly authorize or Reject the record through ‘Account Level MOC Upload– Authorization’ menuu'     END
--          ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'CustomerID' ELSE ErrorinColumn +','+SPACE(1)+  'CustomerID' END  
--          ,Srnooferroneousrows=V.SlNo
 
--          FROM CalypsoUploadCustMocUpload V  
--          INNER Join PRO.CustomerCal_Hist Z On V.CustomerID=Z.RefCustomerID
--        INNER Join PRO.AccountCal_Hist Y on Y.CustomerEntityID=Z.CustomerEntityID
--          WHERE ISNULL(V.CustomerId,'')<>''
-- AND V.CustomerId  IN (
 
-- Select F.RefCustomerID from AccountLevelMOC_mod A
--  INNER Join PRO.AccountCal_Hist F on A.AccountID=F.CustomerACID

--INNER join PRO.CustomerCal_Hist B On F.CustomerEntityId=B.CustomerEntityID

--Where A.EntityKey in   (

--                         SELECT MAX(EntityKey)

--                         FROM AccountLevelMOC_mod

--                         WHERE EffectiveFromTimeKey <= @TimeKey

--                               AND EffectiveToTimeKey >= @TimeKey

--                               AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A')
--                                            And MOCSource<>'U'
--                         GROUP BY AccountID

--                     ))



 ----------------------------------------------
 --IF OBJECT_ID('TEMPDB..#DupCustomerid') IS NOT NULL
 --DROP TABLE #DupCustomerid

 --SELECT * INTO #DupCustomerid FROM(
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY SlNo ORDER BY Customerid ) as rw  FROM CalypsoUploadCustMocUpload
 --)X
 --WHERE rw>1


 --UPDATE V
      --SET  
 --       ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Customerid found. Kindly check and upload again'    
      --                            ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Customerid found. Kindly check and upload again'     END
      --    ,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'Customerid' ELSE V.ErrorinColumn +','+SPACE(1)+  'Customerid' END  
      --    ,Srnooferroneousrows=V.SlNo
 
      --    FROM CalypsoUploadCustMocUpload V
      --    INNer JOIN #DupCustomerid D ON D.DupCustomerid=V.DupCustomerid

---- ----SELECT * FROM CalypsoUploadCustMocUpload
   


-- comment due to forchange field 21062021 as discuused with Jaydev/Akshay/Anuj
 

/*validations on AssetClass */

 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Asset Class or greater than 16 character,  Please check the values and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'Invalid Asset Class or greater than 16 character,  Please check the values and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END      
            ,Srnooferroneousrows=V.SlNo
      
   
   FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(AssetClass,'')<>''
 AND LEN(AssetClass)>16



  UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - \ / _. are allowed , Kindly remove and upload again '    
                                    ELSE ErrorMessage+','+SPACE(1)+'Special characters - \ / _. are allowed , Kindly remove and upload again '    END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END  
            ,Srnooferroneousrows=V.SlNo
                                                
   
   FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(AssetClass,'') LIKE'%[,!@#$%^&*()+=]%'


    Declare @DuplicateAssetClassInt int=0

      

      IF OBJECT_ID('AssetClassData') IS NOT NULL  
        BEGIN  
         DROP TABLE AssetClassData  
      
        END

--      IF OBJECT_ID('AssetClassValidationData') IS NOT NULL  
--      BEGIN  
--       DROP TABLE AssetClassValidationData  
      
--      END
      
--SELECT * into AssetClassValidationData  FROM(
-- SELECT ROW_NUMBER() OVER(PARTITION BY B.CustomerID  ORDER BY  B.CustomerID )
-- ROW ,B.CustomerID,
-- C.AssetClassName as AssetClassOrg,B.AssetClass as AssetClassUpload from PRO.CustomerCal_Hist A
--INNER JOIN CalypsoUploadCustMocUpload B ON A.RefCustomerID=B.CustomerID
--INNER JOIN DimAssetClass C ON A.SysAssetClassAlt_Key=C.AssetClassAlt_Key
--)X
-- WHERE ROW=1
 

SELECT * into AssetClassData  FROM(
 SELECT ROW_NUMBER() OVER(PARTITION BY AssetClass  ORDER BY  AssetClass )
 ROW ,AssetClass FROM CalypsoUploadCustMocUpload
)X
 WHERE ROW=1

  SELECT  @DuplicateAssetClassInt=COUNT(*) FROM AssetClassData A
 Left JOIN DimAssetClass B
 ON  A.AssetClass=B.AssetClassName
 Where B.AssetClassName IS NULL


     IF @DuplicateAssetClassInt>0

          BEGIN
                  UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Asset Class’. Kindly enter the values as mentioned in the ‘Asset Class’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'    
                                    ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Asset Class’. Kindly enter the values as mentioned in the ‘Asset Class’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Asset Class' ELSE   ErrorinColumn +','+SPACE(1)+'Asset Class' END    
            ,Srnooferroneousrows=V.SlNo
             FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(AssetClass,'')<>''
 AND  V.AssetClass IN(
                        
                                      SELECT   A.AssetClass FROM AssetClassData A
                                     Left JOIN DimAssetClass B
                                     ON  A.AssetClass=B.AssetClassName
                                     Where B.AssetClassName IS NULL


                         )
            END

        
 -- UPDATE CalypsoUploadCustMocUpload
      --SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You have AssetClass STANDARD and You can change it only SUB-STANDARD. '    
      --                            ELSE ErrorMessage+','+SPACE(1)+'You have AssetClass STANDARD and You can change it only SUB-STANDARD '    END
      --    ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END  
      --    ,Srnooferroneousrows=V.SlNo
                                                
   
 --  FROM CalypsoUploadCustMocUpload V
   
 --WHERE V.CustomerID IN(Select B.CustomerID
      --            FROM AssetClassValidationData B                           
      --              WHERE (Case When ISNULL(B.AssetClassOrg,'') ='STANDARD' AND ISNULL(B.AssetClassUpload,'') NOT IN('SUB-STANDARD','','STANDARD') Then 1
 --              Else 0 END)=1)
                  

      --   UPDATE CalypsoUploadCustMocUpload
      --SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'You have AssetClass SUB-STANDARD and You can change it only STANDARD,DOUBTFUL I,LOS '    
      --                            ELSE ErrorMessage+','+SPACE(1)+'You have AssetClass SUB-STANDARD and You can change it only STANDARD,DOUBTFUL I,LOS. '    END
      --    ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AssetClass' ELSE   ErrorinColumn +','+SPACE(1)+'AssetClass' END  
      --    ,Srnooferroneousrows=V.SlNo
                                                
 --   FROM CalypsoUploadCustMocUpload V
 -- WHERE V.CustomerID IN(Select B.CustomerID
      --            FROM AssetClassValidationData B                           
      --              WHERE (Case When ISNULL(AssetClassOrg,'') ='SUB-STANDARD' AND ISNULL(AssetClassUpload,'') NOT IN('STANDARD','DOUBTFUL I','LOS','SUB-STANDARD') Then 1
      --                       Else 0 END)=1
      --                       )

                              
 --------------NPIDate-----------------------


 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd/mm/yyyy’'    
                                    ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd/mm/yyyy’'      END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPIDate' ELSE   ErrorinColumn +','+SPACE(1)+'NPIDate' END      
            ,Srnooferroneousrows=V.SlNo
      
 FROM CalypsoUploadCustMocUpload V  
 WHERE   (ISDATE(NPIDate)=0 OR CHARINDEX('/',NPIDate) <> 3)  AND  ISNULL(NPIDate,'')<>'' and CHARINDEX('/',NPIDate) <> 3
 
 
    Print '1A' 

 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPI Date is mandatory since ‘Asset class’ is set as NPI. Kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+ 'NPI Date is mandatory since ‘Asset class’ is set as NPI. Kindly check and upload again'      END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPIDate' ELSE   ErrorinColumn +','+SPACE(1)+'NPIDate' END      
            ,Srnooferroneousrows=V.SlNo
              
 FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(AssetClass,'') IN('SUB-STANDARD','DOUBTFUL I') AND (NPIDate)=''

 
 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPI Date cannot be entered since ‘Asset class’ is not specified. Kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+ 'NPI Date cannot be entered since ‘Asset class’ is not specified. Kindly check and upload again'      END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPIDate' ELSE   ErrorinColumn +','+SPACE(1)+'NPIDate' END      
            ,Srnooferroneousrows=V.SlNo
            
 FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(AssetClass,'') = ''  AND (NPIDate)<>''


  UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPA Date must be blank since ‘Asset class’ is STD. Kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+ 'NPA Date must be blank since ‘Asset class’ is STD. Kindly check and upload again'      END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPIDate' ELSE   ErrorinColumn +','+SPACE(1)+'NPIDate' END      
            ,Srnooferroneousrows=V.SlNo
              

 FROM CalypsoUploadCustMocUpload V  
 WHERE (ISNULL(AssetClass,'') IN('STANDARD') or ISNULL(AssetClass,'') IS NULL) AND (NPIDate)<>''

 Set DateFormat DMY
 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPA date must be less than equal to MOC date. Kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+ 'NPA date must be less than equal to MOC date. Kindly check and upload again'      END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPIDate' ELSE   ErrorinColumn +','+SPACE(1)+'NPIDate' END      
            ,Srnooferroneousrows=V.SlNo
            

 FROM CalypsoUploadCustMocUpload V  
 WHERE (Case When ISDATE(NPIDate)=1 AND  CHARINDEX('/',NPIDate) = 3 Then Case When Cast(NPIDate as date)>Cast(@Date as Date) Then 1 Else 0 END END)=1
 
 Print '2B'

   UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'NPA Date is mandatory  since ‘Asset class’ is not STANDARD. Kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+ 'NPA Date is mandatory  since ‘Asset class’ is not STANDARD. Kindly check and upload again'      END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'NPIDate' ELSE   ErrorinColumn +','+SPACE(1)+'NPIDate' END      
            ,Srnooferroneousrows=V.SlNo
              

 FROM CalypsoUploadCustMocUpload V  
 WHERE (ISNULL(AssetClass,'') NOT IN('STANDARD','') ) AND (NPIDate)=''

  Print '3B'
 


-- --------------security value----------------

-- UPDATE CalypsoUploadCustMocUpload
--    SET  
--        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Security value Please check the values and upload again'    
--                                  ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Security value Please check the values and upload again'     END
--          ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Security value' ELSE ErrorinColumn +','+SPACE(1)+  'Security value' END  
--          ,Srnooferroneousrows=V.SlNo
----                                
-- FROM CalypsoUploadCustMocUpload V  
-- WHERE ISNULL(Securityvalue,'')<>''
--AND (CHARINDEX('.',ISNULL(Securityvalue,''))>0  AND Len(Right(ISNULL(Securityvalue,''),Len(ISNULL(Securityvalue,''))-CHARINDEX('.',ISNULL(Securityvalue,''))))>2)





--  UPDATE CalypsoUploadCustMocUpload
--    SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in ‘Security Value’ column. Kindly check and upload again'    
--                                  ELSE ErrorMessage+','+SPACE(1)+'Invalid value in ‘Security Value’ column. Kindly check and upload again '    END
--          ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SecurityValue' ELSE   ErrorinColumn +','+SPACE(1)+'SecurityValue' END  
--          ,Srnooferroneousrows=V.SlNo
                                                
   
--   FROM CalypsoUploadCustMocUpload V  
--   WHERE (ISNUMERIC(Securityvalue)=0 AND ISNULL(Securityvalue,'')<>'') OR
-- ISNUMERIC(Securityvalue) LIKE '%^[0-9]%'




 --------------Additional Provision%-----------------
 
-- UPDATE CalypsoUploadCustMocUpload
--    SET  
--        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Security value Please check the values and upload again'    
--                                  ELSE ErrorMessage+','+SPACE(1)+ 'Invalid Security value Please check the values and upload again'     END
--          ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Security value' ELSE ErrorinColumn +','+SPACE(1)+  'Security value' END  
--          ,Srnooferroneousrows=V.SlNo
----                                
-- FROM CalypsoUploadCustMocUpload V  
-- WHERE --ISNULL(Securityvalue,'')<>''
-- (CHARINDEX('.',ISNULL(AdditionalProvision,''))>0  AND Len(Right(ISNULL(AdditionalProvision,''),Len(ISNULL(AdditionalProvision,''))-CHARINDEX('.',ISNULL(AdditionalProvision,''))))>2)


-- UPDATE CalypsoUploadCustMocUpload
--	SET  
--        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision %’. Additional Provision % greater than zero and less than or equal to 100.'     
--						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid values in ‘Additional Provision %’. Additional Provision % greater than zero and less than or equal to 100.'     END
--		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision%' ELSE ErrorinColumn +','+SPACE(1)+  'Additional Provision%' END  
--		,Srnooferroneousrows=V.SlNo
----							

-- FROM CalypsoUploadCustMocUpload V  
-- WHERE ISNULL(AdditionalProvision,'')<>''
-- AND Convert(Decimal(18,2),ISNULL(AdditionalProvision,'0'))>100

  UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision %’. Kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+ 'Invalid values in ‘Additional Provision %’. Kindly check and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision%' ELSE ErrorinColumn +','+SPACE(1)+  'Additional Provision%' END  
            ,Srnooferroneousrows=V.SlNo
--          
 FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL([AdditionalProvision],'')<>''
      AND len(AdditionalProvision)<=6
 --AND Convert(Decimal(5,2),ISNULL(AdditionalProvision,'0'))>100
  AND (Case When ISNUMERIC(AdditionalProvision)=1 Then
 Case When Convert(Decimal(5,2),ISNULL(AdditionalProvision,'0'))>100 Then 1 Else 0 END END)=1

   UPDATE CalypsoUploadCustMocUpload
	SET  
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision %’. Additional Provision % greater than zero and less than or equal to 100.'     
						ELSE ErrorMessage+','+SPACE(1)+ 'Invalid values in ‘Additional Provision %’. Additional Provision % greater than zero and less than or equal to 100.'     END
		,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision%' ELSE ErrorinColumn +','+SPACE(1)+  'Additional Provision%' END  
		,Srnooferroneousrows=V.SlNo
--							

FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL([AdditionalProvision],'')<>'' and ISNUMERIC([AdditionalProvision])=1
 AND Convert(Decimal(18,2),ISNULL(AdditionalProvision,'0'))>100

  Print '4B'

UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision %’. Kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Additional Provision %’. Kindly check and upload again '    END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision%' ELSE   ErrorinColumn +','+SPACE(1)+'Additional Provision%' END  
            ,Srnooferroneousrows=V.SlNo
                                                
   
   FROM CalypsoUploadCustMocUpload V  
   WHERE (ISNUMERIC(AdditionalProvision)=0 AND ISNULL(AdditionalProvision,'')<>'') OR
 ISNUMERIC(AdditionalProvision) LIKE '%^[0-9]%'


 --UPDATE CalypsoUploadCustMocUpload
      --SET  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Additional Provision ’. Kindly check and upload again'    
      --                            ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Additional Provision ’. Kindly check and upload again '    END
      --    ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Additional Provision' ELSE   ErrorinColumn +','+SPACE(1)+'Additional Provision' END  
      --    ,Srnooferroneousrows=V.SlNo
                                                
   
 --  FROM CalypsoUploadCustMocUpload V  
 --  WHERE (CHARINDEX('.',AdditionalProvision))>0


 -----------------------------------------------------------------

 


 -------------MOCSource--------------------
  Print '5B'
               UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'    
                                    ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END    
            ,Srnooferroneousrows=V.SlNo
             FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(MOCSOURCE,'')<>''
 AND  V.MOCSOURCE NOT IN(
                        SELECT  B.MOCTypeName FROM  DimMOCType B                          
                               Where   EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey
                         )

      
      
 Print '6B'
       UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC source can not be blank,  Please check the values and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'MOC source can not be blank,  Please check the values and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END      
            ,Srnooferroneousrows=V.SlNo
      
   
   FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(MOCSOURCE,'')=''
 
  Print '7B'

---------------MOCType---------------------


        UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOCType is mandatory . Please check the values and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'MOCType is mandatory . Please check the values and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCType' ELSE   ErrorinColumn +','+SPACE(1)+'MOCType' END  
            ,Srnooferroneousrows=V.SlNo
                                          
   
   FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(MOCType,'')=''
 Print '6A' 
 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC Type column will only accept value – Auto or Manual. Kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'MOC Type column will only accept value – Auto or Manual. Kindly check and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCType' ELSE   ErrorinColumn +','+SPACE(1)+'MOCType' END  
            ,Srnooferroneousrows=V.SlNo
                                          
   
   FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(MOCType,'') NOT IN('Auto','Manual')

 Print '5A' 

 ----------------MOCReason---------------------


 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC Reason column is mandatory. Kindly check and upload again'    
                                    ELSE ErrorMessage+','+SPACE(1)+'MOC Reason column is mandatory. Kindly check and upload again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END  
            ,Srnooferroneousrows=V.SlNo
                                                --STUFF((SELECT ','+SlNo
                                                --FROM CalypsoUploadCustMocUpload A
                                                --WHERE A.SlNo IN(SELECT V.SlNo  FROM CalypsoUploadCustMocUpload V  
                                                --WHERE ISNULL(SOLID,'')='')
                                                --FOR XML PATH ('')
                                                --),1,1,'')
   
FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(MOCReason,'')=''
 Print '4A' 

 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC reason cannot be greater than 500 characters'    
                                    ELSE ErrorMessage+','+SPACE(1)+ 'MOC reason cannot be greater than 500 characters'      END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END      
            ,Srnooferroneousrows=V.SlNo
            --STUFF((SELECT ','+SlNo
            --                                  FROM #UploadNewAccount A
            --                                  WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V  
            --                                                          WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''
            --                                                          )
            --                                  FOR XML PATH ('')
            --                                  ),1,1,'')  

 FROM CalypsoUploadCustMocUpload V  
 WHERE LEN(MOCReason)>500

 Print '3A' 

 UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'    
                                    ELSE ErrorMessage+','+SPACE(1)+ 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'     END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOC reason' ELSE ErrorinColumn +','+SPACE(1)+  'MOC reason' END  
            ,Srnooferroneousrows=V.SlNo
--                                              ----STUFF((SELECT ','+SlNo
--                                              ----FROM CalypsoUploadCustMocUpload A
--                                              ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadCustMocUpload V
--                                              ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'
--                                              ----)
--                                              ----FOR XML PATH ('')
--                                              ----),1,1,'')  

 FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(MOCReason,'') LIKE'%[!@#$%^&*()_+=]%'



    Print '2A' 
  UPDATE CalypsoUploadCustMocUpload
      SET  
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC reason should be as per master values'    
                                    ELSE ErrorMessage+','+SPACE(1)+ 'MOC reason should be as per master values'      END
            ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END      
            ,Srnooferroneousrows=V.SlNo  

 FROM CalypsoUploadCustMocUpload V  
 WHERE ISNULL(MOCReason,'')<>'' and
 ISNULL(MOCReason,'') NOT IN  (select  ParameterName from DimParameter
                   where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and
                    DimParameterName      = 'DimMOCReason')
 ----------------------------------------------
 
  /*validations on SourceSystem*/
--    Declare @DuplicateSourceSystemDataInt int=0

      

--    IF OBJECT_ID('SourceSystemData') IS NOT NULL  
--      BEGIN  
--       DROP TABLE SourceSystemData
      
--      END

--       SELECT * into SourceSystemData  FROM(
-- SELECT ROW_NUMBER() OVER(PARTITION BY SourceSystem  ORDER BY  SourceSystem )
-- ROW ,SourceSystem FROM CalypsoUploadCustMocUpload
--)X
-- WHERE ROW=1

 
--  SELECT  @DuplicateSourceSystemDataInt=COUNT(*) FROM CalypsoUploadCustMocUpload A
-- Left JOIN DIMSOURCEDB B
-- ON  A.SourceSystem=B.SourceName
-- Where B.SourceName IS NULL

--    IF @DuplicateSourceSystemDataInt>0

--    BEGIN
--           UPDATE CalypsoUploadCustMocUpload
--    SET  
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘SourceSystem’. Kindly enter the values as mentioned in the ‘Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for theco
--lumn'    
--                                  ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘SourceSystem’. Kindly enter the values as mentioned in the ‘Segment’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
--        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem' END    
--          ,Srnooferroneousrows=V.SlNo
--           FROM CalypsoUploadCustMocUpload V  
-- WHERE ISNULL(SourceSystem,'')<>''
-- AND  V.SourceSystem IN(
--                     SELECT  A.SourceSystem FROM CalypsoUploadCustMocUpload A
--                             Left JOIN DIMSOURCEDB B
--                             ON  A.SourceSystem=B.SourceName
--                             Where B.SourceName IS NULL
--                 )
                  

                        
--    END
------------------------------------------------------

 Print '123'
 goto valid

  END
      
   ErrorData:  
   print 'no'  

            SELECT *,'Data'TableName
            FROM dbo.MasterUploadData WHERE FileNames=@filepath
            return

   valid:
            IF NOT EXISTS(Select 1 from  CalypsoCustlevelNPAMOCDetails_stg WHERE filname=@FilePathUpload)
            BEGIN
            PRINT 'NO ERRORS'
                  
                  Insert into dbo.MasterUploadData
                  (SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag)
                  SELECT '' SlNo , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS'
                  
            END
            ELSE
            BEGIN
                  PRINT 'VALIDATION ERRORS'
                  Insert into dbo.MasterUploadData
                  (SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag)
                  SELECT SlNo,ErrorinColumn,ErrorMessage,ErrorinColumn,@filepath,Srnooferroneousrows,'SUCCESS'
                  FROM CalypsoUploadCustMocUpload


                  
            --    ----SELECT * FROM CalypsoUploadCustMocUpload

            --    --ORDER BY ErrorMessage,CalypsoUploadCustMocUpload.ErrorinColumn DESC
                  goto final
            END

            

  IF EXISTS (SELECT 1 FROM  dbo.MasterUploadData   WHERE FileNames=@filepath AND  ISNULL(ERRORDATA,'')<>'')
   -- added for delete Upload status while error while uploading data.  
   BEGIN  
   --SELECT * FROM #OAOLdbo.MasterUploadData
    delete from UploadStatus where FileNames=@filepath  
   END  
  --ELSE IF EXISTS (SELECT 1 FROM  UploadStatus where ISNULL(InsertionOfData,'')='' and FileNames=@filepath and UploadedBy=@UserLoginId)  -- added validated condition successfully, delete filename from Upload status  
  --  BEGIN  
  --  print 'RC'  
  --   delete from UploadStatus where FileNames=@filepath  
  --  END    --commented in [OAProvision].[GetStatusOfUpload] SP for checkin 'InsertionOfData' Flag  
  ELSE  
   BEGIN  
 
    Update UploadStatus Set ValidationOfData='Y',ValidationOfDataCompletedOn=GetDate()  
    where FileNames=@filepath  
 
   END  


  final:
IF EXISTS(SELECT 1 FROM dbo.MasterUploadData WHERE FileNames=@filepath AND ISNULL(ERRORDATA,'')<>''
            )
      BEGIN
      PRINT 'ERROR'
            SELECT SR_No
                        ,ColumnName
                        ,ErrorData
                        ,ErrorType
                        ,FileNames
                        ,Flag
                        ,Srnooferroneousrows,'Validation'TableName
            FROM dbo.MasterUploadData
            WHERE FileNames=@filepath
            --(SELECT *,ROW_NUMBER() OVER(PARTITION BY ColumnName,ErrorData,ErrorType,FileNames ORDER BY ColumnName,ErrorData,ErrorType,FileNames )AS ROW
            --FROM  dbo.MasterUploadData    )a
            --WHERE A.ROW=1
            --AND FileNames=@filepath
            --AND ISNULL(ERRORDATA,'')<>''
      
            ORDER BY SR_No
            
             IF EXISTS(SELECT 1 FROM CalypsoCustlevelNPAMOCDetails_stg WHERE filname=@FilePathUpload)
             BEGIN
             DELETE FROM CalypsoCustlevelNPAMOCDetails_stg
             WHERE filname=@FilePathUpload

             PRINT 1

             PRINT 'ROWS DELETED FROM DBO.CalypsoCustlevelNPAMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
             END

      END
      ELSE
      BEGIN
      PRINT ' DATA NOT PRESENT'
            --SELECT *,'Data'TableName
            --FROM dbo.MasterUploadData WHERE FileNames=@filepath
            --ORDER BY ErrorData DESC
            SELECT SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows,'Data'TableName
            FROM
            (
                  SELECT *,ROW_NUMBER() OVER(PARTITION BY ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows
                  ORDER BY ColumnName,ErrorData,ErrorType,FileNames,Flag,Srnooferroneousrows)AS ROW
                  FROM  dbo.MasterUploadData    
            )a
            WHERE A.ROW=1
            AND FileNames=@filepath

      END

      --SELECT * FROM CalypsoUploadCustMocUpload

      print 'p'
  ------to delete file if it has errors
            --if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')
            --begin
            --print 'ppp'
            -- IF EXISTS(SELECT 1 FROM CustlevelNPAMOCDetails_stg WHERE filename=@FilePathUpload)
            -- BEGIN
            -- print '123'
            -- DELETE FROM CustlevelNPAMOCDetails_stg
            -- WHERE filename=@FilePathUpload

            -- PRINT 'ROWS DELETED FROM DBO.CustlevelNPAMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
            -- END
            -- END

   
END  TRY
 
  BEGIN CATCH
      
      
      INSERT INTO dbo.Error_Log
                        SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber
                        ,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState
                        ,GETDATE()

      --IF EXISTS(SELECT 1 FROM CustlevelNPAMOCDetails_stg WHERE filename=@FilePathUpload)
      --     BEGIN
      --     DELETE FROM CustlevelNPAMOCDetails_stg
      --     WHERE filename=@FilePathUpload

      --     PRINT 'ROWS DELETED FROM DBO.CustlevelNPAMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))
      --     END

END CATCH

END
 
GO