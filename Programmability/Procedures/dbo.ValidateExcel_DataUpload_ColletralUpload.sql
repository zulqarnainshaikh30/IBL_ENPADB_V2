SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ValidateExcel_DataUpload_ColletralUpload]  
@MenuID INT=10,    
@UserLoginId  VARCHAR(20)='fnachecker',    
@Timekey INT=49999  
,@filepath VARCHAR(MAX) ='IBPCUPLOAD.xlsx'    
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
   
 Select   @Timekey=Max(Timekey) from sysDayMatrix where Cast(date as Date)=cast(getdate() as Date)  
  
  PRINT @Timekey    
    
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
  
  
IF (@MenuID=24702)   
BEGIN  
  
  
   -- IF OBJECT_ID('tempdb..UploadCollateral') IS NOT NULL    
   IF OBJECT_ID('UploadCollateral') IS NOT NULL    
   BEGIN    
    DROP TABLE UploadCollateral    
   
   END  
     
  IF NOT (EXISTS (SELECT * FROM CollateralDetails_stg where filname=@FilePathUpload))  
  
BEGIN  
print 'NO DATA'  
   Insert into dbo.MasterUploadData  
   (SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag)   
   SELECT 0 SRNO , '' ColumnName,'No Record found' ErrorData,'No Record found' ErrorType,@filepath,'SUCCESS'   
   --SELECT 0 SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS'   
  
   goto errordata  
      
END  
  
ELSE  
BEGIN  
PRINT 'DATA PRESENT'  
    Select *,CAST('' AS varchar(MAX)) ErrorMessage,CAST('' AS varchar(MAX)) ErrorinColumn,CAST('' AS varchar(MAX)) Srnooferroneousrows  
     into UploadCollateral   
    from CollateralDetails_stg   
    WHERE filname=@FilePathUpload  
  
     
END  
  
  
  ------------------------------------------------------------------------------    
     
 --SrNo Territory ACID InterestReversalAmount filname  
   
 UPDATE UploadCollateral  
 SET    
        ErrorMessage='There is no data in excel. Kindly check and upload again'   
  ,ErrorinColumn='CollateralID,Tagging Level,DistributionLevel,CollateralType,CollateralOwnerType,Interest CollateralOwnershipType,Balances,Dates'      
  ,Srnooferroneousrows=''  
 FROM UploadCollateral V    
 WHERE ISNULL(OldCollateralID,'')=''  
AND ISNULL(TaggingLevel,'')=''  
AND ISNULL(DistributionLevel,'')=''  
AND ISNULL(DistributionValue,'')=''  
AND ISNULL(CollateralType,'')=''  
AND ISNULL(CollateralSubType,'')=''  
AND ISNULL(CollateralOwnerType,'')=''  
AND ISNULL(CollateralOwnershipType,'')=''  
AND ISNULL(ChargeType,'')=''  
AND ISNULL(ChargeNature,'')=''  
AND ISNULL(ShareAvailableToBank,'')=''  
AND ISNULL(ShareValue,'')=''  
AND ISNULL(CollateralValueatSanctioninRs,'')=''  
AND ISNULL(CollateralValueasonNPADateinRs,'')=''  
AND ISNULL(CollateralValueatLastReviewinRs,'')=''  
AND ISNULL(ValuationDate,'')=''  
AND ISNULL(CurrentCollateralValueinRs,'')=''  
AND ISNULL(ExpiryBusinessRule,'')=''  
    
--WHERE ISNULL(V.SrNo,'')=''  
-- ----AND ISNULL(Territory,'')=''  
-- AND ISNULL(AccountID,'')=''  
-- AND ISNULL(PoolID,'')=''  
-- AND ISNULL(filname,'')=''  
  
  --IF EXISTS(SELECT 1 FROM UploadCollateral WHERE ISNULL(ErrorMessage,'')<>'')  
  --BEGIN  
  --PRINT 'NO DATA'  
  --GOTO ERRORDATA;  
  --END  
  
      /*validations on Sl. No.*/  
 ------------------------------------------------------------  
 PRINT 'Satart11'  
  Declare @DuplicateCnt int=0  
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(SrNo,'')='' or ISNULL(SrNo,'0')='0'  
  
  
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'SrNo cannot be greater than 16 character . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'SrNo cannot be greater than 16 character . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE Len(SrNo)>16  
  
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Sl. No., kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid Sl. No., kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
  WHERE (ISNUMERIC(SrNo)=0 AND ISNULL(SrNo,'')<>'') OR   
 ISNUMERIC(SrNo) LIKE '%^[0-9]%'  
  
 UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters not allowed, kindly remove and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Special characters not allowed, kindly remove and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
   WHERE ISNULL(SrNo,'') LIKE'%[,!@#$%^&*()_-+=/]%'  
  
   --  
  SELECT @DuplicateCnt=Count(1)  
FROM UploadCollateral  
GROUP BY  SrNo  
HAVING COUNT(SrNo) >1;  
  
IF (@DuplicateCnt>0)  
  
 UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Sl. No., kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Duplicate Sl. No., kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'SrNo' ELSE   ErrorinColumn +','+SPACE(1)+'SrNo' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
   Where ISNULL(SrNo,'') In(    
   SELECT SrNo  
 FROM UploadCollateral  
 GROUP BY  SrNo  
 HAVING COUNT(SrNo) >1  
  
)  
 --------------------------------LEN changes 16082021 sudesh-------  
    
  /*validations on Old Collateral IDl*/  
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Old Collateral ID cannot be blank or Less than 20 Character. Please check the values and upload again.'       
      ELSE ErrorMessage+','+SPACE(1)+'Old Collateral ID cannot be blank or Less than 20 Character . Please check the values and upload again.n'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Old Collateral ID' ELSE   ErrorinColumn +','+SPACE(1)+'Old Collateral ID' END     
  ,Srnooferroneousrows=V.SrNo  
          
   FROM UploadCollateral V    
 WHERE --ISNULL(OldCollateralID,'')='' Or  
 Len((OldCollateralID))>20  
  
  
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Old Collateral ID.’. Kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Old Collateral ID’. Kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Old Collateral ID' ELSE   ErrorinColumn +','+SPACE(1)+'Old Collateral ID' END         
  ,Srnooferroneousrows=V.SrNo  
  
     
   FROM UploadCollateral V    
  WHERE (ISNUMERIC(OldCollateralID)=0 AND ISNULL(OldCollateralID,'')<>'') OR   
 ISNUMERIC(OldCollateralID) LIKE '%^[0-9]%'  
  
  
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Old Collateral ID can not contain decimal. Kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Old Collateral ID can not contain decimal. Kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Old Collateral ID' ELSE   ErrorinColumn +','+SPACE(1)+'Old Collateral ID' END         
  ,Srnooferroneousrows=V.SrNo  
  
     
   FROM UploadCollateral V    
  WHERE (CHARINDEX('.',OldCollateralID))>0  
  
   
 --  UPDATE UploadCollateral  
 --SET    
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate Old Collateral ID, kindly check and upload again '       
 --     ELSE ErrorMessage+','+SPACE(1)+'Duplicate Old Collateral ID, kindly check and upload again'     END  
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Old Collateral ID' ELSE   ErrorinColumn +','+SPACE(1)+'Old Collateral ID' END         
 -- ,Srnooferroneousrows=V.SrNo  
  
     
 --  FROM UploadCollateral V    
 --WHERE   
 -- ISNULL(OldCollateralID,'')  In(   
 --         SELECT OldCollateralID  
 --       FROM UploadCollateral  
 --       GROUP BY  OldCollateralID  
 --       HAVING COUNT(OldCollateralID) >1  
 --      )  
  
  
  
 --  UPDATE UploadCollateral  
 --SET    
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Record for Old Collateral ID is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(100),C.UploadId) +' kindly remove the record and upload again '       
 --     ELSE ErrorMessage+','+SPACE(1)+'Record for Old Collateral ID is pending for authorization in ‘Upload ID’ '+ Convert(Varchar(100),C.UploadId) +' kindly remove the record and upload again '     END  
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Old Collateral ID' ELSE   ErrorinColumn +','+SPACE(1)+'Old Collateral ID' END         
 -- ,Srnooferroneousrows=V.SrNo  
  
     
 --     FROM UploadCollateral V    
 --  Inner Join AdvSecurityDetail_Mod B ON V.OldCollateralID=B.Security_RefNo  
 --  Inner Join CollateralMgmtUpload_Mod C ON V.OldCollateralID=C.OldCollateralID  
 --WHERE   
 -- B.AuthorisationStatus In('NP','MP','FM')  
         
 -------------------------------------------------------------------------  
  
  
