SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


     
      
CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_CalypsoAccNPAMOCUpload]        
@MenuID INT=10,        
@UserLoginId  VARCHAR(20)='fnachecker',        
@Timekey INT=49999      
,@filepath VARCHAR(MAX) ='AccountMOCUpload.xlsx'        
WITH RECOMPILE        
AS        
        
  --fnasuperadmin_IBPCUPLOAD.xlsx      
      
--DECLARE        
        
--@MenuID INT=1458,        
--@UserLoginId varchar(20)='FNASUPERADMIN',        
--@Timekey int=49999      
--,@filepath varchar(500)='fnasuperadmin_IBPCUPLOAD.xlsx'        
        
BEGIN      
      
BEGIN TRY         
--BEGIN TRAN        
        
--Declare @TimeKey int        
    --Update UploadStatus Set ValidationOfData='N' where FileNames=@filepath        
           
  SET DATEFORMAT DMY      
      
 --Select @Timekey=Max(Timekey) from dbo.SysProcessingCycle        
 -- where  ProcessType='Quarterly' ----and PreMOC_CycleFrozenDate IS NULL      
       
  -- SET @Timekey =(Select TimeKey from SysDataMatrix where CurrentStatus='C')       
      
  --SET @Timekey =(Select LastMonthDateKey from SysDayMatrix where Timekey=@Timekey)         
  SET @Timekey =(Select Timekey from SysDataMatrix Where MOC_Initialised='Y' AND ISNULL(MOC_Frozen,'N')='N')      
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
           
        
         
        
 DECLARE @FilePathUpload VARCHAR(100)      
      
 SET @FilePathUpload=@UserLoginId+'_'+@filepath      
 PRINT '@FilePathUpload'      
 PRINT @FilePathUpload      
      
 IF EXISTS(SELECT 1 FROM dbo.MasterUploadData    where FileNames=@filepath )      
 BEGIN      
  Delete from dbo.MasterUploadData    where FileNames=@filepath        
  print @@rowcount      
 END      
      
      
IF (@MenuID=24749)       
BEGIN      
      
   -- IF OBJECT_ID('tempdb..CalypsoUploadAccMOCPool') IS NOT NULL        
   IF OBJECT_ID('CalypsoUploadAccMOCPool') IS NOT NULL        
   BEGIN        
    DROP TABLE CalypsoUploadAccMOCPool        
       
   END      
         
         
  IF NOT (EXISTS (SELECT 1 FROM [CalypsoAccountLvlMOCDetails_stg] where filname=@FilePathUpload))      
       
      
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
     into CalypsoUploadAccMOCPool       
    from CalypsoAccountLvlMOCDetails_stg       
    WHERE filname=@FilePathUpload      
    select 'a'      
   -- update A      
   -- set A.SourceSystem = B.SourceAlt_Key      
   -- from CalypsoUploadAccMOCPool A      
   -- INNER JOIN DIMSOURCEDB B       
   -- ON A.SourceSystem = B.SourceName      
   --select 'b'      
END        
  ------------------------------------------------------------------------------        
    ----SELECT * FROM CalypsoUploadAccMOCPool      
 --SlNo Territory ACID InterestReversalAmount filename      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage='There is no data in excel. Kindly check and upload again'       
  ,ErrorinColumn='SlNo,Account ID,POS,Interest Receivable,Balances,Dates'          
  ,Srnooferroneousrows=''      
 FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(SlNo,'')=''      
AND ISNULL(InvestmentIDDerivativeRefNo,'')=''      
AND ISNULL(AdditionalProvisionAbsolute,'')=''      
--AND ISNULL(SourceSystem,'')=''      
AND ISNULL(BookValueINRMTMValue,'')=''      
AND ISNULL(UnservicedInterest,'')=''      
AND ISNULL(MOCSource,'')=''      
AND ISNULL(MOCReason,'')=''      
      
      
      
UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Sr No is present and remaining  excel file is blank. Please check and Upload again.'           
      ELSE ErrorMessage+','+SPACE(1)+'Sr No is present and remaining  excel file is blank. Please check and Upload again.'     END      
 ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Excel Vaildate ' ELSE   ErrorinColumn +','+SPACE(1)+'Excel Vaildate' END         
  ,Srnooferroneousrows=''      
       
   FROM CalypsoUploadAccMOCPool V        
 WHERE       
 ISNULL(SlNo,'')<>''      
AND ISNULL(InvestmentIDDerivativeRefNo,'')=''      
AND ISNULL(AdditionalProvisionAbsolute,'')=''      
--AND ISNULL(SourceSystem,'')=''      
AND ISNULL(BookValueINRMTMValue,'')=''      
AND ISNULL(UnservicedInterest,'')=''      
AND ISNULL(MOCSource,'')=''      
AND ISNULL(MOCReason,'')=''      
        
--WHERE ISNULL(V.SlNo,'')=''      
-- ----AND ISNULL(Territory,'')=''      
-- AND ISNULL(AccountID,'')=''      
-- AND ISNULL(PoolID,'')=''      
-- AND ISNULL(filename,'')=''      
      
  IF EXISTS(SELECT 1 FROM CalypsoUploadAccMOCPool WHERE ISNULL(ErrorMessage,'')<>'')      
  BEGIN      
  PRINT 'NO DATA'      
  GOTO valid;      
  END      
      
         
--  /*validations on SourceSystem*/      
      
      
--  UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column ‘SourceSystem’ is mandatory. Kindly check and upload again'           
--     ELSE ErrorMessage+','+SPACE(1)+'The column ‘SourceSystem’ is mandatory. Kindly check and upload again'     END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem' ELSE ErrorinColumn +','+SPACE(1)+  'SourceSystem' END        
--  ,Srnooferroneousrows=V.SlNo      
----        ----STUFF((SELECT ','+SlNo       
----        ----FROM CalypsoUploadAccMOCPool A      
----        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V        
----        ----    WHERE ISNULL(ACID,'')='' )      
----        ----FOR XML PATH ('')      
----        ----),1,1,'')         
      
--FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(SourceSystem,'')=''       
      
      
--   UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID not existing with Source System; Please check and upload again.'           
--      ELSE ErrorMessage+','+SPACE(1)+'Account ID not existing with Source System; Please check and upload again.'     END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SourceSystem/AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'SourceSystem/AccountID' END         
--  ,Srnooferroneousrows=V.InvestmentIDDerivativeRefNo        
--  FROM       
--  CalypsoUploadAccMOCPool V      
--  left join dimsourcedb E      
--  on v.SourceSystem =e.sourcealt_key      
--  AND e.EffectiveFromTimeKey<=@timekey AND e.EffectiveToTimeKey>=@timekey        
--   left JOIN InvestmentBasicDetail B       
--   ON       
--      V.InvestmentIDDerivativeRefNo = B.InvID      
--   AND B.EffectiveFromTimeKey<=@timekey AND B.EffectiveToTimeKey>=@timekey      
--    left JOIN CurDat.DerivativeDetail c       
--   ON c.Sourcesystem = e.sourcename       
--   and V.InvestmentIDDerivativeRefNo = c.DerivativeRefNo      
--   AND c.EffectiveFromTimeKey<=@timekey AND c.EffectiveToTimeKey>=@timekey      
--   left join CurDat.InvestmentIssuerDetail d      
--   on b.RefIssuerID=d.IssuerID      
--   and v.SourceSystem = d.SourceAlt_Key       
--   and d.EffectiveFromTimeKey<=@timekey AND d.EffectiveToTimeKey>=@timekey      
-- WHERE (ISNULL(c.DerivativeRefNo,'')=''       
-- and ISNULL(b.InvID,'')='')       
      
      
      
  /*validations on SlNo*/      
        
 Declare @DuplicateCnt int=0      
   UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SlNo cannot be blank . Please check the values and upload again'           
      ELSE ErrorMessage+','+SPACE(1)+'SlNo cannot be blank . Please check the values and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END         
  ,Srnooferroneousrows=V.SlNo      
              
         
   FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(SlNo,'')='' or ISNULL(SlNo,'0')='0'      
      
      
  UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SlNo cannot be greater than 16 character . Please check the values and upload again'           
      ELSE ErrorMessage+','+SPACE(1)+'SlNo cannot be greater than 16 character . Please check the values and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END         
  ,Srnooferroneousrows=V.SlNo      
              
         
   FROM CalypsoUploadAccMOCPool V        
WHERE Len(SlNo)>16      
      
  UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'           
      ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END         
  ,Srnooferroneousrows=V.SlNo      
              
         
   FROM CalypsoUploadAccMOCPool V        
  WHERE (ISNUMERIC(SlNo)=0 AND ISNULL(SlNo,'')<>'') OR       
 ISNUMERIC(SlNo) LIKE '%^[0-9]%'      
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'           
      ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END         
  ,Srnooferroneousrows=V.SlNo      
              
         
   FROM CalypsoUploadAccMOCPool V        
   WHERE ISNULL(SlNo,'') LIKE'%[,!@#$%^&*()_-+=/]%- \ / _'      
      
   --      
  SELECT @DuplicateCnt=Count(1)      
FROM CalypsoUploadAccMOCPool      
GROUP BY  SlNo      
HAVING COUNT(SlNo) >1;      
      
IF (@DuplicateCnt>0)      
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'           
      ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SlNo' ELSE   ErrorinColumn +','+SPACE(1)+'SlNo' END         
  ,Srnooferroneousrows=V.SlNo      
              
         
   FROM CalypsoUploadAccMOCPool V        
   Where ISNULL(SlNo,'') In(        
   SELECT SlNo      
 FROM CalypsoUploadAccMOCPool      
 GROUP BY  SlNo      
 HAVING COUNT(SlNo) >1      
      
)      
      
      
 ------------------------------------------------      
      
/*VALIDATIONS ON AccountID */      
      
  UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column ‘InvestmentIDDerivativeRefNo’ is mandatory. Kindly check and upload again'           
     ELSE ErrorMessage+','+SPACE(1)+'The column ‘InvestmentIDDerivativeRefNo’ is mandatory. Kindly check and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InvestmentIDDerivativeRefNo' ELSE ErrorinColumn +','+SPACE(1)+  'InvestmentIDDerivativeRefNo' END        
  ,Srnooferroneousrows=V.SlNo      
--        ----STUFF((SELECT ','+SlNo       
--        ----FROM CalypsoUploadAccMOCPool A      
--        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V        
--        ----    WHERE ISNULL(ACID,'')='' )      
--        ----FOR XML PATH ('')      
--        ----),1,1,'')         
      
FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(InvestmentIDDerivativeRefNo,'')=''       
       
      
-- ----SELECT * FROM CalypsoUploadAccMOCPool      
        
  UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid InvestmentIDDerivativeRefNo found. Please check the values and upload again'           
      ELSE ErrorMessage+','+SPACE(1)+'Invalid InvestmentIDDerivativeRefNo found. Please check the values and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InvestmentIDDerivativeRefNo' ELSE ErrorinColumn +','+SPACE(1)+  'InvestmentIDDerivativeRefNo' END        
  ,Srnooferroneousrows=V.SlNo      
        
  FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(V.InvestmentIDDerivativeRefNo,'')<>''      
 AND V.InvestmentIDDerivativeRefNo NOT IN(    
  SELECT invid FROM InvestmentBasicDetail      
        WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey      
  UNION    
  SELECT Refinvid FROM InvestmentFinancialDetail      
        WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey     
  union       
  SELECT DerivativeRefNo FROM CurDat.DerivativeDetail      
        WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey      
       )      
      
      
 IF OBJECT_ID('TEMPDB..#DUB2') IS NOT NULL      
 DROP TABLE #DUB2      
      
 SELECT * INTO #DUB2 FROM(      
 SELECT *,ROW_NUMBER() OVER(PARTITION BY InvestmentIDDerivativeRefNo ORDER BY InvestmentIDDerivativeRefNo ) as rw  FROM CalypsoUploadAccMOCPool      
 )X      
 WHERE rw>1      
      
      
 UPDATE V      
 SET        
        ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate InvestmentIDDerivativeRefNo found. Please check the values and upload again'           
      ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate InvestmentIDDerivativeRefNo found. Please check the values and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'InvestmentIDDerivativeRefNo' ELSE V.ErrorinColumn +','+SPACE(1)+  'InvestmentIDDerivativeRefNo' END        
  ,Srnooferroneousrows=V.SlNo      
        
  FROM CalypsoUploadAccMOCPool V       
  INNer JOIN #DUB2 D ON D.InvestmentIDDerivativeRefNo=V.InvestmentIDDerivativeRefNo      
      
            
---------------------Authorization for Screen Same acc ID --------------------------      
      
UPDATE CalypsoUploadAccMOCPool      
 SET        
  ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for this InvestmentIDDerivativeRefNo. Kindly authorize or Reject the record.'           
      ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this InvestmentIDDerivativeRefNo. Kindly authorize or Reject the record.'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InvestmentIDDerivativeRefNo' ELSE ErrorinColumn +','+SPACE(1)+  'InvestmentIDDerivativeRefNo' END        
  ,Srnooferroneousrows=V.SlNo      
        
  FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(V.InvestmentIDDerivativeRefNo,'')<>''      
 AND V.InvestmentIDDerivativeRefNo IN (SELECT Distinct AccountID FROM CalypsoAccountlevelMOC_MOD      
        WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey      
        AND ISNULL(AuthorisationStatus, 'A') IN('NP', 'MP', 'DP', 'RM','1A') and ISNULL(Screenflag,'') <> 'U'      
       )      
      
---------------------------------------------------------------------------Upload for same account ID--------------      
      
UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'You cannot perform MOC, Record is pending for authorization for this InvestmentIDDerivativeRefNo. Kindly authorize or Reject the record'           
      ELSE ErrorMessage+','+SPACE(1)+'You cannot perform MOC, Record is pending for authorization for this InvestmentIDDerivativeRefNo. Kindly authorize or Reject the record '     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InvestmentIDDerivativeRefNo' ELSE ErrorinColumn +','+SPACE(1)+  'InvestmentIDDerivativeRefNo' END        
  ,Srnooferroneousrows=V.SlNo      
        
  FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(V.InvestmentIDDerivativeRefNo,'')<>''      
 AND V.InvestmentIDDerivativeRefNo  IN (SELECT Distinct AccountID FROM CalypsoAccountlevelMOC_MOD      
        WHERE EffectiveFromTimeKey<=@Timekey AND EffectiveToTimeKey>=@Timekey      
        AND AuthorisationStatus in ('NP','MP','1A','FM') --and ISNULL(Screenflag,'') = 'U'      
       )      
      
      
---------------------------------------      
      
       
--/*VALIDATIONS ON POS in Rs */      
      
      
      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid POSinRs. Please check the values and upload again'           
--     ELSE ErrorMessage+','+SPACE(1)+'Invalid POSinRs. Please check the values and upload again'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POSinRs' ELSE ErrorinColumn +','+SPACE(1)+  'POSinRs' END        
--  ,Srnooferroneousrows=V.SlNo      
----        --STUFF((SELECT ','+SlNo       
----        --FROM CalypsoUploadAccMOCPool A      
----        --WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V      
----        --WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR       
----        --ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'      
----        --)      
----        --FOR XML PATH ('')      
----        --),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- --WHERE (ISNUMERIC(POSinRs)=0 AND ISNULL(POSinRs,'')<>'') OR       
-- --ISNUMERIC(POSinRs) LIKE '%^[0-9]%'      
-- PRINT 'INVALID'       
      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid POSinRs. Please check the values and upload again'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid POSinRs. Please check the values and upload again'     END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POSinRs' ELSE ErrorinColumn +','+SPACE(1)+  'POSinRs' END        