----------------------------------------------  
    
  /*validations on Tagging Level*/  
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Tagging Level cannot be blank . Please check the values and upload again.'       
      ELSE ErrorMessage+','+SPACE(1)+' Tagging Level cannot be blank . Please check the values and upload again.n'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Tagging Level' ELSE   ErrorinColumn +','+SPACE(1)+'Tagging Level' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(TaggingLevel,'')=''  
  
  
    
  
  
   
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Tagging Level’. Kindly enter ‘UCIC or Customerid or AccountID’ and upload again. '       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Tagging Level’. Kindly enter ‘UCIC or Customerid or AccountID’ and upload again.'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Tagging Level' ELSE   ErrorinColumn +','+SPACE(1)+'Tagging Level' END         
  ,Srnooferroneousrows=V.SrNo  
   FROM UploadCollateral V    
 WHERE ISNULL(DistributionLevel,'')<>''  
 AND ISNULL(TaggingLevel,'') Not In('UCIC', 'CustomerID', 'AccountID')  
  
 -------------------------------------------------------------------------  
  
 ----------------------------------------------  
    
  /*validations on Related UCIC / Customer ID / Account ID*/  
  Declare @Count Int,@I Int,@Entity_Key Int  
  Declare @TaggingLevel Varchar(100)=''  
  Declare @RelatedUCICCustomerIDAccountID Varchar(100)=''  
  Declare @AccountId Varchar(100)=''  
  Declare @CustomerID Varchar(100)=''  
  Declare @UCIC Varchar(100)=''  
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Related UCIC / Customer ID / Account ID cannot be blank . Please check the values and upload again.'       
      ELSE ErrorMessage+','+SPACE(1)+' Related UCIC / Customer ID / Account ID cannot be blank . Please check the values and upload again.n'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related UCIC / Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related UCIC / Customer ID / Account IDl' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(RelatedUCICCustomerIDAccountID,'')=''  
  
 UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Related UCIC / Customer ID / Account ID should be less than or equal to 16 character . Please check the values and upload again.'       
      ELSE ErrorMessage+','+SPACE(1)+' Related UCIC / Customer ID / Account ID should be less than or equal to 16 character . Please check the values and upload again.n'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related UCIC / Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related UCIC / Customer ID / Account IDl' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE Len(RelatedUCICCustomerIDAccountID)>20  
  
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Special characters - _ \ / are not allowed, kindly remove and try again'       
      ELSE ErrorMessage+','+SPACE(1)+'Special characters - _ \ / are not allowed, kindly remove and try again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related UCIC / Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related UCIC / Customer ID / Account IDl' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE Len(RelatedUCICCustomerIDAccountID) Like '%- \ / _%'  
  
  IF OBJECT_ID('TempDB..#tmp') IS NOT NULL DROP TABLE #tmp;   
    
  Select  ROW_NUMBER() OVER(ORDER BY  CONVERT(INT,Entity_Key) ) RecentRownumber,Entity_Key,TaggingLevel,RelatedUCICCustomerIDAccountID,Convert(Varchar(1000),'') as ErrorMessage   
  into #tmp from UploadCollateral  
  
  Select @Count=Count(*) from #tmp  
    
   SET @I=1  
   SET @Entity_Key=0  
   SET @CustomerId=''  
   SET @UCIC=''  
   SET @AccountId=''  
 While(@I<=@Count)  
     BEGIN  
         Select @TaggingLevel=TaggingLevel,@RelatedUCICCustomerIDAccountID =RelatedUCICCustomerIDAccountID,@Entity_Key=Entity_Key  from #tmp where RecentRownumber=@I   
       order By Entity_Key  
  
       If @TaggingLevel='Account ID'  
         BEGIN  
  
              Select @AccountId=CustomerACID from advacbasicdetail where CustomerACID=@RelatedUCICCustomerIDAccountID  
           IF @AccountId =''  
             BEGIN  
             Update UploadCollateral  
             SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Account ID is invalid. Kindly check the entered Account id'       
            ELSE ErrorMessage+','+SPACE(1)+'Account ID is invalid. Kindly check the entered Account id'      END  
,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related UCIC / Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related UCIC / Customer ID / Account ID' END     
           Where Entity_Key=@Entity_Key  
         END  
         END  
  
         If @TaggingLevel='Customer ID'  
         BEGIN  
           Print 'Sachin'  
           
  
              Select @CustomerId=CustomerId from customerbasicdetail where CustomerId=@RelatedUCICCustomerIDAccountID  
              
  
          IF @CustomerId =''  
               Begin  
             Print '@CustomerIdAf'  
             Print @CustomerId  
              
            
             Update UploadCollateral  
             SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Customer ID is invalid. Kindly check the entered customer id'       
            ELSE ErrorMessage+','+SPACE(1)+'Customer ID is invalid. Kindly check the entered customer id'      END  
 ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related UCIC / Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related UCIC / Customer ID / Account ID' END   
             Where Entity_Key=@Entity_Key  
         END  
         END  
  
          If @TaggingLevel='UCIC'  
         BEGIN  
  
              Select @UCIC=UCIF_ID from customerbasicdetail where UCIF_ID=@RelatedUCICCustomerIDAccountID  
           IF @UCIC =''  
              Begin  
             Update UploadCollateral  
             SET   ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN '   UCIC is invalid. Kindly check the entered UCIC'       
            ELSE ErrorMessage+','+SPACE(1)+'   UCIC is invalid. Kindly check the entered UCIC'      END  
,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Related UCIC / Customer ID / Account ID' ELSE   ErrorinColumn +','+SPACE(1)+'Related UCIC / Customer ID / Account ID' END   
             Where Entity_Key=@Entity_Key  
         End  
         END  
  
           SET @I=@I+1  
        SET @CustomerId=''  
        SET @UCIC=''  
        SET @AccountId=''  
     END  
   
  
  
 -------------------------------------------------------------------------  
----------------------------------------------  
    
  /*validations on Distribution Level*/  
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Distribution Level cannot be blank . Please check the values and upload again.'       
      ELSE ErrorMessage+','+SPACE(1)+'Distribution Level cannot be blank . Please check the values and upload again.n'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Distribution Level' ELSE   ErrorinColumn +','+SPACE(1)+'Distribution Level' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(DistributionLevel,'')=''  
  
  
    
   
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Distribution Level’. Kindly enter ‘Proportionate or Percentage or Absolute’ and upload again’. '       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Distribution Level’. Kindly enter ‘Proportionate or Percentage or Absolute’ and upload againn'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Distribution Level' ELSE   ErrorinColumn +','+SPACE(1)+'Distribution Level' END         
  ,Srnooferroneousrows=V.SrNo  
  
     
   FROM UploadCollateral V    
 WHERE ISNULL(DistributionLevel,'')<>''  
 AND ISNULL(DistributionLevel,'') Not In('Proportionate', 'Percentage', 'Absolute')  
  
  
  
---------------------------22042021-----------------  
/*  
 IF OBJECT_ID('TEMPDB..#DupPool') IS NOT NULL  
 DROP TABLE #DupPool  
  
 SELECT * INTO #DupPool FROM(  
 SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID ORDER BY PoolID ) as rw  FROM UploadCollateral  
 )X  
 WHERE rw>1  
  
  
 UPDATE V  
 SET    
        ErrorMessage=CASE WHEN ISNULL(V.ErrorMessage,'')='' THEN  'Duplicate Pool ID found. Please check the values and upload again'       
      ELSE V.ErrorMessage+','+SPACE(1)+'Duplicate Pool ID found. Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(V.ErrorinColumn,'')='' THEN 'PoolID' ELSE V.ErrorinColumn +','+SPACE(1)+  'PoolID' END    
  ,Srnooferroneousrows=V.SRNO  
    
  FROM UploadCollateral V   
  INNer JOIN #DupPool D ON D.PoolID=V.PoolID  
*/  
--------------------------------------------------------------  
 /*-------------------Distribution Value-Validation------------------------- */ -- changes done on 19-03-21 Pranay   
  /*validations on Distribution Value*/  
  
 -- UPDATE UploadCollateral  
 --SET    
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Distribution Value cannot be blank . Please check the values and upload again'       
 --     ELSE ErrorMessage+','+SPACE(1)+'Distribution Value cannot be blank . Please check the values and upload again'     END  
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Distribution Value' ELSE   ErrorinColumn +','+SPACE(1)+'Distribution Value' END     
 -- ,Srnooferroneousrows=V.SrNo  
          
     
 --  FROM UploadCollateral V    
 --WHERE ISNULL(DistributionValue,'')=''  
    
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Distribution Value’. Kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Distribution Value’. Kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Distribution Value' ELSE   ErrorinColumn +','+SPACE(1)+'Distribution Value' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE (ISNUMERIC(DistributionValue)=0 AND ISNULL(DistributionValue,'')<>'') OR   
 ISNUMERIC(DistributionValue) LIKE '%^[0-9]%'  
  
  
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Distribution Value is mandatory and can not be blank. Kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Distribution Value is mandatory and can not be blank. Kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Distribution Value' ELSE   ErrorinColumn +','+SPACE(1)+'Distribution Value' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE  ISNULL(DistributionLevel,'')  In( 'Percentage', 'Absolute') AND ISNULL(DistributionValue,'')=''  
  
  
  
 --------------------------------precentage,absolute condition changes 16082021 sudesh-------  
  
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid Distribution Level.Percentage cannot be greater than 100.00, Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid Distribution Level.Percentage cannot be greater than 100.00, Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Distribution Level' ELSE   ErrorinColumn +','+SPACE(1)+'Distribution Value' END         
  ,Srnooferroneousrows=V.SrNo  
   
  FROM UploadCollateral V   
  WHERE (ISNULL(DistributionValue,'')<>'' AND  ISNULL(DistributionLevel,'') not In ('Percentage','Absolute'))  
 AND (Len(ISNULL(DistributionValue,'')) Not in(6,5) OR CHARINDEX('.',ISNULL(DistributionValue,''))=0  OR Convert(Decimal(5,2),ISNULL('20.12','0'))>100    
  OR (CHARINDEX('.',ISNULL(DistributionValue,''))>0  AND Len(Right(ISNULL(DistributionValue,''),Len(ISNULL(DistributionValue,''))-CHARINDEX('.',ISNULL(DistributionValue,''))))<>2)  
   OR (CHARINDEX('.',ISNULL(DistributionValue,''))>0  AND  Len(Left(ISNULL(DistributionValue,''),(CHARINDEX('.',ISNULL(DistributionValue,''))-1))) NOT IN(3)) )  
  
 -------------Collateral Type---------------------------------  
 Declare @CollateralTypeCnt int=0,@PoolType int=0  
 IF OBJECT_ID('CollateralTypeData') IS NOT NULL    
   BEGIN    
    DROP TABLE CollateralTypeData    
   
   END  
  
     
 SELECT * into CollateralTypeData  FROM(  
 SELECT ROW_NUMBER() OVER(PARTITION BY CollateralType  ORDER BY  CollateralType )   
 ROW ,CollateralType FROM UploadCollateral  
 )X  
 WHERE ROW=1  
  
   
  
  SELECT  @CollateralTypeCnt=COUNT(*) FROM CollateralTypeData A  
 Left JOIN DimCollateralType B  
 ON  A.CollateralType=B.CollateralTypeDescription  
 Where B.CollateralTypeDescription IS NULL  
  
UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Type cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Collateral Type cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Type' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(CollateralType,'')=''  
  
  
   IF @CollateralTypeCnt>0  
  
BEGIN  
   
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Collateral Type’. Kindly enter the values as mentioned in the ‘Collateral Type’ master and upload again. Click on ‘Download Master value’ to download the valid value
  
   
   
  
s  
  
  
  
  
  
  
  
  
 for the column'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Collateral Type’. Kindly enter the values as mentioned in the ‘Collateral Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
  
  
  
  
  
  
  
  
  
  
  
  
  
   
      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Type' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A  
 --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE ISNULL(CollateralType,'')<>''  
 AND  V.CollateralType IN(  
    SELECT   A.CollateralType FROM CollateralTypeData A  
      Left JOIN DimCollateralType B  
      ON  A.CollateralType=B.CollateralTypeDescription  
      Where B.CollateralTypeDescription IS NULL  
     )  
 END   
 /*  
 UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolID' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A  
 --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE ISNULL(PoolID,'')<>''  
 AND PoolID IN(SELECT PoolID FROM #PoolID GROUP BY PoolID)  
 */  
  
   