--  ,Srnooferroneousrows=V.SlNo      
----        ----STUFF((SELECT ','+SlNo       
----        ----FROM CalypsoUploadAccMOCPool A      
----        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V      
----        ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
----        ----)      
----        ----FOR XML PATH ('')      
----        ----),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- --WHERE ISNULL(POSinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
      
--  UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘POS in Rs.’. Kindly check and upload value'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘POS in Rs.’. Kindly check and upload value'     END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'POSinRs' ELSE ErrorinColumn +','+SPACE(1)+  'POSinRs' END        
--  ,Srnooferroneousrows=V.SlNo      
----        ----STUFF((SELECT ','+SlNo       
----        ----FROM CalypsoUploadAccMOCPool A      
----        ----WHERE A.SlNo IN(SELECT SlNo FROM CalypsoUploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''      
----        ---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0      
----        ---- )      
----        ----FOR XML PATH ('')      
----        ----),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
----WHERE ISNULL(POSinRs,'')<>''      
----AND (CHARINDEX('.',ISNULL(POSinRs,''))>0  AND Len(Right(ISNULL(POSinRs,''),Len(ISNULL(POSinRs,''))-CHARINDEX('.',ISNULL(POSinRs,''))))>2)      
      
      
 -----------------------------------------------------------------      
   
       
 --('Wrong UCIC Linkage','DPD Freeze','Wrong recovery appropriation in source system','Exceptional issue, requires IAD concurrence',      
 --'Advances Adjustment','Security Value Update','CNPA','Restructure','Portfolio Buyout-Requires IAD Concurrence','NPA Date update',      
 --'Litigation','NPA Settlement','Standard Settlement','Erosion in Security Value','Sale of Assets','RFA/Fraud','Additional Provision','NPA Divergence')      
      
      
 ---------------------------------------------------------      
      
/*validations on InterestReceivableinRs */      
      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'InterestReceivableinRs cannot be blank. Please check the values and upload again'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'InterestReceivableinRs cannot be blank. Please check the values and upload again'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END        
--  ,Srnooferroneousrows=V.SlNo      
----        ----STUFF((SELECT ','+SlNo       
----        ----FROM CalypsoUploadAccMOCPool A      
----        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V      
----        ----WHERE ISNULL(InterestReversalAmount,'')='')      
----        ----FOR XML PATH ('')      
----        ----),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(InterestReceivableinRs,'')=''      
      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid InterestReceivableinRs. Please check the values and upload again'           
--     ELSE ErrorMessage+','+SPACE(1)+'Invalid InterestReceivableinRs. Please check the values and upload again'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END        
--  ,Srnooferroneousrows=V.SlNo      
----        --STUFF((SELECT ','+SlNo       
----        --FROM CalypsoUploadAccMOCPool A      
----        --WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V      
----        --WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR       
----        --ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'      
----        --)      
----        --FOR XML PATH ('')      
----        --),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- --WHERE (ISNUMERIC(InterestReceivableinRs)=0 AND ISNULL(InterestReceivableinRs,'')<>'') OR       
-- --ISNUMERIC(InterestReceivableinRs) LIKE '%^[0-9]%'      
-- PRINT 'INVALID'       
      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid InterestReceivableinRs. Please check the values and upload again'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid InterestReceivableinRs. Please check the values and upload again'     END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END        
--  ,Srnooferroneousrows=V.SlNo      
----        ----STUFF((SELECT ','+SlNo       
----        ----FROM CalypsoUploadAccMOCPool A      
----        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V      
----        ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
----        ----)      
----        ----FOR XML PATH ('')      
----        ----),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- --WHERE ISNULL(InterestReceivableinRs,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
      
--  UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid InterestReceivableinRs. Please check the values and upload again'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid InterestReceivableinRs. Please check the values and upload again'     END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'InterestReceivableinRs' ELSE ErrorinColumn +','+SPACE(1)+  'InterestReceivableinRs' END        
--  ,Srnooferroneousrows=V.SlNo      
----        ----STUFF((SELECT ','+SlNo       
----        ----FROM CalypsoUploadAccMOCPool A      
----        ----WHERE A.SlNo IN(SELECT SlNo FROM CalypsoUploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''      
----        ---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0      
----        ---- )      
----        ----FOR XML PATH ('')      
----        ----),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- --WHERE ISNULL(InterestReceivableinRs,'')<>''      
----AND (CHARINDEX('.',ISNULL(InterestReceivableinRs,''))>0  AND Len(Right(ISNULL(InterestReceivableinRs,''),Len(ISNULL(InterestReceivableinRs,''))-CHARINDEX('.',ISNULL(InterestReceivableinRs,''))))>2)      
      
 -----------------------------------------------------------------      
       
      
/*validations on Additional Provision - Absolute in Rs. */      
      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Additional Provision - Absolute in Rs.’. Kindly check and upload value'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Additional Provision - Absolute in Rs.’. Kindly check and upload value'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AdditionalProvisionAbsoluteinRs' ELSE ErrorinColumn +','+SPACE(1)+  'AdditionalProvisionAbsoluteinRs' END        
--  ,Srnooferroneousrows=V.SlNo      
----        ----STUFF((SELECT ','+SlNo       
----        ----FROM CalypsoUploadAccMOCPool A      
----        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V      
----        ----WHERE ISNULL(InterestReversalAmount,'')='')      
----        ----FOR XML PATH ('')      
----        ----),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(AdditionalProvisionAbsoluteinRs,'')=''      
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'           
     ELSE ErrorMessage+','+SPACE(1)+'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'      END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AdditionalProvisionAbsoluteinRs' ELSE ErrorinColumn +','+SPACE(1)+  'AdditionalProvisionAbsoluteinRs' END        
  ,Srnooferroneousrows=V.SlNo      
--        --STUFF((SELECT ','+SlNo       
--        --FROM CalypsoUploadAccMOCPool A      
--        --WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V      
--        --WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR       
--        --ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'      
--        --)      
--        --FOR XML PATH ('')      
--        --),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
 WHERE (ISNUMERIC(AdditionalProvisionAbsolute)=0 AND ISNULL(AdditionalProvisionAbsolute,'')<>'') OR       
 ISNUMERIC(AdditionalProvisionAbsolute) LIKE '%^[0-9]%'      
        
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'           
      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid AdditionalProvisionAbsoluteinRs. Please check the values and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AdditionalProvisionAbsoluteinRs' ELSE ErrorinColumn +','+SPACE(1)+  'AdditionalProvisionAbsoluteinRs' END        
  ,Srnooferroneousrows=V.SlNo      
--        ----STUFF((SELECT ','+SlNo       
--        ----FROM CalypsoUploadAccMOCPool A      
--        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V      
--        ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
--        ----)      
--        ----FOR XML PATH ('')      
--        ----),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(AdditionalProvisionAbsolute,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
      
  UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Decimal values not allowed more then 2 digit in column AdditionalProvisionAbsoluteinRs. Please check the values and upload again'           
      ELSE ErrorMessage+','+SPACE(1)+ 'Decimal values not allowed more then 2 digit in column AdditionalProvisionAbsoluteinRs. Please check the values and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AdditionalProvisionAbsoluteinRs' ELSE ErrorinColumn +','+SPACE(1)+  'AdditionalProvisionAbsoluteinRs' END        
  ,Srnooferroneousrows=V.SlNo      
--        ----STUFF((SELECT ','+SlNo       
--        ----FROM CalypsoUploadAccMOCPool A      
--        ----WHERE A.SlNo IN(SELECT SlNo FROM CalypsoUploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''      
--        ---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0      
--        ---- )      
--        ----FOR XML PATH ('')      
--        ----),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
WHERE ISNULL(AdditionalProvisionAbsolute,'')<>''      
AND (CHARINDEX('.',ISNULL(AdditionalProvisionAbsolute,''))>0  AND Len(Right(ISNULL(AdditionalProvisionAbsolute,''),Len(ISNULL(AdditionalProvisionAbsolute,''))-CHARINDEX('.',ISNULL(AdditionalProvisionAbsolute,''))))>2)      
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Numeric value not allowed more then 16 digit in column AdditionalProvisionAbsoluteinRs. Please check the values and upload again'           
      ELSE ErrorMessage+','+SPACE(1)+ 'Numeric value not allowed more then 16 digit in column AdditionalProvisionAbsoluteinRs. Please check the values and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AdditionalProvisionAbsoluteinRs' ELSE ErrorinColumn +','+SPACE(1)+  'AdditionalProvisionAbsoluteinRs' END        
  ,Srnooferroneousrows=V.SlNo      
   
 FROM CalypsoUploadAccMOCPool V        
WHERE ISNULL(AdditionalProvisionAbsolute,'')<>''      
AND (LEN(LEFT(ISNULL(AdditionalProvisionAbsolute,''),CHARINDEX('.',ISNULL(AdditionalProvisionAbsolute,''))))-1)>16 
 --------------------------RESTRUCTURE FLAG ---------------------------------------      
      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid value in column ‘Restructure Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Restructure Flag(Y/N)’. Kindly enter ‘Y or N’ and upload again'     END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureFlag' ELSE ErrorinColumn +','+SPACE(1)+  'RestructureFlag' END        
--  ,Srnooferroneousrows=V.SlNo      
----        ----STUFF((SELECT ','+SlNo       
----        ----FROM CalypsoUploadAccMOCPool A      
----        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V      
----        ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
----        ----)      
----        ----FOR XML PATH ('')      
----        ----),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(RestructureFlagYN,'') NOT IN('Y','N') AND  ISNULL(RestructureFlagYN,'')<>''      
       
       
--UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is already marked with the Restructured flag. You can only remove the marked flag for this account'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Account is already marked with the Restructured flag. You can only remove the marked flag for this account'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureFlag' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureFlag' END            
--  ,Srnooferroneousrows=V.SlNo      
--  --STUFF((SELECT ','+SlNo       
--  --      FROM #UploadNewAccount A      
--  --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
--  --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
--  --          )      
--  --      FOR XML PATH ('')      
--  --      ),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- Inner Join PRO.AccountCal_Hist  A ON V.AccountID=A.CustomerAcID And A.EffectiveToTimeKey=49999      
-- WHERE ISNULL(A.FlgRestructure,'') ='Y'      
       
       
       
--UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account is not marked to the Restructured flag. You can only add the marked flag for this account'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Account is not marked to the Restructured flag. You can only add the marked flag for this account'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureFlag' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureFlag' END            
--  ,Srnooferroneousrows=V.SlNo      
--  --STUFF((SELECT ','+SlNo       
--  --      FROM #UploadNewAccount A      
--  --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
--  --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
--  --          )      
--  --      FOR XML PATH ('')      
--  --      ),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
--Inner Join PRO.AccountCal_Hist  A ON V.AccountID=A.CustomerAcID And A.EffectiveToTimeKey=49999      
-- WHERE ISNULL(A.FlgRestructure,'') ='N'      
       
      
      
 -----------------------------------------------------------------      
      
 /*validations on Restructure Date */      
      
 --UPDATE CalypsoUploadAccMOCPool      
 --SET        
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'RestructureDate Can not be Blank . Please enter the RestructureDate and upload again'           
 --     ELSE ErrorMessage+','+SPACE(1)+ 'RestructureDate Can not be Blank. Please enter the RestructureDate and upload again'      END      
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END            
 -- ,Srnooferroneousrows=V.SlNo      
 -- --STUFF((SELECT ','+SlNo       
 -- --      FROM #UploadNewAccount A      
 -- --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
 -- --          WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''      
 -- --          )      
 -- --      FOR XML PATH ('')      
 -- --      ),1,1,'')         
      
 --FROM CalypsoUploadAccMOCPool V        
 --WHERE ISNULL(RestructureDate,'')=''       
      
-- SET DATEFORMAT DMY     
--UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END            
--  ,Srnooferroneousrows=V.SlNo      
--  --STUFF((SELECT ','+SlNo       
--  --      FROM #UploadNewAccount A      
--  --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
--  --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
--  --          )      
--  --      FOR XML PATH ('')      
--  --      ),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(RestructureDate,'')<>'' AND ISDATE(RestructureDate)=0      
      
      
--  Set DateFormat DMY      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Restructure date must be less than equal to current date. Kindly check and upload again'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Restructure date must be less than equal to current date. Kindly check and upload again'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END            
--  ,Srnooferroneousrows=V.SlNo      
--  --STUFF((SELECT ','+SlNo       
--  --      FROM #UploadNewAccount A      
--  --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
--  --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
--  --          )      
--  --      FOR XML PATH ('')      
--  --      ),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- WHERE (Case When ISDATE(RestructureDate)=1 Then Case When Cast(RestructureDate as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1      
      
      
      
--  UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Restructure Date is mandatory when value ‘Y’ is entered in column ‘Restructure Flag'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Restructure Date is mandatory when value ‘Y’ is entered in column ‘Restructure Flag'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'RestructureDate' ELSE   ErrorinColumn +','+SPACE(1)+'RestructureDate' END            
--  ,Srnooferroneousrows=V.SlNo      
--  --STUFF((SELECT ','+SlNo       
--  --      FROM #UploadNewAccount A      
--  --      WHERE A.SlNo IN(SELECT V.SlNo FROM #UploadNewAccount V        
--  --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
--  --          )      
--  --      FOR XML PATH ('')      
--  --      ),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(RestructureFlagYN,'') IN('Y') AND ISNULL(RestructureDate,'' )=''      
      
       
      
 -----------------------------------------------------------------      
      
 /*validations on FraudDate */      
      
 --UPDATE CalypsoUploadAccMOCPool      
 --SET        
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'FraudDate Can not be Blank . Please enter the FraudDate and upload again'           
 --     ELSE ErrorMessage+','+SPACE(1)+ 'FraudDate Can not be Blank. Please enter the FraudDate and upload again'      END      
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FraudDate' ELSE   ErrorinColumn +','+SPACE(1)+'FraudDate' END            
 -- ,Srnooferroneousrows=V.SlNo      
 -- --STUFF((SELECT ','+SlNo       
 -- --      FROM #UploadNewAccount A      
 -- --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
 -- --          WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''      
 -- --          )      
 -- --      FOR XML PATH ('')      
 -- --      ),1,1,'')         
      
 --FROM CalypsoUploadAccMOCPool V        
 --WHERE ISNULL(FraudDate,'')=''       
      
-- Set DateFormat DMY      
--UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FraudDate' ELSE   ErrorinColumn +','+SPACE(1)+'FraudDate' END            
--  ,Srnooferroneousrows=V.SlNo      
--  --STUFF((SELECT ','+SlNo       
--  --      FROM #UploadNewAccount A      
--  --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
--  --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
--  --          )      
--  --      FOR XML PATH ('')      
--  --      ),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(FraudDate,'')<>'' AND ISDATE(FraudDate)=0      
      
      
       
-- Set DateFormat DMY      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Fraud date must be less than equal to current date. Kindly check and upload again'           
-- ELSE ErrorMessage+','+SPACE(1)+ 'Fraud date must be less than equal to current date. Kindly check and upload again'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FraudDate' ELSE   ErrorinColumn +','+SPACE(1)+'FraudDate' END            
--  ,Srnooferroneousrows=V.SlNo      
--  --STUFF((SELECT ','+SlNo       
--  --      FROM #UploadNewAccount A      
--  --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
--  --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
--  --          )      
--  --      FOR XML PATH ('')      
--  --      ),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
--WHERE (Case When ISDATE(FraudDate)=1 Then Case When Cast(FraudDate as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1      
       
      
 -- UPDATE CalypsoUploadAccMOCPool      
 --SET        
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Fraud Date is mandatory when value ‘Y’ is entered in column ‘Fraud Flag'           
 --     ELSE ErrorMessage+','+SPACE(1)+ 'Fraud Date is mandatory when value ‘Y’ is entered in column ‘Fraud Flag'      END      
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'FraudDate' ELSE   ErrorinColumn +','+SPACE(1)+'FraudDate' END            
 -- ,Srnooferroneousrows=V.SlNo      
 -- --STUFF((SELECT ','+SlNo       
 -- --      FROM #UploadNewAccount A      
 -- --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
 -- --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
 -- --          )      
 -- --      FOR XML PATH ('')      
 -- --      ),1,1,'')         
      
 --FROM CalypsoUploadAccMOCPool V        
 --WHERE ISNULL(FraudDate,'')=''      
 ---------------------------------MOC Source---------------------------      
      
       
      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the    
  
   
      
      
      
      
      
      
      
      
      
      
--column'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSource' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSource' END            
--  ,Srnooferroneousrows=V.SlNo      
--  --STUFF((SELECT ','+SlNo       
--  --      FROM #UploadNewAccount A      
--  --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
--  --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
--  --          )      
--  --      FOR XML PATH ('')      
--  --      ),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- left JOIN  DimMOCType a       
-- on v.MOCSOURCE = A.MOCTypeName      
-- WHERE A.MOCTypeName is NULL      
      
      
      
      
 -------------MOCSource--------------------      
--   Declare @ValidSourceInt int=0      
      
-- IF OBJECT_ID('MocSourceData') IS NOT NULL        
--   BEGIN        
--    DROP TABLE MocSourceData        
       
--   END      
      
--SELECT * into MocSourceData  FROM(      
-- SELECT ROW_NUMBER() OVER(PARTITION BY MOCSOURCE  ORDER BY  MOCSOURCE )       
-- ROW ,MOCSOURCE FROM CalypsoUploadAccMOCPool      
--)X      
-- WHERE ROW=1      
      
      
--   SELECT  @ValidSourceInt=COUNT(*) FROM MocSourceData A      
-- Left JOIN DimMOCType B      
-- ON  A.MOCSOURCE=B.MOCTypeName      
-- Where B.MOCTypeName IS NULL      
-- AND   EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey      
      
--   IF @ValidSourceInt>0      
      
--     BEGIN      
--          UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for th 
  
   
--e column'           
--      ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END        
--        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END           
--  ,Srnooferroneousrows=V.SlNo      
--   FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(MOCSOURCE,'')<>''      
-- AND  V.MOCSOURCE IN(      
--    SELECT  A.MOCSOURCE FROM MocSourceData A      
--      Left JOIN DimMOCType B      
--      ON  A.MOCSOURCE=B.MOCTypeName      
--      Where B.MOCTypeName IS NULL      
--      AND   EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey      
--     )      
      
--  END      
      
      
--  UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC source can not be blank,  Please check the values and upload again'           
--      ELSE ErrorMessage+','+SPACE(1)+'MOC source can not be blank,  Please check the values and upload again'     END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END             
--  ,Srnooferroneousrows=V.SlNo      
       
         
--   FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(MOCSOURCE,'')=''      
      
      
 Declare @ValidSourceInt int=0      
      
       
      
 IF OBJECT_ID('MocSourceData') IS NOT NULL        
   BEGIN        
    DROP TABLE MocSourceData        
       
   END      
      
SELECT * into MocSourceData  FROM(      
 SELECT ROW_NUMBER() OVER(PARTITION BY MOCSOURCE  ORDER BY  MOCSOURCE )       
 ROW ,MOCSOURCE FROM CalypsoUploadAccMOCPool      
)X      
 WHERE ROW=1      
      
      
   SELECT  @ValidSourceInt=COUNT(*) FROM MocSourceData A      
 Left JOIN DimMOCType B      
 ON A.MOCSOURCE=B.MOCTypeName      
 Where B.MOCTypeName IS NULL      
 AND      
 (    
 (B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@Timekey)or    
 (B.EffectiveFromTimeKey IS NULL And B.EffectiveToTimeKey IS NULL)    
 )    
      
   IF @ValidSourceInt>0      
      
     BEGIN      
          UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the 
c  
    
olumn'           
      ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘MOC Source’. Kindly enter the values as mentioned in the ‘MOC Source’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END        
        ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END           
  ,Srnooferroneousrows=V.SlNo      
   FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(MOCSOURCE,'')<>''      
 AND  V.MOCSOURCE IN(      
    SELECT  A.MOCSOURCE FROM MocSourceData A      
      Left JOIN DimMOCType B      
      ON  A.MOCSOURCE=B.MOCTypeName      
      Where B.MOCTypeName IS NULL      
      AND  (    
           (B.EffectiveFromTimeKey<=@Timekey And B.EffectiveToTimeKey>=@Timekey)or    
           (B.EffectiveFromTimeKey IS NULL And B.EffectiveToTimeKey IS NULL)    
           )    
     )      
      
  END      
      
      
  UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC source can not be blank,  Please check the values and upload again'           
      ELSE ErrorMessage+','+SPACE(1)+'MOC source can not be blank,  Please check the values and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCSOURCE' ELSE   ErrorinColumn +','+SPACE(1)+'MOCSOURCE' END             
  ,Srnooferroneousrows=V.SlNo      
       
   FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(MOCSOURCE,'')=''      
       
 ---------------------------------------      
      
       
/*VALIDATIONS ON BookValueINRMTMValue */      
      
      
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Digit between 0 to 9 must be present in column BookValueINRMTMValue. Please check the values and upload again'           
     ELSE ErrorMessage+','+SPACE(1)+'Digit between 0 to 9 must be present in column BookValueINRMTMValue. Please check the values and upload again'      END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BookValueINRMTMValue' ELSE ErrorinColumn +','+SPACE(1)+  'BookValueINRMTMValue' END        
  ,Srnooferroneousrows=V.SlNo      
--        --STUFF((SELECT ','+SlNo       
--        --FROM UploadAccMOCPool A      
--        --WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V      
--        --WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR       
--        --ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'      
--        --)      
--        --FOR XML PATH ('')      
--        --),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
 WHERE (ISNUMERIC(BookValueINRMTMValue)=0 AND ISNULL(BookValueINRMTMValue,'')<>'') OR       
 ISNUMERIC(BookValueINRMTMValue) LIKE '%^[0-9]%'      
 PRINT 'INVALID'       
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Following character ,!@#$%^&*()_-+=/ must not be present in column BookValueINRMTMValue.Not allow special character in BookValueINRMTMValue column'           
      ELSE ErrorMessage+','+SPACE(1)+ 'Following character ,!@#$%^&*()_-+=/ must not be present in column BookValueINRMTMValue. Please check the values and upload again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BookValueINRMTMValue' ELSE ErrorinColumn +','+SPACE(1)+  'BookValueINRMTMValue' END        
  ,Srnooferroneousrows=V.SlNo      
--        ----STUFF((SELECT ','+SlNo       
--        ----FROM UploadAccMOCPool A      
--        ----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V      
--        ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
--        ----)      
--        ----FOR XML PATH ('')      
--        ----),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(BookValueINRMTMValue,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
      
  UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Decimal values not allowed more then 2 digit in column BookValueINRMTMValue’. Kindly check and upload value'           
      ELSE ErrorMessage+','+SPACE(1)+ 'Decimal values not allowed more then 2 digit in column ‘BookValueINRMTMValue’. Kindly check and upload value'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'BookValueINRMTMValue' ELSE ErrorinColumn +','+SPACE(1)+  'BookValueINRMTMValue' END        
  ,Srnooferroneousrows=V.SlNo      
--        ----STUFF((SELECT ','+SlNo       
--        ----FROM UploadAccMOCPool A      
--        ----WHERE A.SlNo IN(SELECT SlNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''      
--        ---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0      
--        ---- )      
--        ----FOR XML PATH ('')      
--        ----),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
WHERE ISNULL(BookValueINRMTMValue,'')<>''      
AND (CHARINDEX('.',ISNULL(BookValueINRMTMValue,''))>0  AND Len(Right(ISNULL(BookValueINRMTMValue,''),Len(ISNULL(BookValueINRMTMValue,''))-CHARINDEX('.',ISNULL(BookValueINRMTMValue,''))))>2)      
      
      
 -----------------------------------------------------------------      
      
  ---------------------------------------      
      
       
/*VALIDATIONS ON UnservicedInterest */      
      
      
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Digit between 0 to 9 must be present in column UnservicedInterest. Please check the values and upload again'           
     ELSE ErrorMessage+','+SPACE(1)+'Digit between 0 to 9 must be present in column UnservicedInterest. Please check the values and upload again'      END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UnservicedInterest' ELSE ErrorinColumn +','+SPACE(1)+  'UnservicedInterest' END        
  ,Srnooferroneousrows=V.SlNo      
--        --STUFF((SELECT ','+SlNo       
--        --FROM UploadAccMOCPool A      
--        --WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V      
--        --WHERE (ISNUMERIC(InterestReversalAmount)=0 AND ISNULL(InterestReversalAmount,'')<>'') OR       
--        --ISNUMERIC(InterestReversalAmount) LIKE '%^[0-9]%'      
--        --)      
--        --FOR XML PATH ('')      
--        --),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
 WHERE (ISNUMERIC(UnservicedInterest)=0 AND ISNULL(UnservicedInterest,'')<>'') OR       
 ISNUMERIC(UnservicedInterest) LIKE '%^[0-9]%'      
 PRINT 'INVALID'       
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid UnservicedInterest. Not allow special character in UnservicedInterest column'           
      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid UnservicedInterest. Not allow special character in UnservicedInterest column'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UnservicedInterest' ELSE ErrorinColumn +','+SPACE(1)+  'UnservicedInterest' END        
  ,Srnooferroneousrows=V.SlNo      
--        ----STUFF((SELECT ','+SlNo       
--        ----FROM UploadAccMOCPool A      
--        ----WHERE A.SlNo IN(SELECT V.SlNo FROM UploadAccMOCPool V      
--        ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
--        ----)      
--        ----FOR XML PATH ('')      
--        ----),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(UnservicedInterest,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
      
  UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage= CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Decimal values not allowed more then 2 digit in column ‘UnservicedInterest’. Kindly check and upload value'           
      ELSE ErrorMessage+','+SPACE(1)+ 'Decimal values not allowed more then 2 digit in column ‘UnservicedInterest’. Kindly check and upload value'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UnservicedInterest' ELSE ErrorinColumn +','+SPACE(1)+  'UnservicedInterest' END        
  ,Srnooferroneousrows=V.SlNo      
--        ----STUFF((SELECT ','+SlNo       
--        ----FROM UploadAccMOCPool A      
--        ----WHERE A.SlNo IN(SELECT SlNo FROM UploadAccMOCPool WHERE ISNULL(InterestReversalAmount,'')<>''      
--        ---- AND TRY_CONVERT(DECIMAL(25,2),ISNULL(InterestReversalAmount,0)) <0      
--        ---- )      
--        ----FOR XML PATH ('')      
--        ----),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
WHERE ISNULL(UnservicedInterest,'')<>''      
AND (CHARINDEX('.',ISNULL(UnservicedInterest,''))>0  AND Len(Right(ISNULL(UnservicedInterest,''),Len(ISNULL(UnservicedInterest,''))-CHARINDEX('.',ISNULL(UnservicedInterest,''))))>2)      
      
      
 -----------------------------------------------------------------      
      
 -----------------------------------MOC Reason-------------------------      
      
       
 --UPDATE CalypsoUploadAccMOCPool      
 --SET        
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC Reason Can not be Blank . Please enter the MOC Reason and upload again'           
 --     ELSE ErrorMessage+','+SPACE(1)+ 'MOC Reason Can not be Blank. Please enter the MOC Reason and upload again'      END      
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END            
 -- ,Srnooferroneousrows=V.SlNo      
 -- --STUFF((SELECT ','+SlNo       
 -- --      FROM #UploadNewAccount A      
 -- --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
 -- --          WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''      
 -- --          )      
 -- --      FOR XML PATH ('')      
 -- --      ),1,1,'')         
      
 --FROM CalypsoUploadAccMOCPool V        
 --WHERE ISNULL(MOCReason,'')=''       
      
       
 --UPDATE CalypsoUploadAccMOCPool      
 --SET        
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC reason cannot be greater than 500 characters'           
 --     ELSE ErrorMessage+','+SPACE(1)+ 'MOC reason cannot be greater than 500 characters'      END      
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END            
 -- ,Srnooferroneousrows=V.SlNo      
 -- --STUFF((SELECT ','+SlNo       
 -- --      FROM #UploadNewAccount A      
 -- --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
 -- --          WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''      
 -- --          )      
 -- --      FOR XML PATH ('')      
 -- --      ),1,1,'')         
      
 --FROM CalypsoUploadAccMOCPool V        
 --WHERE LEN(MOCReason)>500      
       
 -- UPDATE CalypsoUploadAccMOCPool      
 --SET        
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'           
 --     ELSE ErrorMessage+','+SPACE(1)+ 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'      END      
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END            
 -- ,Srnooferroneousrows=V.SlNo      
 -- --STUFF((SELECT ','+SlNo       
 -- --      FROM #UploadNewAccount A      
 -- --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
 -- --          WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''      
 -- --          )      
 -- --      FOR XML PATH ('')      
 -- --      ),1,1,'')         
      
 --FROM CalypsoUploadAccMOCPool V        
 --WHERE LEN(MOCReason) LIKE '%[!@#$%^&*()_+=]%'      
      
      
      
      
       
 UPDATE CalypsoUploadAccMOCPool      
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
         
FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(MOCReason,'')=''      
      
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC reason cannot be greater than 500 characters'           
      ELSE ErrorMessage+','+SPACE(1)+ 'MOC reason cannot be greater than 500 characters'      END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END            
  ,Srnooferroneousrows=V.SlNo      
  --STUFF((SELECT ','+SlNo       
  --      FROM #UploadNewAccount A      
  --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
  --          WHERE ISNULL(AssetClass,'')<>'' AND ISNULL(AssetClass,'')<>'STD' and  ISNULL(NPIDate,'')=''      
  --          )      
  --      FOR XML PATH ('')      
  --      ),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
 WHERE LEN(MOCReason)>500      
      
      
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'           
      ELSE ErrorMessage+','+SPACE(1)+ 'For MOC reason column, special characters - , /\ are allowed. Kindly check and try again'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOC reason' ELSE ErrorinColumn +','+SPACE(1)+  'MOC reason' END        
  ,Srnooferroneousrows=V.SlNo      
--        ----STUFF((SELECT ','+SlNo       
--        ----FROM CalypsoUploadCustMocUpload A      
--        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadCustMocUpload V      
--        ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
--        ----)      
--        ----FOR XML PATH ('')      
--        ----),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(MOCReason,'') LIKE'%[!@#$%^&*()_+=]%'      
      
  UPDATE CalypsoUploadAccMOCPool      
 SET        
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'MOC reason should be as per master values'           
      ELSE ErrorMessage+','+SPACE(1)+ 'MOC reason should be as per master values'      END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE   ErrorinColumn +','+SPACE(1)+'MOCReason' END            
  ,Srnooferroneousrows=V.SlNo        
      
 FROM CalypsoUploadAccMOCPool V        
 WHERE ISNULL(MOCReason,'')<>'' and      
 ISNULL(MOCReason,'') NOT IN  (select  ParameterName from DimParameter      
    where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and      
     DimParameterName = 'DimMOCReason')    
	 


--	  /*validations on MOC Reason */      
      
--  UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'Invalid MOC Reason. Please check the values and upload again'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid MOC Reasons. Please check the values and upload again'     END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'MOCReason' ELSE ErrorinColumn +','+SPACE(1)+  'MOCReason' END        
--  ,Srnooferroneousrows=V.SlNo      
----        ----STUFF((SELECT ','+SlNo       
----        ----FROM CalypsoUploadAccMOCPool A      
----        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V      
----        ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
----        ----)      
----        ----FOR XML PATH ('')      
----        ----),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(MOCReason,'') NOT IN (select  ParameterName from DimParameter      
--    where EffectiveFromTimeKey<=@Timekey And EffectiveToTimeKey>=@Timekey and      
--     DimParameterName = 'DimMOCReason')   
      
      
 UPDATE CalypsoUploadAccMOCPool      
 SET        
   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN  'One values is mandatory out of UnservicedInterest , BookValueINRMTMValue ,AdditionalProvisionAbsolute'           
      ELSE ErrorMessage+','+SPACE(1)+ 'One values is mandatory out of UnservicedInterest , BookValueINRMTMValue ,AdditionalProvisionAbsolute'     END      
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'UnservicedInterest , BookValueINRMTMValue ,AdditionalProvisionAbsolute' ELSE ErrorinColumn +','+SPACE(1)+  'UnservicedInterest , BookValueINRMTMValue ,AdditionalProvisionAbsolute' END        
  ,Srnooferroneousrows=V.SlNo      
--        ----STUFF((SELECT ','+SlNo       
--        ----FROM CalypsoUploadCustMocUpload A      
--        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadCustMocUpload V      
--        ---- WHERE ISNULL(InterestReversalAmount,'') LIKE'%[,!@#$%^&*()_-+=/]%'      
--        ----)      
--        ----FOR XML PATH ('')      
--        ----),1,1,'')         
      
 FROM CalypsoUploadAccMOCPool V        
WHERE    
ISNULL(UnservicedInterest,'')=''           AND     
ISNULL(BookValueINRMTMValue,'')=''         AND    
ISNULL(AdditionalProvisionAbsolute,'')=''       
       
       
/*VALIDATIONS ON TWO Date */      
      
--UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid date format. Please enter the date in format ‘dd-mm-yyyy’'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'TwoDate' ELSE   ErrorinColumn +','+SPACE(1)+'TwoDate' END            
--  ,Srnooferroneousrows=V.SlNo      
--  --STUFF((SELECT ','+SlNo       
--  --      FROM #UploadNewAccount A      
--  --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
--  --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
--  --          )      
--  --      FOR XML PATH ('')      
--  --      ),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(TWODate,'')<>'' AND ISDATE(TWODate)=0      
      
--  UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'The column ‘TWO Date’ is mandatory. Kindly check and upload again'           
--     ELSE ErrorMessage+','+SPACE(1)+'The column ‘TWO Date’ is mandatory. Kindly check and upload again'     END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'TWO Date' ELSE ErrorinColumn +','+SPACE(1)+  'TWO Date' END        
--  ,Srnooferroneousrows=V.SlNo      
----        ----STUFF((SELECT ','+SlNo       
----        ----FROM CalypsoUploadAccMOCPool A      
----        ----WHERE A.SlNo IN(SELECT V.SlNo FROM CalypsoUploadAccMOCPool V        
----        ----    WHERE ISNULL(ACID,'')='' )      
----        ----FOR XML PATH ('')      
----        ----),1,1,'')         
      
--FROM CalypsoUploadAccMOCPool V        
-- WHERE ISNULL(Twodate,'')=''  --and ISNULL(TWOFlag,'') = 'Y'      
      
-- UPDATE CalypsoUploadAccMOCPool      
-- SET        
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'TWO date must be less than equal to current date. Kindly check and upload again'           
--      ELSE ErrorMessage+','+SPACE(1)+ 'TWO date must be less than equal to current date. Kindly check and upload again'      END      
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'TwoDate' ELSE   ErrorinColumn +','+SPACE(1)+'TwoDate' END            
--  ,Srnooferroneousrows=V.SlNo      
--  --STUFF((SELECT ','+SlNo       
--  --      FROM #UploadNewAccount A      
--  --      WHERE A.SlNo IN(SELECT V.SlNo  FROM #UploadNewAccount V        
--  --            WHERE ISNULL(NPIDate,'')<>'' AND (CAST(ISNULL(NPIDate ,'')AS Varchar(10))<>FORMAT(cast(NPIDate as date),'dd-MM-yyyy'))      
      
--  --          )      
--  --      FOR XML PATH ('')      
-- --      ),1,1,'')         
      
-- FROM CalypsoUploadAccMOCPool V        
--WHERE (Case When ISDATE(Twodate)=1 Then Case When Cast(Twodate as date)>Cast(GETDATE() as Date) Then 1 Else 0 END END)=1      
      
 -------------------------------Validations on TWO Amount-----------------      
      
      
 -----------------------------------------------------------      
 --select * from DimMOCType      
 Print '123'      
 goto valid      
      
  END      
       
   ErrorData:        
   print 'no'        
      
  SELECT *,'Data'TableName      
  FROM dbo.MasterUploadData WHERE FileNames=@filepath       
  return      
      
   valid:      
  IF NOT EXISTS(Select 1 from  CalypsoAccountLvlMOCDetails_stg WHERE filname=@FilePathUpload)      
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
   FROM CalypsoUploadAccMOCPool       
      
      
         
  -- ----SELECT * FROM CalypsoUploadAccMOCPool       
      
  -- --ORDER BY ErrorMessage,CalypsoUploadAccMOCPool.ErrorinColumn DESC      
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
print 'Jayadev'      
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
  print 'Jayadev1'      
   IF EXISTS(SELECT 1 FROM CalypsoAccountLvlMOCDetails_stg WHERE filname=@FilePathUpload)      
   BEGIN      
   DELETE FROM CalypsoAccountLvlMOCDetails_stg      
   WHERE filname=@FilePathUpload      
   print 'Jayadev2'      
   PRINT 1      
      
   PRINT 'ROWS DELETED FROM DBO.CalypsoAccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))      
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
      
 ----SELECT * FROM CalypsoUploadAccMOCPool      
      
 print 'p'      
  ------to delete file if it has errors      
  --if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')      
  --begin      
  --print 'ppp'      
  -- IF EXISTS(SELECT 1 FROM CalypsoAccountLvlMOCDetails_stg WHERE filename=@FilePathUpload)      
  -- BEGIN      
  -- print '123'      
  -- DELETE FROM CalypsoAccountLvlMOCDetails_stg      
  -- WHERE filename=@FilePathUpload      
      
  -- PRINT 'ROWS DELETED FROM DBO.CalypsoAccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))      
  -- END      
  -- END      
      
         
END  TRY      
        
  BEGIN CATCH      
       
      
 INSERT INTO dbo.Error_Log      
    SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber      
    ,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState      
    ,GETDATE()      
      
 --IF EXISTS(SELECT 1 FROM CalypsoAccountLvlMOCDetails_stg WHERE filename=@FilePathUpload)      
 --  BEGIN      
 --  DELETE FROM CalypsoAccountLvlMOCDetails_stg      
 --  WHERE filename=@FilePathUpload      
      
 --  PRINT 'ROWS DELETED FROM DBO.CalypsoAccountLvlMOCDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))      
 --  END      
      
END CATCH      
      
END      
      
GO