-------------Collateral Sub Type---------------------------------  
 Declare @CollateralSubTypeCnt int=0  
 IF OBJECT_ID('CollateralSubTypeData') IS NOT NULL    
   BEGIN    
    DROP TABLE CollateralSubTypeData    
   
   END  
  
     
 SELECT * into CollateralSubTypeData  FROM(  
 SELECT ROW_NUMBER() OVER(PARTITION BY A.CollateralSubType  ORDER BY  A.CollateralSubType )   
 ROW ,A.CollateralSubType,B.CollateralTypeAltKey FROM UploadCollateral A  
LEFT JOIN DimCollateralSubType B  
 ON  A.CollateralSubType=B.CollateralSubTypeDescription  
 )X  
 WHERE ROW=1  
  
   
  
  SELECT  @CollateralSubTypeCnt=COUNT(*) FROM CollateralSubTypeData A  
 LEFT JOIN DimCollateralSubType B  
 ON  A.CollateralSubType=B.CollateralSubTypeDescription  
 Where B.CollateralSubTypeDescription IS NULL  
  
   
  
UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Sub Type cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Collateral Sub Type cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Type' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(CollateralSubType,'')=''  
  
  
IF @CollateralSubTypeCnt>0  
  
BEGIN  
   
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Collateral Sub Type’. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master and upload again. Click on ‘Download Master value’ to download the vali
  
  
  
  
  
  
d values for the column'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Collateral Sub Type’. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'  
  
  
  
  
  
  
END     
      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Typ' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Typ' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A  
 --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE ISNULL(CollateralSubType,'')<>''  
 AND  V.CollateralSubType IN(  
    SELECT  A.CollateralSubType FROM CollateralSubTypeData A  
       LEFT JOIN DimCollateralSubType B  
       ON  A.CollateralSubType=B.CollateralSubTypeDescription  
       Where B.CollateralSubTypeDescription IS NULL  
     )  
 END   
  
  
 BEGIN  
   
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid ‘Collateral Sub Type’ & ‘Collateral Type’ combination. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master & it’s ‘Collateral Type’ and upload again. Click on ‘Do
  
  
  
  
  
  
wnload Master value’ to download the valid values for the column'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid ‘Collateral Sub Type’ & ‘Collateral Type’ combination. Kindly enter the values as mentioned in the ‘Collateral Sub Type’ master & it’s ‘Collateral Type’ and upload again. Click on ‘Download Master value’ to do
  
  
  
  
  
  
wnload the valid values for the column'  END     
      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Sub Typ' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Sub Typ' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A   --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE ISNULL(CollateralSubType,'')<>''  
 AND  V.CollateralSubType IN(  
    SELECT  A.CollateralSubType FROM CollateralSubTypeData A  
     LEFT JOIN DimCollateralType B  
     ON  A.CollateralTypeAltKey=B.CollateralTypeAltKey  
     Where B.CollateralTypeAltKey IS NULL  
   
     )  
 END   
  
 ----------------------------------------  
 ------------Collateral Owner Typee---------------------------------  
 Declare @CollateralOwnerType int=0  
 IF OBJECT_ID('CollateralOwnerTypeData') IS NOT NULL    
   BEGIN    
    DROP TABLE CollateralOwnerTypeData    
   
   END  
  
     
 SELECT * into CollateralOwnerTypeData  FROM(  
 SELECT ROW_NUMBER() OVER(PARTITION BY CollateralOwnerType  ORDER BY  CollateralOwnerType )   
 ROW ,CollateralOwnerType FROM UploadCollateral  
 )X  
 WHERE ROW=1  
  
   
  
  SELECT  @CollateralOwnerType=COUNT(*) FROM CollateralOwnerTypeData A  
 LEFT JOIN DimCollateralOwnerType B  
 ON  A.CollateralOwnerType=B.CollOwnerDescription  
 Where B.CollOwnerDescription IS NULL  
  
   
  
UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Owner Type cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Collateral Owner Type cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Owner Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Owner Type' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(CollateralOwnerType,'')=''  
  
  
   IF @CollateralSubTypeCnt>0  
  
BEGIN  
   
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN '“Invalid value in column ‘Collateral Owner Type’. Kindly enter the values as mentioned in the ‘Collateral Owner Type’ master and upload again. Click on ‘Download Master value’ to download the
  
  
  
  
  
  
valid values for the column'       
      ELSE ErrorMessage+','+SPACE(1)+'“Invalid value in column ‘Collateral Owner Type’. Kindly enter the values as mentioned in the ‘Collateral Owner Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the colu
  
  
  
  
  
  
mn'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Owner Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Owner Type' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A  
 --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE ISNULL(CollateralType,'')<>''  
 AND  V.CollateralOwnerType IN(  
     SELECT  A.CollateralOwnerType FROM CollateralOwnerTypeData A  
      LEFT JOIN DimCollateralOwnerType B  
      ON  A.CollateralOwnerType=B.CollOwnerDescription  
      Where B.CollOwnerDescription IS NULL  
     )  
 END   
  
 ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
 --------------------Share available to Bank----------------------------------  
  
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Share available to Bank cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Share available to Bank cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Share available to Bank' ELSE   ErrorinColumn +','+SPACE(1)+'Share available to Bank' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(ShareAvailableToBank,'')=''  
  
  
    
  
  
   
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN '“Invalid value in column ‘Share available to Bank’. Kindly enter ‘Percentage or Absolute’ and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Share available to Bank’. Kindly enter ‘Percentage or Absolute’ and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Share available to Bank' ELSE   ErrorinColumn +','+SPACE(1)+'Share available to Bank' END         
  ,Srnooferroneousrows=V.SrNo  
  
     
   FROM UploadCollateral V    
 WHERE ISNULL(ShareAvailableToBank,'')<>''  
 AND ISNULL(ShareAvailableToBank,'')  Not In( 'Percentage', 'Absolute')  
----------------------------------------------------------------------------------------  
 --/*  New Changes in Pool Name  */  
 --IF OBJECT_ID('TEMPDB..#PoolName') IS NOT NULL  
 --DROP TABLE #PoolName  
  
 --SELECT * INTO #PoolName FROM(  
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,PoolType ORDER BY  PoolID,PoolType ) ROW FROM UploadCollateral  
 --)X  
 --WHERE ROW>1  
  
 --UPDATE UploadCollateral  
 --SET    
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'       
 --     ELSE ErrorMessage+','+SPACE(1)+ 'PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END  
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'PoolName' ELSE   ErrorinColumn +','+SPACE(1)+'PoolName' END       
 -- ,Srnooferroneousrows=V.SrNo  
 ---- STUFF((SELECT ','+SRNO   
 ----       FROM #UploadNewAccount A  
 ----       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 ----WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ------AND SRNO IN(SELECT Srno FROM #DUB2))  
 ----AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 ----       FOR XML PATH ('')  
 ----       ),1,1,'')     
  
 --FROM UploadCollateral V    
 --WHERE ISNULL(PoolID,'')<>''  
 --AND PoolID IN(SELECT PoolID FROM #PoolName GROUP BY PoolID)  
  
   
 --Check  
------------Collateral Ownership Type---------------------------------  
   
   
   
  
UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Ownership Type cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Collateral Ownership Type cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Ownership Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Ownership Type' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(CollateralOwnershipType,'')=''  
  
  
    
  
  
   
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Collateral Ownership Type’. Kindly enter ‘Joint or Sole and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Collateral Ownership Type’. Kindly enter ‘Joint or Sole’ and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Ownership Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Ownership Type' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A  
 --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE  (CollateralOwnershipType) NOT IN('Joint', 'Sole')  
  
  
 ------------------------------------------------  
 ------------Charge Typee---------------------------------  
 Declare @ChargeTypeCnt int=0  
 IF OBJECT_ID('ChargeTypeData') IS NOT NULL    
   BEGIN    
    DROP TABLE ChargeTypeData    
   
   END  
  
     
 SELECT * into ChargeTypeData  FROM(  
 SELECT ROW_NUMBER() OVER(PARTITION BY ChargeType  ORDER BY  CollateralOwnerType )   
 ROW ,ChargeType FROM UploadCollateral  
 )X  
 WHERE ROW=1  
  
   
  
  SELECT  @ChargeTypeCnt=COUNT(*) FROM ChargeTypeData A  
 LEFT JOIN DimCollateralChargeType B  
 ON  A.ChargeType=B.CollChargeDescription  
 Where B.CollChargeDescription IS NULL  
  
   
  
UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Charge Type cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Charge Type cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Charge Type' ELSE   ErrorinColumn +','+SPACE(1)+'Charge Type' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(ChargeType,'')=''  
  
  
   IF @ChargeTypeCnt>0  
  
BEGIN  
   
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Charge Type’. Kindly enter the values as mentioned in the ‘Charge Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for th 
  
  
  
  
  
  
  
  
   
   
   
  
e  
 column'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Charge Type’. Kindly enter the values as mentioned in the ‘Charge Type’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Charge Type' ELSE   ErrorinColumn +','+SPACE(1)+'Charge Type' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A  
 --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE ISNULL(ChargeType,'')<>''  
 AND  V.ChargeType IN(  
      SELECT  A.ChargeType FROM ChargeTypeData A  
      LEFT JOIN DimCollateralChargeType B  
      ON  A.ChargeType=B.CollChargeDescription  
      Where B.CollChargeDescription IS NULL  
     )  
 END   
  
  
---------------------25042021 Added by Poonam/Anuj--------------------------  
------------Charge Nature---------------------------  
 Declare @ChargeNatureCnt int=0  
 IF OBJECT_ID('ChargeNatureData') IS NOT NULL    
   BEGIN    
    DROP TABLE ChargeNatureData    
   
   END  
  
     
 SELECT * into ChargeNatureData  FROM(  
 SELECT ROW_NUMBER() OVER(PARTITION BY ChargeNature  ORDER BY  ChargeNature )   
 ROW ,ChargeNature FROM UploadCollateral  
 )X  
 WHERE ROW=1  
  
   
  
  SELECT  @ChargeTypeCnt=COUNT(*) FROM ChargeNatureData A  
 LEFT JOIN DimSecurityChargeType B  
 ON  A.ChargeNature=B.SecurityChargeTypeName  
 Where B.SecurityChargeTypeName IS NULL  
  
   
  
UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Charge Nature cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Charge Nature cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Charge Nature' ELSE   ErrorinColumn +','+SPACE(1)+'Charge Nature' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(ChargeNature,'')=''  
  
  
   IF @ChargeNatureCnt>0  
  
BEGIN  
   
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Charge Nature’. Kindly enter the values as mentioned in the ‘Charge Nature’ master and upload again. Click on ‘Download Master value’ to download the valid values for
  
  
  
  
  
  
 the column'       
      ELSE ErrorMessage+','+SPACE(1)+ 'Invalid value in column ‘Charge Nature’. Kindly enter the values as mentioned in the ‘Charge Nature’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'     END  
      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Charge Nature' ELSE   ErrorinColumn +','+SPACE(1)+'Charge Nature' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A  
 --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE ISNULL(ChargeNature,'')<>''  
 AND  V.ChargeNature IN(  
     SELECT  A.ChargeNature FROM ChargeNatureData A  
      LEFT JOIN DimSecurityChargeType B  
      ON  A.ChargeNature=B.SecurityChargeTypeName  
      Where B.SecurityChargeTypeName IS NULL  
     )  
 END   
         
---------------------------------------------------------------------------  
  
  
  
  
 /*    
   UPDATE   
  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Duplicate records found.AccountID are repeated.  Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+ 'Duplicate records found. AccountID are repeated.  Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'AccountID' ELSE   ErrorinColumn +','+SPACE(1)+'AccountID' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A  
 --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE ISNULL(AccountID,'')<>''  
 AND AccountID IN(SELECT AccountID FROM #DUB2 GROUP BY AccountID)  
 */  
  
 ----------------------------------------------  
  
   
/*VALIDATIONS ON CustomerID */  
  
   
   
  
-- ----SELECT * FROM UploadCollateral  
    
   
 ----------------------------------------------  
  
  
---- ----SELECT * FROM UploadCollateral  
     
  
  
/*validations on PrincipalOutstandinginRs */  
  
  
  
  
 -----------------------------------------------------------------  
   
  
 -----------------------------------------------------------------  
  
   
  
   
--UPDATE UploadCollateral  
-- SET    
--        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'DateofIBPCreckoning Can not be Greater than Other Maturity and not less to DateofIBPCreckoning. Please enter the Correct Date'       
--      ELSE ErrorMessage+','+SPACE(1)+ 'DateofIBPCreckoning Can not be Greater than Other Maturity and not less to DateofIBPCreckoning. Please enter the Correct Date'      END  
--  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCreckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCreckoning' END        
--  ,Srnooferroneousrows=V.SrNo  
--  --STUFF((SELECT ','+SRNO   
--  --      FROM #UploadNewAccount A  
--  --      WHERE A.SrNo IN(SELECT V.SrNo  FROM #UploadNewAccount V    
--  --            WHERE ISNULL(NPADate,'')<>'' AND (CAST(ISNULL(NPADate ,'')AS Varchar(10))<>FORMAT(cast(NPADate as date),'dd-MM-yyyy'))  
  
--  --          )  
--  --      FOR XML PATH ('')  
--  --      ),1,1,'')     
  
-- FROM UploadCollateral V    
-- WHERE ISNULL(DateofIBPCmarking,'')<>'' AND (Cast(DateofIBPCmarking as date)<Cast(DateofIBPCreckoning as Date) OR Cast(DateofIBPCmarking as Date)>Cast(MaturityDate as Date))  
  
  
  
 --------------------------------------  
  
   
   
 /*  
 UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'PoolID found different Dates of DateofIBPCreckoning. Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+ 'PoolID found different Dates of DateofIBPCreckoning. Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'DateofIBPCreckoning' ELSE   ErrorinColumn +','+SPACE(1)+'DateofIBPCreckoning' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A  
 --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE ISNULL(PoolID,'')<>''  
 AND PoolID IN(SELECT PoolID FROM #Date1 GROUP BY PoolID)  
 */  
 ---------------------------------  
   
 /*  Validations on MisMatch DateofIBPCmarking  */ ---- Pranay 20-03-21  
 --IF OBJECT_ID('TEMPDB..#Date2') IS NOT NULL  
 --DROP TABLE #Date2  
  
 --SELECT * INTO #Date2 FROM(  
 --SELECT *,ROW_NUMBER() OVER(PARTITION BY PoolID,DateofIBPCmarking ORDER BY  PoolID,DateofIBPCmarking ) ROW FROM UploadCollateral  
 --)X  
 --WHERE ROW>1  
  
 -------------------DateofIBPCmarking--------------------------Pranay 20-03-21  
  
   
   
 ---------------------------------  
  
 /*-------------------Share Value-Validation------------------------- */ -- changes done on 19-03-21 Pranay   
  /*validations on Share Valuel*/  
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Share Value cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Share Valu cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Share Value' ELSE   ErrorinColumn +','+SPACE(1)+'Share Value' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(Sharevalue,'')=''  
  
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Share Value’. Kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Share Value’. Kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Share Value' ELSE   ErrorinColumn +','+SPACE(1)+'Share Value' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
  WHERE (ISNUMERIC(Sharevalue)=0 AND ISNULL(Sharevalue,'')<>'') OR   
 ISNUMERIC(Sharevalue) LIKE '%^[0-9]%'  
  
  
    
  
  
   
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Share Value’. Percentage cannot be greater than 100.00. Kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Share Value’. Percentage cannot be greater than 100.00. Kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Share Value' ELSE   ErrorinColumn +','+SPACE(1)+'Share Value' END         
  ,Srnooferroneousrows=V.SrNo  
  
     
   FROM UploadCollateral V    
 WHERE ISNULL(ShareValue,'')<>''   
  AND ISNULL(ShareAvailableToBank,'')  In( 'Percentage')  
  AND Convert(Decimal(5,2),ISNULL(ShareValue,'0'))>100  
 --AND (Len(ISNULL(ShareValue,'')) Not in(6,5) OR CHARINDEX('.',ISNULL(ShareValue,''))=0  OR Convert(Decimal(5,2),ISNULL(ShareValue,'0'))>100    
 -- OR (CHARINDEX('.',ISNULL(ShareValue,''))>0  AND Len(Right(ISNULL(ShareValue,''),Len(ISNULL(ShareValue,''))-CHARINDEX('.',ISNULL(ShareValue,''))))<>2)  
 --  OR (CHARINDEX('.',ISNULL(ShareValue,''))>0  AND  Len(Left(ISNULL(DistributionValue,''),(CHARINDEX('.',ISNULL(DistributionValue,''))-1))) NOT IN(3)) )  
    
 -------------------------------------------------------------------------------------------------------------  
  /*-------------------Collateral Value at Sanction in Rs.-Validation------------------------- */ -- changes done on 19-03-21 Pranay   
  /*validations on Collateral Value at Sanction in Rsl*/  
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Value at Sanction in Rs. cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Collateral Value at Sanction in Rs.e cannot be blank . Please check the values and upload again'   END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Value at Sanction in Rs.' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Value at Sanction in Rs.' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
   WHERE ISNULL(CollateralValueatSanctioninRs,'')=''  
  
  
  
    
  --(case  
  --when CollateralValueatSanctioninRs like '%[^0-9]%' then 'Y'  
  --else 'N' END)='Y  
  
   
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Collateral Value as on NPA Date in Rs.’. Kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Collateral Value as on NPA Date in Rs.’. Kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Value as on NPA Date in Rs.l' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Value as on NPA Date in Rs.' END         
  ,Srnooferroneousrows=V.SrNo  
  
     
   FROM UploadCollateral V    
  WHERE (ISNUMERIC(CollateralValueatSanctioninRs)=0 AND ISNULL(CollateralValueatSanctioninRs,'')<>'') OR   
 ISNUMERIC(CollateralValueatSanctioninRs) LIKE '%^[0-9]%'  
   
-----------------------------------------------------------------------------------  
 -------------------------------------------------------------------------------------------------------------  
  /*-------------------CCollateral Value as on NPA Date in Rs..-Validation------------------------- */ -- changes done on 19-03-21 Pranay   
  /*validations on Collateral Value as on NPA Date in Rs.l*/  
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Value as on NPA Date in Rs. cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Collateral Value as on NPA Date in Rs. cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Value as on NPA Date in Rs.' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Value as on NPA Date in Rs.' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
   WHERE ISNULL(CollateralValueasonNPADateinRs,'')=''  
  
  
  
    
  
  
   
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Collateral Value as on NPA Date in Rs.’. Kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid Collateral Value as on NPA Date in Rs..  Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Value as on NPA Date in Rs.' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Value as on NPA Date in Rs.' END         
  ,Srnooferroneousrows=V.SrNo  
  
     
   FROM UploadCollateral V    
  WHERE (ISNUMERIC(CollateralValueasonNPADateinRs)=0 AND ISNULL(CollateralValueasonNPADateinRs,'')<>'') OR   
 ISNUMERIC(CollateralValueasonNPADateinRs) LIKE '%^[0-9]%'  
  
 --------------------------------------------------------------------------------------------------------------------  
  
 /*-------------------Collateral Value at Last Review in Rs...-Validation------------------------- */ -- changes done on 19-03-21 Pranay   
  /*validations on Collateral Value at Last Review in Rs.l*/  
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Collateral Value at Last Review in Rs.. cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Collateral Value at Last Review in Rs. cannot be blank . Please check the values and upload again'  END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Value at Last Review in Rs..' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Value at Last Review in Rs..' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
   WHERE ISNULL(CollateralValueatLastReviewinRs,'')=''  
  
  
  
    
  
  
   
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Collateral Value at Last Review in Rs.’. Kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Collateral Value at Last Review in Rs.’. Kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Value at Last Review in Rs.' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Value at Last Review in Rs.' END         
  ,Srnooferroneousrows=V.SrNo  
  
     
   FROM UploadCollateral V    
  WHERE (ISNUMERIC(CollateralValueatLastReviewinRs)=0 AND ISNULL(CollateralValueatLastReviewinRs,'')<>'') OR   
 ISNUMERIC(CollateralValueatLastReviewinRs) LIKE '%^[0-9]%'  
  
 ------------------------------------------------------------------------------------------------------  
 ---Check  
 /*-------------------Valuation Date...-Validation------------------------- */ -- changes done on 19-03-21 Pranay   
  /*validations on Valuation Date.l*/  
    
 -- UPDATE UploadCollateral  
 --SET    
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation Date. cannot be blank . Please check the values and upload again'       
 --     ELSE ErrorMessage+','+SPACE(1)+'Valuation Date cannot be blank . Please check the values and upload again'     END  
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END     
 -- ,Srnooferroneousrows=V.SrNo  
          
     
 --  FROM UploadCollateral V    
 --  WHERE ISNULL(ValuationDate,'')=''  
  
  
  
    
  
  
   
 -- UPDATE UploadCollateral  
 --SET    
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Valuation Date’. Kindly check and upload again'       
 --     ELSE ErrorMessage+','+SPACE(1)+'Invalid Valuation Date Please check the values and upload again'     END  
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END         
 -- ,Srnooferroneousrows=V.SrNo  
  
     
 --  FROM UploadCollateral V    
 --WHERE ISNUMERIC(ValuationDate)<>1  
-------------------------------------------------------------------  
 /*-------------------Valuation Date...-Validation------------------------- */ -- changes done on 19-03-21 Pranay   
  /*validations on Valuation Date.l*/  
    
 -- UPDATE UploadCollateral  
 --SET    
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation Date. cannot be blank . Please check the values and upload again'       
 --     ELSE ErrorMessage+','+SPACE(1)+'Valuation Date cannot be blank . Please check the values and upload again'     END  
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END     
 -- ,Srnooferroneousrows=V.SrNo  
          
     
 --  FROM UploadCollateral V    
 --  WHERE ISNULL(ValuationDate,'')=''  
  
  
  
   
  
  
   
 -- UPDATE UploadCollateral  
 --SET    
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation date must be less than equal to Process Date viz. ########. Kindly check and upload again'       
 --     ELSE ErrorMessage+','+SPACE(1)+'Invalid Valuation Date  Please check the values and upload again'     END  
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END         
 -- ,Srnooferroneousrows=V.SrNo  
  
     
 --  FROM UploadCollateral V    
 --WHERE ISDATE(ValuationDate)<>1  
  
 -------------------------------------------------------------  
  
 /*-------------------Current Collateral Value in Rs...-Validation------------------------- */ -- changes done on 19-03-21 Pranay   
  /*validations on Current Collateral Value in Rs.l*/  
    
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Current Collateral Value in Rs. cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Current Collateral Value in Rs. cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Current Collateral Value in Rs..' ELSE   ErrorinColumn +','+SPACE(1)+'PoolID' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
   WHERE ISNULL(CurrentCollateralValueinRs,'')=''  
  
  
  
    
  
  
   
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid values in ‘Current Collateral Value in Rs.’. Kindly check and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid values in ‘Current Collateral Value in Rs.’. Kindly check and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Current Collateral Value in Rs..' ELSE   ErrorinColumn +','+SPACE(1)+'Current Collateral Value in Rs.' END         
  ,Srnooferroneousrows=V.SrNo  
  
     
   FROM UploadCollateral V    
  WHERE (ISNUMERIC(CurrentCollateralValueinRs)=0 AND ISNULL(CurrentCollateralValueinRs,'')<>'') OR   
 ISNUMERIC(CurrentCollateralValueinRs) LIKE '%^[0-9]%'  
  
 -----------------------------------------------------------------------------------  
  
   
 -------------------------------------------------------------  
  
 /*-------------------Validation Date------------------------- */ -- changes done on 19-03-21 Pranay   
  /*validations on -Validation Datel*/  
  Declare @Validation as date  
  --SET @Validation='2100-12-31'  
  Select @Validation= B.date from SysDataMatrix A INNER JOIN SysDayMatrix B  
                            ON A.TimeKey=B.TimeKey   where CurrentStatus='C'  
  
  UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation Date cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Valuation Date cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'Valuation Date' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
   WHERE ISNULL(ValuationDate,'')=''  
   SET DateFormat DMY  
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation Date is not Valid Date . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Valuation Date is not Valid Date . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation Date' ELSE   ErrorinColumn +','+SPACE(1)+'Valuation Date' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
   WHERE ISDATE(ValuationDate)=0 AND ISNULL(ValuationDate,'')=''  
  
  
  
    
  
  
   
 -- UPDATE UploadCollateral  
 --SET    
 --select  
 --       ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Valuation date must be less than equal to Process Date viz. ########. Kindly check and upload again'       
 --     ELSE ErrorMessage+','+SPACE(1)+'Valuation date must be less than equal to Process Date viz. ########. Kindly check and upload again'     END  
 -- ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Valuation date.' ELSE   ErrorinColumn +','+SPACE(1)+'Valuation date' END         
 -- ,Srnooferroneousrows=V.SrNo  
  
     
 --  FROM UploadCollateral V    
 --WHERE ISDATE(ValuationDate)=1  --AND Convert(date,ValuationDate)>Convert(date,@Validation)  
  
  -----------------------------------------  
  
  ------------Expiry Business Rule---------------------------  
Declare @ExpiryBusinessRuleCnt int=0  
  Declare @ColletralTypeCnt int=0  
 IF OBJECT_ID('ExpiryBusinessRuleData') IS NOT NULL    
   BEGIN    
    DROP TABLE ExpiryBusinessRuleData   
   
   END  
  
  
   IF OBJECT_ID('ExpiryBusinessRuleData1') IS NOT NULL    
   BEGIN    
    DROP TABLE ExpiryBusinessRuleData1   
   
   END  
     
 SELECT * into ExpiryBusinessRuleData  FROM(  
 SELECT ROW_NUMBER() OVER(PARTITION BY ExpiryBusinessRule  ORDER BY  ExpiryBusinessRule )   
 ROW ,A.ExpiryBusinessRule,A.CollateralType,C.SecurityTypeAlt_Key FROM UploadCollateral A  
 LEFT JOIN  DimValueExpiration C ON  A.ExpiryBusinessRule=C.Documents  
)X  
 WHERE ROW=1  
  
 SELECT * into ExpiryBusinessRuleData1  FROM(  
 Select A.* from ExpiryBusinessRuleData A  
 Left Join  DimCollateralType B ON B.CollateralTypeAltKey=A.SecurityTypeAlt_Key  
  Where B.CollateralTypeAltKey IS NULL  
 ) X  
  
  SELECT  @ExpiryBusinessRuleCnt=COUNT(*) FROM ExpiryBusinessRuleData A  
 LEFT JOIN DimValueExpiration B  
ON  A.ExpiryBusinessRule=B.Documents--Check  
 Where B.Documents IS NULL  
  
   
  
UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Expiry Business Rule cannot be blank . Please check the values and upload again'       
      ELSE ErrorMessage+','+SPACE(1)+'Expiry Business Rule cannot be blank . Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Expiry Business Rule' ELSE   ErrorinColumn +','+SPACE(1)+'Expiry Business Rulee' END     
  ,Srnooferroneousrows=V.SrNo  
          
     
   FROM UploadCollateral V    
 WHERE ISNULL(ExpiryBusinessRule,'')=''  
  
  
   IF @ExpiryBusinessRuleCnt>0  
  
BEGIN  
   
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid value in column ‘Expiry Business Rule’. Kindly enter the values as mentioned in the ‘Expiry Business Rule’ master and upload again. Click on ‘Download Master value’ to download the v 
  
  
   
  
   
   
alid values for the column'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid value in column ‘Expiry Business Rule’. Kindly enter the values as mentioned in the ‘Expiry Business Rule’ master and upload again. Click on ‘Download Master value’ to download the valid values for the column'
  
  
  
  
  
  
 END     
      --ELSE ErrorMessage+','+SPACE(1)+ 'Different PoolID of same combination of PoolName and PoolType is Available. Please check the values and upload again'     END  
  ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Expiry Business Rule' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Owner Type' END       
  ,Srnooferroneousrows=V.SrNo  
 -- STUFF((SELECT ','+SRNO   
 --       FROM #UploadNewAccount A  
 --       WHERE A.SrNo IN(SELECT V.SrNo FROM #UploadNewAccount V    
 --WHERE ISNULL(ACID,'')<>'' AND ISNULL(TERRITORY,'')<>''  
 ----AND SRNO IN(SELECT Srno FROM #DUB2))  
 --AND ACID IN(SELECT ACID FROM #DUB2 GROUP BY ACID))  
  
 --       FOR XML PATH ('')  
 --       ),1,1,'')     
  
 FROM UploadCollateral V    
 WHERE ISNULL(ExpiryBusinessRule,'')<>''  
 AND  V.ExpiryBusinessRule IN(  
    SELECT  A.ExpiryBusinessRule FROM ExpiryBusinessRuleData A  
       LEFT JOIN DimValueExpiration B  
      ON  A.ExpiryBusinessRule=B.Documents--Check  
       Where B.Documents IS NULL  
     )  
 END   
  
SELECT  @ColletralTypeCnt=COUNT(*) FROM ExpiryBusinessRuleData A  
 Left JOIN DimCollateralType B  
 ON  A.CollateralType=B.CollateralTypeDescription  
 Where B.CollateralTypeDescription IS NULL  
  
  
  
 IF @CollateralTypeCnt>0  
  
BEGIN  
   
   UPDATE UploadCollateral  
 SET    
        ErrorMessage=CASE WHEN ISNULL(ErrorMessage,'')='' THEN 'Invalid ‘Expiry Business Rule & ‘Collateral Type’ combination.   
  Kindly enter the values as mentioned in the ‘Expiry Business Rule’ master & it’s ‘Collateral Type’ and upload again. Click on ‘D  
  
  
  
  
  
ownload Master value’ to download the valid values for the column'       
      ELSE ErrorMessage+','+SPACE(1)+'Invalid ‘Expiry Business Rule & ‘Collateral Type’ combination. Kindly enter the values as mentioned in the ‘Expiry Business Rule’ master & it’s ‘Collateral Type’ and upload again. Click on ‘Download Master value’ to d
  
  
  
  
  
  
ownload the valid values for the column'     END    
                      ,ErrorinColumn=CASE WHEN ISNULL(ErrorinColumn,'')='' THEN 'Collateral Type' ELSE   ErrorinColumn +','+SPACE(1)+'Collateral Type' END       
         ,Srnooferroneousrows=V.SrNo  
    
  
 FROM UploadCollateral V    
 WHERE ISNULL(ExpiryBusinessRule,'')<>''  
 AND  V.CollateralType IN(  
    SELECT  A.CollateralType FROM ExpiryBusinessRuleData1 A  
       
     )  
 END   
  
 ---------------------------------------------------  
 Print '123'  
 goto valid  
  
  END  
   
   ErrorData:    
   print 'no'    
  
  SELECT *,'Data'TableName  
  FROM dbo.MasterUploadData WHERE FileNames=@filepath   
  return  
  
   valid:  
  IF NOT EXISTS(Select 1 from  CollateralDetails_stg WHERE filname=@FilePathUpload)  
  BEGIN  
  PRINT 'NO ERRORS'  
     
   Insert into dbo.MasterUploadData  
   (SR_No,ColumnName,ErrorData,ErrorType,FileNames,Flag)   
   SELECT '' SRNO , '' ColumnName,'' ErrorData,'' ErrorType,@filepath,'SUCCESS'   
     
  END  
  ELSE  
  BEGIN  
   PRINT 'VALIDATION ERRORS'  
   PRINT '@filepath'  
   PRINT @filepath  
   Insert into dbo.MasterUploadData  
   (SR_No,ColumnName,ErrorData,ErrorType,FileNames,Srnooferroneousrows,Flag)   
   SELECT SrNo,ErrorinColumn,ErrorMessage,ErrorinColumn,@filepath,Srnooferroneousrows,'SUCCESS'   
   FROM UploadCollateral   
  
   print 'Row Effected'  
  
   print @@ROWCOUNT  
     
  -- ----SELECT * FROM UploadCollateral   
  
  -- --ORDER BY ErrorMessage,UploadCollateral.ErrorinColumn DESC  
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
  
   IF EXISTS(SELECT 1 FROM CollateralDetails_stg WHERE filname=@FilePathUpload)  
   BEGIN  
   Print '1'  
   DELETE FROM CollateralDetails_stg  
   WHERE filname=@FilePathUpload  
  
   PRINT '2';  
  
   PRINT 'ROWS DELETED FROM DBO.CollateralDetails_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))  
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
  
 ----SELECT * FROM UploadCollateral  
  
 print 'p'  
  ------to delete file if it has errors  
  --if exists(Select  1 from dbo.MasterUploadData where FileNames=@filepath and ISNULL(ErrorData,'')<>'')  
  --begin  
  --print 'ppp'  
  -- IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)  
  -- BEGIN  
  -- print '123'  
  -- DELETE FROM IBPCPoolDetail_stg  
  -- WHERE filname=@FilePathUpload  
  
  -- PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))  
  -- END  
  -- END  
  
     
END  TRY   
    
  BEGIN CATCH    
   
  
 INSERT INTO dbo.Error_Log  
    SELECT ERROR_LINE() as ErrorLine,ERROR_MESSAGE()ErrorMessage,ERROR_NUMBER()ErrorNumber  
    ,ERROR_PROCEDURE()ErrorProcedure,ERROR_SEVERITY()ErrorSeverity,ERROR_STATE()ErrorState  
    ,GETDATE()  
  
 --IF EXISTS(SELECT 1 FROM IBPCPoolDetail_stg WHERE filname=@FilePathUpload)  
 --  BEGIN  
 --  DELETE FROM IBPCPoolDetail_stg  
 --  WHERE filname=@FilePathUpload  
  
 --  PRINT 'ROWS DELETED FROM DBO.IBPCPoolDetail_stg'+CAST(@@ROWCOUNT AS VARCHAR(100))  
 --  END  
  
END CATCH   
  
END
GO